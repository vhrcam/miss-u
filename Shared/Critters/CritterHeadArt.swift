import SwiftUI

extension Species {
    var head: Path {
        let (w, t, kt, kb): (CGFloat, CGFloat, CGFloat, CGFloat) = switch self {
        case .cat: (28, 19, 0.63, 0.7)
        case .bear: (26.5, 20.5, 0.57, 0.62)
        case .dog: (27, 20, 0.6, 0.68)
        case .rabbit: (25.5, 21, 0.58, 0.66)
        }
        let b: CGFloat = 19, r = w * 0.985, lm: CGFloat = 2.6, rm: CGFloat = 1.8
        var p = Path()
        p.move(to: CGPoint(x: 0, y: -t))
        p.addCurve(to: CGPoint(x: r, y: rm), control1: CGPoint(x: r * kt, y: -t), control2: CGPoint(x: r, y: rm - (t + rm) * kt))
        p.addCurve(to: CGPoint(x: 0, y: b), control1: CGPoint(x: r, y: rm + (b - rm) * kb), control2: CGPoint(x: r * kb, y: b))
        p.addCurve(to: CGPoint(x: -w, y: lm), control1: CGPoint(x: -w * kb, y: b), control2: CGPoint(x: -w, y: lm + (b - lm) * kb))
        p.addCurve(to: CGPoint(x: 0, y: -t), control1: CGPoint(x: -w, y: lm - (t + lm) * kt), control2: CGPoint(x: -w * kt, y: -t))
        p.closeSubpath()
        return p
    }

    var crown: CGFloat {
        switch self {
        case .cat: -33
        case .bear: -25
        case .dog: -23
        case .rabbit: -48
        }
    }
}

extension CritterInk {
    func head(_ species: Species, fur: Fur, mood: CritterMood) {
        let flip = CGAffineTransform(scaleX: -1, y: 1)
        switch species {
        case .cat:
            var ear = Path()
            ear.move(to: CGPoint(x: 5, y: -15))
            ear.addArc(tangent1End: CGPoint(x: 16.5, y: -31), tangent2End: CGPoint(x: 25.5, y: -10), radius: 3.6)
            ear.addLine(to: CGPoint(x: 25.5, y: -10))
            ear.closeSubpath()
            var inner = Path()
            inner.move(to: CGPoint(x: 9.5, y: -18))
            inner.addArc(tangent1End: CGPoint(x: 16.5, y: -27.5), tangent2End: CGPoint(x: 22, y: -14), radius: 2)
            inner.addLine(to: CGPoint(x: 22, y: -14))
            inner.closeSubpath()
            for t in [flip, .identity] {
                context.fill(ear.applying(t), with: .color(fur.base))
                context.fill(inner.applying(t), with: .color(Palette.earPink))
                outline(ear.applying(t))
            }
        case .bear:
            for s: CGFloat in [-1, 1] {
                let ear = Path(ellipseIn: CGRect(x: s * 18 - 7.4, y: -22.9, width: 14.8, height: 14.8))
                context.fill(ear, with: .color(fur.base))
                context.fill(Path(ellipseIn: CGRect(x: s * 18.4 - 3.9, y: -20.4, width: 7.8, height: 7.8)), with: .color(Palette.earPink))
                outline(ear)
            }
        case .rabbit:
            let ears = [(CGPoint(x: -9, y: -12), CGPoint(x: -11.5, y: -29), CGPoint(x: -12, y: -42)),
                        (CGPoint(x: 9, y: -12), CGPoint(x: 12, y: -38), CGPoint(x: 20, y: -39.5))]
            for (a, c, b) in ears {
                var ear = Path()
                ear.move(to: a)
                ear.addQuadCurve(to: b, control: c)
                tube(ear, width: 10.5, fur.base)
                context.stroke(ear.trimmedPath(from: 0.22, to: 0.8), with: .color(Palette.earPink), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            }
        case .dog:
            break
        }
        shape(species.head, fur.base)
        face(mood)
        if species == .dog {
            var ear = Path()
            ear.move(to: CGPoint(x: 14, y: -17.5))
            ear.addCurve(to: CGPoint(x: 31.5, y: 2), control1: CGPoint(x: 24, y: -21.5), control2: CGPoint(x: 32.5, y: -10))
            ear.addCurve(to: CGPoint(x: 26, y: 10), control1: CGPoint(x: 31, y: 8), control2: CGPoint(x: 28.5, y: 10.5))
            ear.addCurve(to: CGPoint(x: 14, y: -17.5), control1: CGPoint(x: 23, y: 7), control2: CGPoint(x: 20, y: -9))
            ear.closeSubpath()
            shape(ear.applying(flip), fur.accent)
            shape(ear, fur.accent)
        }
    }
}
