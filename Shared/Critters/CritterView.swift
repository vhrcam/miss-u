import SwiftUI

struct CritterView: View {
    let species: Species
    var pose: CritterPose
    var mood: CritterMood?
    var fur: Fur?
    var animated: Bool

    init(_ species: Species, pose: CritterPose = .idle, mood: CritterMood? = nil, fur: Fur? = nil, animated: Bool = false) {
        self.species = species
        self.pose = pose
        self.mood = mood
        self.fur = fur
        self.animated = animated
    }

    var body: some View {
        if animated {
            TimelineView(.animation) { canvas(at: $0.date.timeIntervalSinceReferenceDate) }
        } else {
            canvas(at: nil)
        }
    }

    func canvas(at time: Double?) -> some View {
        CritterCanvas(frame: CGRect(x: 5, y: 8, width: 90, height: 90), headroom: 16) { ink in
            var ink = ink
            if let time {
                let breath = sin(time * 1.85) * 0.014
                ink.context.translateBy(x: 50, y: 92.5)
                ink.context.scaleBy(x: 1 - breath / 2, y: 1 + breath)
                ink.context.translateBy(x: -50, y: -92.5)
            }
            let blink = time.map { $0.truncatingRemainder(dividingBy: 4.6) < 0.14 } ?? false
            ink.critter(species, fur: fur ?? species.fur, rig: pose.rig, mood: mood ?? pose.mood, blink: blink)
        }
    }
}
