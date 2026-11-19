import SwiftUI

struct CritterGallery: View {
    var body: some View {
        VStack(spacing: 44) {
            Grid(horizontalSpacing: 8, verticalSpacing: 22) {
                ForEach(Species.allCases, id: \.self) { species in
                    GridRow {
                        ForEach(CritterPose.allCases, id: \.self) { CritterView(species, pose: $0) }
                    }
                }
            }
            Grid(horizontalSpacing: 18, verticalSpacing: 16) {
                ForEach(Species.allCases, id: \.self) { species in
                    GridRow {
                        ForEach(CritterMood.allCases, id: \.self) { CritterHead(species, mood: $0).frame(width: 52, height: 52) }
                    }
                }
            }
            VStack(spacing: 44) {
                HoldingHands(.cat, .bear)
                HoldingHands(.dog, .rabbit)
            }
        }
    }
}
