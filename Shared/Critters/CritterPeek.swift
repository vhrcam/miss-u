import SwiftUI

/// A character peeking over an edge with its paws on it. Line the bottom of this view up
/// with the top of a card, bar or button and the character looks like it's holding on from behind.
struct CritterPeek: View {
    let species: Species
    var mood: CritterMood
    var fur: Fur?
    var animated: Bool
    var gaze: CGFloat

    @Environment(\.accessibilityReduceMotion) private var calm

    init(_ species: Species, mood: CritterMood = .happy, fur: Fur? = nil, animated: Bool = true, gaze: CGFloat = 0) {
        self.species = species
        self.mood = mood
        self.fur = fur
        self.animated = animated
        self.gaze = gaze
    }

    var body: some View {
        Group {
            if animated {
                TimelineView(.animation) { canvas($0.date) }
            } else {
                canvas(nil)
            }
        }
        .accessibilityHidden(true)
    }

    private func canvas(_ date: Date?) -> some View {
        CritterCanvas(frame: CGRect(x: -31, y: -38, width: 62, height: 45), headroom: 12) { paint in
            var paint = paint
            paint.context.clip(to: Path(CGRect(x: -80, y: -140, width: 160, height: 147)))
            var life = CritterLife()
            if let date {
                life = .at(date.timeIntervalSinceReferenceDate + species.phase, species: species, calm: calm)
                life.gaze = CGPoint(x: gaze, y: 0.3)
            }
            let f = fur ?? species.fur
            let skull = paint.head(species, fur: f, mood: mood, life: life, at: CGAffineTransform(translationX: 0, y: -4 - life.breath * 0.6))
            paint.paws(f, at: 5.4, over: skull)
        }
    }
}
