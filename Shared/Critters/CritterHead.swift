import SwiftUI

struct CritterHead: View {
    let species: Species
    var mood: CritterMood
    var fur: Fur?

    init(_ species: Species, mood: CritterMood = .happy, fur: Fur? = nil) {
        self.species = species
        self.mood = mood
        self.fur = fur
    }

    var body: some View {
        CritterCanvas(frame: CGRect(x: -33, y: -36.5, width: 66, height: 66), headroom: 13) {
            $0.head(species, fur: fur ?? species.fur, mood: mood)
        }
    }
}
