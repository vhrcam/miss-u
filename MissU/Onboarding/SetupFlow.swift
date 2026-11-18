import SwiftUI

struct SetupFlow: View {
    @Environment(AppModel.self) private var model
    @State private var step = 0
    @State private var avatar = AvatarConfig()
    @State private var saving = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Theme.rose : Theme.ink.opacity(0.12))
                        .frame(height: 5)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Group {
                switch step {
                case 0: avatarStep
                case 1: partnerStep
                default: widgetStep
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)).combined(with: .opacity))
        }
        .screen()
        .onAppear { avatar = model.state?.me.avatar ?? AvatarConfig() }
    }

    private var avatarStep: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenTitle(title: "Make your character", subtitle: "This is you on your person's home screen.")
                    AvatarView(config: avatar, animated: true)
                        .frame(height: 190)
                        .frame(maxWidth: .infinity)
                    AvatarEditor(config: $avatar)
                }
                .padding(24)
            }
            Button("Continue") {
                Task {
                    saving = true
                    await model.saveAvatar(avatar)
                    saving = false
                    withAnimation { step = 1 }
                }
            }
            .buttonStyle(.primary)
            .disabled(saving)
            .padding(24)
        }
    }

    private var partnerStep: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let state = model.state, let partner = state.partner {
                        ScreenTitle(title: "You're connected!", subtitle: "You and @\(partner.username) are a pair now.")
                        HStack(alignment: .bottom, spacing: -14) {
                            AvatarView(config: partner.avatar, activity: .missingYou, animated: true)
                            AvatarView(config: state.me.avatar, animated: true)
                        }
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                    } else {
                        ScreenTitle(title: "Find your person", subtitle: "Send your partner a request with their username.")
                        ConnectPanel()
                    }
                }
                .padding(24)
            }
            Group {
                if model.state?.partner == nil {
                    Button("Skip for now") { withAnimation { step = 2 } }.buttonStyle(.soft)
                } else {
                    Button("Continue") { withAnimation { step = 2 } }.buttonStyle(.primary)
                }
            }
            .padding(24)
        }
    }

    private var widgetStep: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ScreenTitle(title: "Add the widget", subtitle: "Keep your person on your home screen.")
                    WidgetPreview(snapshot: model.state?.snapshot)
                        .frame(maxWidth: .infinity)
                    VStack(alignment: .leading, spacing: 14) {
                        instruction(1, "Touch and hold an empty spot on your Home Screen.")
                        instruction(2, "Tap Edit, then Add Widget.")
                        instruction(3, "Search for Miss U and pick a size.")
                        instruction(4, "Tap Add Widget, then Done.")
                    }
                    .card()
                    Text("Your person can restyle your widget from their phone, and you can always change it back.")
                        .font(.rounded(14, .medium))
                        .opacity(0.55)
                }
                .padding(24)
            }
            Button("Done") { model.setupDone = true }
                .buttonStyle(.primary)
                .padding(24)
        }
    }

    private func instruction(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.rounded(14, .heavy))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Theme.rose, in: Circle())
            Text(text).font(.rounded(16, .medium))
        }
    }
}
