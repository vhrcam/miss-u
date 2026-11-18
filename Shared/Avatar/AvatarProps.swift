import SwiftUI

extension AvatarView {
    static func prop(_ activity: ActivityKind?) -> [Layer] {
        switch activity {
        case .missingYou: heart
        case .shopping: basket
        case .gaming: controller
        case .studying: book
        case .working: laptop
        case .coffee: mug
        case .tv: popcorn
        default: []
        }
    }

    static func behind(_ activity: ActivityKind?) -> [Layer] {
        guard activity == .studying else { return [] }
        let low = Path(roundedRect: CGRect(x: 73.5, y: 83, width: 23, height: 7), cornerRadius: 1.8)
        let high = Path(roundedRect: CGRect(x: 76, y: 76.5, width: 19, height: 6.5), cornerRadius: 1.8)
        return [
            .solid(low, Color(hex: 0xFF9A80)),
            .solid(low.intersection(Path(CGRect(x: 90.5, y: 84.5, width: 4.5, height: 4))), Theme.cream, 1.2),
            .solid(high, Color(hex: 0x9ED39A)),
            .solid(high.intersection(Path(CGRect(x: 89.5, y: 78, width: 4, height: 3.5))), Theme.cream, 1.2)
        ]
    }

    static var heart: [Layer] {
        [
            .solid(HeartShape().path(in: CGRect(x: 36, y: 58.5, width: 28, height: 25.5)), Theme.rose),
            .flat(oval(42.5, 64.5, 3, 1.8).applying(turn(-35, 42.5, 64.5)), .white.opacity(0.75))
        ]
    }

    static var basket: [Layer] {
        var body = Pen()
        body.move(34, 67)
        body.line(66, 67)
        body.line(62.8, 84)
        body.quad(62.3, 86.5, 59.5, 86.5)
        body.line(40.5, 86.5)
        body.quad(37.7, 86.5, 37.2, 84)
        body.close()
        var weave = Pen()
        weave.move(30, 74.5)
        weave.line(70, 74.5)
        weave.move(30, 80.5)
        weave.line(70, 80.5)
        for x in stride(from: CGFloat(42.5), through: 57.5, by: 7.5) {
            weave.move(x, 67)
            weave.line(x + (x - 50) * 0.12, 87)
        }
        var bread = Pen()
        bread.move(34, 58.6)
        bread.line(36.6, 60.4)
        bread.move(36.8, 61.6)
        bread.line(39.4, 63.4)
        return [
            .solid(capsule(43, 68, 29, 56, 3.6), Color(hex: 0xEDB872)),
            .ink(bread.path, 1.3),
            .solid(circle(57, 63.5, 5), Color(hex: 0xFF6B6B)),
            .solid(oval(58.5, 57.6, 2.6, 1.3).applying(turn(-30, 58.5, 57.6)), Color(hex: 0x7BC67E), 1.3),
            .solid(body.path, Color(hex: 0xE8B672)),
            .flat(Stack.outline(weave.path, 1.2).intersection(body.path), Theme.ink.opacity(0.3)),
            .solid(Path(roundedRect: CGRect(x: 32, y: 64.5, width: 36, height: 5.5), cornerRadius: 2.5), Color(hex: 0xD49A55))
        ]
    }

    static var controller: [Layer] {
        var pad = Pen()
        pad.move(33, 70.5)
        pad.curve(33, 65, 38, 64, 43, 65)
        pad.line(57, 65)
        pad.curve(62, 64, 67, 65, 67, 70.5)
        pad.curve(67.5, 77.5, 65.5, 81.5, 61.5, 81.5)
        pad.curve(58.5, 81.5, 57.5, 77.5, 55, 76.5)
        pad.line(45, 76.5)
        pad.curve(42.5, 77.5, 41.5, 81.5, 38.5, 81.5)
        pad.curve(34.5, 81.5, 32.5, 77.5, 33, 70.5)
        pad.close()
        let cross = Path(CGRect(x: 38.6, y: 66.6, width: 2.8, height: 7)).union(Path(CGRect(x: 36.5, y: 68.7, width: 7, height: 2.8)))
        return [
            .solid(pad.path, Color(hex: 0x7A6A92)),
            .flat(cross, Theme.cream),
            .flat(circle(60, 67.4, 1.6), Theme.rose),
            .flat(circle(62.6, 70, 1.6), Color(hex: 0xFFD45C)),
            .flat(circle(57.4, 70, 1.6), Color(hex: 0x8EDBC6)),
            .flat(circle(60, 72.6, 1.6), Color(hex: 0x8FC2F2))
        ]
    }

    static var book: [Layer] {
        var cover = Pen()
        cover.move(50, 64.5)
        cover.quad(42, 61, 33, 62)
        cover.line(33, 80.5)
        cover.quad(42, 79.5, 50, 83)
        cover.quad(58, 79.5, 67, 80.5)
        cover.line(67, 62)
        cover.quad(58, 61, 50, 64.5)
        cover.close()
        var page = Pen()
        page.move(50, 66)
        page.quad(42.5, 62.5, 35, 63.5)
        page.line(35, 78.5)
        page.quad(42.5, 77.5, 50, 81)
        page.close()
        var text = Pen()
        for y in stride(from: CGFloat(68), through: 76, by: 4) {
            text.move(38.5, y - 0.6)
            text.quad(42.5, y - 1, 46.5, y + 0.4)
        }
        var spine = Pen()
        spine.move(50, 66)
        spine.line(50, 81)
        return [
            .solid(cover.path, Color(hex: 0x7FB4E8)),
            .solid(pair(page.path), Theme.cream, 1.6),
            .ink(pair(text.path), 1.2, Theme.ink.opacity(0.35)),
            .ink(spine.path, 1.4)
        ]
    }

    static var laptop: [Layer] {
        [
            .solid(Path(roundedRect: CGRect(x: 30.5, y: 61, width: 39, height: 23.5), cornerRadius: 3), Color(hex: 0xD6D1E3)),
            .solid(HeartShape().path(in: CGRect(x: 45.5, y: 68.5, width: 9, height: 8)), Theme.cream, 1.5),
            .solid(Path(roundedRect: CGRect(x: 26, y: 83, width: 48, height: 5), cornerRadius: 2.5), Color(hex: 0xBDB6CE))
        ]
    }

    static var mug: [Layer] {
        [
            .solid(Stack.outline(circle(60.5, 73, 5.2), 3.4), Theme.cream, 1.6),
            .solid(Path(roundedRect: CGRect(x: 40.5, y: 63.5, width: 19, height: 19.5), cornerRadius: 4.5), Theme.cream),
            .flat(oval(50, 65.6, 7.6, 1.8), Color(hex: 0x8A5A44)),
            .solid(HeartShape().path(in: CGRect(x: 46.2, y: 70.5, width: 7.6, height: 6.8)), Theme.rose, 1.5)
        ]
    }

    static var popcorn: [Layer] {
        var bucket = Pen()
        bucket.move(37, 67)
        bucket.line(63, 67)
        bucket.line(60, 87)
        bucket.line(40, 87)
        bucket.close()
        var stripes = Path(CGRect(x: 43.5, y: 60, width: 4.5, height: 30))
        stripes.addRect(CGRect(x: 52, y: 60, width: 4.5, height: 30))
        var kernels = Path()
        for (x, y, r) in [(40.5, 64.5, 3.6), (45.5, 61.8, 4), (51, 62.2, 4.2), (56.5, 61.6, 3.8), (61, 64.5, 3.5), (48, 65.5, 3.5), (54, 65.6, 3.4)] as [(CGFloat, CGFloat, CGFloat)] {
            kernels = kernels.union(circle(x, y, r))
        }
        return [
            .solid(kernels, Color(hex: 0xFFF3D2)),
            .flat(circle(47, 61, 1.2).union(circle(55.5, 62.6, 1.1)).union(circle(41.5, 64, 1)), Color(hex: 0xFFD45C)),
            .solid(bucket.path, .white),
            .flat(stripes.intersection(bucket.path), Color(hex: 0xFF6B6B)),
            .solid(Path(roundedRect: CGRect(x: 35.5, y: 65.5, width: 29, height: 4), cornerRadius: 2), .white, 1.8)
        ]
    }

    static var dumbbell: [Layer] {
        let plates = Path(roundedRect: CGRect(x: 78.5, y: 37.5, width: 4.5, height: 12), cornerRadius: 1.6)
            .union(Path(roundedRect: CGRect(x: 92.5, y: 37.5, width: 4.5, height: 12), cornerRadius: 1.6))
        return [
            .solid(capsule(80.5, 43.5, 95, 43.5, 1.6), Color(hex: 0xB9B2C6), 1.6),
            .solid(plates, Color(hex: 0x6E5D7E))
        ]
    }

    static func tank(_ shirt: ShirtColor) -> [Layer] {
        let top = bodyPath.intersection(neckline(55, 66))
        return [
            .solid(top, shirt.fill),
            .solid(top.intersection(Path(CGRect(x: 0, y: 72, width: 100, height: 3.6))), shirt == .cream ? Theme.rose : Theme.cream, 1.4)
        ]
    }

    static func sweatband(_ shirt: ShirtColor) -> [Layer] {
        let band = bodyPath.applying(grow(1.07, 1.07, 50, 60)).intersection(Path(CGRect(x: 0, y: 30.5, width: 100, height: 6.5)))
        return [
            .solid(band, shirt.fill),
            .flat(band.intersection(Path(CGRect(x: 0, y: 32.9, width: 100, height: 1.7))), shirt == .cream ? Theme.rose : Theme.cream)
        ]
    }

    static var headphones: [Layer] {
        var band = Pen()
        band.move(22.5, 42)
        band.curve(20, 18, 34, 9, 50, 9)
        band.curve(66, 9, 80, 18, 77.5, 42)
        let cups = pair(Path(roundedRect: CGRect(x: 16.5, y: 37.5, width: 9.5, height: 15.5), cornerRadius: 4.5))
        return [
            .solid(Stack.outline(band.path, 4), Color(hex: 0x6E5D7E), 1.8),
            .solid(cups, Theme.rose),
            .flat(pair(oval(19.6, 42.5, 1.3, 2.8)), .white.opacity(0.7))
        ]
    }

    static var pillow: [Layer] {
        var pen = Pen()
        pen.move(3, 79)
        pen.curve(2, 66, 12, 59, 25, 60)
        pen.curve(38, 61, 47, 67, 47, 77)
        pen.curve(47, 87, 41, 91, 25, 91)
        pen.curve(10, 91, 4, 88, 3, 79)
        pen.close()
        var seam = Pen()
        seam.move(9, 66)
        seam.quad(12, 69, 11, 73)
        return [.solid(pen.path, .white), .ink(seam.path, 1.3, Theme.ink.opacity(0.3))]
    }

    static func blanket(_ shirt: ShirtColor) -> [Layer] {
        var pen = Pen()
        pen.move(57.5, 89.5)
        pen.line(57.5, 30)
        pen.curve(57.5, 27, 60, 25.5, 64, 25.5)
        pen.curve(70, 25.5, 75.5, 27, 80, 31)
        pen.curve(86, 36, 91, 45, 91.5, 57)
        pen.curve(92, 70, 91, 82, 89, 89.5)
        pen.close()
        let cover = pen.path
        var dots = Path()
        for (x, y) in [(71, 36), (82, 46), (73, 55), (86, 64), (71, 72), (82, 80)] as [(CGFloat, CGFloat)] {
            dots.addPath(HeartShape().path(in: CGRect(x: x - 2.6, y: y - 2.3, width: 5.2, height: 4.6)))
        }
        var folds = Pen()
        folds.move(73, 31)
        folds.quad(77, 46, 74, 58)
        folds.move(86, 50)
        folds.quad(84, 66, 86, 80)
        return [
            .solid(cover, shirt.fill),
            .flat(dots.intersection(cover), trim(shirt)),
            .ink(folds.path, 1.3, Theme.ink.opacity(0.25)),
            .solid(cover.intersection(Path(CGRect(x: 54, y: 20, width: 11, height: 75))), trim(shirt))
        ]
    }
}
