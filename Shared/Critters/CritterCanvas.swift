import SwiftUI

struct CritterCanvas: View {
    let frame: CGRect
    let headroom: CGFloat
    let draw: (CritterInk) -> Void

    var body: some View {
        Color.clear
            .aspectRatio(frame.width / frame.height, contentMode: .fit)
            .overlay(alignment: .bottom) {
                Canvas { context, size in
                    let s = min(size.width / frame.width, size.height / (frame.height + headroom))
                    var c = context
                    c.translateBy(x: size.width / 2 - frame.midX * s, y: size.height - frame.maxY * s)
                    c.scaleBy(x: s, y: s)
                    draw(CritterInk(c, scale: s))
                }
                .aspectRatio(frame.width / (frame.height + headroom), contentMode: .fill)
            }
    }
}
