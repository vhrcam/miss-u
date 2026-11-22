import SwiftUI

struct CritterHead: View {
    let species: Species
    var mood: CritterMood
    var fur: Fur?
    var animated: Bool

    @Environment(\.accessibilityReduceMotion) private var calm

    init(_ species: Species, mood: CritterMood = .happy, fur: Fur? = nil, animated: Bool = false) {
        self.species = species
        self.mood = mood
        self.fur = fur
        self.animated = animated
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
        CritterCanvas(frame: CGRect(x: -33, y: -36.5, width: 66, height: 66), headroom: 13) { paint in
            let life = date.map { CritterLife.at($0.timeIntervalSinceReferenceDate + species.phase, species: species, calm: calm) } ?? CritterLife()
            paint.head(species, fur: fur ?? species.fur, mood: mood, life: life, at: CGAffineTransform(translationX: 0, y: -life.breath * 0.5))
        }
    }
}
