import SwiftUI

struct ReactionOverlay: View {
    @Environment(AppModel.self) private var model
    let partner: Person
    let interaction: Interaction
    @State private var shown = false
    @State private var burst = 0

    var body: some View {
        ZStack {
            Theme.ink.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { close() }
            VStack(spacing: 12) {
                Text(interaction.kind.emoji).font(.system(size: 52))
                AvatarView(config: partner.avatar, activity: interaction.kind == .poke ? nil : .missingYou, animated: true)
                    .frame(width: 170)
                    .heartBurst(burst)
                Text("@\(partner.username) \(interaction.kind.sentence)")
                    .font(.rounded(22, .heavy))
                    .multilineTextAlignment(.center)
                Text(interaction.createdAt.formatted(.relative(presentation: .named)))
                    .font(.rounded(14, .semibold))
                    .opacity(0.5)
                    .padding(.bottom, 6)
                Button("Send one back \(interaction.kind.emoji)") {
                    Task { await model.sendInteraction(interaction.kind) }
                    burst += 1
                    Task {
                        try? await Task.sleep(for: .milliseconds(650))
                        close()
                    }
                }
                .buttonStyle(.primary)
                Button("Close") { close() }
                    .font(.rounded(16, .bold))
                    .foregroundStyle(Theme.rose)
                    .padding(.top, 2)
            }
            .foregroundStyle(Theme.ink)
            .padding(26)
            .background(.white, in: RoundedRectangle(cornerRadius: 36, style: .continuous))
            .padding(28)
            .scaleEffect(shown ? 1 : 0.7)
            .opacity(shown ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.62)) { shown = true }
            burst += 1
        }
        .sensoryFeedback(.success, trigger: shown)
    }

    private func close() {
        Task { await model.dismissReaction() }
    }
}
