import SwiftUI

/// Concept B: keepsake characters cut from felt and sewn by hand. Faces are embroidered,
/// and a couple is literally sewn together with a heart patch.
enum FeltConcept {
    static let linen = Color(hex: 0xF4ECE2)
    static let rose = Color(hex: 0xE3A098)
    static let cream = Color(hex: 0xFFF0DF)
    static let toffee = Color(hex: 0xC4895B)
    static let oat = Color(hex: 0xF0D9BC)
    static let sky = Color(hex: 0x93C2D8)
    static let heartRed = Color(hex: 0xDE4F5D)
    static let pinkFelt = Color(hex: 0xF2A6A6)
    static let lightThread = Color(hex: 0xFFF8EE)
    static let darkThread = Color(hex: 0x553429)

    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

    static func oval(_ c: CGPoint, _ rx: CGFloat, _ ry: CGFloat, n: Int = 12) -> [CGPoint] {
        (0..<n).map { i in
            let a = CGFloat(i) / CGFloat(n) * 2 * .pi
            return pt(c.x + rx * cos(a), c.y + ry * sin(a))
        }
    }

    /// A felt piece: hand-cut edge, fibers, an optional running stitch, and a little thickness.
    static func piece(_ c: GraphicsContext, _ anchors: [CGPoint], _ color: Color, thread: Color? = nil, seed: Int, inset: CGFloat = 2.2, lift: Bool = true) {
        let pts = Pen.cut(Pen.curve(anchors, steps: 8), amount: 0.4, seed: seed)
        let path = Pen.polygon(pts)
        var layer = c
        if lift { layer.addFilter(.shadow(color: Color(hex: 0x3B2418).opacity(0.24), radius: 1.1, x: 0.4, y: 1)) }
        layer.drawLayer { l in
            l.fill(path, with: .color(color))
            var f = l
            f.clip(to: path)
            let box = path.boundingRect
            for i in 0..<Int(box.width * box.height / 14) {
                let h = Pen.noise(i * 7 + seed, seed + i) * 0.5 + 0.5
                let k = Pen.noise(i * 13 + 3, seed * 2 + i) * 0.5 + 0.5
                let x = box.minX + CGFloat((i * 37 + seed * 11) % 97) / 97 * box.width
                let y = box.minY + CGFloat((i * 59 + seed * 7) % 89) / 89 * box.height
                var hair = Path()
                hair.move(to: pt(x, y))
                hair.addLine(to: pt(x + (h - 0.5) * 2.2, y + (k - 0.5) * 2.2))
                f.stroke(hair, with: .color((i % 2 == 0 ? Color.white : Color.black).opacity(0.07)), lineWidth: 0.5)
            }
            if let thread {
                l.stroke(Pen.polygon(Pen.inset(pts, by: inset)), with: .color(thread),
                         style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2, 1.5]))
            }
        }
    }

    static func stitch(_ c: GraphicsContext, _ anchors: [CGPoint], _ color: Color = darkThread, width: CGFloat = 1.15, dash: [CGFloat] = [1.6, 0.55]) {
        c.stroke(Pen.polygon(Pen.curve(anchors, closed: false, steps: 6), closed: false), with: .color(color),
                 style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round, dash: dash))
    }

    static func satinEye(_ c: GraphicsContext, _ p: CGPoint, _ w: CGFloat = 2.3, _ h: CGFloat = 2.9) {
        c.fill(Path(ellipseIn: CGRect(x: p.x - w, y: p.y - h, width: w * 2, height: h * 2)), with: .color(darkThread))
        for k in -1...1 {
            var s = Path()
            s.move(to: pt(p.x - w * 0.8, p.y + CGFloat(k) * h * 0.45 - 0.6))
            s.addLine(to: pt(p.x + w * 0.8, p.y + CGFloat(k) * h * 0.45 + 0.6))
            c.stroke(s, with: .color(.black.opacity(0.18)), lineWidth: 0.4)
        }
        var shine = Path()
        shine.move(to: pt(p.x + w * 0.2, p.y - h * 0.55))
        shine.addLine(to: pt(p.x + w * 0.55, p.y - h * 0.2))
        c.stroke(shine, with: .color(lightThread), style: StrokeStyle(lineWidth: 0.9, lineCap: .round))
    }

    static func crossStitches(_ c: GraphicsContext, _ center: CGPoint, _ color: Color, count: Int, spread: CGFloat) {
        for i in 0..<count {
            let a = CGFloat(i) / CGFloat(count) * 2 * .pi
            let p = pt(center.x + cos(a) * spread, center.y + sin(a) * spread * 0.85)
            var x = Path()
            x.move(to: pt(p.x - 1, p.y - 1)); x.addLine(to: pt(p.x + 1, p.y + 1))
            x.move(to: pt(p.x + 1, p.y - 1)); x.addLine(to: pt(p.x - 1, p.y + 1))
            c.stroke(x, with: .color(color), style: StrokeStyle(lineWidth: 0.8, lineCap: .round))
        }
    }

    static func ground(_ c: GraphicsContext, _ center: CGPoint, _ width: CGFloat) {
        var g = c
        g.addFilter(.blur(radius: 2.5))
        g.drawLayer { l in l.fill(Path(ellipseIn: CGRect(x: center.x - width / 2, y: center.y - 3, width: width, height: 6)), with: .color(Color(hex: 0x3B2418).opacity(0.18))) }
    }

    static let soloSize = CGSize(width: 150, height: 150)
    static let pairSize = CGSize(width: 210, height: 150)

    // MARK: cat

    static func catHead(_ c: GraphicsContext, _ P: Place, wink: Bool, content: Bool = false) {
        piece(c, P([pt(-27, -6), pt(-25, -27), pt(-14, -14)]), rose, seed: 21)
        piece(c, P([pt(14, -14), pt(25, -28), pt(28, -6)]), rose, seed: 22)
        piece(c, P([pt(-23, -9), pt(-22, -21), pt(-16, -13)]), cream, seed: 23, lift: false)
        piece(c, P([pt(16, -13), pt(22, -22), pt(24, -9)]), cream, seed: 24, lift: false)
        piece(c, P(oval(pt(0, 0), 29, 21, n: 14)), rose, thread: lightThread, seed: 25)
        piece(c, P(oval(pt(0, 8.5), 9.5, 6.5)), cream, seed: 26, lift: false)
        piece(c, P(oval(pt(-17, 6), 4.2, 3.2, n: 8)), pinkFelt, seed: 27, lift: false)
        piece(c, P(oval(pt(17, 6), 4.2, 3.2, n: 8)), pinkFelt, seed: 28, lift: false)
        if content {
            stitch(c, P([pt(-13, 0), pt(-10, 2.4), pt(-6.5, 0)]), width: 1.5, dash: [])
            stitch(c, P([pt(6.5, 0), pt(10, 2.4), pt(13, 0)]), width: 1.5, dash: [])
        } else {
            satinEye(c, P(pt(-9.5, -0.5)))
            if wink {
                stitch(c, P([pt(6.5, 0.6), pt(9.8, -2.6), pt(13, 0.6)]), width: 1.5, dash: [])
            } else {
                satinEye(c, P(pt(9.5, -0.5)))
            }
        }
        c.fill(Pen.shape(P([pt(-2, 4.6), pt(2, 4.6), pt(0, 6.8)])), with: .color(Color(hex: 0xB8616A)))
        stitch(c, P([pt(-3.4, 9.2), pt(-1.6, 10.6), pt(0, 9.2), pt(1.6, 10.6), pt(3.4, 9.2)]))
        for s: CGFloat in [-1, 1] {
            stitch(c, P([pt(s * 21, 9), pt(s * 27, 8.2)]), lightThread, width: 0.8, dash: [])
            stitch(c, P([pt(s * 21, 12), pt(s * 27, 12.6)]), lightThread, width: 0.8, dash: [])
        }
    }

    /// Waving hello with a wink.
    static func waving(_ c: inout GraphicsContext) {
        c.fill(Path(CGRect(origin: .zero, size: soloSize)), with: .color(linen))
        ground(c, pt(76, 136), 62)
        let tailSpine = Pen.curve([pt(94, 122), pt(110, 121), pt(119, 108), pt(118, 92)], closed: false, steps: 6)
        piece(c, Pen.tube(tailSpine, width: 8.5, taper: 0.15), rose, thread: lightThread, seed: 31, inset: 1.8)
        piece(c, [pt(56, 122), pt(67, 122), pt(67, 137), pt(56, 137)], rose, thread: lightThread, seed: 32, inset: 1.6)
        piece(c, [pt(80, 122), pt(91, 122), pt(91, 137), pt(80, 137)], rose, thread: lightThread, seed: 33, inset: 1.6)
        piece(c, [pt(52, 92), pt(43, 104), pt(46, 113), pt(55, 104)], rose, thread: lightThread, seed: 34, inset: 1.6)
        piece(c, [pt(55, 84), pt(94, 84), pt(101, 107), pt(97, 126), pt(75, 131), pt(52, 126), pt(48, 107)], rose, thread: lightThread, seed: 35)
        piece(c, [pt(65, 98), pt(85, 98), pt(89, 112), pt(75, 122), pt(61, 112)], cream, thread: Color(hex: 0xE6A79F), seed: 36, inset: 1.8)
        piece(c, Pen.heart(pt(75, 108), 9), heartRed, seed: 37, lift: false)
        crossStitches(c, pt(75, 108), lightThread, count: 1, spread: 0)
        piece(c, [pt(93, 92), pt(103, 70), pt(110, 63), pt(117, 69), pt(103, 97)], rose, thread: lightThread, seed: 38, inset: 1.6)
        catHead(c, Place(at: pt(72, 62), turn: -9), wink: true)
    }

    // MARK: bear

    static func bearHead(_ c: GraphicsContext, _ P: Place, eyes: String) {
        for x: CGFloat in [-22, 22] {
            piece(c, P(oval(pt(x, -18), 9.5, 9, n: 10)), toffee, thread: lightThread, seed: Int(x) + 40, inset: 1.8)
            piece(c, P(oval(pt(x, -17.5), 4.6, 4.3, n: 8)), oat, seed: Int(x) + 44, lift: false)
        }
        piece(c, P(oval(pt(0, 0), 30, 23, n: 14)), toffee, thread: lightThread, seed: 46)
        piece(c, P(oval(pt(0, 8), 11, 8, n: 12)), oat, thread: Color(hex: 0xC9A27A), seed: 47, inset: 1.6)
        c.fill(Pen.shape(P(oval(pt(0, 4.8), 3.4, 2.4, n: 8))), with: .color(darkThread))
        stitch(c, P([pt(0, 7), pt(0, 9.4)]))
        stitch(c, P([pt(-3.6, 9.6), pt(0, 11.6), pt(3.6, 9.6)]))
        piece(c, P(oval(pt(-18, 5), 4.4, 3.2, n: 8)), pinkFelt, seed: 48, lift: false)
        piece(c, P(oval(pt(18, 5), 4.4, 3.2, n: 8)), pinkFelt, seed: 49, lift: false)
        if eyes == "content" {
            stitch(c, P([pt(-13, -2), pt(-10, 0.6), pt(-6.6, -2)]), width: 1.5, dash: [])
            stitch(c, P([pt(6.6, -2), pt(10, 0.6), pt(13, -2)]), width: 1.5, dash: [])
        } else {
            satinEye(c, P(pt(-10, -2)))
            satinEye(c, P(pt(10, -2)))
        }
    }

    /// Warming its paws on a mug of cocoa.
    static func cocoa(_ c: inout GraphicsContext) {
        c.fill(Path(CGRect(origin: .zero, size: soloSize)), with: .color(linen))
        ground(c, pt(75, 139), 74)
        piece(c, [pt(50, 122), pt(66, 121), pt(66, 139), pt(50, 139)], toffee, thread: lightThread, seed: 51, inset: 1.6)
        piece(c, [pt(84, 121), pt(100, 122), pt(100, 139), pt(84, 139)], toffee, thread: lightThread, seed: 52, inset: 1.6)
        piece(c, [pt(52, 84), pt(98, 84), pt(108, 110), pt(102, 131), pt(75, 137), pt(48, 131), pt(42, 110)], toffee, thread: lightThread, seed: 53)
        piece(c, [pt(60, 104), pt(90, 104), pt(94, 120), pt(75, 130), pt(56, 120)], oat, thread: Color(hex: 0xC9A27A), seed: 54, inset: 1.8)
        let handle = Pen.tube(Pen.curve([pt(86, 100), pt(94, 101), pt(95, 110), pt(87, 113)], closed: false, steps: 6), width: 4, taper: 0)
        piece(c, handle, sky, seed: 55)
        piece(c, [pt(62, 95), pt(88, 95), pt(87, 117), pt(75, 120), pt(63, 117)], sky, thread: lightThread, seed: 56, inset: 1.8)
        crossStitches(c, pt(75, 107), lightThread, count: 1, spread: 0)
        stitch(c, Pen.heart(pt(75, 107), 7) + [Pen.heart(pt(75, 107), 7)[0]], lightThread, width: 0.9, dash: [1.2, 0.6])
        piece(c, [pt(52, 92), pt(46, 104), pt(58, 112), pt(66, 104)], toffee, thread: lightThread, seed: 57, inset: 1.6)
        piece(c, [pt(98, 92), pt(104, 104), pt(92, 112), pt(84, 104)], toffee, thread: lightThread, seed: 58, inset: 1.6)
        stitch(c, [pt(70, 90), pt(67, 84), pt(71, 78), pt(68, 72)], lightThread, width: 1.3, dash: [1.4, 1])
        stitch(c, [pt(80, 90), pt(77, 83), pt(81, 77), pt(78, 70)], lightThread, width: 1.3, dash: [1.4, 1])
        bearHead(c, Place(at: pt(75, 58), turn: 4), eyes: "content")
    }

    /// Sewn together: cheek to cheek, the bear's arm over the cat's shoulder and one heart patch stitched across them both.
    static func together(_ c: inout GraphicsContext) {
        c.fill(Path(CGRect(origin: .zero, size: pairSize)), with: .color(linen))
        ground(c, pt(106, 138), 130)
        // bear, behind on the right
        piece(c, [pt(118, 122), pt(134, 121), pt(134, 138), pt(118, 138)], toffee, thread: lightThread, seed: 61, inset: 1.6)
        piece(c, [pt(146, 121), pt(160, 122), pt(160, 138), pt(146, 138)], toffee, thread: lightThread, seed: 62, inset: 1.6)
        piece(c, [pt(118, 86), pt(160, 86), pt(170, 110), pt(164, 131), pt(140, 136), pt(114, 130), pt(108, 108)], toffee, thread: lightThread, seed: 63)
        piece(c, [pt(160, 94), pt(170, 104), pt(164, 114), pt(156, 104)], toffee, thread: lightThread, seed: 64, inset: 1.6)
        bearHead(c, Place(at: pt(136, 62), turn: -12), eyes: "content")
        // cat, in front on the left
        let tailSpine = Pen.curve([pt(64, 124), pt(48, 124), pt(40, 110), pt(44, 96)], closed: false, steps: 6)
        piece(c, Pen.tube(tailSpine, width: 8.5, taper: 0.15), rose, thread: lightThread, seed: 65, inset: 1.8)
        piece(c, [pt(68, 122), pt(79, 122), pt(79, 138), pt(68, 138)], rose, thread: lightThread, seed: 66, inset: 1.6)
        piece(c, [pt(90, 122), pt(101, 122), pt(101, 138), pt(90, 138)], rose, thread: lightThread, seed: 67, inset: 1.6)
        piece(c, [pt(66, 88), pt(102, 88), pt(110, 108), pt(106, 127), pt(85, 132), pt(64, 127), pt(60, 108)], rose, thread: lightThread, seed: 68)
        piece(c, [pt(74, 100), pt(94, 100), pt(97, 114), pt(85, 123), pt(71, 114)], cream, thread: Color(hex: 0xE6A79F), seed: 69, inset: 1.8)
        catHead(c, Place(at: pt(86, 64), turn: 12), wink: false, content: true)
        // the bear's arm over the cat's shoulder
        piece(c, [pt(118, 92), pt(100, 84), pt(84, 86), pt(80, 93), pt(98, 96), pt(114, 101)], toffee, thread: lightThread, seed: 70, inset: 1.6)
        // one heart, sewn across both of them
        piece(c, Pen.heart(pt(110, 112), 24), heartRed, thread: lightThread, seed: 71, inset: 2)
        crossStitches(c, pt(110, 112), lightThread, count: 6, spread: 6.5)
    }
}
