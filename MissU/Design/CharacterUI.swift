import SwiftUI

struct CoupleStage: View {
    var me: Species
    var partner: Species
    var partnerName: String
    var bubble: (icon: Icon, text: String)?
    var tint: Tint = .pink

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if let bubble {
                    ThoughtBubble(icon: bubble.icon, text: bubble.text, tint: tint)
                }
                Spacer()
            }
            .frame(height: 64, alignment: .bottom)
            HoldingHands(partner, me).frame(width: 290)
            HStack {
                Text(partnerName).frame(maxWidth: .infinity)
                Text("you").frame(maxWidth: .infinity)
            }
            .font(Typeface.caption)
            .foregroundStyle(Palette.cocoa)
            .padding(.horizontal, Space.xxl)
        }
        .padding(Space.l)
        .frame(maxWidth: .infinity)
        .sticker(tint.soft, lip: tint.deep, depth: 5, corner: 30, line: Line.card, seed: 31)
        .padding(.bottom, 5)
    }
}

struct EmptyState: View {
    var species: Species
    var pose: CritterPose = .sitting
    var title: String
    var message: String

    var body: some View {
        VStack(spacing: Space.s) {
            CritterView(species, pose: pose, animated: true).frame(width: 130)
            Text(title).font(Typeface.headline)
            Text(message)
                .font(Typeface.caption)
                .foregroundStyle(Palette.cocoa)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Space.xl)
        .frame(maxWidth: .infinity)
    }
}

struct CritterLoader: View {
    var species: Species
    var text = "One sec"

    var body: some View {
        VStack(spacing: Space.xs) {
            CritterView(species)
                .frame(width: 96)
                .phaseAnimator([0, 1, 2]) { view, phase in
                    view
                        .offset(y: phase == 1 ? -14 : 0)
                        .scaleEffect(x: phase == 2 ? 1.06 : 1, y: phase == 2 ? 0.94 : 1, anchor: .bottom)
                } animation: { phase in
                    phase == 1 ? .easeOut(duration: 0.28) : .spring(response: 0.26, dampingFraction: 0.5)
                }
            Ground(width: 64)
            Text(text).font(Typeface.caption).foregroundStyle(Palette.cocoa).padding(.top, Space.xs)
        }
    }
}
