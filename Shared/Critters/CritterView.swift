import SwiftUI

struct CritterView: View {
    let species: Species
    var pose: CritterPose
    var mood: CritterMood?
    var fur: Fur?

    init(_ species: Species, pose: CritterPose = .idle, mood: CritterMood? = nil, fur: Fur? = nil) {
        self.species = species
        self.pose = pose
        self.mood = mood
        self.fur = fur
    }

    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height) / 108
            var c = context
            c.translateBy(x: (size.width - 108 * s) / 2 + 4 * s, y: (size.height - 108 * s) / 2 + 7 * s)
            c.scaleBy(x: s, y: s)
            CritterInk(c, scale: s).critter(species, fur: fur ?? species.fur, rig: pose.rig, mood: mood ?? pose.mood)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
