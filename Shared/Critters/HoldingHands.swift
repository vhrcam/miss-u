import SwiftUI

struct HoldingHands: View {
    let left: Species
    let right: Species

    init(_ left: Species, _ right: Species) {
        self.left = left
        self.right = right
    }

    var body: some View {
        CritterCanvas(frame: CGRect(x: 19, y: 8, width: 132, height: 90), headroom: 16) { ink in
            ink.context.fill(Path(ellipseIn: CGRect(x: 29, y: 90, width: 112, height: 6)), with: .color(Palette.ground))
            var a = CritterPose.idle.rig, b = a
            a.back[1] = .init(64, 63, 81, 73.5)
            b.back[0] = .init(36, 63, 19, 73.5)
            a.tilt = .degrees(5)
            b.tilt = .degrees(-5)
            a.shadow = .zero
            b.shadow = .zero
            ink.at(CGPoint(x: 3, y: 0)).critter(left, fur: left.fur, rig: a, mood: .happy)
            ink.at(CGPoint(x: 67, y: 0)).critter(right, fur: right.fur, rig: b, mood: .happy)
        }
    }
}
