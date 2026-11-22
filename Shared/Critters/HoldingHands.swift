import SwiftUI

/// Two characters holding hands. When animated they breathe out of step, glance at each other
/// now and then, and each answers a tap. Bumping `react` makes the left one (your partner) light up.
struct HoldingHands: View {
    let left: Species
    let right: Species
    var animated: Bool
    var react: Int

    @State private var leftAt = Date.distantPast
    @State private var rightAt = Date.distantPast
    @State private var taps = 0
    @Environment(\.accessibilityReduceMotion) private var calm

    init(_ left: Species, _ right: Species, animated: Bool = false, react: Int = 0) {
        self.left = left
        self.right = right
        self.animated = animated
        self.react = react
    }

    var body: some View {
        Group {
            if animated {
                TimelineView(.animation) { canvas($0.date) }
            } else {
                canvas(nil)
            }
        }
        .overlay {
            if animated {
                HStack(spacing: 0) {
                    Color.clear.contentShape(Rectangle()).onTapGesture { leftAt = .now; taps += 1 }
                    Color.clear.contentShape(Rectangle()).onTapGesture { rightAt = .now; taps += 1 }
                }
            }
        }
        .onChange(of: react) { leftAt = .now }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.55), trigger: taps)
        .accessibilityHidden(true)
    }

    private func canvas(_ date: Date?) -> some View {
        CritterCanvas(frame: CGRect(x: 19, y: 8, width: 132, height: 90), headroom: 16) { paint in
            paint.ground(CGRect(x: 29, y: 90, width: 112, height: 6))
            var a = CritterRig.standing, b = a
            a.arms[1] = .init(64, 63, 81, 73.5)
            b.arms[0] = .init(36, 63, 19, 73.5)
            a.tilt = 5
            a.tailSide = -1
            b.tilt = -5
            a.shadow = .zero
            b.shadow = .zero
            var la = CritterLife(), lb = CritterLife()
            var ka: CGFloat = 0, kb: CGFloat = 0
            if let date {
                let t = date.timeIntervalSinceReferenceDate
                la = .at(t + left.phase, species: left, calm: calm)
                lb = .at(t + right.phase + 0.9, species: right, calm: calm)
                let g = calm ? 0 : CritterLife.glance(t)
                la.gaze = CGPoint(x: g, y: 0.15 * g)
                lb.gaze = CGPoint(x: -g, y: 0.15 * g)
                let ra = CritterLife.reaction(date.timeIntervalSince(leftAt), calm: calm)
                let rb = CritterLife.reaction(date.timeIntervalSince(rightAt), calm: calm)
                (ka, la.glee, la.pop) = ra
                (kb, lb.glee, lb.pop) = rb
            }
            var pa = paint.shifted(3, 0)
            pa.squash(ka, around: CGPoint(x: 50, y: 92.5))
            pa.critter(left, fur: left.fur, rig: a, mood: .happy, life: la)
            var pb = paint.shifted(67, 0)
            pb.squash(kb, around: CGPoint(x: 50, y: 92.5))
            pb.critter(right, fur: right.fur, rig: b, mood: .happy, life: lb)
        }
    }
}
