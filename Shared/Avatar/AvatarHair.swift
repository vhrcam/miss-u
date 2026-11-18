import SwiftUI

extension AvatarView {
    static var crown: Path {
        bodyPath.applying(grow(1.06, 1.06, 50, 60))
    }

    static func hairBack(_ style: HairStyle, _ color: Color, hatted: Bool) -> [Layer] {
        var pen = Pen()
        switch style {
        case .tuft where !hatted:
            pen.move(46.8, 19)
            pen.curve(46.3, 12, 51, 7, 58, 6)
            pen.curve(54.5, 8.5, 53.5, 12.5, 54.5, 19)
            pen.close()
            pen.move(45.5, 19.5)
            pen.curve(43, 15, 43.5, 11, 46, 9.5)
            pen.curve(46.6, 12.5, 48, 15.5, 49.5, 19)
            pen.close()
            return [.solid(pen.path.applying(grow(1.25, 1.25, 50, 19)), color)]
        case .bun where !hatted:
            var curl = Pen()
            curl.move(45.5, 12)
            curl.curve(46.5, 8, 53, 7.5, 54.5, 11.5)
            return [.solid(circle(50, 11.5, 8), color), .ink(curl.path, 1.6)]
        case .long:
            pen.move(50, 12)
            pen.curve(73, 12, 86, 33, 86, 56)
            pen.curve(86, 68, 87, 75, 90, 81)
            pen.curve(85, 82.5, 80, 81.5, 77, 78)
            pen.line(23, 78)
            pen.curve(20, 81.5, 15, 82.5, 10, 81)
            pen.curve(13, 75, 14, 68, 14, 56)
            pen.curve(14, 33, 27, 12, 50, 12)
            pen.close()
        default:
            return []
        }
        return [.solid(pen.path, color)]
    }

    static func hairFront(_ style: HairStyle, _ color: Color) -> [Layer] {
        var pen = Pen()
        pen.move(0, 0)
        pen.line(100, 0)
        switch style {
        case .none, .tuft:
            return []
        case .swoop:
            pen.line(100, 27)
            pen.line(84, 27)
            pen.curve(68, 28.5, 52, 31, 40, 37)
            pen.curve(32, 41, 26, 46, 14, 50)
            pen.line(0, 50)
        case .bob, .long:
            let end: CGFloat = style == .bob ? 57 : 62
            pen.line(100, end)
            pen.line(82, end)
            pen.curve(76, end, 72.5, end - 2.5, 72.5, end - 7)
            pen.line(72, 33.5)
            pen.curve(64.5, 36, 57.5, 36, 50, 33.5)
            pen.curve(42.5, 36, 35.5, 36, 28, 33.5)
            pen.line(27.5, end - 7)
            pen.curve(27.5, end - 2.5, 24, end, 18, end)
            pen.line(0, end)
        case .bun:
            pen.line(100, 42)
            pen.line(82, 42)
            pen.curve(70, 30, 60, 27, 50, 27)
            pen.curve(40, 27, 30, 30, 18, 42)
            pen.line(0, 42)
        }
        pen.close()
        return [.solid(crown.intersection(pen.path), color)]
    }
}
