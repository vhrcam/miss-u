import SwiftUI

/// Paints characters as soft, lit forms. Lines are thin and warm, heavier on the shadow side,
/// and only the outside edge gets a full line. Where parts overlap, a lighter crease is enough.
struct CritterPaint {
    var context: GraphicsContext
    let scale: CGFloat

    init(_ context: GraphicsContext, scale: CGFloat) {
        self.context = context
        self.scale = scale
    }

    var edge: CGFloat { max(0.78, 0.82 / scale) }
    var fine: CGFloat { max(0.62, 0.7 / scale) }
    private var weight: CGSize { CGSize(width: max(0.22, 0.24 / scale), height: max(0.55, 0.58 / scale)) }

    func shifted(_ dx: CGFloat, _ dy: CGFloat) -> CritterPaint {
        var p = self
        p.context.translateBy(x: dx, y: dy)
        return p
    }

    mutating func squash(_ k: CGFloat, around p: CGPoint) {
        guard k != 0 else { return }
        context.translateBy(x: p.x, y: p.y)
        context.scaleBy(x: 1 + k * 0.6, y: 1 - k)
        context.translateBy(x: -p.x, y: -p.y)
    }

    /// Draws the outer edge of a group of parts before any of them is filled, so the line
    /// only shows around the outside. Anything in `beneath` was painted earlier and keeps its look.
    func outline(_ parts: [(Path, Color)], outside beneath: [Path] = []) {
        var c = context
        for b in beneath { c.clip(to: b, options: .inverse) }
        for (p, color) in parts {
            c.fill(p.offsetBy(dx: weight.width, dy: weight.height), with: lineShading(color, p))
        }
        for (p, color) in parts {
            c.stroke(p, with: lineShading(color, p), style: StrokeStyle(lineWidth: edge * 2, lineCap: .round, lineJoin: .round))
        }
    }

    private func lineShading(_ color: Color, _ p: Path) -> GraphicsContext.Shading {
        let r = p.boundingRect
        return .linearGradient(Gradient(colors: [color.mix(with: .white, by: 0.3), color]),
                               startPoint: CGPoint(x: r.midX, y: r.minY), endPoint: CGPoint(x: r.midX, y: r.maxY))
    }

    /// Fills a part as a soft rounded form, lit from the upper left.
    func form(_ path: Path, _ tone: Tone, light: CGPoint? = nil) {
        let r = path.boundingRect
        let focus = light ?? CGPoint(x: r.minX + r.width * 0.34, y: r.minY + r.height * 0.26)
        let reach = max(hypot(r.width, r.height) * 0.86, 1)
        context.fill(path, with: .radialGradient(Gradient(stops: [
            .init(color: tone.light, location: 0),
            .init(color: tone.base, location: 0.38),
            .init(color: tone.base, location: 0.62),
            .init(color: tone.shade, location: 1),
        ]), center: focus, startRadius: 0, endRadius: reach))
    }

    /// A round light or shadow that fades to nothing at its edge.
    func glow(_ center: CGPoint, _ rx: CGFloat, _ ry: CGFloat, _ color: Color, _ opacity: Double) {
        guard rx > 0, ry > 0, opacity > 0 else { return }
        var c = context
        c.translateBy(x: center.x, y: center.y)
        c.scaleBy(x: 1, y: ry / rx)
        c.fill(Path(ellipseIn: CGRect(x: -rx, y: -rx, width: rx * 2, height: rx * 2)),
               with: .radialGradient(Gradient(colors: [color.opacity(opacity), color.opacity(0)]), center: .zero, startRadius: 0, endRadius: rx))
    }

    func sheen(_ shape: Path, at p: CGPoint, _ rx: CGFloat, _ ry: CGFloat, opacity: Double = 0.55) {
        var c = self
        c.context.clip(to: shape)
        c.glow(p, rx, ry, .white, opacity)
    }

    /// Light reflected up from the ground, just inside the lower edge.
    func bounce(in shape: Path, from top: CGFloat, to bottom: CGFloat, _ color: Color) {
        context.drawLayer { layer in
            layer.clip(to: shape)
            layer.drawLayer { inner in
                inner.addFilter(.blur(radius: 0.9 * scale))
                inner.stroke(shape.offsetBy(dx: -0.3, dy: -1.6), with: .linearGradient(Gradient(colors: [color.opacity(0), color.opacity(0.85)]),
                             startPoint: CGPoint(x: 0, y: top), endPoint: CGPoint(x: 0, y: bottom)), lineWidth: 1.8)
            }
        }
    }

    func crease(_ path: Path, inside region: Path, _ color: Color, width: CGFloat? = nil) {
        var c = context
        c.clip(to: region)
        c.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width ?? fine, lineCap: .round, lineJoin: .round))
    }

    func pen(_ path: Path, _ color: Color, width: CGFloat? = nil) {
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width ?? fine, lineCap: .round, lineJoin: .round))
    }

    /// A soft shadow that `shape` casts onto `region` only.
    func shadow(of shape: Path, onto region: Path, _ color: Color, opacity: Double, offset: CGSize, blur: CGFloat) {
        context.drawLayer { layer in
            layer.clip(to: region)
            layer.drawLayer { inner in
                inner.addFilter(.blur(radius: blur * scale))
                inner.fill(shape.offsetBy(dx: offset.width, dy: offset.height), with: .color(color.opacity(opacity)))
            }
        }
    }

    func ground(_ r: CGRect) {
        guard r.width > 0 else { return }
        glow(CGPoint(x: r.midX, y: r.midY + 0.4), r.width * 0.62, r.height * 1.05, Palette.shadow, 0.16)
        glow(CGPoint(x: r.midX, y: r.midY), r.width * 0.4, r.height * 0.55, Palette.shadow, 0.14)
    }

    func ear(_ ear: CritterEar, _ fur: Fur) {
        form(ear.outer, ear.accent ? fur.accent : fur.coat)
        guard let inner = ear.inner else { return }
        let r = inner.boundingRect
        var c = context
        c.clip(to: ear.outer)
        c.fill(inner, with: .linearGradient(Gradient(colors: [fur.ear.opacity(0.9), fur.ear.opacity(0.3)]),
                                            startPoint: CGPoint(x: r.midX, y: r.maxY), endPoint: CGPoint(x: r.midX, y: r.minY)))
    }

    static func heartShape(_ c: CGPoint, _ w: CGFloat) -> Path {
        let h = w * 0.9, x = c.x, y = c.y
        var p = Path()
        p.move(to: CGPoint(x: x, y: y + h * 0.5))
        p.addCurve(to: CGPoint(x: x - w / 2, y: y - h * 0.1), control1: CGPoint(x: x - w * 0.2, y: y + h * 0.36), control2: CGPoint(x: x - w / 2, y: y + h * 0.18))
        p.addCurve(to: CGPoint(x: x, y: y - h * 0.28), control1: CGPoint(x: x - w / 2, y: y - h * 0.55), control2: CGPoint(x: x - w * 0.05, y: y - h * 0.58))
        p.addCurve(to: CGPoint(x: x + w / 2, y: y - h * 0.1), control1: CGPoint(x: x + w * 0.05, y: y - h * 0.58), control2: CGPoint(x: x + w / 2, y: y - h * 0.55))
        p.addCurve(to: CGPoint(x: x, y: y + h * 0.5), control1: CGPoint(x: x + w / 2, y: y + h * 0.18), control2: CGPoint(x: x + w * 0.2, y: y + h * 0.36))
        p.closeSubpath()
        return p
    }

    @discardableResult
    func heart(at c: CGPoint, width w: CGFloat, outlined: Bool = true, opacity: Double = 1) -> Path {
        let p = Self.heartShape(c, w)
        var paint = self
        paint.context.opacity *= opacity
        if outlined { paint.outline([(p, Palette.heartLine)]) }
        paint.context.fill(p, with: .radialGradient(Gradient(colors: [Palette.heartLight, Palette.heartBase, Palette.heartDeep]),
                                                    center: CGPoint(x: c.x - w * 0.16, y: c.y - w * 0.22), startRadius: 0, endRadius: w * 0.8))
        paint.glow(CGPoint(x: c.x - w * 0.21, y: c.y - w * 0.17), w * 0.15, w * 0.1, .white, 0.8)
        return p
    }

    func z(at c: CGPoint, size s: CGFloat, opacity: Double) {
        let h = s / 2
        var z = Path()
        z.addLines([CGPoint(x: c.x - h, y: c.y - h), CGPoint(x: c.x + h, y: c.y - h), CGPoint(x: c.x - h, y: c.y + h), CGPoint(x: c.x + h, y: c.y + h)])
        var ctx = context
        ctx.opacity *= opacity
        ctx.stroke(z, with: .color(Palette.dream), style: StrokeStyle(lineWidth: fine * 1.25, lineCap: .round, lineJoin: .round))
    }
}
