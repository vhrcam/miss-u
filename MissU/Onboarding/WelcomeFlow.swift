import SwiftUI

struct WelcomeFlow: View {
    @Environment(AppModel.self) private var model
    @State private var path: [Step] = []

    enum Step: Hashable {
        case username, email, code
    }

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(
                start: {
                    model.pendingUsername = nil
                    path = [.username]
                },
                signIn: {
                    model.pendingUsername = nil
                    path = [.email]
                }
            )
            .navigationDestination(for: Step.self) { step in
                switch step {
                case .username:
                    UsernameView { name in
                        model.pendingUsername = name
                        path.append(.email)
                    }
                case .email:
                    EmailView { path.append(.code) }
                case .code:
                    CodeView()
                }
            }
        }
        .tint(Theme.rose)
    }
}

struct WelcomeView: View {
    let start: () -> Void
    let signIn: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(alignment: .bottom, spacing: -16) {
                AvatarView(
                    config: AvatarConfig(color: .lavender, presentation: .feminine, hair: .bob, outfit: .sweater, shirt: .butter),
                    activity: .missingYou,
                    animated: true
                )
                .frame(width: 170)
                AvatarView(
                    config: AvatarConfig(color: .peach, presentation: .masculine, hair: .tuft, outfit: .hoodie, shirt: .sky),
                    animated: true
                )
                .frame(width: 150)
            }
            Wordmark(size: 52).padding(.top, 28)
            Text("Make someone feel close,\neven when they're not there.")
                .font(.rounded(18, .medium))
                .multilineTextAlignment(.center)
                .opacity(0.6)
                .padding(.top, 10)
            Spacer()
            Button("Get started", action: start).buttonStyle(.primary)
            Button("I already have an account", action: signIn)
                .font(.rounded(16, .bold))
                .foregroundStyle(Theme.rose)
                .padding(.vertical, 14)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .screen()
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct UsernameView: View {
    @Environment(AppModel.self) private var model
    let onContinue: (String) -> Void
    @State private var name = ""
    @State private var available: Bool?
    @FocusState private var focused: Bool

    private var valid: Bool { name.wholeMatch(of: #/[a-z0-9_.]{3,20}/#) != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ScreenTitle(title: "Pick a username", subtitle: "Your person uses it to find you.")
            HStack(spacing: 4) {
                Text("@").opacity(0.35)
                TextField("username", text: $name)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .onSubmit(next)
                if valid && available == true {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.rose)
                }
            }
            .font(.rounded(24, .bold))
            .padding(.horizontal, 18)
            .frame(height: 62)
            .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Text(hint)
                .font(.rounded(14, .semibold))
                .foregroundStyle(available == false ? Theme.rose : Theme.ink.opacity(0.55))
            Spacer()
            Button("Continue", action: next)
                .buttonStyle(.primary)
                .disabled(!(valid && available == true))
        }
        .padding(24)
        .screen()
        .onAppear { focused = true }
        .onChange(of: name) { _, new in
            let allowed = String(new.lowercased().filter { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "_" || $0 == ".") }.prefix(20))
            if allowed != new { name = allowed }
            available = nil
        }
        .task(id: name) {
            guard valid else { return }
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            available = await model.usernameAvailable(name)
        }
    }

    private var hint: String {
        if name.isEmpty || !valid { return "3–20 letters, numbers, dots or underscores." }
        switch available {
        case .some(true): return "@\(name) is all yours."
        case .some(false): return "That one's taken. Try another."
        case .none: return "Checking…"
        }
    }

    private func next() {
        if valid && available == true { onContinue(name) }
    }
}

struct EmailView: View {
    @Environment(AppModel.self) private var model
    let onSent: () -> Void
    @State private var address = ""
    @State private var sending = false
    @FocusState private var focused: Bool

    private var cleaned: String { address.trimmingCharacters(in: .whitespaces).lowercased() }
    private var valid: Bool { cleaned.wholeMatch(of: #/[^@\s]+@[^@\s]+\.[^@\s]+/#) != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ScreenTitle(
                title: model.pendingUsername == nil ? "Welcome back" : "Save your account",
                subtitle: "We'll email you a 6-digit code. No password needed."
            )
            TextField("you@email.com", text: $address)
                .font(.rounded(20, .semibold))
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focused)
                .onSubmit(send)
                .padding(.horizontal, 18)
                .frame(height: 62)
                .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer()
            Button(action: send) {
                if sending { ProgressView().tint(.white) } else { Text("Send code") }
            }
            .buttonStyle(.primary)
            .disabled(!valid || sending)
        }
        .padding(24)
        .screen()
        .onAppear { focused = true }
    }

    private func send() {
        guard valid, !sending else { return }
        sending = true
        Task {
            if await model.sendCode(to: cleaned) { onSent() }
            sending = false
        }
    }
}

struct CodeView: View {
    @Environment(AppModel.self) private var model
    @State private var code = ""
    @State private var checking = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ScreenTitle(title: "Check your email", subtitle: "Enter the code we sent to \(model.email).")
            ZStack {
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { i in
                        let digits = Array(code)
                        let active = focused && i == digits.count
                        Text(i < digits.count ? String(digits[i]) : "")
                            .font(.rounded(28, .heavy))
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(active ? Theme.rose : Theme.ink.opacity(0.08), lineWidth: active ? 2 : 1)
                            )
                    }
                }
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($focused)
                    .opacity(0.02)
            }
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
            Button("Send a new code") {
                Task {
                    if await model.sendCode(to: model.email) { model.toast = "New code sent" }
                }
            }
            .font(.rounded(15, .bold))
            .foregroundStyle(Theme.rose)
            Spacer()
            if checking {
                ProgressView().tint(Theme.rose).frame(maxWidth: .infinity)
            }
        }
        .padding(24)
        .screen()
        .onAppear { focused = true }
        .onChange(of: code) { _, new in
            let digits = String(new.filter(\.isNumber).prefix(6))
            if digits != new { code = digits }
            if digits.count == 6 { verify() }
        }
    }

    private func verify() {
        guard !checking else { return }
        checking = true
        Task {
            if !(await model.verify(code)) { code = "" }
            checking = false
        }
    }
}
