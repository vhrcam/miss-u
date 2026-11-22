import SwiftUI

/// Concept A: little ink-drawn bean creatures with stick limbs, colored slightly off the line like
/// a hand-printed zine. Every couple is tied together by a red thread.
enum ThreadConcept {
    static let ink = Color(hex: 0x5A3934)
    static let paper = Color(hex: 0xFBF4EC)
    static let cream = Color(hex: 0xFFF3E4)
    static let ginger = Color(hex: 0xF1AC72)
    static let caramel = Color(hex: 0xDDA06A)
    static let muzzle = Color(hex: 0xF7E0C4)
    static let pink = Color(hex: 0xF3A99F)
    static let blush = Color(hex: 0xEE8A88)
    static let thread = Color(hex: 0xDC4157)
    static let mint = Color(hex: 0xA6D9C6)

    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

    // MARK: drawing helpers

    static func fill(_ c: GraphicsContext, _ pts: [CGPoint], _ color: Color, shift: CGSize = CGSize(width: 1, height: 1.3)) {
        c.fill(Pen.shape(pts).offsetBy(dx: shift.width, dy: shift.height), with: .color(color))
    }

    static func outline(_ c: GraphicsContext, _ pts: [CGPoint], width: CGFloat = 2.3, seed: Int = 0) {
        c.fill(Pen.ink(Pen.curve(pts), closed: true, width: width, seed: seed), with: .color(ink), style: FillStyle(eoFill: true))
    }

    static func shape(_ c: GraphicsContext, _ pts: [CGPoint], _ color: Color, width: CGFloat = 2.3, seed: Int = 0) {
        fill(c, pts, color)
        outline(c, pts, width: width, seed: seed)
    }

    static func line(_ c: GraphicsContext, _ pts: [CGPoint], width: CGFloat = 2.4, color: Color = ink, seed: Int = 0) {
        c.fill(Pen.ink(Pen.curve(pts, closed: false), closed: false, width: width, seed: seed), with: .color(color))
    }

    static func dot(_ c: GraphicsContext, _ p: CGPoint, _ r: CGFloat, _ color: Color = ink) {
        c.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)), with: .color(color))
    }

    static func eye(_ c: GraphicsContext, _ p: CGPoint, _ r: CGFloat = 2.5, look: CGPoint = .zero) {
        dot(c, p, r)
        dot(c, pt(p.x + r * 0.35 + look.x * 0.4, p.y - r * 0.4 + look.y * 0.4), r * 0.34, .white)
    }

    static func paw(_ c: GraphicsContext, _ p: CGPoint, _ r: CGFloat, _ color: Color) {
        let pts = (0..<8).map { i -> CGPoint in
            let a = CGFloat(i) / 8 * 2 * .pi
            return pt(p.x + r * cos(a), p.y + r * 0.92 * sin(a))
        }
        shape(c, pts, color, width: 1.9, seed: Int(p.x))
    }

    static func blushLines(_ c: GraphicsContext, _ place: Place, at p: CGPoint) {
        for k in 0..<3 {
            let x = p.x + CGFloat(k) * 2.6
            line(c, place([pt(x, p.y + 1.6), pt(x + 1.5, p.y - 1.6)]), width: 1.25, color: blush, seed: k)
        }
    }

    static func ground(_ c: GraphicsContext, _ center: CGPoint, _ width: CGFloat) {
        c.fill(Path(ellipseIn: CGRect(x: center.x - width / 2, y: center.y - 2.4, width: width, height: 4.8)), with: .color(ink.opacity(0.12)))
    }

    static func tail(_ c: GraphicsContext, _ anchors: [CGPoint], width: CGFloat, color: Color, tip: Color) {
        let spine = Pen.curve(anchors, closed: false, steps: 8)
        let outer = Pen.tube(spine, width: width, taper: 0.3)
        fill(c, outer, color)
        var t = c
        t.clip(to: Pen.polygon(outer).offsetBy(dx: 1, dy: 1.3))
        let cut = Int(Double(spine.count) * 0.68)
        t.fill(Pen.polygon(Pen.tube(Array(spine[cut...]), width: width * 1.6, taper: 0)).offsetBy(dx: 1, dy: 1.3), with: .color(tip))
        c.fill(Pen.ink(outer, closed: true, width: 2.1, seed: 9), with: .color(ink), style: FillStyle(eoFill: true))
    }

    static func threadLine(_ c: GraphicsContext, _ anchors: [CGPoint]) {
        c.stroke(Pen.polygon(Pen.curve(anchors, closed: false), closed: false), with: .color(thread),
                 style: StrokeStyle(lineWidth: 1.35, lineCap: .round, lineJoin: .round))
    }

    // MARK: the cat

    static let catBody: [CGPoint] = [pt(0, -42), pt(13, -41), pt(23, -33), pt(27, -18), pt(25, -2), pt(26, 14), pt(22, 28), pt(12, 38),
                                     pt(0, 41), pt(-12, 39), pt(-21, 30), pt(-24, 16), pt(-21, 2), pt(-24, -12), pt(-21, -28), pt(-12, -38)]
    static let catLeftEar: [CGPoint] = [pt(-21, -28), pt(-25, -43), pt(-29, -52), pt(-21, -54), pt(-7, -40)]
    static let catRightEar: [CGPoint] = [pt(5, -41), pt(15, -58), pt(21, -57), pt(25, -33)]

    static func cat(_ c: GraphicsContext, _ P: Place, face: (GraphicsContext, Place) -> Void, tailAnchors: [CGPoint], limbs: (GraphicsContext, Place) -> Void, front: (GraphicsContext, Place) -> Void) {
        tail(c, P(tailAnchors), width: 7.5, color: cream, tip: ginger)
        limbs(c, P)
        shape(c, P(catLeftEar), ginger, seed: 1)
        shape(c, P(catRightEar), cream, seed: 2)
        c.fill(Pen.shape(P([pt(9, -42), pt(15, -52), pt(20, -39)])), with: .color(pink))
        fill(c, P(catBody), cream)
        var spot = c
        spot.clip(to: Pen.shape(P(catBody)).offsetBy(dx: 1, dy: 1.3))
        spot.fill(Pen.shape(P([pt(-26, 4), pt(-14, -2), pt(-8, 8), pt(-13, 20), pt(-26, 22)])).offsetBy(dx: 1, dy: 1.3), with: .color(ginger))
        outline(c, P(catBody), seed: 3)
        face(c, P)
        front(c, P)
    }

    // MARK: the bear

    static let bearBody: [CGPoint] = [pt(0, -44), pt(16, -42), pt(29, -32), pt(36, -14), pt(37, 6), pt(33, 24), pt(22, 37), pt(8, 42),
                                      pt(-8, 42), pt(-22, 37), pt(-33, 24), pt(-37, 6), pt(-36, -14), pt(-29, -32), pt(-16, -42)]

    static func bearEars(_ c: GraphicsContext, _ P: Place) {
        for x: CGFloat in [-24, 24] {
            let ear = (0..<8).map { i -> CGPoint in
                let a = CGFloat(i) / 8 * 2 * .pi
                return pt(x + 8.5 * cos(a), -37 + 8 * sin(a))
            }
            shape(c, P(ear), caramel, seed: Int(x))
            c.fill(Pen.shape(P(ear.map { pt(x + ($0.x - x) * 0.5, -36 + ($0.y + 37) * 0.5) })), with: .color(pink.opacity(0.9)))
        }
    }

    // MARK: illustrations

    static let soloSize = CGSize(width: 150, height: 150)
    static let pairSize = CGSize(width: 210, height: 150)

    /// Curious and a little mischievous: up on its toes, batting at a dangling red thread.
    static func curious(_ c: inout GraphicsContext) {
        c.fill(Path(CGRect(origin: .zero, size: soloSize)), with: .color(paper))
        let P = Place(at: pt(68, 89), turn: 9)
        ground(c, pt(72, 140.5), 54)
        threadLine(c, [pt(132, -4), pt(128, 18), pt(121, 36), pt(116, 52), pt(110, 63), pt(104, 64)])
        cat(c, P, face: { c, P in
            eye(c, P(pt(4, -22)), look: pt(1, -1))
            eye(c, P(pt(17, -25)), look: pt(1, -1))
            line(c, P([pt(0, -30), pt(3, -31.5), pt(6.5, -31.2)]), width: 1.4)
            line(c, P([pt(13.5, -34), pt(16.5, -34.8), pt(20, -34)]), width: 1.4)
            c.fill(Pen.shape(P([pt(11.2, -16.5), pt(13.6, -16.8), pt(12.4, -15)])), with: .color(ink))
            let mouth = (0..<8).map { i -> CGPoint in
                let a = CGFloat(i) / 8 * 2 * .pi
                return pt(13 + 2.1 * cos(a), -10.5 + 2.5 * sin(a))
            }
            c.fill(Pen.shape(P(mouth)), with: .color(Color(hex: 0xC85A6A)))
            outline(c, P(mouth), width: 1.1, seed: 4)
            line(c, P([pt(24, -16), pt(28, -17), pt(33, -19)]), width: 1.1)
            line(c, P([pt(24, -11), pt(28, -11), pt(33, -10)]), width: 1.1)
            blushLines(c, P, at: pt(-6, -13))
        }, tailAnchors: [pt(-19, 28), pt(-29, 25), pt(-35, 15), pt(-35, 3), pt(-30, -4), pt(-25, -2)], limbs: { c, P in
            line(c, P([pt(-20, 4), pt(-26, 11), pt(-29, 15)]), width: 2.5)
            paw(c, P(pt(-29.5, 16)), 3.1, cream)
            line(c, P([pt(-6, 37), pt(-8, 44), pt(-10, 49.5)]), width: 2.5)
            line(c, P([pt(9, 36), pt(11, 43), pt(13, 48.5)]), width: 2.5)
            paw(c, P(pt(-10.8, 51)), 3.3, cream)
            paw(c, P(pt(13.6, 50.2)), 3.3, cream)
        }, front: { c, P in
            line(c, P([pt(22, -2), pt(30, -12), pt(36, -21)]), width: 2.5)
            paw(c, P(pt(37, -23.5)), 3.5, cream)
        })
    }

    /// Gentle and cozy: headphones on, eyes closed, snapping along to the music.
    static func listening(_ c: inout GraphicsContext) {
        c.fill(Path(CGRect(origin: .zero, size: soloSize)), with: .color(paper))
        let P = Place(at: pt(74, 88), turn: -6)
        ground(c, pt(74, 136), 80)
        threadLine(c, [P(pt(-21, 21)), pt(30, 114), pt(14, 120), pt(4, 117), pt(-6, 124)])
        bearEars(c, P)
        fill(c, P(bearBody), caramel)
        var belly = c
        belly.clip(to: Pen.shape(P(bearBody)).offsetBy(dx: 1, dy: 1.3))
        belly.fill(Pen.shape(P([pt(-18, 14), pt(0, 6), pt(18, 14), pt(20, 30), pt(0, 40), pt(-20, 30)])).offsetBy(dx: 1, dy: 1.3), with: .color(muzzle))
        outline(c, P(bearBody), seed: 5)
        shape(c, P([pt(-13, 1), pt(0, -7), pt(13, 1), pt(11, 10), pt(0, 13), pt(-11, 10)]), muzzle, width: 1.6, seed: 6)
        c.fill(Pen.shape(P([pt(-3.4, -2.6), pt(0, -4.4), pt(3.4, -2.6), pt(0, 0.6)])), with: .color(ink))
        line(c, P([pt(-3.4, 3.6), pt(-1.6, 5.4), pt(0, 3.8), pt(1.6, 5.4), pt(3.4, 3.6)]), width: 1.2)
        line(c, P([pt(-19, -11), pt(-15, -8), pt(-11, -11)]), width: 1.6)
        line(c, P([pt(11, -11), pt(15, -8), pt(19, -11)]), width: 1.6)
        blushLines(c, P, at: pt(-28, -1))
        blushLines(c, P, at: pt(22, -1))
        shape(c, P(Pen.tube(Pen.curve([pt(-37, -8), pt(-33, -33), pt(-17, -49), pt(0, -53), pt(17, -49), pt(33, -33), pt(37, -8)], closed: false, steps: 6), width: 5.5, taper: 0)), mint, width: 1.9, seed: 7)
        for x: CGFloat in [-40, 40] {
            shape(c, P([pt(x - 6, -16), pt(x + 6, -16), pt(x + 6.5, 0), pt(x, 3), pt(x - 6.5, 0)]), mint, width: 2, seed: Int(x) + 50)
        }
        line(c, P([pt(-34, 10), pt(-27, 17), pt(-22, 20)]), width: 2.6)
        paw(c, P(pt(-20.5, 21)), 4, caramel)
        line(c, P([pt(34, 5), pt(42, -4), pt(46, -14)]), width: 2.6)
        paw(c, P(pt(46.5, -16.5)), 4.1, caramel)
        for (x, s) in [(-15.0, 3), (15.0, 4)] {
            shape(c, P([pt(x - 9, 38), pt(x, 34), pt(x + 9, 38), pt(x + 8, 45), pt(x, 48), pt(x - 8, 45)]), caramel, width: 2.1, seed: s)
            c.fill(Path(ellipseIn: CGRect(origin: P(pt(x - 3, 40)), size: CGSize(width: 6, height: 4.5))), with: .color(pink))
        }
        note(c, at: pt(118, 46), turn: 12)
        note(c, at: pt(132, 28), turn: -8, scale: 0.8)
    }

    static func note(_ c: GraphicsContext, at p: CGPoint, turn: CGFloat, scale: CGFloat = 1) {
        let P = Place(at: p, turn: turn, scale: scale)
        let head = (0..<8).map { i -> CGPoint in
            let a = CGFloat(i) / 8 * 2 * .pi
            return pt(3.6 * cos(a), 2.7 * sin(a))
        }
        c.fill(Pen.shape(P(head)), with: .color(ink))
        line(c, P([pt(3.2, -0.5), pt(3.4, -8), pt(3.5, -15)]), width: 1.5)
        line(c, P([pt(3.5, -15), pt(7, -12.5), pt(9, -8.5)]), width: 1.5)
    }

    /// Tied together: the cat leans into the bear's hug, its tail curled around, a red thread knotted around them both.
    static func together(_ c: inout GraphicsContext) {
        c.fill(Path(CGRect(origin: .zero, size: pairSize)), with: .color(paper))
        let B = Place(at: pt(128, 90), turn: -8)
        let C = Place(at: pt(82, 95), turn: 14)
        ground(c, pt(106, 137), 120)

        // bear, behind
        bearEars(c, B)
        fill(c, B(bearBody), caramel)
        var belly = c
        belly.clip(to: Pen.shape(B(bearBody)).offsetBy(dx: 1, dy: 1.3))
        belly.fill(Pen.shape(B([pt(-18, 14), pt(0, 6), pt(18, 14), pt(20, 30), pt(0, 40), pt(-20, 30)])).offsetBy(dx: 1, dy: 1.3), with: .color(muzzle))
        outline(c, B(bearBody), seed: 5)
        shape(c, B([pt(-19, -1), pt(-7, -9), pt(5, -1), pt(3, 8), pt(-7, 11), pt(-17, 8)]), muzzle, width: 1.6, seed: 6)
        c.fill(Pen.shape(B([pt(-10.4, -4.6), pt(-7, -6.4), pt(-3.6, -4.6), pt(-7, -1.4)])), with: .color(ink))
        line(c, B([pt(-10, 2), pt(-7, 4.2), pt(-4, 2)]), width: 1.2)
        line(c, B([pt(-26, -13), pt(-22, -10), pt(-18, -13)]), width: 1.6)
        line(c, B([pt(2, -14), pt(6, -11), pt(10, -14)]), width: 1.6)
        blushLines(c, B, at: pt(12, -3))
        for (x, s) in [(-12.0, 3), (17.0, 4)] {
            shape(c, B([pt(x - 9, 38), pt(x, 34), pt(x + 9, 38), pt(x + 8, 45), pt(x, 48), pt(x - 8, 45)]), caramel, width: 2.1, seed: s)
        }
        line(c, B([pt(34, 6), pt(40, 14), pt(42, 22)]), width: 2.6)
        paw(c, B(pt(42.5, 24)), 4, caramel)
        line(c, [B(pt(-34, 2)), C(pt(14, -6)), C(pt(-6, -8)), C(pt(-20, -4))], width: 2.7)

        // cat, in front, leaning into the bear
        cat(c, C, face: { c, P in
            line(c, P([pt(1, -22), pt(4, -19.5), pt(7.5, -22)]), width: 1.5)
            line(c, P([pt(14, -24.5), pt(17, -22), pt(20.5, -24.5)]), width: 1.5)
            c.fill(Pen.shape(P([pt(10.6, -16.5), pt(13, -16.8), pt(11.8, -15)])), with: .color(ink))
            line(c, P([pt(9, -12.6), pt(10.6, -11), pt(12, -12.4), pt(13.4, -11), pt(15, -12.6)]), width: 1.1)
            line(c, P([pt(23, -15), pt(27, -16), pt(31, -18)]), width: 1.05)
            blushLines(c, P, at: pt(-6, -14))
            blushLines(c, P, at: pt(19, -17))
        }, tailAnchors: [pt(-19, 28), pt(-29, 25), pt(-35, 15), pt(-35, 3), pt(-30, -4), pt(-25, -2)], limbs: { c, P in
            line(c, P([pt(-6, 37), pt(-8, 44), pt(-9, 49)]), width: 2.5)
            line(c, P([pt(9, 36), pt(10, 43), pt(11, 48)]), width: 2.5)
            paw(c, P(pt(-9.6, 50.5)), 3.3, cream)
            paw(c, P(pt(11.6, 49.8)), 3.3, cream)
        }, front: { c, P in
            line(c, [P(pt(23, 8)), B(pt(-18, 16)), B(pt(-6, 22)), B(pt(2, 22))], width: 2.5)
            paw(c, B(pt(4, 22)), 3.4, cream)
        })

        // the bear's paw, around the cat's far shoulder
        paw(c, C(pt(-23, -3)), 4.2, caramel)

        // the red thread, knotted around them both
        threadLine(c, [C(pt(-25, 18)), C(pt(0, 24)), C(pt(22, 24)), B(pt(-18, 30)), B(pt(10, 32)), B(pt(36, 24))])
        threadLine(c, [B(pt(-24, 26)), B(pt(-20, 20)), B(pt(-15, 23)), B(pt(-20, 29)), B(pt(-24, 26)), B(pt(-30, 21)), B(pt(-27, 30)), B(pt(-21, 28))])
        threadLine(c, [B(pt(-21, 29)), B(pt(-22, 38)), B(pt(-18, 44))])
        threadLine(c, [B(pt(-20, 29)), B(pt(-12, 36)), B(pt(-10, 42))])
        shape(c, Pen.heart(pt(103, 30), 11), thread, width: 1.6, seed: 11)
    }
}
