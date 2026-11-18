import SwiftUI

extension AvatarView {
    static func neckline(_ side: CGFloat, _ dip: CGFloat) -> Path {
        var pen = Pen()
        pen.move(0, side)
        pen.curve(28, side, 38, dip, 50, dip)
        pen.curve(62, dip, 72, side, 100, side)
        pen.line(100, 100)
        pen.line(0, 100)
        pen.close()
        return pen.path
    }

    static func trim(_ shirt: ShirtColor) -> Color {
        shirt == .charcoal ? shirt.fill.mix(with: .white, by: 0.2) : shirt.fill.mix(with: Theme.ink, by: 0.12)
    }

    static func outfit(_ outfit: Outfit, _ shirt: ShirtColor) -> [Layer] {
        let body = bodyPath
        let fill = shirt.fill
        let trim = trim(shirt)
        switch outfit {
        case .tee:
            return [.solid(body.intersection(neckline(57, 62.5)), fill)]

        case .hoodie:
            let hood = body.intersection(neckline(55.5, 60)).subtracting(neckline(60, 65))
            var strings = Pen()
            strings.move(46.2, 65)
            strings.line(45.6, 69.5)
            strings.move(53.8, 65)
            strings.line(54.4, 69.5)
            var pocket = Pen()
            pocket.move(34.5, 83)
            pocket.quad(37.5, 79, 37.5, 75.5)
            pocket.line(62.5, 75.5)
            pocket.quad(62.5, 79, 65.5, 83)
            pocket.quad(50, 85, 34.5, 83)
            pocket.close()
            return [
                .solid(body.intersection(neckline(60, 65)), fill),
                .solid(hood, trim),
                .ink(strings.path, 1.6),
                .solid(circle(45.6, 70.2, 1.4).union(circle(54.4, 70.2, 1.4)), .white, 1.3),
                .solid(pocket.path, trim, 1.6)
            ]

        case .sweater:
            let collar = body.intersection(neckline(57, 62.5)).subtracting(neckline(60.2, 65.7))
            var ribs = Pen()
            for x in stride(from: 32.5, through: 67.5, by: 5) {
                ribs.move(x, 81.6)
                ribs.line(x, 86)
            }
            let heart = HeartShape().path(in: CGRect(x: 45, y: 67, width: 10, height: 9))
            return [
                .solid(body.intersection(neckline(57, 62.5)), fill),
                .solid(collar, trim, 1.6),
                .solid(body.intersection(Path(CGRect(x: 0, y: 80, width: 100, height: 20))), trim, 1.6),
                .flat(Stack.outline(ribs.path, 1.1).intersection(body), Theme.ink.opacity(0.35)),
                .solid(heart, shirt == .cream ? Theme.rose : Theme.cream, 1.6)
            ]

        case .overalls:
            var region = Path(CGRect(x: 36, y: 63, width: 28, height: 20))
            region.addRect(CGRect(x: 0, y: 74, width: 100, height: 30))
            let straps = capsule(39, 64.5, 27, 53.5, 2).union(capsule(61, 64.5, 73, 53.5, 2)).intersection(body)
            return [
                .solid(straps, fill, 1.6),
                .solid(body.intersection(region), fill),
                .solid(Path(roundedRect: CGRect(x: 44.5, y: 67, width: 11, height: 7), cornerRadius: 2), trim, 1.4),
                .solid(circle(39.5, 65.6, 1.6).union(circle(60.5, 65.6, 1.6)), Color(hex: 0xFFE3A3), 1.3)
            ]

        case .dress:
            var skirt = Pen()
            skirt.move(23, 68)
            skirt.curve(21, 75, 17.5, 79.5, 15.5, 82.5)
            skirt.quad(26.8, 87, 38.3, 83.6)
            skirt.quad(50, 87.6, 61.7, 83.6)
            skirt.quad(73.2, 87, 84.5, 82.5)
            skirt.curve(82.5, 79.5, 79, 75, 77, 68)
            skirt.close()
            let collar = pair(oval(44.2, 63.4, 6.2, 3.4).applying(turn(14, 44.2, 63.4)))
            return [
                .solid(body.intersection(neckline(57.5, 61)).union(skirt.path), fill),
                .solid(collar, shirt == .cream ? Theme.blush : Theme.cream, 1.6)
            ]
        }
    }
}
