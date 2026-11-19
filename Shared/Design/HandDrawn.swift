import SwiftUI

struct Blob: Shape {
    var corner: CGFloat = 24
    var wobble: CGFloat = 0.9
    var seed: Int = 0

    func path(in r: CGRect) -> Path {
        let rad = min(corner, min(r.width, r.height) / 2)
        let straightW = max(r.width - 2 * rad, 0), straightH = max(r.height - 2 * rad, 0)
        let arc = CGFloat.pi * rad / 2
        let total = 2 * straightW + 2 * straightH + 4 * arc
        let count = max(40, Int(total / 5))
        let phases = (0..<3).map { Self.random(seed, $0) * .pi * 2 }
        let points = (0..<count).map { i -> CGPoint in
            let s = CGFloat(i) / CGFloat(count)
            let (p, n) = Self.walk(s * total, r, rad, straightW, straightH, arc)
            let t = s * .pi * 2
            let bump = wobble * (0.55 * sin(2 * t + phases[0]) + 0.3 * sin(3 * t + phases[1]) + 0.15 * sin(5 * t + phases[2]))
            return CGPoint(x: p.x + n.dx * bump, y: p.y + n.dy * bump)
        }
        var path = Path()
        path.move(to: points[0])
        for i in 0..<count {
            let p0 = points[(i - 1 + count) % count], p1 = points[i]
            let p2 = points[(i + 1) % count], p3 = points[(i + 2) % count]
            path.addCurve(to: p2,
                          control1: CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6),
                          control2: CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6))
        }
        path.closeSubpath()
        return path
    }

    private static func walk(_ d: CGFloat, _ r: CGRect, _ rad: CGFloat, _ w: CGFloat, _ h: CGFloat, _ arc: CGFloat) -> (CGPoint, CGVector) {
        var d = d
        func corner(_ cx: CGFloat, _ cy: CGFloat, _ start: CGFloat) -> (CGPoint, CGVector) {
            let a = start + (rad > 0 ? d / rad : 0)
            return (CGPoint(x: cx + rad * cos(a), y: cy + rad * sin(a)), CGVector(dx: cos(a), dy: sin(a)))
        }
        if d < w { return (CGPoint(x: r.minX + rad + d, y: r.minY), CGVector(dx: 0, dy: -1)) }
        d -= w
        if d < arc { return corner(r.maxX - rad, r.minY + rad, -.pi / 2) }
        d -= arc
        if d < h { return (CGPoint(x: r.maxX, y: r.minY + rad + d), CGVector(dx: 1, dy: 0)) }
        d -= h
        if d < arc { return corner(r.maxX - rad, r.maxY - rad, 0) }
        d -= arc
        if d < w { return (CGPoint(x: r.maxX - rad - d, y: r.maxY), CGVector(dx: 0, dy: 1)) }
        d -= w
        if d < arc { return corner(r.minX + rad, r.maxY - rad, .pi / 2) }
        d -= arc
        if d < h { return (CGPoint(x: r.minX, y: r.maxY - rad - d), CGVector(dx: -1, dy: 0)) }
        d -= h
        return corner(r.minX + rad, r.minY + rad, .pi)
    }

    static func random(_ seed: Int, _ salt: Int) -> CGFloat {
        let x = sin(Double(seed) * 12.9898 + Double(salt) * 78.233) * 43758.5453
        return CGFloat(x - x.rounded(.down))
    }
}

struct Sticker: ViewModifier {
    var fill: Color
    var lip: Color = Palette.ink
    var depth: CGFloat = 4
    var corner: CGFloat = 24
    var line: CGFloat = 2.5
    var seed: Int = 0

    func body(content: Content) -> some View {
        let shape = Blob(corner: corner, seed: seed)
        content.background {
            ZStack {
                if depth > 0 {
                    shape.fill(lip).offset(y: depth)
                    shape.stroke(Palette.ink, lineWidth: line).offset(y: depth)
                }
                shape.fill(fill)
                shape.stroke(Palette.ink, lineWidth: line)
            }
        }
    }
}

extension View {
    func sticker(_ fill: Color, lip: Color = Palette.ink, depth: CGFloat = 4, corner: CGFloat = 24, line: CGFloat = 2.5, seed: Int = 0) -> some View {
        modifier(Sticker(fill: fill, lip: lip, depth: depth, corner: corner, line: line, seed: seed))
    }
}
