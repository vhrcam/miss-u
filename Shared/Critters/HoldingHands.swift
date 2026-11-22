import SwiftUI

/// Two characters holding hands. When animated they breathe out of step and now and then turn to look at each other.
struct HoldingHands: View {
    let left: Species
    let right: Species
    var animated: Bool

    @Environment(\.accessibilityReduceMotion) private var calm

    init(_ left: Species, _ right: Species, animated: Bool = false) {
        self.left = left
        self.right = right
        self.animated = animated
    }

    var body: some View {
        Group {
            if animated {
                TimelineView(.animation) { canvas($0.date.timeIntervalSinceReferenceDate) }
            } else {
                canvas(nil)
            }
        }
        .accessibilityHidden(true)
    }

    private func canvas(_ t: Double?) -> some View {
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
            if let t {
                la = .at(t + left.phase, species: left, calm: calm)
                lb = .at(t + right.phase + 0.9, species: right, calm: calm)
                let g = calm ? 0 : CritterLife.glance(t)
                la.gaze = CGPoint(x: g, y: 0.15 * g)
                lb.gaze = CGPoint(x: -g, y: 0.15 * g)
            }
            paint.shifted(3, 0).critter(left, fur: left.fur, rig: a, mood: .happy, life: la)
            paint.shifted(67, 0).critter(right, fur: right.fur, rig: b, mood: .happy, life: lb)
        }
    }
}
