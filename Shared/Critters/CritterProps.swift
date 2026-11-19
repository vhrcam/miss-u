import SwiftUI

extension CritterRig {
    enum Prop {
        case zs(CGPoint)
    }
}

extension CritterInk {
    func prop(_ prop: CritterRig.Prop) {
        switch prop {
        case let .zs(c):
            let zs: [(CGFloat, CGFloat, CGFloat)] = [(0, 0, 4.5), (7, -8.5, 6), (15.5, -19, 7.5)]
            for (dx, dy, size) in zs {
                let x = c.x + dx, y = c.y + dy, h = size / 2
                var z = Path()
                z.addLines([CGPoint(x: x - h, y: y - h), CGPoint(x: x + h, y: y - h), CGPoint(x: x - h, y: y + h), CGPoint(x: x + h, y: y + h)])
                pen(z)
            }
        }
    }
}
