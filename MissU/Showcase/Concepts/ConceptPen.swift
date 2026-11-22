import SwiftUI

/// Drawing tools for the character concepts: smooth curves through hand-placed points,
/// inked with a brush that swells and tapers, cut felt edges, and stitching.
enum Pen {
    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

    /// A smooth curve through `anchors`, sampled densely.
    static func curve(_ anchors: [CGPoint], closed: Bool = true, steps: Int = 10) -> [CGPoint] {
        let n = anchors.count
        guard n > 1 else { return anchors }
        var out: [CGPoint] = []
        let segments = closed ? n : n - 1
        for i in 0..<segments {
            let p0 = anchors[closed ? (i - 1 + n) % n : max(i - 1, 0)]
            let p1 = anchors[i]
            let p2 = anchors[closed ? (i + 1) % n : min(i + 1, n - 1)]
            let p3 = anchors[closed ? (i + 2) % n : min(i + 2, n - 1)]
            for s in 0..<steps {
                let t = CGFloat(s) / CGFloat(steps), t2 = t * t, t3 = t2 * t
                func c(_ a: CGFloat, _ b: CGFloat, _ cc: CGFloat, _ d: CGFloat) -> CGFloat {
                    0.5 * (2 * b + (-a + cc) * t + (2 * a - 5 * b + 4 * cc - d) * t2 + (-a + 3 * b - 3 * cc + d) * t3)
                }
                out.append(CGPoint(x: c(p0.x, p1.x, p2.x, p3.x), y: c(p0.y, p1.y, p2.y, p3.y)))
            }
        }
        if !closed { out.append(anchors[n - 1]) }
        return out
    }

    static func polygon(_ pts: [CGPoint], closed: Bool = true) -> Path {
        var p = Path()
        p.addLines(pts)
        if closed { p.closeSubpath() }
        return p
    }

    static func shape(_ anchors: [CGPoint]) -> Path { polygon(curve(anchors)) }

    private static func area(_ pts: [CGPoint]) -> CGFloat {
        var a: CGFloat = 0
        for i in pts.indices {
            let p = pts[i], q = pts[(i + 1) % pts.count]
            a += p.x * q.y - q.x * p.y
        }
        return a / 2
    }

    /// Unit normals; for closed curves they point outward.
    static func normals(_ pts: [CGPoint], closed: Bool) -> [CGPoint] {
        let n = pts.count
        let flip: CGFloat = closed && area(pts) < 0 ? -1 : 1
        return (0..<n).map { i in
            let a = pts[closed ? (i - 1 + n) % n : max(i - 1, 0)]
            let b = pts[closed ? (i + 1) % n : min(i + 1, n - 1)]
            let d = CGPoint(x: b.x - a.x, y: b.y - a.y)
            let l = max(hypot(d.x, d.y), 0.0001)
            return CGPoint(x: d.y / l * flip, y: -d.x / l * flip)
        }
    }

    static func noise(_ i: Int, _ seed: Int) -> CGFloat {
        let x = CGFloat(i)
        return sin(x * 0.53 + CGFloat(seed) * 1.7) * 0.6 + sin(x * 0.21 + CGFloat(seed) * 4.3) * 0.4
    }

    /// A brush line: heavier where the curve faces `heavy`, a little uneven like a real brush, tapered at open ends.
    static func ink(_ pts: [CGPoint], closed: Bool, width: CGFloat, heavy: CGPoint = CGPoint(x: 0.35, y: 0.94),
                    vary: CGFloat = 0.55, jitter: CGFloat = 0.14, seed: Int = 0, taper: Bool = true) -> Path {
        let ns = normals(pts, closed: closed)
        let n = pts.count
        var left: [CGPoint] = [], right: [CGPoint] = []
        for i in 0..<n {
            let face = closed ? max(0, ns[i].x * heavy.x + ns[i].y * heavy.y) : abs(ns[i].x * heavy.x + ns[i].y * heavy.y)
            var w = width * (1 - vary * 0.5 + vary * face) * (1 + jitter * noise(i, seed))
            if !closed && taper {
                let t = CGFloat(i) / CGFloat(max(n - 1, 1))
                w *= max(0.22, pow(sin(.pi * t), 0.5))
            }
            left.append(CGPoint(x: pts[i].x + ns[i].x * w / 2, y: pts[i].y + ns[i].y * w / 2))
            right.append(CGPoint(x: pts[i].x - ns[i].x * w / 2, y: pts[i].y - ns[i].y * w / 2))
        }
        var p = Path()
        if closed {
            p.addLines(left)
            p.closeSubpath()
            p.addLines(right)
            p.closeSubpath()
        } else {
            p.addLines(left + right.reversed())
            p.closeSubpath()
        }
        return p
    }

    /// Edges that look cut by hand.
    static func cut(_ pts: [CGPoint], amount: CGFloat, seed: Int) -> [CGPoint] {
        let ns = normals(pts, closed: true)
        return pts.indices.map { i in
            let k = amount * noise(i * 3, seed)
            return CGPoint(x: pts[i].x + ns[i].x * k, y: pts[i].y + ns[i].y * k)
        }
    }

    static func inset(_ pts: [CGPoint], by d: CGFloat) -> [CGPoint] {
        let ns = normals(pts, closed: true)
        return pts.indices.map { CGPoint(x: pts[$0].x - ns[$0].x * d, y: pts[$0].y - ns[$0].y * d) }
    }

    /// The outline of a tube along a dense `spine`, thinning toward the tip by `taper`.
    static func tube(_ spine: [CGPoint], width: CGFloat, taper: CGFloat = 0.25) -> [CGPoint] {
        tube(spine) { t in width * (1 - taper * t) }
    }

    /// A tube whose width follows `profile` from 0 at the start to 1 at the tip.
    static func tube(_ spine: [CGPoint], profile: (CGFloat) -> CGFloat) -> [CGPoint] {
        let ns = normals(spine, closed: false)
        let n = spine.count
        var left: [CGPoint] = [], right: [CGPoint] = []
        for i in 0..<n {
            let t = CGFloat(i) / CGFloat(max(n - 1, 1))
            let w = profile(t) / 2
            left.append(CGPoint(x: spine[i].x + ns[i].x * w, y: spine[i].y + ns[i].y * w))
            right.append(CGPoint(x: spine[i].x - ns[i].x * w, y: spine[i].y - ns[i].y * w))
        }
        func cap(_ c: CGPoint, _ a: CGPoint, _ b: CGPoint, _ out: CGPoint) -> [CGPoint] {
            let r = hypot(a.x - c.x, a.y - c.y)
            let start = atan2(a.y - c.y, a.x - c.x), end = atan2(b.y - c.y, b.x - c.x)
            var sweep = end - start
            let mid = start + sweep / 2
            if cos(mid) * out.x + sin(mid) * out.y < 0 { sweep += sweep > 0 ? -2 * .pi : 2 * .pi }
            return (1..<6).map { k in
                let ang = start + sweep * CGFloat(k) / 6
                return CGPoint(x: c.x + r * cos(ang), y: c.y + r * sin(ang))
            }
        }
        let tip = CGPoint(x: spine[n - 1].x - spine[n - 2].x, y: spine[n - 1].y - spine[n - 2].y)
        let back = CGPoint(x: spine[0].x - spine[1].x, y: spine[0].y - spine[1].y)
        return left + cap(spine[n - 1], left[n - 1], right[n - 1], tip) + right.reversed() + cap(spine[0], right[0], left[0], back)
    }

    static func heart(_ c: CGPoint, _ w: CGFloat) -> [CGPoint] {
        let h = w * 0.9
        return [pt(c.x, c.y + h * 0.48), pt(c.x - w * 0.3, c.y + h * 0.2), pt(c.x - w * 0.5, c.y - h * 0.12), pt(c.x - w * 0.34, c.y - h * 0.42),
                pt(c.x - w * 0.08, c.y - h * 0.36), pt(c.x, c.y - h * 0.2), pt(c.x + w * 0.08, c.y - h * 0.36), pt(c.x + w * 0.34, c.y - h * 0.42),
                pt(c.x + w * 0.5, c.y - h * 0.12), pt(c.x + w * 0.3, c.y + h * 0.2)]
    }
}

/// Moves a hand-drawn part into place.
struct Place {
    var at: CGPoint
    var turn: CGFloat = 0
    var scale: CGFloat = 1
    var flip = false

    func callAsFunction(_ p: CGPoint) -> CGPoint {
        let x = (flip ? -p.x : p.x) * scale, y = p.y * scale
        let a = turn * .pi / 180
        return CGPoint(x: at.x + x * cos(a) - y * sin(a), y: at.y + x * sin(a) + y * cos(a))
    }

    func callAsFunction(_ ps: [CGPoint]) -> [CGPoint] { ps.map { self($0) } }
}

/// A fixed-size drawing surface for one concept illustration.
struct ConceptCanvas: View {
    let size: CGSize
    let draw: (inout GraphicsContext) -> Void

    var body: some View {
        Canvas { context, canvas in
            let s = min(canvas.width / size.width, canvas.height / size.height)
            var c = context
            c.translateBy(x: (canvas.width - size.width * s) / 2, y: (canvas.height - size.height * s) / 2)
            c.scaleBy(x: s, y: s)
            draw(&c)
        }
        .aspectRatio(size.width / size.height, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
