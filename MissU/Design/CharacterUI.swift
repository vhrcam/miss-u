import SwiftUI

/// The two of you, standing in a soft pool of light. Your partner's thought floats above them,
/// and bumping `react` (when you send love) makes their character light up.
struct CoupleStage: View {
    var me: Species
    var partner: Species
    var partnerName: String
    var bubble: (icon: Icon, text: String)?
    var tint: Tint = .pink
    var react = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if let bubble {
                    ThoughtBubble(icon: bubble.icon, text: bubble.text, tint: tint)
                }
                Spacer(minLength: 0)
            }
            .padding(.leading, Space.xxl)
            .frame(height: 62, alignment: .bottom)
            HoldingHands(partner, me, animated: true, react: react)
                .frame(width: 320)
            HStack {
                Text(partnerName).frame(maxWidth: .infinity)
                Text("you").frame(maxWidth: .infinity)
            }
            .font(Typeface.tiny)
            .tracking(1)
            .textCase(.uppercase)
            .foregroundStyle(Palette.cocoa)
            .padding(.horizontal, 64)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .background {
            Ellipse()
                .fill(RadialGradient(colors: [Palette.warmWhite.opacity(0.95), tint.soft.opacity(0.55), tint.soft.opacity(0)], center: .center, startRadius: 0, endRadius: 190))
                .frame(width: 400, height: 300)
                .offset(y: 16)
        }
    }
}

struct EmptyState: View {
    var species: Species
    var pose: CritterPose = .sitting
    var title: String
    var message: String

    var body: some View {
        VStack(spacing: Space.s) {
            CritterView(species, pose: pose, animated: true, interactive: true).frame(width: 132)
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
        VStack(spacing: Space.s) {
            CritterView(species, pose: .sitting, animated: true)
                .frame(width: 92)
                .phaseAnimator([false, true]) { view, up in
                    view.offset(y: up ? -5 : 0)
                } animation: { _ in .easeInOut(duration: 0.9) }
            Text(text).font(Typeface.caption).foregroundStyle(Palette.cocoa)
        }
    }
}
