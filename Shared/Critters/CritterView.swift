import SwiftUI

/// A whole character. When `animated`, it breathes, blinks and flicks an ear, and pose changes
/// blend smoothly. When `interactive`, a tap makes it squish happily and float a heart.
struct CritterView: View {
    let species: Species
    var pose: CritterPose
    var mood: CritterMood?
    var fur: Fur?
    var animated: Bool
    var gaze: CGFloat
    var interactive: Bool
    var react: Int

    @State private var from: CritterPose?
    @State private var changed = Date.distantPast
    @State private var tapped = Date.distantPast
    @State private var taps = 0
    @Environment(\.accessibilityReduceMotion) private var calm

    init(_ species: Species, pose: CritterPose = .idle, mood: CritterMood? = nil, fur: Fur? = nil,
         animated: Bool = false, gaze: CGFloat = 0, interactive: Bool = false, react: Int = 0) {
        self.species = species
        self.pose = pose
        self.mood = mood
        self.fur = fur
        self.animated = animated
        self.gaze = gaze
        self.interactive = interactive
        self.react = react
    }

    var body: some View {
        Group {
            if animated || interactive {
                TimelineView(.animation) { canvas(at: $0.date) }
            } else {
                canvas(at: nil)
            }
        }
        .contentShape(Rectangle())
        .gesture(TapGesture().onEnded { poke() }, including: interactive ? .all : .subviews)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.55), trigger: taps)
        .onChange(of: pose) { old, _ in
            from = old
            changed = .now
        }
        .onChange(of: react) { tapped = .now }
        .accessibilityHidden(!interactive)
        .accessibilityLabel(species.rawValue)
        .accessibilityAction { poke() }
    }

    private func poke() {
        tapped = .now
        taps += 1
    }

    private func canvas(at date: Date?) -> some View {
        CritterCanvas(frame: CGRect(x: 5, y: 8, width: 90, height: 90), headroom: 16) { paint in
            var paint = paint
            var rig = pose.rig
            var shown = mood ?? pose.mood
            var life = CritterLife()
            var squash: CGFloat = 0
            if let date {
                life = .at(date.timeIntervalSinceReferenceDate + species.phase, species: species, calm: calm)
                life.gaze = CGPoint(x: gaze, y: 0)
                let p = date.timeIntervalSince(changed) / 0.6
                if let from, p < 1 {
                    let e = CGFloat(p < 0.5 ? 2 * p * p : 1 - pow(-2 * p + 2, 2) / 2)
                    rig = .blend(from.rig, pose.rig, e)
                    if p < 0.5, mood == nil { shown = from.mood }
                    if !calm { squash += CGFloat(0.035 * sin(.pi * p)) }
                }
                let r = date.timeIntervalSince(tapped)
                if r >= 0, r < 1.3 {
                    life.glee = CGFloat(r < 0.75 ? 1 : max(0, 1 - (r - 0.75) / 0.4))
                    if !calm { squash += CGFloat(0.06 * exp(-r * 5.5) * cos(r * 2 * .pi / 0.5)) }
                    life.pop = CGFloat(r / 1.3)
                }
            }
            paint.squash(squash, around: CGPoint(x: rig.torso.cx, y: rig.torso.bottom))
            paint.critter(species, fur: fur ?? species.fur, rig: rig, mood: shown, life: life)
        }
    }
}
