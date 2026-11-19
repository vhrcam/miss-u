import SwiftUI

extension CritterRig {
    enum Prop {
        case heart(CGPoint, CGFloat)
        case zs(CGPoint)
    }
}

extension CritterInk {
    func prop(_ prop: CritterRig.Prop) {
        switch prop {
        case let .heart(c, w):
            let h = w * 0.9, x = c.x, y = c.y
            var p = Path()
            p.move(to: CGPoint(x: x, y: y + h * 0.5))
            p.addCurve(to: CGPoint(x: x - w / 2, y: y - h * 0.1), control1: CGPoint(x: x - w * 0.2, y: y + h * 0.36), control2: CGPoint(x: x - w / 2, y: y + h * 0.18))
            p.addCurve(to: CGPoint(x: x, y: y - h * 0.28), control1: CGPoint(x: x - w / 2, y: y - h * 0.55), control2: CGPoint(x: x - w * 0.05, y: y - h * 0.58))
            p.addCurve(to: CGPoint(x: x + w / 2, y: y - h * 0.1), control1: CGPoint(x: x + w * 0.05, y: y - h * 0.58), control2: CGPoint(x: x + w / 2, y: y - h * 0.55))
            p.addCurve(to: CGPoint(x: x, y: y + h * 0.5), control1: CGPoint(x: x + w / 2, y: y + h * 0.18), control2: CGPoint(x: x + w * 0.2, y: y + h * 0.36))
            p.closeSubpath()
            shape(p, Color(hex: 0xF9879B))
            context.fill(Path(ellipseIn: CGRect(x: x - w * 0.3, y: y - h * 0.36, width: w * 0.14, height: w * 0.11)), with: .color(.white.opacity(0.8)))
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
