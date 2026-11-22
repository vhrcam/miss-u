import SwiftUI

/// Shape helpers for drawing creatures as smooth, organic forms.
enum Sketch {
    /// A closed smooth curve through `points`.
    static func blob(_ points: [CGPoint]) -> Path {
        var p = Path()
        let n = points.count
        guard n > 2 else { return p }
        p.move(to: points[0])
        for i in 0..<n {
            let p0 = points[(i - 1 + n) % n], p1 = points[i], p2 = points[(i + 1) % n], p3 = points[(i + 2) % n]
            p.addCurve(to: p2,
                       control1: CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6),
                       control2: CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6))
        }
        p.closeSubpath()
        return p
    }

    /// A soft rounded oval, squarer than an ellipse and a little fuller toward the bottom, like a rice cake.
    static func mochi(rx: CGFloat, ry: CGFloat, fullness: CGFloat = 0.07, squareness: CGFloat = 2.4) -> Path {
        let e = 2 / squareness
        let points = (0..<120).map { i -> CGPoint in
            let t = CGFloat(i) / 120 * 2 * .pi
            let c = cos(t), s = sin(t)
            let y = ry * copysign(pow(abs(s), e), s)
            let x = rx * copysign(pow(abs(c), e), c) * (1 + fullness * y / ry)
            return CGPoint(x: x, y: y)
        }
        var p = Path()
        p.addLines(points)
        p.closeSubpath()
        return p
    }

    static func oval(_ c: CGPoint, _ rx: CGFloat, _ ry: CGFloat, turn: CGFloat = 0) -> Path {
        Path(ellipseIn: CGRect(x: -rx, y: -ry, width: rx * 2, height: ry * 2))
            .applying(CGAffineTransform(rotationAngle: turn * .pi / 180).concatenating(CGAffineTransform(translationX: c.x, y: c.y)))
    }

    static func roundedTriangle(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint, radius: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2))
        p.addArc(tangent1End: b, tangent2End: c, radius: radius)
        p.addArc(tangent1End: c, tangent2End: a, radius: radius)
        p.addArc(tangent1End: a, tangent2End: b, radius: radius)
        p.closeSubpath()
        return p
    }

    /// A tapered tube along a cubic curve, with rounded ends. `bulge` fattens the middle.
    static func tube(_ a: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ b: CGPoint, from w0: CGFloat, to w1: CGFloat, bulge: CGFloat = 0, trim: ClosedRange<CGFloat> = 0...1) -> Path {
        func point(_ t: CGFloat) -> CGPoint {
            let u = 1 - t
            return CGPoint(x: u * u * u * a.x + 3 * u * u * t * c1.x + 3 * u * t * t * c2.x + t * t * t * b.x,
                           y: u * u * u * a.y + 3 * u * u * t * c1.y + 3 * u * t * t * c2.y + t * t * t * b.y)
        }
        let n = 28
        var left: [CGPoint] = [], right: [CGPoint] = []
        var ends: [(CGPoint, CGFloat, CGPoint)] = []
        for i in 0...n {
            let t = trim.lowerBound + (trim.upperBound - trim.lowerBound) * CGFloat(i) / CGFloat(n)
            let p = point(t)
            let q = point(min(1, t + 0.01)), o = point(max(0, t - 0.01))
            var d = CGPoint(x: q.x - o.x, y: q.y - o.y)
            let len = max(hypot(d.x, d.y), 0.0001)
            d = CGPoint(x: d.x / len, y: d.y / len)
            let w = (w0 + (w1 - w0) * t + bulge * sin(.pi * t)) / 2
            let nrm = CGPoint(x: -d.y, y: d.x)
            left.append(CGPoint(x: p.x + nrm.x * w, y: p.y + nrm.y * w))
            right.append(CGPoint(x: p.x - nrm.x * w, y: p.y - nrm.y * w))
            if i == 0 || i == n { ends.append((p, w, d)) }
        }
        var path = Path()
        path.addLines(left)
        let (endP, endW, endD) = ends[1]
        let endAngle = atan2(endD.y, endD.x)
        path.addArc(center: endP, radius: endW, startAngle: .radians(Double(endAngle + .pi / 2)), endAngle: .radians(Double(endAngle - .pi / 2)), clockwise: true)
        path.addLines(right.reversed())
        let (startP, startW, startD) = ends[0]
        let startAngle = atan2(startD.y, startD.x)
        path.addArc(center: startP, radius: startW, startAngle: .radians(Double(startAngle - .pi / 2)), endAngle: .radians(Double(startAngle + .pi / 2)), clockwise: true)
        path.closeSubpath()
        return path
    }
}

extension GraphicsContext {
    /// Fills several shapes as one, with the joins between them rounded off like soft clay.
    func merged(_ paths: [Path], color: Color, round: CGFloat, soft: CGFloat) {
        var c = self
        c.addFilter(.blur(radius: soft))
        c.addFilter(.alphaThreshold(min: 0.5, color: color))
        c.addFilter(.blur(radius: round))
        c.drawLayer { l in
            for p in paths { l.fill(p, with: .color(.black)) }
        }
    }

    /// The part of `shapes` left after taking away the same shapes moved by `away`, softened.
    /// Moved toward the light, it leaves the shadow side; moved away from it, the lit side.
    func crescent(_ shapes: [Path], away: CGSize, color: Color, opacity: Double, blur: CGFloat) {
        guard opacity > 0, !shapes.isEmpty else { return }
        var c = self
        c.opacity *= opacity
        if blur > 0 { c.addFilter(.blur(radius: blur)) }
        c.drawLayer { l in
            for s in shapes { l.fill(s, with: .color(color)) }
            l.blendMode = .destinationOut
            for s in shapes { l.fill(s.offsetBy(dx: away.width, dy: away.height), with: .color(.black)) }
        }
    }

    func soft(_ shapes: [Path], color: Color, opacity: Double, blur: CGFloat) {
        guard opacity > 0, !shapes.isEmpty else { return }
        var c = self
        c.opacity *= opacity
        if blur > 0 { c.addFilter(.blur(radius: blur)) }
        c.drawLayer { l in
            for s in shapes { l.fill(s, with: .color(color)) }
        }
    }
}
