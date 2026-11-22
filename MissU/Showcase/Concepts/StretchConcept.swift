import SwiftUI

/// Concept C: stretchy animals in one clean, warm line. When they miss someone they stretch,
/// so a hug can wrap all the way around.
enum StretchConcept {
    static let paper = Color(hex: 0xFFF7EC)
    static let lilac = Color(hex: 0xD5C6EC)
    static let lilacShade = Color(hex: 0xBBA7DE)
    static let plum = Color(hex: 0x5D3760)
    static let butter = Color(hex: 0xF7D489)
    static let butterShade = Color(hex: 0xE8B95E)
    static let rust = Color(hex: 0x86462A)
    static let coral = Color(hex: 0xF0877A)
    static let pink = Color(hex: 0xF5ABB0)
    static let cover = Color(hex: 0x86BFA9)
    static let page = Color(hex: 0xFFFBF3)

    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

    /// Draws with concept A's brush instead of the even line.
    nonisolated(unsafe) static var inked = false

    static func oval(_ c: CGPoint, _ rx: CGFloat, _ ry: CGFloat, turn: CGFloat = 0, n: Int = 12) -> [CGPoint] {
        let a0 = turn * .pi / 180
        return (0..<n).map { i in
            let a = CGFloat(i) / CGFloat(n) * 2 * .pi
            let x = rx * cos(a), y = ry * sin(a)
            return pt(c.x + x * cos(a0) - y * sin(a0), c.y + x * sin(a0) + y * cos(a0))
        }
    }

    /// Flat color, one crisp shadow shape on the side away from the light, and a single even line.
    static func part(_ c: GraphicsContext, _ outline: [CGPoint], _ fill: Color, shade: Color?, line: Color, width: CGFloat = 2.3, smooth: Bool = true) {
        let path = smooth ? Pen.shape(outline) : Pen.polygon(outline)
        if inked {
            c.fill(path.offsetBy(dx: 1, dy: 1.3), with: .color(fill))
            if let shade {
                var s = c
                s.clip(to: path.offsetBy(dx: 1, dy: 1.3))
                s.drawLayer { l in
                    l.fill(path.offsetBy(dx: 1, dy: 1.3), with: .color(shade.opacity(0.7)))
                    l.blendMode = .destinationOut
                    l.fill(path.offsetBy(dx: -1.6, dy: -2.3), with: .color(.black))
                }
            }
            let pts = smooth ? Pen.curve(outline) : outline
            c.fill(Pen.ink(pts, closed: true, width: width * 1.05, seed: Int(outline.first?.x ?? 0)), with: .color(line), style: FillStyle(eoFill: true))
            return
        }
        c.fill(path, with: .color(fill))
        if let shade {
            var s = c
            s.clip(to: path)
            s.drawLayer { l in
                l.fill(path, with: .color(shade))
                l.blendMode = .destinationOut
                l.fill(path.offsetBy(dx: -2.6, dy: -3.6), with: .color(.black))
            }
        }
        c.stroke(path, with: .color(line), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    static func stroke(_ c: GraphicsContext, _ anchors: [CGPoint], _ color: Color, width: CGFloat = 2.1) {
        c.stroke(Pen.polygon(Pen.curve(anchors, closed: false, steps: 6), closed: false), with: .color(color),
                 style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    static func freckles(_ c: GraphicsContext, _ at: CGPoint) {
        for (dx, dy) in [(-1.8, 0.0), (0.0, 1.4), (1.8, 0.0)] {
            c.fill(Path(ellipseIn: CGRect(x: at.x + dx - 0.75, y: at.y + dy - 0.75, width: 1.5, height: 1.5)), with: .color(coral))
        }
    }

    static func ground(_ c: GraphicsContext, _ y: CGFloat, from x0: CGFloat, to x1: CGFloat) {
        c.fill(Path(roundedRect: CGRect(x: x0, y: y - 1.6, width: x1 - x0, height: 3.2), cornerRadius: 1.6), with: .color(plum.opacity(0.12)))
    }

    static let soloSize = CGSize(width: 150, height: 150)
    static let pairSize = CGSize(width: 210, height: 150)

    static func catHead(_ c: GraphicsContext, _ P: Place, face: (GraphicsContext, Place) -> Void) {
        part(c, P([pt(-13, -6), pt(-16, -22), pt(-4, -12)]), lilac, shade: nil, line: plum, smooth: false)
        part(c, P([pt(4, -12), pt(15, -23), pt(13, -5)]), lilac, shade: nil, line: plum, smooth: false)
        c.fill(Pen.polygon(P([pt(-12, -9), pt(-13.5, -18), pt(-7, -12)])), with: .color(pink))
        c.fill(Pen.polygon(P([pt(7, -12), pt(12.5, -18.5), pt(11, -9)])), with: .color(pink))
        part(c, P([pt(0, -14), pt(12, -11), pt(17, 0), pt(13, 10), pt(0, 13), pt(-13, 10), pt(-17, 0), pt(-12, -11)]), lilac, shade: lilacShade, line: plum)
        face(c, P)
    }

    /// The big morning stretch, front paws out and tail up.
    static func stretch(_ c: inout GraphicsContext) {
        c.fill(Path(CGRect(origin: .zero, size: soloSize)), with: .color(paper))
        ground(c, 134, from: 12, to: 138)
        let tail = Pen.tube(Pen.curve([pt(112, 76), pt(121, 60), pt(126, 44), pt(122, 32), pt(115, 31)], closed: false, steps: 6), width: 6.5, taper: 0.35)
        part(c, tail, lilac, shade: lilacShade, line: plum, smooth: false)
        for x: CGFloat in [101, 113] {
            let leg = Pen.tube(Pen.curve([pt(x + 1, 84), pt(x, 108), pt(x - 1, 130)], closed: false, steps: 6), width: 7, taper: 0)
            part(c, leg, lilac, shade: lilacShade, line: plum, smooth: false)
        }
        let body = Pen.tube(Pen.curve([pt(46, 112), pt(64, 105), pt(84, 93), pt(103, 82), pt(113, 78)], closed: false, steps: 8)) { t in
            15 + 4 * sin(.pi * t) + 4 * max(0, t - 0.7)
        }
        part(c, body, lilac, shade: lilacShade, line: plum, smooth: false)
        for (y, x) in [(131.0, 18.0), (133.0, 30.0)] {
            let leg = Pen.tube(Pen.curve([pt(50, 112), pt(36, 121), pt(x + 4, y - 1)], closed: false, steps: 6), width: 6.8, taper: 0)
            part(c, leg, lilac, shade: lilacShade, line: plum, smooth: false)
            part(c, oval(pt(x, y), 5.4, 3.4), lilac, shade: nil, line: plum)
        }
        for x: CGFloat in [99, 112] {
            part(c, oval(pt(x, 131.5), 5.2, 3.2), lilac, shade: nil, line: plum)
        }
        catHead(c, Place(at: pt(36, 104), turn: -18)) { c, P in
            stroke(c, P([pt(-9, -2), pt(-6, -0.5), pt(-3.5, -2.6)]), plum, width: 1.6)
            stroke(c, P([pt(3.5, -2.6), pt(6, -0.5), pt(9, -2)]), plum, width: 1.6)
            part(c, P(oval(pt(0, 5.2), 3.6, 4.4)), Color(hex: 0x8E4A6A), shade: nil, line: plum, width: 1.5)
            c.fill(Pen.shape(P(oval(pt(0, 7.4), 2.2, 1.6))), with: .color(pink))
            freckles(c, P(pt(-10, 3)))
            freckles(c, P(pt(10, 3)))
        }
        stroke(c, [pt(16, 88), pt(12, 84)], plum.opacity(0.6), width: 1.4)
        stroke(c, [pt(20, 84), pt(19, 79)], plum.opacity(0.6), width: 1.4)
    }

    static func bearHead(_ c: GraphicsContext, _ P: Place, face: (GraphicsContext, Place) -> Void) {
        for x: CGFloat in [-13, 13] {
            part(c, P(oval(pt(x, -13), 6, 5.6)), butter, shade: nil, line: rust)
            c.fill(Pen.shape(P(oval(pt(x, -12.6), 2.8, 2.6))), with: .color(pink))
        }
        part(c, P([pt(0, -16), pt(14, -12), pt(19, 1), pt(14, 13), pt(0, 16), pt(-14, 13), pt(-19, 1), pt(-14, -12)]), butter, shade: butterShade, line: rust)
        part(c, P(oval(pt(0, 6), 7.5, 5.2)), Color(hex: 0xFCEBC4), shade: nil, line: rust, width: 1.6)
        c.fill(Pen.shape(P(oval(pt(0, 3.6), 2.4, 1.6))), with: .color(rust))
        face(c, P)
    }

    /// Reading on its belly, feet kicked up, glasses on.
    static func reading(_ c: inout GraphicsContext) {
        c.fill(Path(CGRect(origin: .zero, size: soloSize)), with: .color(paper))
        ground(c, 133, from: 14, to: 140)
        for (x, y, s) in [(120.0, 92.0, -18.0), (131.0, 98.0, 8.0)] {
            let leg = Pen.tube(Pen.curve([pt(106, 118), pt((106 + x) / 2 + 2, (118 + y) / 2), pt(x, y)], closed: false, steps: 6), width: 9.5, taper: 0)
            part(c, leg, butter, shade: butterShade, line: rust, smooth: false)
            part(c, oval(pt(x, y), 6, 5, turn: s), butter, shade: nil, line: rust)
            c.fill(Pen.shape(oval(pt(x, y), 3, 2.5, turn: s)), with: .color(pink))
        }
        part(c, [pt(50, 102), pt(76, 98), pt(100, 101), pt(115, 108), pt(116, 121), pt(104, 130), pt(74, 132), pt(50, 130), pt(40, 118)], butter, shade: butterShade, line: rust)
        part(c, [pt(10, 131), pt(15, 119), pt(32, 116), pt(33, 128)], cover, shade: nil, line: rust)
        part(c, [pt(33, 128), pt(34, 116), pt(52, 119), pt(56, 131)], cover, shade: nil, line: rust)
        part(c, [pt(13, 128), pt(17, 120), pt(31, 118), pt(31.5, 126)], page, shade: nil, line: rust, width: 1.3)
        part(c, [pt(35, 126), pt(35.5, 118), pt(50, 120), pt(53, 128)], page, shade: nil, line: rust, width: 1.3)
        for (k, x) in [(0, 22.0), (1, 46.0)] {
            let arm = Pen.tube(Pen.curve([pt(50 + CGFloat(k) * 6, 112), pt(x + 6, 117), pt(x, 119)], closed: false, steps: 6), width: 7.5, taper: 0)
            part(c, arm, butter, shade: butterShade, line: rust, smooth: false)
            part(c, oval(pt(x, 119), 4.6, 3.8), butter, shade: nil, line: rust)
        }
        bearHead(c, Place(at: pt(38, 94), turn: 10)) { c, P in
            for x: CGFloat in [-6.5, 6.5] {
                c.stroke(Path(ellipseIn: CGRect(origin: P(pt(x - 4.2, -4.6)), size: CGSize(width: 8.4, height: 8.4))), with: .color(rust), lineWidth: 1.3)
                c.fill(Path(ellipseIn: CGRect(origin: P(pt(x - 1.1, -0.4)), size: CGSize(width: 2.2, height: 2.6))), with: .color(rust))
            }
            stroke(c, P([pt(-2.2, -1), pt(0, -2), pt(2.2, -1)]), rust, width: 1.2)
            stroke(c, P([pt(-2.4, 7.6), pt(0, 9), pt(2.4, 7.6)]), rust, width: 1.3)
            freckles(c, P(pt(-12, 5)))
            freckles(c, P(pt(12, 5)))
        }
    }

    /// The cat stretches all the way around the bear, its long body making a heart.
    static func together(_ c: inout GraphicsContext) {
        c.fill(Path(CGRect(origin: .zero, size: pairSize)), with: .color(paper))
        ground(c, 140, from: 40, to: 172)
        // the bear inside the heart
        part(c, oval(pt(106, 108), 24, 25), butter, shade: butterShade, line: rust)
        part(c, oval(pt(106, 116), 13, 11), Color(hex: 0xFCEBC4), shade: nil, line: rust, width: 1.6)
        for x: CGFloat in [94, 118] {
            part(c, oval(pt(x, 133), 7, 5), butter, shade: nil, line: rust)
        }
        bearHead(c, Place(at: pt(106, 74), turn: -6, scale: 1.2)) { c, P in
            stroke(c, P([pt(-9.5, -1.5), pt(-7, 0.8), pt(-4.5, -1.5)]), rust, width: 1.5)
            stroke(c, P([pt(4.5, -1.5), pt(7, 0.8), pt(9.5, -1.5)]), rust, width: 1.5)
            stroke(c, P([pt(-2.6, 7.4), pt(0, 9.2), pt(2.6, 7.4)]), rust, width: 1.3)
            freckles(c, P(pt(-12, 4)))
            freckles(c, P(pt(12, 4)))
        }
        // the cat's long body, around the bear in a heart
        let spine = Pen.curve([pt(80, 66), pt(70, 44), pt(54, 32), pt(38, 40), pt(32, 62), pt(46, 90), pt(74, 116), pt(106, 138),
                               pt(138, 116), pt(166, 88), pt(178, 60), pt(170, 36), pt(150, 30), pt(136, 42)], closed: false, steps: 8)
        let body = Pen.tube(spine) { t in t < 0.86 ? 14 : 14 - (t - 0.86) / 0.14 * 7 }
        part(c, body, lilac, shade: lilacShade, line: plum, smooth: false)
        for (x, y) in [(70.0, 106.0), (142.0, 106.0)] {
            part(c, oval(pt(x, y), 6.5, 5.5), butter, shade: nil, line: rust)
        }
        catHead(c, Place(at: pt(80, 70), turn: 18, scale: 1.15)) { c, P in
            stroke(c, P([pt(-8.5, -1), pt(-6, 1.2), pt(-3.5, -1)]), plum, width: 1.5)
            stroke(c, P([pt(3.5, -1), pt(6, 1.2), pt(8.5, -1)]), plum, width: 1.5)
            stroke(c, P([pt(-2.6, 5), pt(-1.3, 6.4), pt(0, 5.2), pt(1.3, 6.4), pt(2.6, 5)]), plum, width: 1.2)
            freckles(c, P(pt(-10, 3)))
            freckles(c, P(pt(10, 3)))
        }
    }
}
