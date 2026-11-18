import SwiftUI

@main
struct MissUApp: App {
    var body: some Scene {
        WindowGroup {
            AvatarView(config: AvatarConfig())
                .padding(60)
        }
    }
}
