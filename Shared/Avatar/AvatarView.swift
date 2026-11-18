import SwiftUI

struct AvatarView: View {
    var config: AvatarConfig
    var activity: ActivityKind? = nil
    var animated: Bool = false

    var body: some View {
        Circle()
            .fill(Color.pink.opacity(0.35))
            .aspectRatio(1, contentMode: .fit)
    }
}
