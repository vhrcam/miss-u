import SwiftUI

struct ActivitiesView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenTitle(title: "Activities", subtitle: "Show your person what you're up to.")
                    if let me = model.state?.me {
                        current(me)
                    }
                    ActivityGrid()
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $model.headphoneDetection) {
                            Label("Headphones", systemImage: "headphones").font(.rounded(17, .bold))
                        }
                        .tint(Theme.rose)
                        Text(headphoneNote)
                            .font(.rounded(14, .medium))
                            .opacity(0.6)
                    }
                    .card()
                }
                .padding(20)
            }
            .screen()
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func current(_ me: Person) -> some View {
        let live = me.activity.flatMap { $0.isLive() ? $0 : nil }
        return VStack(spacing: 10) {
            AvatarView(config: me.avatar, activity: live?.kind, animated: true)
                .frame(height: 180)
            Text(live?.kind.title ?? "Just you").font(.rounded(20, .heavy))
            if let ends = live?.expiresAt {
                Text("Clears \(ends, style: .relative) from now")
                    .font(.rounded(13, .semibold))
                    .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            LinearGradient(colors: [Theme.blush, .white], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 32, style: .continuous)
        )
    }

    private var headphoneNote: String {
        guard model.headphoneDetection else {
            return "Off. Your character won't change when you plug in headphones."
        }
        return model.headphonesConnected
            ? "Headphones connected, so your character is wearing them. They come off when you unplug."
            : "Your character puts on headphones when yours connect. Miss U only checks the connection. It never listens or sees what you play."
    }
}
