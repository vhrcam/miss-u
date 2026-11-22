import SwiftUI

/// Paints creatures without outlines: a single soft silhouette, then light and shade
/// laid over it as one form, and soft shadows wherever one part meets another.
struct CreaturePainter {
    var context: GraphicsContext
    var finish: CreatureFinish
    var px: CGFloat

    private static let toLight = CGSize(width: -0.55, height: -0.83)

    private func reach(_ k: CGFloat, _ s: CGFloat, toward light: Bool = true) -> CGSize {
        let d = light ? 1 : -1 as CGFloat
        return CGSize(width: Self.toLight.width * k * s * d, height: Self.toLight.height * k * s * d)
    }

    func ground(_ form: CreatureForm, width: CGFloat, strength: Double = 1) {
        let s = form.size
        let crisp = finish == .shape
        var wide = context
        wide.addFilter(.blur(radius: (crisp ? 0.8 : 2.8) * s))
        wide.drawLayer { l in
            l.fill(Path(ellipseIn: CGRect(x: form.base.x - width * s / 2, y: form.base.y - 2.6 * s, width: width * s, height: 5.4 * s)),
                   with: .color(Palette.shadow.opacity(0.2 * strength)))
        }
        var core = context
        core.addFilter(.blur(radius: (crisp ? 0.5 : 1.2) * s))
        core.drawLayer { l in
            l.fill(Path(ellipseIn: CGRect(x: form.base.x - width * s * 0.34, y: form.base.y - 1.4 * s, width: width * s * 0.68, height: 2.8 * s)),
                   with: .color(Palette.shadow.opacity(0.18 * strength)))
        }
    }

    func paint(_ form: CreatureForm, _ species: Species, _ pose: CreaturePose) {
        let r = finish.recipe
        let colors = species.colors
        let coat = colors.coat
        let s = form.size
        var outer = context
        if r.halo > 0 { outer.addFilter(.shadow(color: Palette.shadow.opacity(r.halo), radius: 2.2 * s, x: 0.4 * s, y: 1.4 * s)) }
        outer.drawLayer { layer in
            layer.merged(form.silhouette, color: coat.base, round: 1.6 * s, soft: 0.45 / px)
            var inside = layer
            inside.blendMode = .sourceAtop

            let crisp = finish == .shape
            inside.soft(form.patches, color: colors.patch, opacity: species == .bear ? 1 : 0.85, blur: (crisp ? 0.3 : species == .bear ? 0.7 : 1.8) * s)
            inside.soft(form.innerEars, color: colors.inner, opacity: 0.95, blur: 0.6 * s)

            if r.wash > 0 {
                let box = form.silhouette.reduce(CGRect.null) { $0.union($1.boundingRect) }
                inside.fill(Path(box), with: .linearGradient(Gradient(stops: [
                    .init(color: coat.light.opacity(r.wash), location: 0),
                    .init(color: coat.light.opacity(0), location: 0.4),
                    .init(color: coat.shade.opacity(0), location: 0.6),
                    .init(color: coat.shade.opacity(r.wash), location: 1),
                ]), startPoint: CGPoint(x: box.midX, y: box.minY), endPoint: CGPoint(x: box.midX, y: box.maxY)))
            }

            // the side of each form turned away from the light
            inside.crescent(form.torso, away: reach(r.shadowReach, s), color: coat.shade, opacity: r.shadow, blur: r.shadowBlur * s)
            inside.crescent([form.head], away: reach(r.shadowReach, s), color: coat.shade, opacity: r.shadow, blur: r.shadowBlur * s)
            inside.crescent(form.ears, away: reach(r.shadowReach * 0.45, s), color: coat.shade, opacity: r.shadow * 0.8, blur: r.shadowBlur * 0.5 * s)
            if let tail = form.tail {
                inside.crescent([tail], away: reach(2.2, s), color: coat.shade, opacity: r.shadow, blur: r.shadowBlur * 0.4 * s)
            }
            if r.core > 0 {
                inside.crescent(form.torso + [form.head], away: reach(r.shadowReach * 0.35, s), color: coat.deep, opacity: r.core, blur: r.shadowBlur * 0.45 * s)
                inside.crescent(form.torso + [form.head], away: reach(r.shadowReach * 0.6, s), color: Palette.cheek, opacity: 0.1, blur: r.shadowBlur * 0.6 * s)
            }

            // soft shadows where forms meet
            let occ = r.occlusion, ob = r.occlusionBlur * s
            let chin = r.occlusionReach * s
            inside.crescent([form.head.offsetBy(dx: 0.2 * chin, dy: chin)], away: CGSize(width: -0.2 * chin, height: -chin), color: coat.deep, opacity: occ, blur: ob)
            inside.crescent([form.head.offsetBy(dx: 0, dy: -2 * s)], away: CGSize(width: 0, height: 2 * s), color: coat.deep, opacity: occ * 0.55, blur: ob * 0.8)
            for (i, h) in form.haunches.enumerated() {
                let side: CGFloat = i == 0 ? -1 : 1
                if !crisp {
                    inside.crescent([h.offsetBy(dx: -side * 1.3 * s, dy: -1.9 * s)], away: CGSize(width: side * 1.3 * s, height: 1.9 * s), color: coat.deep, opacity: occ * 0.7, blur: ob * 0.8)
                }
            }
            for (arm, side) in form.arms {
                inside.crescent([arm.offsetBy(dx: -side * 1.2 * s, dy: 1.4 * s)], away: CGSize(width: side * 1.2 * s, height: -1.4 * s), color: coat.deep, opacity: occ * 0.75, blur: ob * 0.8)
                inside.crescent([arm], away: reach(r.shadowReach * 0.4, s), color: coat.shade, opacity: r.shadow * 0.8, blur: r.shadowBlur * 0.4 * s)
            }
            if let tail = form.tail {
                inside.crescent(form.torso.map { $0.offsetBy(dx: form.tailSide * 1.8 * s, dy: 0.6 * s) }, away: CGSize(width: -form.tailSide * 1.8 * s, height: -0.6 * s), color: coat.deep, opacity: occ * 0.7, blur: ob * 0.7)
                _ = tail
            }
            if let gap = form.legGap {
                var g = inside
                g.opacity *= occ * 0.45
                g.addFilter(.blur(radius: 1.1 * s))
                g.drawLayer { l in l.stroke(gap, with: .color(coat.deep), style: StrokeStyle(lineWidth: 1.6 * s, lineCap: .round)) }
            }

            // the lit side
            inside.crescent([form.head], away: reach(r.lightReach, s, toward: false), color: coat.light, opacity: r.light, blur: r.lightBlur * s)
            inside.crescent(form.torso, away: reach(r.lightReach, s, toward: false), color: coat.light, opacity: r.light * 0.7, blur: r.lightBlur * s)

            if finish == .soft {
                var sheen = inside
                sheen.addFilter(.blur(radius: 3 * s))
                let top = form.head.boundingRect
                sheen.drawLayer { l in
                    l.fill(Path(ellipseIn: CGRect(x: top.minX + top.width * 0.2, y: top.minY + top.height * 0.12, width: top.width * 0.3, height: top.height * 0.22)),
                           with: .color(.white.opacity(0.28)))
                }
            }
            if r.edge > 0 { edge(inside, form.silhouette, coat.deep, r.edge, r.edgeWidth * s, s) }
            if r.bounce > 0 {
                inside.crescent(form.torso, away: CGSize(width: 0, height: -2.2 * s), color: coat.light, opacity: r.bounce, blur: 1.3 * s)
            }

            if !form.paws.isEmpty {
                inside.soft(form.paws.map { $0.offsetBy(dx: 0.5 * s, dy: 1.2 * s) }, color: coat.deep, opacity: occ * 0.6, blur: ob * 0.7)
                part(layer, form.paws, colors.coat, s)
            }
            if !form.frontEars.isEmpty {
                inside.soft(form.frontEars.map { $0.offsetBy(dx: 0.6 * s, dy: 1.4 * s) }, color: coat.deep, opacity: occ * 0.7, blur: ob)
                part(layer, form.frontEars, colors.accent, s)
            }

            face(layer, species, form, pose)
        }
    }

    /// A form that sits in front of another, painted on its own.
    func part(_ into: GraphicsContext, _ shapes: [Path], _ coat: Coat, _ s: CGFloat) {
        let r = finish.recipe
        into.drawLayer { f in
            f.merged(shapes, color: coat.base, round: 0.6 * s, soft: 0.45 / px)
            var fi = f
            fi.blendMode = .sourceAtop
            fi.crescent(shapes, away: reach(r.shadowReach * 0.5, s), color: coat.shade, opacity: r.shadow, blur: r.shadowBlur * 0.45 * s)
            fi.crescent(shapes, away: reach(r.lightReach * 0.45, s, toward: false), color: coat.light, opacity: r.light, blur: r.lightBlur * 0.45 * s)
            if r.edge > 0 { edge(fi, shapes, coat.deep, r.edge, r.edgeWidth * 0.8 * s, s) }
            if r.bounce > 0 { fi.crescent(shapes, away: CGSize(width: 0, height: -1.3 * s), color: coat.light, opacity: r.bounce * 0.7, blur: 0.8 * s) }
        }
    }

    /// A standalone limb, like an arm around someone, with the soft shadow it casts.
    func limb(_ shape: Path, _ coat: Coat, size s: CGFloat) {
        var c = context
        c.addFilter(.shadow(color: Palette.shadow.opacity(0.22), radius: 2.2 * s, x: 0.6 * s, y: 1.6 * s))
        c.drawLayer { l in part(l, [shape], coat, s) }
    }

    /// Darkens just inside the silhouette, more on the shadow side, so the edge reads without a line.
    private func edge(_ inside: GraphicsContext, _ shapes: [Path], _ color: Color, _ strength: Double, _ width: CGFloat, _ s: CGFloat) {
        var e = inside
        e.opacity *= strength
        e.addFilter(.blur(radius: width))
        let box = shapes.reduce(CGRect.null) { $0.union($1.boundingRect) }.insetBy(dx: -20 * s, dy: -20 * s)
        e.drawLayer { l in
            l.fill(Path(box), with: .color(color))
            l.blendMode = .destinationOut
            var m = l
            m.translateBy(x: -0.5 * s, y: -0.8 * s)
            m.merged(shapes, color: .black, round: 1.6 * s, soft: 0.45 / px)
        }
    }

    func heart(at c: CGPoint, width w: CGFloat, opacity: Double = 1) {
        let p = CritterPaint.heartShape(c, w)
        var h = context
        h.opacity *= opacity
        h.fill(p, with: .radialGradient(Gradient(colors: [Palette.heartLight, Palette.heartBase, Palette.heartDeep]),
                                        center: CGPoint(x: c.x - w * 0.16, y: c.y - w * 0.22), startRadius: 0, endRadius: w * 0.8))
    }

    private func face(_ layer: GraphicsContext, _ species: Species, _ form: CreatureForm, _ pose: CreaturePose) {
        var f = layer
        f.concatenate(form.face)
        let t = pose.turn
        let line = max(1.05, 0.7 / (px * form.size))

        for side: CGFloat in [-1, 1] {
            let c = CGPoint(x: side * 15.4 + t * 2.4, y: 7.4)
            var b = f
            b.translateBy(x: c.x, y: c.y)
            b.scaleBy(x: 1, y: 0.62)
            b.fill(Path(ellipseIn: CGRect(x: -6.4, y: -6.4, width: 12.8, height: 12.8)),
                   with: .radialGradient(Gradient(colors: [Palette.cheek.opacity(pose.blush), Palette.cheek.opacity(0)]), center: .zero, startRadius: 0, endRadius: 6.4))
        }

        let gx = pose.gaze.x * 1.3 + t * 2.6, gy = pose.gaze.y * 0.9
        for side: CGFloat in [-1, 1] {
            let x = side * 9.6 + gx, y = 2.4 + gy
            switch pose.eyes {
            case .open:
                let open = max(0.08, 1 - pose.blink)
                if open > 0.25 {
                    let rx: CGFloat = 2.15, ry = 2.6 * open
                    f.fill(Path(ellipseIn: CGRect(x: x - rx, y: y - ry, width: rx * 2, height: ry * 2)), with: .color(Palette.eye))
                    if open > 0.8 {
                        f.fill(Path(ellipseIn: CGRect(x: x + 0.25, y: y - ry + 0.5, width: 1.25, height: 1.25)), with: .color(.white.opacity(0.95)))
                        f.fill(Path(ellipseIn: CGRect(x: x - 1.2, y: y + 0.9, width: 0.6, height: 0.6)), with: .color(.white.opacity(0.5)))
                    }
                } else {
                    var lid = Path()
                    lid.move(to: CGPoint(x: x - 2.4, y: y))
                    lid.addQuadCurve(to: CGPoint(x: x + 2.4, y: y), control: CGPoint(x: x, y: y + 1.2))
                    f.stroke(lid, with: .color(Palette.eye), style: StrokeStyle(lineWidth: line, lineCap: .round))
                }
            case .content:
                var lid = Path()
                lid.move(to: CGPoint(x: x - 2.6, y: y - 0.2))
                lid.addQuadCurve(to: CGPoint(x: x + 2.6, y: y - 0.2), control: CGPoint(x: x, y: y + 2.3))
                f.stroke(lid, with: .color(Palette.eye), style: StrokeStyle(lineWidth: line, lineCap: .round))
            case .happy:
                var lid = Path()
                lid.move(to: CGPoint(x: x - 2.6, y: y + 1))
                lid.addQuadCurve(to: CGPoint(x: x + 2.6, y: y + 1), control: CGPoint(x: x, y: y - 2.4))
                f.stroke(lid, with: .color(Palette.eye), style: StrokeStyle(lineWidth: line, lineCap: .round))
            }
        }

        let nx = t * 3.2
        switch species {
        case .cat, .rabbit:
            let k: CGFloat = species == .cat ? 1 : 0.8
            var nose = Path()
            nose.addLines([CGPoint(x: nx - 1.35 * k, y: 4.8), CGPoint(x: nx + 1.35 * k, y: 4.8), CGPoint(x: nx, y: 4.8 + 1.3 * k)])
            nose.closeSubpath()
            f.fill(nose, with: .color(Palette.nose))
            f.stroke(nose, with: .color(Palette.nose), style: StrokeStyle(lineWidth: 0.8, lineJoin: .round))
        case .bear, .dog:
            let rx: CGFloat = species == .dog ? 2.3 : 2.05, ry: CGFloat = species == .dog ? 1.6 : 1.45
            f.fill(Path(ellipseIn: CGRect(x: nx - rx, y: 5 - ry, width: rx * 2, height: ry * 2)), with: .color(Palette.eye))
            f.fill(Path(ellipseIn: CGRect(x: nx - rx * 0.5, y: 5 - ry * 0.72, width: rx * 0.55, height: ry * 0.45)), with: .color(.white.opacity(0.5)))
        }

        let top: CGFloat = species == .bear || species == .dog ? 6.6 : 6.2
        var mouth = Path()
        mouth.move(to: CGPoint(x: nx - 2.2, y: top + 0.5))
        mouth.addQuadCurve(to: CGPoint(x: nx, y: top + 0.6), control: CGPoint(x: nx - 1.15, y: top + 2.2))
        mouth.addQuadCurve(to: CGPoint(x: nx + 2.2, y: top + 0.5), control: CGPoint(x: nx + 1.15, y: top + 2.2))
        f.stroke(mouth, with: .color(Palette.mouth), style: StrokeStyle(lineWidth: line * 0.85, lineCap: .round, lineJoin: .round))
    }
}
