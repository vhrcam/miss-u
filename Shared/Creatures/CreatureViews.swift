import SwiftUI

/// One creature, sitting. When animated it breathes, blinks, flicks an ear and sways its tail.
struct CreatureView: View {
    let species: Species
    var pose: CreaturePose
    var finish: CreatureFinish
    var animated: Bool
    var seed: Double

    @Environment(\.accessibilityReduceMotion) private var calm

    init(_ species: Species, pose: CreaturePose = CreaturePose(), finish: CreatureFinish = .soft, animated: Bool = false, seed: Double = 0) {
        self.species = species
        self.pose = pose
        self.finish = finish
        self.animated = animated
        self.seed = seed
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
        CritterCanvas(frame: CGRect(x: -36, y: -86, width: 72, height: 92), headroom: species == .rabbit ? 16 : 0) { paint in
            var pose = pose
            if let t {
                let t = t + species.phase + seed
                pose.blink = CritterLife.blink(t)
                if !calm {
                    pose.breath = CGFloat(sin(t * 2 * .pi / 3.8))
                    let flick = CritterLife.earFlick(t) * 0.7
                    pose.ears.right += flick
                    pose.tail += CGFloat(sin(t * 2 * .pi / 4.8)) * 6
                }
            }
            let painter = CreaturePainter(context: paint.context, finish: finish, px: paint.scale)
            let form = species.form(pose, at: .zero, scale: 1)
            painter.ground(form, width: 44)
            painter.paint(form, species, pose)
        }
    }
}

/// The bear holding the cat close: the cat leans in with its eyes closed, the bear rests its head
/// against the cat's and looks down at it, its arm around the cat's shoulders.
struct CuddleScene: View {
    var finish: CreatureFinish
    var animated: Bool

    @Environment(\.accessibilityReduceMotion) private var calm

    init(finish: CreatureFinish = .soft, animated: Bool = false) {
        self.finish = finish
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
        CritterCanvas(frame: CGRect(x: 24, y: 10, width: 120, height: 104), headroom: 0) { paint in
            Self.draw(paint, finish: finish, time: t, calm: calm)
        }
    }

    static func draw(_ paint: CritterPaint, finish: CreatureFinish, time t: Double?, calm: Bool = false) {
        let painter = CreaturePainter(context: paint.context, finish: finish, px: paint.scale)
        var bear = CreaturePose(lean: -7, tilt: -13, headShift: CGSize(width: -1, height: 3), turn: -0.4,
                                gaze: CGPoint(x: -0.9, y: 0.7), blush: 0.6, ears: (left: 6, right: -3), arms: (left: false, right: true))
        var cat = CreaturePose(lean: 4, tilt: 9, turn: 0.3, eyes: .content, blush: 0.8, ears: (left: -4, right: 22), tail: -10)
        if let t {
            bear.blink = CritterLife.blink(t + 1.1)
            if !calm {
                bear.breath = CGFloat(sin(t * 2 * .pi / 4.2))
                cat.breath = CGFloat(sin(t * 2 * .pi / 3.6 + 1.3))
                cat.tilt += CGFloat(sin(t * 2 * .pi / 5.5)) * 1.2
                cat.tail += CGFloat(sin(t * 2 * .pi / 4.6)) * 7
            }
        }
        let bearForm = Species.bear.form(bear, at: CGPoint(x: 113, y: 96), scale: 1.08)
        let catForm = Species.cat.form(cat, at: CGPoint(x: 62, y: 108), scale: 0.95)
        painter.ground(bearForm, width: 46)
        painter.paint(bearForm, .bear, bear)
        painter.ground(catForm, width: 42)
        painter.paint(catForm, .cat, cat)

        let shoulder = Species.bear.shoulder(-1).applying(bearForm.place)
        let paw = CGPoint(x: 67.5, y: 86)
        let arm = Sketch.tube(shoulder, CGPoint(x: shoulder.x - 9, y: shoulder.y - 1), CGPoint(x: 75, y: 71), paw, from: 9.6, to: 8.8)
        var hug = painter
        hug.context.clip(to: catForm.head, options: .inverse)
        hug.limb(arm, Species.bear.colors.coat, size: 1.08)

        if let t, !calm {
            let p = CritterLife.cycle(t, 4.2)
            painter.heart(at: CGPoint(x: 89 + 3 * sin(p * 5), y: 28 - 14 * p), width: 7 * (1 - 0.2 * p), opacity: CritterLife.fade(p))
        } else {
            painter.heart(at: CGPoint(x: 89, y: 22), width: 7)
        }
    }
}
