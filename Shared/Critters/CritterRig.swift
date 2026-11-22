import SwiftUI

enum CritterPose: CaseIterable {
    case idle, sitting, sleeping, heart

    var mood: CritterMood {
        switch self {
        case .idle, .sitting: .happy
        case .sleeping: .sleepy
        case .heart: .love
        }
    }

    var rig: CritterRig {
        switch self {
        case .idle: .standing
        case .sitting: .sitting
        case .sleeping: .sleeping
        case .heart: .holdingHeart
        }
    }
}

enum CritterMood: CaseIterable {
    case happy, love, sleepy, surprised
}

/// Where every part of a character sits. A pose is only a rig, and any two rigs blend,
/// so a character moves from one pose to the next instead of jumping.
struct CritterRig {
    struct Torso {
        var cx: CGFloat = 50
        var top: CGFloat
        var bottom: CGFloat = 92.5
        var shoulder: CGFloat
        var hip: CGFloat
        var notch: CGFloat = 0
        var hump: CGFloat = 0
    }

    struct Limb {
        var from: CGPoint
        var to: CGPoint
        var width: CGFloat
    }

    struct Foot {
        var center: CGPoint
        var size: CGFloat
        var angle: CGFloat
    }

    var torso: Torso
    var head: CGPoint
    var tilt: CGFloat = 0
    var arms: [Limb]
    var armsInFront = false
    var feet = [Foot(center: CGPoint(x: 39.5, y: 87), size: 0, angle: -0.26),
                Foot(center: CGPoint(x: 60.5, y: 87), size: 0, angle: 0.26)]
    var heart: CGFloat = 0
    var zs: CGFloat = 0
    var tailSide: CGFloat = 1
    var shadow: CGRect

    static let standing = CritterRig(
        torso: Torso(top: 54, shoulder: 15, hip: 19, notch: 4.5),
        head: CGPoint(x: 50, y: 43),
        arms: [Limb(36, 63, 30.5, 76), Limb(64, 63, 69.5, 76)],
        shadow: CGRect(x: 29, y: 90, width: 42, height: 6))

    static let sitting = CritterRig(
        torso: Torso(top: 61, shoulder: 15.5, hip: 21),
        head: CGPoint(x: 50, y: 50),
        arms: [Limb(35.5, 68, 28, 80.5), Limb(64.5, 68, 72, 80.5)],
        feet: [Foot(center: CGPoint(x: 39.5, y: 87), size: 1, angle: -0.26),
               Foot(center: CGPoint(x: 60.5, y: 87), size: 1, angle: 0.26)],
        shadow: CGRect(x: 26, y: 90, width: 48, height: 6))

    static let sleeping = CritterRig(
        torso: Torso(cx: 66, top: 63, shoulder: 15, hip: 24, hump: 5),
        head: CGPoint(x: 39, y: 67), tilt: -10,
        arms: [Limb(26, 89.3, 31, 89.3, width: 6.8), Limb(43, 90, 48, 90, width: 6.8)],
        armsInFront: true,
        feet: [Foot(center: CGPoint(x: 60, y: 90), size: 0, angle: 0),
               Foot(center: CGPoint(x: 86, y: 88), size: 0.75, angle: 1.1)],
        zs: 1,
        shadow: CGRect(x: 12, y: 90, width: 80, height: 6))

    static let holdingHeart = CritterRig(
        torso: Torso(top: 54, shoulder: 15, hip: 19, notch: 4.5),
        head: CGPoint(x: 50, y: 43),
        arms: [Limb(33, 64, 41.5, 74.5, width: 8.2), Limb(67, 64, 58.5, 74.5, width: 8.2)],
        armsInFront: true,
        heart: 1,
        shadow: CGRect(x: 29, y: 90, width: 42, height: 6))
}

extension CritterRig.Limb {
    init(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, width: CGFloat = 8.4) {
        self.init(from: CGPoint(x: x1, y: y1), to: CGPoint(x: x2, y: y2), width: width)
    }
}

func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }
func lerp(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint { CGPoint(x: lerp(a.x, b.x, t), y: lerp(a.y, b.y, t)) }

extension CritterRig {
    /// The pose `t` of the way from `a` to `b`.
    static func blend(_ a: CritterRig, _ b: CritterRig, _ t: CGFloat) -> CritterRig {
        var r = t < 0.5 ? a : b
        let x = a.torso, y = b.torso
        r.torso = Torso(cx: lerp(x.cx, y.cx, t), top: lerp(x.top, y.top, t), bottom: lerp(x.bottom, y.bottom, t),
                        shoulder: lerp(x.shoulder, y.shoulder, t), hip: lerp(x.hip, y.hip, t),
                        notch: lerp(x.notch, y.notch, t), hump: lerp(x.hump, y.hump, t))
        r.head = lerp(a.head, b.head, t)
        r.tilt = lerp(a.tilt, b.tilt, t)
        r.arms = zip(a.arms, b.arms).map { Limb(from: lerp($0.from, $1.from, t), to: lerp($0.to, $1.to, t), width: lerp($0.width, $1.width, t)) }
        r.feet = zip(a.feet, b.feet).map { Foot(center: lerp($0.center, $1.center, t), size: lerp($0.size, $1.size, t), angle: lerp($0.angle, $1.angle, t)) }
        r.heart = lerp(a.heart, b.heart, t)
        r.zs = lerp(a.zs, b.zs, t)
        r.shadow = CGRect(x: lerp(a.shadow.minX, b.shadow.minX, t), y: lerp(a.shadow.minY, b.shadow.minY, t),
                          width: lerp(a.shadow.width, b.shadow.width, t), height: lerp(a.shadow.height, b.shadow.height, t))
        return r
    }
}
