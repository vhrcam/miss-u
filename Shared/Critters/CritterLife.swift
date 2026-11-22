import SwiftUI

/// The small movements that make a character feel alive: breathing, blinking, an ear flick, a tail sway.
struct CritterLife {
    var breath: CGFloat = 0
    var blink: CGFloat = 0
    var gaze: CGPoint = .zero
    var glee: CGFloat = 0
    var ears: (left: CGFloat, right: CGFloat) = (0, 0)
    var tail: CGFloat = 0
    var clock: Double?
    var pop: CGFloat?

    /// `calm` keeps only the blinks, for Reduce Motion.
    static func at(_ t: Double, species: Species, calm: Bool = false) -> CritterLife {
        var life = CritterLife(clock: t)
        life.blink = blink(t)
        guard !calm else { return life }
        life.breath = CGFloat(sin(t * 2 * .pi / 3.7))
        let flick = earFlick(t)
        life.ears = Int((t / 8.3).rounded(.down)) % 2 == 0 ? (flick, 0) : (0, flick)
        life.tail = species == .dog ? CGFloat(7 * sin(t * 2 * .pi / 1.4)) : CGFloat(6 * sin(t * 2 * .pi / 4.8))
        return life
    }

    static func blink(_ t: Double) -> CGFloat {
        let period = 4.6
        let k = (t / period).rounded(.down)
        let local = t - k * period - noise(k) * 1.8
        var b = pulse(local, 0.16)
        if Int(k) % 3 == 0 { b = max(b, pulse(local - 0.3, 0.15)) }
        return CGFloat(b)
    }

    static func earFlick(_ t: Double) -> CGFloat {
        let e = cycle(t, 8.3) * 8.3
        if e < 0.2 { return CGFloat(10 * sin(e / 0.2 * .pi)) }
        if e < 0.6 { return CGFloat(-3 * sin((e - 0.2) / 0.4 * .pi)) }
        return 0
    }

    /// 0...1 while two characters look at each other, every ten seconds or so.
    static func glance(_ t: Double) -> CGFloat {
        let e = cycle(t, 10) * 10
        return CGFloat(smooth((e - 3) / 0.5) - smooth((e - 5.8) / 0.5))
    }

    static func heartbeat(_ t: Double) -> Double {
        let p = cycle(t, 1.6)
        return pulse(p, 0.12) + 0.6 * pulse(p - 0.2, 0.12)
    }

    static func cycle(_ t: Double, _ period: Double) -> Double {
        let x = t / period
        return x - x.rounded(.down)
    }

    /// Fades in quickly, holds, then fades out over the last 40%.
    static func fade(_ p: Double) -> Double {
        min(1, p / 0.15) * (p > 0.6 ? max(0, 1 - (p - 0.6) / 0.4) : 1)
    }

    static func smooth(_ x: Double) -> Double {
        let c = min(1, max(0, x))
        return c * c * (3 - 2 * c)
    }

    private static func pulse(_ x: Double, _ d: Double) -> Double {
        x > 0 && x < d ? sin(x / d * .pi) : 0
    }

    private static func noise(_ k: Double) -> Double {
        let x = sin(k * 12.9898 + 4.1) * 43758.5453
        return x - x.rounded(.down)
    }
}
