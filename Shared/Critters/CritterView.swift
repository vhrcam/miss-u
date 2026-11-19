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
        CritterCanvas(frame: CGRect(x: 5, y: 8, width: 90, height: 90), headroom: 16) {
            $0.critter(species, fur: fur ?? species.fur, rig: pose.rig, mood: mood ?? pose.mood)
        }
    }
}
