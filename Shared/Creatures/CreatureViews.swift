import SwiftUI

/// One character standing. When animated it breathes, blinks and flicks an ear; tap it and it beams.
struct StandingCreature: View {
    let species: Species
    var pose: CreaturePose
    var animated: Bool

    @State private var tapped = Date.distantPast
    @State private var taps = 0
    @Environment(\.accessibilityReduceMotion) private var calm

    init(_ species: Species, pose: CreaturePose = CreaturePose(), animated: Bool = true) {
        self.species = species
        self.pose = pose
        self.animated = animated
    }

    var body: some View {
        Group {
            if animated {
                TimelineView(.animation(minimumInterval: 1.0 / 30)) { canvas($0.date) }
            } else {
                canvas(nil)
            }
        }
        .contentShape(Rectangle())
        .gesture(TapGesture().onEnded { tapped = .now; taps += 1 }, including: animated ? .all : .subviews)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.55), trigger: taps)
        .accessibilityHidden(true)
    }

    private func canvas(_ date: Date?) -> some View {
        CritterCanvas(frame: CGRect(x: -34, y: -98, width: 68, height: 102), headroom: 0) { paint in
            var pose = pose
            var heart: (CGPoint, Double)?
            if let date {
                let t = date.timeIntervalSinceReferenceDate + species.phase
                if pose.eyes == .open { pose.blink = CritterLife.blink(t) }
                if !calm {
                    pose.breath = CGFloat(sin(t * 2 * .pi / 3.8))
                    pose.tail += CGFloat(sin(t * 2 * .pi / 4.8)) * 6
                    pose.ears.right += CritterLife.earFlick(t) * 0.6
                }
                let reaction = CritterLife.reaction(date.timeIntervalSince(tapped), calm: calm)
                if reaction.glee > 0 {
                    pose.eyes = .happy
                    pose.blush = 0.9
                }
                if let pop = reaction.pop, !calm { heart = (CGPoint(x: 0, y: -86 - 14 * pop), CritterLife.fade(Double(pop))) }
            }
            let painter = CreaturePainter(context: paint.context, finish: .tonal, px: paint.scale)
            let form = species.standing(pose, at: .zero, scale: 1)
            painter.ground(form, width: 30)
            painter.paint(form, species, pose)
            if let (at, opacity) = heart { painter.heart(at: at, width: 7, opacity: opacity) }
        }
    }
}

/// A character's head, for avatars and notifications.
struct CreatureHead: View {
    let species: Species
    var pose = CreaturePose(turn: 0.15)

    init(_ species: Species) {
        self.species = species
    }

    var body: some View {
        CritterCanvas(frame: CGRect(x: -26, y: -42, width: 52, height: 50), headroom: 0) { paint in
            let painter = CreaturePainter(context: paint.context, finish: .tonal, px: paint.scale)
            painter.paint(species.peeking(pose, at: .zero, scale: 1, paws: false), species, pose)
        }
        .accessibilityHidden(true)
    }
}

/// The two of you: the right one has an arm around the left one's shoulders, the left one leans in.
/// Bumping `react` makes the left one (your partner) light up; tapping either side makes that one react.
struct CoupleScene: View {
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
                TimelineView(.animation(minimumInterval: 1.0 / 30)) { canvas($0.date) }
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
        CritterCanvas(frame: CGRect(x: 34, y: 2, width: 116, height: 104), headroom: 0) { paint in
            Self.draw(paint, left, right, at: date, leftAt: leftAt, rightAt: rightAt, calm: calm)
        }
    }

    static func draw(_ paint: CritterPaint, _ left: Species, _ right: Species, at date: Date?, leftAt: Date = .distantPast, rightAt: Date = .distantPast, calm: Bool = false) {
        let painter = CreaturePainter(context: paint.context, finish: .tonal, px: paint.scale)
        var l = CreaturePose(lean: 6, tilt: 6, turn: 0.3, eyes: .content, blush: 0.75, ears: (left: -3, right: -9), tail: -6, tailSide: -1, arms: (left: true, right: false))
        var r = CreaturePose(lean: -4, tilt: -8, turn: -0.3, gaze: CGPoint(x: -0.8, y: 0.45), blush: 0.6, arms: (left: false, right: true))
        var heart: (CGPoint, Double)? = (CGPoint(x: 100, y: 16), 1)
        if let date {
            let t = date.timeIntervalSinceReferenceDate
            r.blink = CritterLife.blink(t + 1.1)
            if !calm {
                l.breath = CGFloat(sin(t * 2 * .pi / 3.7 + 1.3))
                r.breath = CGFloat(sin(t * 2 * .pi / 4.2))
                l.tilt += CGFloat(sin(t * 2 * .pi / 5.5)) * 1.2
                l.tail += CGFloat(sin(t * 2 * .pi / 4.6)) * 7
                let p = CritterLife.cycle(t, 4.4)
                heart = (CGPoint(x: 100 + 2.5 * sin(p * 5), y: 24 - 14 * p), CritterLife.fade(p))
            }
            for (at, isLeft) in [(leftAt, true), (rightAt, false)] {
                let reaction = CritterLife.reaction(date.timeIntervalSince(at), calm: calm)
                guard reaction.glee > 0 else { continue }
                if isLeft {
                    l.eyes = .happy
                    l.blush = 0.95
                } else {
                    r.eyes = .happy
                    r.blush = 0.9
                }
                if let pop = reaction.pop, !calm {
                    heart = (CGPoint(x: isLeft ? 76 : 118, y: 20 - 16 * pop), CritterLife.fade(Double(pop)))
                }
            }
        }

        let rightForm = right.standing(r, at: CGPoint(x: 122, y: 100), scale: 1.06)
        let leftForm = left.standing(l, at: CGPoint(x: 78, y: 102), scale: 0.95)
        painter.ground(rightForm, width: 30)
        painter.paint(rightForm, right, r)

        let shoulder = right.standingShoulder(-1).applying(rightForm.place)
        let far = left.standingShoulder(-1).applying(leftForm.place)
        let arm = Sketch.tube(shoulder, CGPoint(x: shoulder.x - 8, y: shoulder.y - 1), CGPoint(x: far.x + 10, y: far.y - 2), CGPoint(x: far.x + 2, y: far.y + 0.5),
                              from: 7.6 * 1.06, to: 7)
        painter.limb(arm, right.colors.coat, size: 1.06)

        painter.ground(leftForm, width: 28)
        painter.paint(leftForm, left, l)

        let near = left.standingShoulder(1).applying(leftForm.place)
        let waist = CGPoint(x: 110, y: 78)
        let hug = Sketch.tube(near, CGPoint(x: near.x + 5, y: near.y + 4), CGPoint(x: waist.x - 6, y: waist.y - 1), waist, from: 6.2 * 0.95, to: 5.6)
        painter.limb(hug, left.colors.coat, size: 0.95)
        painter.limb(Sketch.oval(CGPoint(x: far.x + 1, y: far.y + 0.6), 4.4, 3.6), right.colors.coat, size: 1.06)

        if let (at, opacity) = heart {
            painter.heart(at: at, width: 7, opacity: opacity)
        }
    }
}

/// A character holding on to the top edge of whatever sits below it, in the same design as the couple.
struct CreaturePeek: View {
    let species: Species
    var animated: Bool
    @Environment(\.accessibilityReduceMotion) private var calm

    init(_ species: Species, animated: Bool = true) {
        self.species = species
        self.animated = animated
    }

    var body: some View {
        Group {
            if animated {
                TimelineView(.animation(minimumInterval: 1.0 / 30)) { canvas($0.date.timeIntervalSinceReferenceDate) }
            } else {
                canvas(nil)
            }
        }
        .accessibilityHidden(true)
    }

    private func canvas(_ t: Double?) -> some View {
        CritterCanvas(frame: CGRect(x: -26, y: -48, width: 52, height: 48), headroom: 0) { paint in
            var pose = CreaturePose(turn: 0.15, gaze: CGPoint(x: 0, y: 0.35))
            if let t {
                pose.blink = CritterLife.blink(t + species.phase)
                if !calm { pose.breath = CGFloat(sin(t * 2 * .pi / 3.8)) }
            }
            var c = paint
            c.context.clip(to: Path(CGRect(x: -80, y: -120, width: 160, height: 120)))
            let painter = CreaturePainter(context: c.context, finish: .tonal, px: paint.scale)
            painter.paint(species.peeking(pose, at: .zero, scale: 1), species, pose)
        }
    }
}
