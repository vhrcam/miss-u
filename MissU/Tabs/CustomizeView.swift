import SwiftUI

struct CustomizeView: View {
    @Environment(AppModel.self) private var model
    @State private var section = Section.me
    @State private var avatar = AvatarConfig()
    @State private var saving = false

    enum Section: String, CaseIterable, Identifiable {
        case me = "Me", mine = "My widget", theirs = "Their widget"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenTitle(title: "Customize")
                    Picker("Section", selection: $section) {
                        ForEach(Section.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    switch section {
                    case .me: mePanel
                    case .mine: MyWidgetPanel()
                    case .theirs: PartnerWidgetPanel()
                    }
                }
                .padding(20)
            }
            .screen()
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear { avatar = model.state?.me.avatar ?? AvatarConfig() }
    }

    private var mePanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            AvatarView(config: avatar, animated: true)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            AvatarEditor(config: $avatar)
            Button {
                Task {
                    saving = true
                    await model.saveAvatar(avatar)
                    saving = false
                }
            } label: {
                if saving { ProgressView().tint(.white) } else { Text("Save character") }
            }
            .buttonStyle(.primary)
            .disabled(saving || avatar == model.state?.me.avatar)
        }
    }
}
