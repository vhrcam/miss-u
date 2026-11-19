import SwiftUI

extension CritterRig.Body {
    var path: Path {
        var p = Path()
        switch self {
        case .standing:
            p.move(to: CGPoint(x: 35, y: 54))
            p.addCurve(to: CGPoint(x: 31, y: 81), control1: CGPoint(x: 32.5, y: 62), control2: CGPoint(x: 30.5, y: 72))
            p.addCurve(to: CGPoint(x: 39, y: 92.5), control1: CGPoint(x: 31.4, y: 88.5), control2: CGPoint(x: 34, y: 92.5))
            p.addCurve(to: CGPoint(x: 47.4, y: 89.5), control1: CGPoint(x: 43.5, y: 92.5), control2: CGPoint(x: 46.8, y: 92))
            p.addQuadCurve(to: CGPoint(x: 52.6, y: 89.5), control: CGPoint(x: 50, y: 84.5))
            p.addCurve(to: CGPoint(x: 61, y: 92.5), control1: CGPoint(x: 53.2, y: 92), control2: CGPoint(x: 56.5, y: 92.5))
            p.addCurve(to: CGPoint(x: 69, y: 81), control1: CGPoint(x: 66, y: 92.5), control2: CGPoint(x: 68.6, y: 88.5))
            p.addCurve(to: CGPoint(x: 65, y: 54), control1: CGPoint(x: 69.5, y: 72), control2: CGPoint(x: 67.5, y: 62))
        case .sitting:
            p.move(to: CGPoint(x: 34.5, y: 61))
            p.addCurve(to: CGPoint(x: 29, y: 85), control1: CGPoint(x: 32, y: 68), control2: CGPoint(x: 28.5, y: 77))
            p.addCurve(to: CGPoint(x: 38, y: 92.5), control1: CGPoint(x: 29.5, y: 90.5), control2: CGPoint(x: 33, y: 92.5))
            p.addLine(to: CGPoint(x: 62, y: 92.5))
            p.addCurve(to: CGPoint(x: 71, y: 85), control1: CGPoint(x: 67, y: 92.5), control2: CGPoint(x: 70.5, y: 90.5))
            p.addCurve(to: CGPoint(x: 65.5, y: 61), control1: CGPoint(x: 71.5, y: 77), control2: CGPoint(x: 68, y: 68))
        case .lying:
            p.move(to: CGPoint(x: 42, y: 92.5))
            p.addLine(to: CGPoint(x: 80, y: 92.5))
            p.addCurve(to: CGPoint(x: 90, y: 80), control1: CGPoint(x: 86.5, y: 92.5), control2: CGPoint(x: 90.5, y: 87))
            p.addCurve(to: CGPoint(x: 66, y: 62), control1: CGPoint(x: 89.5, y: 70), control2: CGPoint(x: 79, y: 62))
            p.addCurve(to: CGPoint(x: 42, y: 70), control1: CGPoint(x: 55, y: 62), control2: CGPoint(x: 46, y: 65))
        }
        p.closeSubpath()
        return p
    }

    var feet: [Path] {
        switch self {
        case .standing: []
        case .sitting:
            [(39, -0.26), (61, 0.26)].map { x, a in
                Path(ellipseIn: CGRect(x: -5.6, y: -6.3, width: 11.2, height: 12.6))
                    .applying(CGAffineTransform(rotationAngle: a).concatenating(.init(translationX: x, y: 86.3)))
            }
        case .lying: [Path(ellipseIn: CGRect(x: 80, y: 84, width: 10, height: 8))]
        }
    }
}

extension CritterRig.Limb {
    var path: Path {
        var p = Path()
        p.move(to: from)
        p.addLine(to: to)
        return p
    }
}

extension CritterInk {
    func critter(_ species: Species, fur: Fur, rig: CritterRig, mood: CritterMood) {
        context.fill(Path(ellipseIn: rig.shadow), with: .color(Palette.ground))
        for limb in rig.back { tube(limb.path, width: limb.width, fur.base) }
        let body = rig.body.path
        context.fill(body, with: .color(fur.base))
        var shade = context
        shade.clip(to: body)
        let chin = CGAffineTransform(scaleX: 1.14, y: 1.14).rotated(by: rig.tilt.radians).concatenating(.init(translationX: rig.head.x, y: rig.head.y + 3))
        shade.fill(species.head.applying(chin), with: .color(fur.shade))
        outline(body)
        for foot in rig.body.feet { shape(foot, fur.base) }
        at(rig.head, tilt: rig.tilt).head(species, fur: fur, mood: mood)
        for limb in rig.front { tube(limb.path, width: limb.width, fur.base) }
        for prop in rig.props { self.prop(prop) }
    }
}
