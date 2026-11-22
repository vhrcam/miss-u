import SwiftUI

enum CreatureEyes {
    case open, content, happy
}

/// How a creature holds itself. Angles are in degrees.
struct CreaturePose {
    var lean: CGFloat = 0
    var tilt: CGFloat = 0
    var headShift = CGSize.zero
    var turn: CGFloat = 0
    var gaze = CGPoint.zero
    var eyes = CreatureEyes.open
    var blush = 0.55
    var ears: (left: CGFloat, right: CGFloat) = (0, 0)
    var tail: CGFloat = 0
    var tailSide: CGFloat = 1
    var arms: (left: Bool, right: Bool) = (true, true)
    var breath: CGFloat = 0
    var blink: CGFloat = 0
}

/// A creature's shapes, placed in the scene. The torso, haunches, arms, head, ears and tail
/// are painted as one form; paws and floppy ears sit in front of it.
struct CreatureForm {
    var torso: [Path]
    var haunches: [Path]
    var arms: [(Path, CGFloat)]
    var head: Path
    var ears: [Path]
    var innerEars: [Path]
    var frontEars: [Path]
    var tail: Path?
    var tailSide: CGFloat
    var paws: [Path]
    var patches: [Path]
    var legGap: Path?
    var face: CGAffineTransform
    var place: CGAffineTransform
    var base: CGPoint
    var size: CGFloat
    var snout: Path? = nil
    var frontArms: [Path] = []
    var whiteFeet = false
    var natural = false

    var silhouette: [Path] { torso + [head] + ears + (tail.map { [$0] } ?? []) }
}

private struct Build {
    var hip: CGFloat
    var height: CGFloat
    var shoulder: CGFloat
    var neck: CGFloat
    var rx: CGFloat
    var ry: CGFloat
    var square: CGFloat
}

extension Species {
    private var build: Build {
        switch self {
        case .cat: Build(hip: 18, height: 37, shoulder: 10.5, neck: 15, rx: 25.5, ry: 19.5, square: 2.5)
        case .bear: Build(hip: 19.5, height: 37, shoulder: 12, neck: 14.5, rx: 24.5, ry: 20.5, square: 2.3)
        case .dog: Build(hip: 18.5, height: 37, shoulder: 11, neck: 15, rx: 25, ry: 20, square: 2.4)
        case .rabbit: Build(hip: 17.5, height: 36, shoulder: 10, neck: 15, rx: 24, ry: 20.5, square: 2.3)
        }
    }

    private var hasArms: Bool { self == .bear || self == .dog }

    /// Where the hugging arm starts, in the creature's own space.
    func shoulder(_ side: CGFloat) -> CGPoint {
        let b = build
        return CGPoint(x: side * (b.shoulder + 2.5), y: -b.height + 7.5)
    }

    func form(_ pose: CreaturePose, at base: CGPoint, scale s: CGFloat) -> CreatureForm {
        let b = build
        let place = CGAffineTransform(scaleX: s, y: s)
            .concatenating(CGAffineTransform(rotationAngle: pose.lean * .pi / 180))
            .concatenating(CGAffineTransform(translationX: base.x, y: base.y))
        let body = CGAffineTransform(scaleX: 1 - 0.006 * pose.breath, y: 1 + 0.016 * pose.breath).concatenating(place)
        let lift = b.height * 0.016 * pose.breath
        let face = CGAffineTransform(rotationAngle: pose.tilt * .pi / 180)
            .concatenating(CGAffineTransform(translationX: pose.headShift.width, y: -b.height - b.neck + pose.headShift.height - lift))
            .concatenating(place)

        let haunches = [CGFloat(-1), 1].map { side in Sketch.oval(CGPoint(x: side * (b.hip - 5.2), y: -8.2), 8.6, 8).applying(body) }
        var arms: [(Path, CGFloat)] = []
        if hasArms {
            for side: CGFloat in [-1, 1] where side < 0 ? pose.arms.left : pose.arms.right {
                let arm = Sketch.tube(shoulder(side), CGPoint(x: side * (b.shoulder + 5.5), y: -b.height + 13),
                                      CGPoint(x: side * (b.hip + 1.5), y: -b.height * 0.56), CGPoint(x: side * (b.hip + 0.6), y: -b.height * 0.4),
                                      from: 9, to: 8.4)
                arms.append((arm.applying(body), side))
            }
        }
        let torso = [Self.torso(hip: b.hip, height: b.height, shoulder: b.shoulder).applying(body)] + haunches + arms.map(\.0)

        let (ears, inner, front) = earShapes(pose.ears)
        let tail = tailShape(hip: b.hip, swing: pose.tail, side: pose.tailSide)?.applying(body)

        var patches: [Path] = []
        switch self {
        case .cat:
            patches = [Sketch.oval(CGPoint(x: 0, y: -22), 8, 10.5).applying(body), Sketch.oval(CGPoint(x: 0, y: 6.4), 7.2, 5).applying(face)]
        case .bear:
            patches = [Sketch.oval(CGPoint(x: 0, y: -15), 11, 12.5).applying(body), Sketch.oval(CGPoint(x: 0, y: 6.4), 8.4, 6.3).applying(face)]
        case .dog:
            patches = [Sketch.oval(CGPoint(x: 0, y: -20), 8.5, 11).applying(body), Sketch.oval(CGPoint(x: 0, y: 6.2), 8, 5.8).applying(face)]
        case .rabbit:
            patches = []
        }

        let paws: [Path] = switch self {
        case .bear: [-1, 1].map { Sketch.oval(CGPoint(x: $0 * 7.2, y: -3.4), 5.6, 4).applying(place) }
        case .dog: [-1, 1].map { Sketch.oval(CGPoint(x: $0 * 5.6, y: -3), 5, 3.5).applying(place) }
        case .rabbit: [-1, 1].map { Sketch.oval(CGPoint(x: $0 * 5, y: -2.8), 4.6, 3.2).applying(place) }
        case .cat: [-1, 1].map { Sketch.oval(CGPoint(x: $0 * 5.4, y: -2.9), 4.8, 3.4).applying(place) }
        }
        var gap: Path?
        if !hasArms {
            var p = Path()
            p.move(to: CGPoint(x: 0, y: -3))
            p.addLine(to: CGPoint(x: 0, y: -13))
            gap = p.applying(body)
        }

        return CreatureForm(torso: torso, haunches: haunches, arms: arms, head: Sketch.mochi(rx: b.rx, ry: b.ry, squareness: b.square).applying(face),
                            ears: ears.map { $0.applying(face) }, innerEars: inner.map { $0.applying(face) }, frontEars: front.map { $0.applying(face) },
                            tail: tail, tailSide: pose.tailSide, paws: paws, patches: patches, legGap: gap,
                            face: face, place: place, base: base, size: s)
    }

    private static func torso(hip w: CGFloat, height h: CGFloat, shoulder sh: CGFloat) -> Path {
        Sketch.blob([
            CGPoint(x: 0, y: -h),
            CGPoint(x: -sh, y: -h + 1.6),
            CGPoint(x: -(sh + w) / 2 - 1, y: -h * 0.74),
            CGPoint(x: -w, y: -h * 0.42),
            CGPoint(x: -w, y: -h * 0.17),
            CGPoint(x: -w * 0.74, y: -h * 0.025),
            CGPoint(x: -w * 0.3, y: 0.4),
            CGPoint(x: w * 0.3, y: 0.4),
            CGPoint(x: w * 0.74, y: -h * 0.025),
            CGPoint(x: w, y: -h * 0.17),
            CGPoint(x: w, y: -h * 0.42),
            CGPoint(x: (sh + w) / 2 + 1, y: -h * 0.74),
            CGPoint(x: sh, y: -h + 1.6),
        ])
    }

    /// Ears in head space: behind the head, their pink insides, and ears that hang in front.
    private func earShapes(_ turn: (left: CGFloat, right: CGFloat)) -> ([Path], [Path], [Path]) {
        func turned(_ p: Path, _ degrees: CGFloat, around h: CGPoint) -> Path {
            p.applying(CGAffineTransform(translationX: -h.x, y: -h.y)
                .concatenating(CGAffineTransform(rotationAngle: degrees * .pi / 180))
                .concatenating(CGAffineTransform(translationX: h.x, y: h.y)))
        }
        let flip = CGAffineTransform(scaleX: -1, y: 1)
        switch self {
        case .cat:
            let ear = Sketch.roundedTriangle(CGPoint(x: 6.5, y: -14.5), CGPoint(x: 22.5, y: -8.5), CGPoint(x: 16.5, y: -30.5), radius: 3.4)
            let inner = Sketch.roundedTriangle(CGPoint(x: 10.2, y: -13.6), CGPoint(x: 19.6, y: -10.6), CGPoint(x: 16.2, y: -25.6), radius: 2)
            let hinge = CGPoint(x: 15, y: -12)
            return ([turned(ear.applying(flip), -turn.left, around: CGPoint(x: -hinge.x, y: hinge.y)), turned(ear, turn.right, around: hinge)],
                    [turned(inner.applying(flip), -turn.left, around: CGPoint(x: -hinge.x, y: hinge.y)), turned(inner, turn.right, around: hinge)], [])
        case .bear:
            let ear = Sketch.oval(CGPoint(x: 17.5, y: -15.5), 7.4, 7.4)
            let inner = Sketch.oval(CGPoint(x: 17, y: -14.6), 3.9, 3.9)
            let hinge = CGPoint(x: 16, y: -11)
            return ([turned(ear.applying(flip), -turn.left, around: CGPoint(x: -hinge.x, y: hinge.y)), turned(ear, turn.right, around: hinge)],
                    [turned(inner.applying(flip), -turn.left, around: CGPoint(x: -hinge.x, y: hinge.y)), turned(inner, turn.right, around: hinge)], [])
        case .rabbit:
            let left = (CGPoint(x: -8, y: -13), CGPoint(x: -9.5, y: -28), CGPoint(x: -10.5, y: -40), CGPoint(x: -9, y: -49))
            let right = (CGPoint(x: 8, y: -13), CGPoint(x: 11.5, y: -28), CGPoint(x: 14.5, y: -40), CGPoint(x: 19.5, y: -46.5))
            let l = Sketch.tube(left.0, left.1, left.2, left.3, from: 7.2, to: 6.2, bulge: 2.2)
            let r = Sketch.tube(right.0, right.1, right.2, right.3, from: 7.2, to: 6.2, bulge: 2.2)
            let li = Sketch.tube(left.0, left.1, left.2, left.3, from: 3, to: 2.6, bulge: 1.2, trim: 0.2...0.86)
            let ri = Sketch.tube(right.0, right.1, right.2, right.3, from: 3, to: 2.6, bulge: 1.2, trim: 0.2...0.86)
            return ([turned(l, -turn.left, around: left.0), turned(r, turn.right, around: right.0)],
                    [turned(li, -turn.left, around: left.0), turned(ri, turn.right, around: right.0)], [])
        case .dog:
            let ear = Sketch.blob([CGPoint(x: 14, y: -15), CGPoint(x: 22.5, y: -15.5), CGPoint(x: 29, y: -8), CGPoint(x: 31, y: 2),
                                   CGPoint(x: 29, y: 11), CGPoint(x: 24, y: 14), CGPoint(x: 20.5, y: 8), CGPoint(x: 19, y: -2), CGPoint(x: 16, y: -9)])
            let hinge = CGPoint(x: 17, y: -14)
            return ([], [], [turned(ear.applying(flip), -turn.left, around: CGPoint(x: -hinge.x, y: hinge.y)), turned(ear, turn.right, around: hinge)])
        }
    }

    private func tailShape(hip w: CGFloat, swing: CGFloat, side: CGFloat) -> Path? {
        let tail: Path
        let root: CGPoint
        switch self {
        case .cat:
            root = CGPoint(x: w - 6, y: -4)
            tail = Sketch.tube(root, CGPoint(x: w + 7, y: -1), CGPoint(x: w + 13.5, y: -10), CGPoint(x: w + 11, y: -23), from: 5.4, to: 4.4)
        case .dog:
            root = CGPoint(x: w - 7, y: -6)
            tail = Sketch.tube(root, CGPoint(x: w + 2, y: -5), CGPoint(x: w + 6, y: -9), CGPoint(x: w + 7, y: -15), from: 5, to: 4.2)
        case .bear, .rabbit:
            return nil
        }
        return tail.applying(CGAffineTransform(translationX: -root.x, y: -root.y)
            .concatenating(CGAffineTransform(rotationAngle: swing * .pi / 180))
            .concatenating(CGAffineTransform(translationX: root.x, y: root.y))
            .concatenating(CGAffineTransform(scaleX: side, y: 1)))
    }
}
