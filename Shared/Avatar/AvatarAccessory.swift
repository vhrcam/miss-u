import SwiftUI

extension AvatarView {
    static func accessory(_ accessory: Accessory, _ shirt: ShirtColor) -> [Layer] {
        let fill = shirt.fill
        let trim = trim(shirt)
        switch accessory {
        case .none:
            return []

        case .glasses:
            return [.flat(pair(circle(40.5, 46.5, 6.4)), .white.opacity(0.35))]

        case .bow:
            var loop = Pen()
            loop.move(0, 0)
            loop.curve(2.5, -6.5, 10.5, -7, 10.5, 0)
            loop.curve(10.5, 7, 2.5, 6.5, 0, 0)
            loop.close()
            let loops = loop.path.union(loop.path.applying(CGAffineTransform(scaleX: -1, y: 1)))
            let place = CGAffineTransform(translationX: 64, y: 21).rotated(by: 0.35).scaledBy(x: 1.2, y: 1.2)
            return [
                .solid(loops.applying(place), Theme.rose),
                .solid(circle(0, 0, 2.8).applying(place), Theme.rose, 1.8)
            ]

        case .flower:
            var petals = Path()
            for i in 0..<6 {
                petals = petals.union(oval(4, 0, 3.6, 2.7).applying(CGAffineTransform(rotationAngle: CGFloat(i) * .pi / 3)))
            }
            return [
                .solid(petals.applying(CGAffineTransform(translationX: 67.5, y: 24.5).scaledBy(x: 1.2, y: 1.2)), .white),
                .solid(circle(67.5, 24.5, 3), Color(hex: 0xFFD45C), 1.6)
            ]

        case .beanie:
            let hat = crown.intersection(Path(CGRect(x: 0, y: 0, width: 100, height: 33)))
            let cuff = bodyPath.applying(grow(1.1, 1.1, 50, 60)).intersection(Path(CGRect(x: 0, y: 27, width: 100, height: 7.5)))
            var ribs = Pen()
            for x in stride(from: CGFloat(26), through: 74, by: 4) {
                ribs.move(x, 28)
                ribs.line(x, 33.5)
            }
            return [
                .solid(hat, fill),
                .solid(cuff, trim),
                .flat(Stack.outline(ribs.path, 1.1).intersection(cuff), Theme.ink.opacity(0.3)),
                .solid(circle(50, 12, 5.8), Theme.cream)
            ]

        case .cap:
            var brim = Pen()
            brim.move(22, 31)
            brim.curve(30, 28, 70, 28, 78, 31)
            brim.curve(80, 34, 74, 37.5, 66, 37)
            brim.curve(58, 36, 42, 36, 34, 37)
            brim.curve(26, 37.5, 20, 34, 22, 31)
            brim.close()
            return [
                .solid(crown.intersection(Path(CGRect(x: 0, y: 0, width: 100, height: 31.5))), fill),
                .solid(HeartShape().path(in: CGRect(x: 45.5, y: 20.5, width: 9, height: 8)), shirt == .cream ? Theme.rose : Theme.cream, 1.6),
                .solid(circle(50, 13.8, 2), trim, 1.6),
                .solid(brim.path, trim)
            ]
        }
    }

    static var glasses: [Layer] {
        var frame = Pen()
        frame.move(46.9, 45.8)
        frame.quad(50, 43.8, 53.1, 45.8)
        frame.move(34.1, 45.6)
        frame.line(24.2, 43.6)
        frame.move(65.9, 45.6)
        frame.line(75.8, 43.6)
        frame.path.addPath(pair(circle(40.5, 46.5, 6.4)))
        return [.ink(frame.path, 2.1)]
    }
}
