import SwiftUI

/// The Miss U characters standing: small and round, with a big head, a real snout,
/// stubby legs and little arms that can reach.
private struct Frame {
    var top: CGFloat
    var bottom: CGFloat
    var shoulder: CGFloat
    var belly: CGFloat
    var leg: CGFloat
    var stance: CGFloat
    var foot: CGSize
    var arm: CGFloat
    var armLength: CGFloat
    var headY: CGFloat
    var head: CGFloat
    var rx: CGFloat
    var ry: CGFloat
    var square: CGFloat
}

extension Species {
    /// How each one stands when nothing's happening: never stiff, each with its own personality.
    var idlePose: CreaturePose {
        switch self {
        case .cat: CreaturePose(lean: 3, tilt: -9, turn: 0.25, ears: (left: 0, right: 6), tail: 4, reach: (left: 6, right: 118))
        case .bear: CreaturePose(lean: -2, tilt: 7, turn: -0.15, reach: (left: 32, right: 32))
        case .dog: CreaturePose(lean: -3, tilt: 10, turn: 0.2, eyes: .happy, blush: 0.75, tail: -10, reach: (left: 128, right: 128))
        case .rabbit: CreaturePose(lean: 2, tilt: -10, turn: -0.2, ears: (left: -10, right: 16), reach: (left: 8, right: 26))
        }
    }

    private var frame: Frame {
        switch self {
        case .cat: Frame(top: -26, bottom: -8, shoulder: 8.6, belly: 12.6, leg: 7.4, stance: 5, foot: CGSize(width: 5.2, height: 3.3), arm: 6.4, armLength: 10, headY: -41, head: 1.12, rx: 20.5, ry: 16.5, square: 2.15)
        case .bear: Frame(top: -27, bottom: -8, shoulder: 10, belly: 14.6, leg: 8.4, stance: 5.8, foot: CGSize(width: 6, height: 3.6), arm: 7.4, armLength: 10.5, headY: -42.5, head: 1.1, rx: 20.5, ry: 17.5, square: 2.2)
        case .dog: Frame(top: -26, bottom: -8, shoulder: 9, belly: 13.2, leg: 7.8, stance: 5.3, foot: CGSize(width: 5.4, height: 3.4), arm: 6.8, armLength: 10, headY: -41.5, head: 1.1, rx: 19.5, ry: 17, square: 2.3)
        case .rabbit: Frame(top: -25, bottom: -7.5, shoulder: 8.2, belly: 12.2, leg: 7.2, stance: 4.9, foot: CGSize(width: 6.2, height: 3.2), arm: 6, armLength: 9.5, headY: -39.5, head: 1.1, rx: 18, ry: 16.5, square: 2.2)
        }
    }

    /// Where the shoulder meets the arm, in the creature's own space.
    func standingShoulder(_ side: CGFloat) -> CGPoint {
        let f = frame
        return CGPoint(x: side * (f.shoulder - 0.8), y: f.top + 3.2)
    }

    /// The paw at the end of an arm reaching `reach` degrees up from hanging.
    func standingPaw(_ side: CGFloat, reach: CGFloat) -> CGPoint {
        let f = frame
        let a = standingShoulder(side)
        let theta = (22 + reach) * .pi / 180
        return CGPoint(x: a.x + side * f.armLength * sin(theta), y: a.y + f.armLength * cos(theta))
    }

    func standing(_ pose: CreaturePose, at base: CGPoint, scale s: CGFloat) -> CreatureForm {
        let f = frame
        let place = CGAffineTransform(scaleX: s, y: s)
            .concatenating(CGAffineTransform(rotationAngle: pose.lean * .pi / 180))
            .concatenating(CGAffineTransform(translationX: base.x, y: base.y))
        let body = CGAffineTransform(scaleX: 1 + 0.008 * pose.breath, y: 1 + 0.02 * pose.breath).concatenating(place)
        let lift = -f.top * 0.02 * pose.breath
        let face = CGAffineTransform(scaleX: f.head, y: f.head)
            .concatenating(CGAffineTransform(rotationAngle: pose.tilt * .pi / 180))
            .concatenating(CGAffineTransform(translationX: pose.headShift.width, y: f.headY + pose.headShift.height - lift))
            .concatenating(place)

        let h = f.bottom - f.top
        let torso = Sketch.blob([
            CGPoint(x: 0, y: f.top - 1.5),
            CGPoint(x: f.shoulder, y: f.top + 0.2),
            CGPoint(x: f.shoulder + (f.belly - f.shoulder) * 0.7, y: f.top + h * 0.36),
            CGPoint(x: f.belly, y: f.top + h * 0.7),
            CGPoint(x: f.belly * 0.8, y: f.bottom + 0.4),
            CGPoint(x: f.belly * 0.35, y: f.bottom + 2),
            CGPoint(x: -f.belly * 0.35, y: f.bottom + 2),
            CGPoint(x: -f.belly * 0.8, y: f.bottom + 0.4),
            CGPoint(x: -f.belly, y: f.top + h * 0.7),
            CGPoint(x: -(f.shoulder + (f.belly - f.shoulder) * 0.7), y: f.top + h * 0.36),
            CGPoint(x: -f.shoulder, y: f.top + 0.2),
        ]).applying(body)
        let legs = [CGFloat(-1), 1].map { side in
            Sketch.tube(CGPoint(x: side * f.stance, y: f.bottom - 3), CGPoint(x: side * f.stance, y: f.bottom - 1),
                        CGPoint(x: side * f.stance * 1.05, y: -4), CGPoint(x: side * f.stance * 1.08, y: -2.6), from: f.leg, to: f.leg * 0.95).applying(place)
        }
        let feet = [CGFloat(-1), 1].map { side in
            Sketch.oval(CGPoint(x: side * (f.stance + 1.2), y: side < 0 ? -2.3 : -2.9), f.foot.width, f.foot.height, turn: side * 11).applying(place)
        }
        var arms: [Path] = []
        for side: CGFloat in [-1, 1] where side < 0 ? pose.arms.left : pose.arms.right {
            let reach = side < 0 ? pose.reach.left : pose.reach.right
            let a = standingShoulder(side), b = standingPaw(side, reach: reach)
            let theta = (22 + reach) * .pi / 180
            let bend = CGPoint(x: side * cos(theta) * 1.8, y: -sin(theta) * 1.8)
            arms.append(Sketch.tube(a, CGPoint(x: a.x + (b.x - a.x) * 0.35 + bend.x, y: a.y + (b.y - a.y) * 0.35 + bend.y),
                                    CGPoint(x: a.x + (b.x - a.x) * 0.72 + bend.x, y: a.y + (b.y - a.y) * 0.72 + bend.y), b,
                                    from: f.arm, to: f.arm * 1.02).applying(body))
        }

        let head = Sketch.mochi(rx: f.rx, ry: f.ry, fullness: 0.07, squareness: f.square).applying(face)
        let (ears, inner, front) = naturalEars(pose.ears)
        var tail: Path?
        let swing = CGAffineTransform(rotationAngle: pose.tail * .pi / 180)
        switch self {
        case .cat:
            let root = CGPoint(x: f.belly - 3, y: f.bottom - 2)
            tail = Sketch.tube(root, CGPoint(x: f.belly + 6, y: f.bottom), CGPoint(x: f.belly + 11, y: f.bottom - 9), CGPoint(x: f.belly + 9, y: f.top),
                               from: 5, to: 4)
                .applying(CGAffineTransform(translationX: -root.x, y: -root.y).concatenating(swing)
                    .concatenating(CGAffineTransform(translationX: root.x, y: root.y)).concatenating(CGAffineTransform(scaleX: pose.tailSide, y: 1)))
                .applying(body)
        case .dog:
            let root = CGPoint(x: f.belly - 4, y: f.bottom - 4)
            tail = Sketch.tube(root, CGPoint(x: f.belly + 2, y: f.bottom - 5), CGPoint(x: f.belly + 5, y: f.bottom - 10), CGPoint(x: f.belly + 3, y: f.bottom - 15),
                               from: 4.8, to: 3.8)
                .applying(CGAffineTransform(translationX: -root.x, y: -root.y).concatenating(swing)
                    .concatenating(CGAffineTransform(translationX: root.x, y: root.y)).concatenating(CGAffineTransform(scaleX: pose.tailSide, y: 1)))
                .applying(body)
        case .bear, .rabbit:
            tail = nil
        }

        var patches: [Path] = []
        switch self {
        case .cat, .dog: patches = [Sketch.oval(CGPoint(x: 0, y: f.top + 6.5), 6.2, 6.8).applying(body)]
        case .bear: patches = [Sketch.oval(CGPoint(x: 0, y: f.top + h * 0.6), 8.8, 8.2).applying(body)]
        case .rabbit: patches = []
        }

        let snout: Path = switch self {
        case .cat:
            Sketch.oval(CGPoint(x: -2.7, y: 6.3), 3.7, 3.1).union(Sketch.oval(CGPoint(x: 2.7, y: 6.3), 3.7, 3.1)).union(Sketch.oval(CGPoint(x: 0, y: 8.7), 2.4, 1.8)).applying(face)
        case .bear: Sketch.oval(CGPoint(x: 0, y: 6.4), 8.2, 6.2).applying(face)
        case .dog: Sketch.oval(CGPoint(x: 0, y: 6.8), 7.8, 6.4).applying(face)
        case .rabbit: Sketch.oval(CGPoint(x: -2.3, y: 5.8), 3.1, 2.7).union(Sketch.oval(CGPoint(x: 2.3, y: 5.8), 3.1, 2.7)).applying(face)
        }

        return CreatureForm(torso: [torso] + legs, haunches: [], arms: [], head: head,
                            ears: ears.map { $0.applying(face) }, innerEars: inner.map { $0.applying(face) }, frontEars: front.map { $0.applying(face) },
                            tail: tail, tailSide: pose.tailSide, paws: feet, patches: patches, legGap: nil,
                            face: face, place: place, base: base, size: s,
                            snout: snout, frontArms: arms, whiteFeet: self == .cat, natural: true)
    }

    /// Just the head and two paws, for holding on to the top edge of a card, a button or the tab bar.
    /// The edge sits at y = 0 in the creature's own space.
    func peeking(_ pose: CreaturePose, at base: CGPoint, scale s: CGFloat, paws showPaws: Bool = true) -> CreatureForm {
        let f = frame
        let place = CGAffineTransform(scaleX: s, y: s).concatenating(CGAffineTransform(translationX: base.x, y: base.y))
        let face = CGAffineTransform(scaleX: f.head, y: f.head)
            .concatenating(CGAffineTransform(rotationAngle: pose.tilt * .pi / 180))
            .concatenating(CGAffineTransform(translationX: pose.headShift.width, y: (-f.ry + 4) * f.head - pose.breath * 0.5))
            .concatenating(place)
        let (ears, inner, front) = naturalEars(pose.ears)
        let paws = [CGFloat(-1), 1].map { side in Sketch.oval(CGPoint(x: side * f.rx * f.head * 0.88, y: -0.6), f.arm * 0.82, f.arm * 0.62).applying(place) }
        let full = standing(pose, at: .zero, scale: 1)
        return CreatureForm(torso: [], haunches: [], arms: [], head: Sketch.mochi(rx: f.rx, ry: f.ry, fullness: 0.06, squareness: f.square).applying(face),
                            ears: ears.map { $0.applying(face) }, innerEars: inner.map { $0.applying(face) }, frontEars: front.map { $0.applying(face) },
                            tail: nil, tailSide: 1, paws: showPaws ? paws : [], patches: [], legGap: nil, face: face, place: place, base: base, size: s,
                            snout: full.snout.map { $0.applying(full.face.inverted()).applying(face) }, frontArms: [], whiteFeet: self == .cat, natural: true)
    }

    private func naturalEars(_ turn: (left: CGFloat, right: CGFloat)) -> ([Path], [Path], [Path]) {
        func turned(_ p: Path, _ degrees: CGFloat, around h: CGPoint) -> Path {
            p.applying(CGAffineTransform(translationX: -h.x, y: -h.y)
                .concatenating(CGAffineTransform(rotationAngle: degrees * .pi / 180))
                .concatenating(CGAffineTransform(translationX: h.x, y: h.y)))
        }
        let flip = CGAffineTransform(scaleX: -1, y: 1)
        func pair(_ ear: Path, _ inner: Path?, _ hinge: CGPoint) -> ([Path], [Path]) {
            let l = turned(ear.applying(flip), -turn.left, around: CGPoint(x: -hinge.x, y: hinge.y))
            let r = turned(ear, turn.right, around: hinge)
            guard let inner else { return ([l, r], []) }
            return ([l, r], [turned(inner.applying(flip), -turn.left, around: CGPoint(x: -hinge.x, y: hinge.y)), turned(inner, turn.right, around: hinge)])
        }
        switch self {
        case .cat:
            let ear = Sketch.roundedTriangle(CGPoint(x: 6.5, y: -12.5), CGPoint(x: 20.5, y: -5), CGPoint(x: 17, y: -30), radius: 3.2)
            let inner = Sketch.roundedTriangle(CGPoint(x: 10, y: -11.6), CGPoint(x: 17.6, y: -7.4), CGPoint(x: 16, y: -24.6), radius: 1.9)
            let (e, i) = pair(ear, inner, CGPoint(x: 12, y: -10))
            return (e, i, [])
        case .bear:
            let (e, i) = pair(Sketch.oval(CGPoint(x: 14.5, y: -14), 6.4, 6.2), Sketch.oval(CGPoint(x: 14.1, y: -13.4), 3.4, 3.3), CGPoint(x: 13, y: -10))
            return (e, i, [])
        case .rabbit:
            let l = Sketch.tube(CGPoint(x: -6.5, y: -12), CGPoint(x: -7.5, y: -24), CGPoint(x: -8.5, y: -34), CGPoint(x: -7.5, y: -41), from: 6.4, to: 5.6, bulge: 1.8)
            let r = Sketch.tube(CGPoint(x: 6.5, y: -12), CGPoint(x: 9, y: -24), CGPoint(x: 11.5, y: -33), CGPoint(x: 15.5, y: -38), from: 6.4, to: 5.6, bulge: 1.8)
            let li = Sketch.tube(CGPoint(x: -6.5, y: -12), CGPoint(x: -7.5, y: -24), CGPoint(x: -8.5, y: -34), CGPoint(x: -7.5, y: -41), from: 2.6, to: 2.2, bulge: 1, trim: 0.22...0.86)
            let ri = Sketch.tube(CGPoint(x: 6.5, y: -12), CGPoint(x: 9, y: -24), CGPoint(x: 11.5, y: -33), CGPoint(x: 15.5, y: -38), from: 2.6, to: 2.2, bulge: 1, trim: 0.22...0.86)
            return ([turned(l, -turn.left, around: CGPoint(x: -6.5, y: -12)), turned(r, turn.right, around: CGPoint(x: 6.5, y: -12))],
                    [turned(li, -turn.left, around: CGPoint(x: -6.5, y: -12)), turned(ri, turn.right, around: CGPoint(x: 6.5, y: -12))], [])
        case .dog:
            let ear = Sketch.blob([CGPoint(x: 12.5, y: -13), CGPoint(x: 19.5, y: -14), CGPoint(x: 24.5, y: -6), CGPoint(x: 25.5, y: 4),
                                   CGPoint(x: 22.5, y: 10), CGPoint(x: 18.5, y: 6), CGPoint(x: 16.5, y: -3), CGPoint(x: 13.5, y: -8)])
            let (e, _) = pair(ear, nil, CGPoint(x: 15, y: -12))
            return ([], [], e)
        }
    }
}
