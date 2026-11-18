import SwiftUI

struct ConnectPanel: View {
    @Environment(AppModel.self) private var model
    @State private var username = ""
    @State private var sending = false

    private var cleaned: String {
        username.trimmingCharacters(in: .whitespaces).lowercased().replacingOccurrences(of: "@", with: "")
    }

    var body: some View {
        if let state = model.state {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(state.incoming) { request in
                    incoming(request)
                }
                if let waiting = state.outgoing.first {
                    HStack(spacing: 12) {
                        Image(systemName: "paperplane.fill").foregroundStyle(Theme.rose)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Waiting for @\(waiting.username)").font(.rounded(16, .bold))
                            Text("They'll see your request in Miss U.").font(.rounded(13, .medium)).opacity(0.55)
                        }
                        Spacer()
                        Button("Cancel") { Task { await model.cancel(waiting) } }
                            .font(.rounded(14, .bold))
                            .foregroundStyle(Theme.rose)
                    }
                    .card()
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Their username").font(.rounded(15, .bold)).opacity(0.65)
                        HStack(spacing: 10) {
                            HStack(spacing: 2) {
                                Text("@").opacity(0.35)
                                TextField("username", text: $username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .onSubmit(send)
                            }
                            .font(.rounded(18, .bold))
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(Theme.cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            Button(action: send) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 52, height: 52)
                                    .background(Theme.rose.opacity(canSend ? 1 : 0.4), in: Circle())
                            }
                            .disabled(!canSend)
                            .accessibilityLabel("Send request")
                        }
                    }
                    .card()
                }
                ShareLink(item: "Add me on Miss U! My username is @\(state.me.username)") {
                    Label("Share my username, @\(state.me.username)", systemImage: "square.and.arrow.up")
                        .font(.rounded(15, .bold))
                        .foregroundStyle(Theme.rose)
                }
                .padding(.leading, 4)
            }
        }
    }

    private var canSend: Bool { cleaned.count >= 3 && !sending }

    private func send() {
        guard canSend else { return }
        sending = true
        Task {
            if await model.sendRequest(to: cleaned) { username = "" }
            sending = false
        }
    }

    private func incoming(_ request: AppState.ConnectionRequest) -> some View {
        HStack(spacing: 12) {
            AvatarView(config: request.avatar ?? AvatarConfig()).frame(width: 56)
            VStack(alignment: .leading, spacing: 2) {
                Text("@\(request.username)").font(.rounded(16, .bold))
                Text("wants to connect").font(.rounded(13, .medium)).opacity(0.55)
            }
            Spacer()
            Button { Task { await model.respond(to: request, accept: false) } } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .frame(width: 42, height: 42)
                    .background(Theme.cream, in: Circle())
            }
            .accessibilityLabel("Decline")
            Button { Task { await model.respond(to: request, accept: true) } } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Theme.rose, in: Circle())
            }
            .accessibilityLabel("Accept")
        }
        .buttonStyle(.plain)
        .card()
    }
}

struct ActivityGrid: View {
    @Environment(AppModel.self) private var model
    var onPick: () -> Void = {}

    var body: some View {
        let current = model.state?.me.activity()
        VStack(spacing: 14) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(ActivityKind.allCases) { kind in
                    Button { pick(kind) } label: {
                        VStack(spacing: 8) {
                            Image(systemName: kind.symbol)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(Theme.rose)
                                .frame(height: 28)
                            Text(kind.title)
                                .font(.rounded(13, .bold))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                        }
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity, minHeight: 96)
                        .background(current == kind ? Theme.blush : .white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(current == kind ? Theme.rose : Theme.ink.opacity(0.06), lineWidth: current == kind ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            if current != nil {
                Button("Clear activity") { pick(nil) }.buttonStyle(.soft)
            }
        }
        .sensoryFeedback(.selection, trigger: current)
    }

    private func pick(_ kind: ActivityKind?) {
        Task { await model.setActivity(kind) }
        onPick()
    }
}

struct MyWidgetPanel: View {
    @Environment(AppModel.self) private var model
    @State private var style = WidgetStyle()
    @State private var saving = false

    var body: some View {
        if let state = model.state {
            VStack(alignment: .leading, spacing: 18) {
                if state.myWidget.byPartner, let partner = state.partner {
                    HStack(spacing: 12) {
                        HeartShape().fill(Theme.rose).frame(width: 20, height: 18)
                        Text("@\(partner.username) styled your widget").font(.rounded(15, .bold))
                        Spacer()
                        Button("Restore mine") { Task { await model.restoreMyWidget() } }
                            .font(.rounded(14, .bold))
                            .foregroundStyle(Theme.rose)
                    }
                    .card()
                }
                WidgetPreviews(snapshot: WidgetSnapshot(me: state.me, partner: state.partner, style: style, byPartner: false))
                WidgetEditor(style: $style)
                Button {
                    Task {
                        saving = true
                        _ = await model.styleMyWidget(style)
                        saving = false
                    }
                } label: {
                    if saving { ProgressView().tint(.white) } else { Text("Save my widget") }
                }
                .buttonStyle(.primary)
                .disabled(saving || style == state.myWidget.style)
                Button("Reset to default") { Task { await model.resetMyWidget() } }
                    .buttonStyle(.soft)
            }
            .onAppear { style = state.myWidget.style }
            .onChange(of: state.myWidget.style) { _, new in style = new }
        }
    }
}

struct PartnerWidgetPanel: View {
    @Environment(AppModel.self) private var model
    var onSent: () -> Void = {}
    @State private var style = WidgetStyle()
    @State private var sending = false

    var body: some View {
        if let state = model.state, let partner = state.partner {
            let allowed = state.partnerWidget?.allowPartner ?? false
            VStack(alignment: .leading, spacing: 18) {
                Text("This is what @\(partner.username) sees on their home screen.")
                    .font(.rounded(15, .medium))
                    .opacity(0.6)
                WidgetPreviews(snapshot: state.partnerSnapshot(style: style))
                if allowed {
                    WidgetEditor(style: $style)
                    Button {
                        Task {
                            sending = true
                            if await model.stylePartnerWidget(style) {
                                model.toast = "Sent to @\(partner.username)'s widget"
                                onSent()
                            }
                            sending = false
                        }
                    } label: {
                        if sending { ProgressView().tint(.white) } else { Text("Send to @\(partner.username)") }
                    }
                    .buttonStyle(.primary)
                    .disabled(sending || style == state.partnerWidget?.style)
                } else {
                    Label("@\(partner.username) turned off widget changes.", systemImage: "lock.fill")
                        .font(.rounded(15, .semibold))
                        .opacity(0.6)
                }
            }
            .onAppear { style = state.partnerWidget?.style ?? WidgetStyle() }
        } else {
            Text("Connect with your person to style their widget.")
                .font(.rounded(16, .medium))
                .opacity(0.6)
        }
    }
}
