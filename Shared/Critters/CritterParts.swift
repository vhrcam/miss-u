import SwiftUI

extension CritterRig.Torso {
    /// One rounded shape for every pose, so poses can morph into each other.
    var path: Path {
        let mid = top + (bottom - top) * 0.6
        let drop = (mid - top) * 0.5, fall = (bottom - mid) * 0.72
        let tl = CGPoint(x: cx - shoulder, y: top), tr = CGPoint(x: cx + shoulder, y: top)
        var p = Path()
        p.move(to: tl)
        p.addCurve(to: CGPoint(x: cx - hip, y: mid), control1: CGPoint(x: tl.x - shoulder * 0.14, y: top + drop), control2: CGPoint(x: cx - hip, y: mid - drop))
        p.addCurve(to: CGPoint(x: cx - hip * 0.46, y: bottom), control1: CGPoint(x: cx - hip, y: mid + fall), control2: CGPoint(x: cx - hip * 0.86, y: bottom))
        p.addCurve(to: CGPoint(x: cx, y: bottom - notch), control1: CGPoint(x: cx - hip * 0.16, y: bottom), control2: CGPoint(x: cx - 1.4, y: bottom - notch))
        p.addCurve(to: CGPoint(x: cx + hip * 0.46, y: bottom), control1: CGPoint(x: cx + 1.4, y: bottom - notch), control2: CGPoint(x: cx + hip * 0.16, y: bottom))
        p.addCurve(to: CGPoint(x: cx + hip, y: mid), control1: CGPoint(x: cx + hip * 0.86, y: bottom), control2: CGPoint(x: cx + hip, y: mid + fall))
        p.addCurve(to: tr, control1: CGPoint(x: cx + hip, y: mid - drop), control2: CGPoint(x: tr.x + shoulder * 0.14, y: top + drop))
        p.addCurve(to: tl, control1: CGPoint(x: tr.x - shoulder * 0.4, y: top - hump), control2: CGPoint(x: tl.x + shoulder * 0.4, y: top - hump))
        p.closeSubpath()
        return p
    }

    func tailBase(_ side: CGFloat) -> CGPoint { CGPoint(x: cx + side * hip * 0.74, y: bottom - 6.5) }
}

extension CritterRig.Limb {
    var path: Path {
        var p = Path()
        p.move(to: from)
        p.addLine(to: to)
        return p.strokedPath(StrokeStyle(lineWidth: width, lineCap: .round))
    }
}

extension CritterRig.Foot {
    var path: Path {
        let w = 11.2 * size, h = 12.4 * size
        return Path(ellipseIn: CGRect(x: -w / 2, y: -h / 2, width: w, height: h))
            .applying(CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: center.x, y: center.y)))
    }
}

struct CritterEar {
    var outer: Path
    var inner: Path?
    var front = false
    var accent = false

    func applying(_ t: CGAffineTransform) -> CritterEar {
        CritterEar(outer: outer.applying(t), inner: inner?.applying(t), front: front, accent: accent)
    }

    func turned(_ degrees: CGFloat, around p: CGPoint) -> CritterEar {
        guard degrees != 0 else { return self }
        return applying(CGAffineTransform(translationX: p.x, y: p.y).rotated(by: degrees * .pi / 180).translatedBy(x: -p.x, y: -p.y))
    }
}

/// Heads are drawn around 0,0: the face spans about ±28 across and ±19 down.
extension Species {
    var skull: Path {
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

    func ears(twitch: (left: CGFloat, right: CGFloat) = (0, 0)) -> [CritterEar] {
        switch self {
        case .cat:
            var ear = Path()
            ear.move(to: CGPoint(x: 4.5, y: -14))
            ear.addQuadCurve(to: CGPoint(x: 14.4, y: -29.2), control: CGPoint(x: 8.4, y: -23.4))
            ear.addQuadCurve(to: CGPoint(x: 19.2, y: -28.6), control: CGPoint(x: 16.8, y: -31.8))
            ear.addQuadCurve(to: CGPoint(x: 26, y: -9.5), control: CGPoint(x: 24.8, y: -20.6))
            ear.closeSubpath()
            var inner = Path()
            inner.move(to: CGPoint(x: 9.6, y: -16.5))
            inner.addQuadCurve(to: CGPoint(x: 15.4, y: -25.6), control: CGPoint(x: 12, y: -22))
            inner.addQuadCurve(to: CGPoint(x: 18, y: -25), control: CGPoint(x: 16.8, y: -27.2))
            inner.addQuadCurve(to: CGPoint(x: 22.2, y: -13), control: CGPoint(x: 21.4, y: -19.4))
            inner.closeSubpath()
            return pair(CritterEar(outer: ear, inner: inner), hinge: CGPoint(x: 15, y: -13), twitch: twitch)
        case .bear:
            let ear = Path(ellipseIn: CGRect(x: 10.6, y: -22.9, width: 14.8, height: 14.8))
            let inner = Path(ellipseIn: CGRect(x: 14.3, y: -19.6, width: 7.8, height: 7.8))
            return pair(CritterEar(outer: ear, inner: inner), hinge: CGPoint(x: 17, y: -12), twitch: twitch)
        case .rabbit:
            func ear(_ a: CGPoint, _ c: CGPoint, _ b: CGPoint) -> CritterEar {
                var spine = Path()
                spine.move(to: a)
                spine.addQuadCurve(to: b, control: c)
                let stem = spine.strokedPath(StrokeStyle(lineWidth: 9.4, lineCap: .round))
                let belly = spine.trimmedPath(from: 0.2, to: 0.8).strokedPath(StrokeStyle(lineWidth: 11.2, lineCap: .round))
                let inner = spine.trimmedPath(from: 0.26, to: 0.78).strokedPath(StrokeStyle(lineWidth: 3.8, lineCap: .round))
                return CritterEar(outer: stem.union(belly), inner: inner)
            }
            return [ear(CGPoint(x: -9, y: -12), CGPoint(x: -11.5, y: -29), CGPoint(x: -12, y: -42)).turned(-twitch.left, around: CGPoint(x: -9, y: -14)),
                    ear(CGPoint(x: 9, y: -12), CGPoint(x: 12, y: -38), CGPoint(x: 20, y: -39.5)).turned(twitch.right, around: CGPoint(x: 9, y: -14))]
        case .dog:
            var ear = Path()
            ear.move(to: CGPoint(x: 14, y: -17.5))
            ear.addCurve(to: CGPoint(x: 31.5, y: 2), control1: CGPoint(x: 24, y: -21.5), control2: CGPoint(x: 32.5, y: -10))
            ear.addCurve(to: CGPoint(x: 26, y: 10), control1: CGPoint(x: 31, y: 8), control2: CGPoint(x: 28.5, y: 10.5))
            ear.addCurve(to: CGPoint(x: 14, y: -17.5), control1: CGPoint(x: 23, y: 7), control2: CGPoint(x: 20, y: -9))
            ear.closeSubpath()
            return pair(CritterEar(outer: ear, front: true, accent: true), hinge: CGPoint(x: 16, y: -16), twitch: (twitch.left * 0.5, twitch.right * 0.5))
        }
    }

    private func pair(_ right: CritterEar, hinge: CGPoint, twitch: (left: CGFloat, right: CGFloat)) -> [CritterEar] {
        let left = right.applying(CGAffineTransform(scaleX: -1, y: 1))
        return [left.turned(-twitch.left, around: CGPoint(x: -hinge.x, y: hinge.y)), right.turned(twitch.right, around: hinge)]
    }

    func tail(from base: CGPoint, swing: CGFloat, side: CGFloat = 1) -> Path? {
        var spine = Path()
        switch self {
        case .cat:
            spine.move(to: base)
            spine.addCurve(to: CGPoint(x: base.x + 11, y: base.y - 15), control1: CGPoint(x: base.x + 9, y: base.y + 3), control2: CGPoint(x: base.x + 15, y: base.y - 6))
        case .dog:
            spine.move(to: base)
            spine.addQuadCurve(to: CGPoint(x: base.x + 7.5, y: base.y - 9), control: CGPoint(x: base.x + 7, y: base.y - 1))
        case .bear, .rabbit:
            return nil
        }
        let turn = CGAffineTransform(translationX: base.x, y: base.y).scaledBy(x: side, y: 1).rotated(by: swing * .pi / 180).translatedBy(x: -base.x, y: -base.y)
        return spine.applying(turn).strokedPath(StrokeStyle(lineWidth: self == .cat ? 5 : 5.4, lineCap: .round))
    }
}
