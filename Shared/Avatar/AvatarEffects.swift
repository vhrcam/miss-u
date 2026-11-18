import SwiftUI

extension AvatarView {
    static func effects(_ activity: ActivityKind?, _ t: Double?) -> [Layer] {
        switch activity {
        case .sleeping:
            return (0..<3).map { i in
                let f = phase(t, 3.6, Double(i) / 3, still: (Double(i) + 0.5) / 3)
                let size = 4.5 + 6 * f
                return .solid(place(zee(size), 30 + 24 * f, 30 - 24 * f, pop(f)), .white, 1.4)
            }
        case .music:
            return [
                .flat(float(note, 13, 30, t, 2.8, 0), Theme.ink),
                .flat(float(notes, 84, 24, t, 2.8, 0.45), Theme.ink),
                .flat(float(note.applying(CGAffineTransform(scaleX: 0.7, y: 0.7)), 8, 56, t, 2.8, 0.75), Theme.ink)
            ]
        case .coffee:
            return (0..<2).map { i in
                let x: CGFloat = i == 0 ? 46 : 54
                let sway = CGFloat(t.map { sin($0 * 2.6 + Double(i) * 2) } ?? 0)
                var pen = Pen()
                pen.move(x, 63)
                pen.curve(x - 2.2 + sway, 61, x + 2.2 + sway, 59, x + sway * 0.6, 56.5)
                return .ink(pen.path, 1.8, Theme.ink.opacity(0.4))
            }
        case .missingYou:
            return [(19.0, 30.0, 8.0, 0.0), (81, 24, 10, 0.4), (86, 47, 6, 0.7)].map { x, y, s, o in
                .solid(float(HeartShape().path(in: CGRect(x: -s / 2, y: -s * 0.45, width: s, height: s * 0.9)), x, y, t, 3, o), Theme.rose, 1.5)
            }
        case .exercising:
            return [(19.0, 31.0, -25.0, 0.0), (26, 20, -15, 0.5), (75, 23, 20, 0.25)].map { x, y, tilt, o in
                let f = phase(t, 1.4, o, still: 0.5)
                let out = CGFloat(f - 0.5) * 6 * (x < 50 ? -1 : 1)
                let drop = sweat.applying(turn(tilt, 0, 0))
                return .solid(place(drop, x + out, y + CGFloat(f - 0.5) * 4, pop(f)), Color(hex: 0xA8DCFF), 1.4)
            }
        case .gaming:
            return sparkles([(14, 57, 12, 0), (87, 53, 9, 0.5)], t)
        case .shopping:
            return sparkles([(75, 54, 11, 0), (83, 43, 7, 0.5)], t)
        case .tv:
            let f = phase(t, 1.8, 0, still: 0.5)
            let x = 61 + 10 * f
            let y = 62 - 34 * f * (1 - f)
            return [.solid(place(circle(0, 0, 2.6).union(circle(2, -1.6, 2.2)).union(circle(-1.6, -1.8, 2)), x, y, pop(f)), Color(hex: 0xFFF3D2), 1.3)]
        default:
            return []
        }
    }

    static func phase(_ t: Double?, _ period: Double, _ offset: Double, still: Double) -> Double {
        guard let t else { return still }
        return (t / period + offset).truncatingRemainder(dividingBy: 1)
    }

    static func pop(_ f: Double) -> CGFloat {
        CGFloat(min(1, sin(f * .pi) * 2.2))
    }

    static func place(_ path: Path, _ x: CGFloat, _ y: CGFloat, _ scale: CGFloat) -> Path {
        path.applying(CGAffineTransform(translationX: x, y: y).scaledBy(x: max(scale, 0.01), y: max(scale, 0.01)))
    }

    static func float(_ path: Path, _ x: CGFloat, _ y: CGFloat, _ t: Double?, _ period: Double, _ offset: Double) -> Path {
        let f = phase(t, period, offset, still: 0.5)
        let sway = CGFloat(sin(f * 2 * .pi)) * 1.5
        return place(path, x + sway, y + CGFloat(0.5 - f) * 9, pop(f))
    }

    static func sparkles(_ spots: [(CGFloat, CGFloat, CGFloat, Double)], _ t: Double?) -> [Layer] {
        spots.map { x, y, s, o in
            let twinkle = t.map { 0.75 + 0.25 * CGFloat(sin(($0 / 1.2 + o) * 2 * .pi)) } ?? 1
            let star = SparkleShape().path(in: CGRect(x: -s / 2, y: -s / 2, width: s, height: s))
            return Layer(path: place(star, x, y, twinkle), fill: Color(hex: 0xFFD45C), stroke: Theme.ink, width: 1.3)
        }
    }

    static func zee(_ s: CGFloat) -> Path {
        let k = s * 0.3
        var pen = Pen()
        pen.move(0, 0)
        pen.line(s, 0)
        pen.line(s, k)
        pen.line(k * 1.1, s - k)
        pen.line(s, s - k)
        pen.line(s, s)
        pen.line(0, s)
        pen.line(0, s - k)
        pen.line(s - k * 1.1, k)
        pen.line(0, k)
        pen.close()
        return pen.path.offsetBy(dx: -s / 2, dy: -s / 2)
    }

    static var note: Path {
        var pen = Pen()
        pen.move(3.6, -11.5)
        pen.curve(5.6, -9.8, 8.6, -8.6, 7.4, -4.2)
        pen.curve(6.8, -6.6, 5.4, -7.7, 3.6, -8)
        pen.close()
        var path = pen.path
        path.addPath(oval(0, 0, 3.2, 2.4).applying(turn(-20, 0, 0)))
        path.addRect(CGRect(x: 1.9, y: -11.5, width: 1.7, height: 11.3))
        return path.offsetBy(dx: -2, dy: 5)
    }

    static var notes: Path {
        var pen = Pen()
        pen.move(1.9, -12.5)
        pen.line(12.6, -14.5)
        pen.line(12.6, -11)
        pen.line(1.9, -9)
        pen.close()
        var path = pen.path
        path.addPath(oval(0, 0, 3.2, 2.4).applying(turn(-20, 0, 0)))
        path.addPath(oval(9, -2, 3.2, 2.4).applying(turn(-20, 9, -2)))
        path.addRect(CGRect(x: 1.9, y: -12.5, width: 1.7, height: 12.3))
        path.addRect(CGRect(x: 10.9, y: -14.5, width: 1.7, height: 12.3))
        return path.offsetBy(dx: -6, dy: 6)
    }

    static var sweat: Path {
        var pen = Pen()
        pen.move(0, -4.5)
        pen.curve(2.6, -1.2, 3.3, 0.6, 3.3, 1.9)
        pen.curve(3.3, 3.9, 1.7, 5.2, 0, 5.2)
        pen.curve(-1.7, 5.2, -3.3, 3.9, -3.3, 1.9)
        pen.curve(-3.3, 0.6, -2.6, -1.2, 0, -4.5)
        pen.close()
        return pen.path
    }
}
