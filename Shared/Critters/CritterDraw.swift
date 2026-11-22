import SwiftUI

extension CritterPaint {
    func critter(_ species: Species, fur: Fur, rig: CritterRig, mood: CritterMood, life: CritterLife = CritterLife()) {
        let coat = fur.coat
        let t = rig.torso
        let rise = (t.bottom - t.top) * 0.018 * life.breath
        let swell = CGAffineTransform(translationX: t.cx, y: t.bottom)
            .scaledBy(x: 1 - 0.008 * life.breath, y: 1 + 0.018 * life.breath)
            .translatedBy(x: -t.cx, y: -t.bottom)
        let torso = t.path.applying(swell)
        let place = CGAffineTransform(translationX: rig.head.x, y: rig.head.y - rise)
            .rotated(by: (rig.tilt + life.gaze.x * 2.5) * .pi / 180)
        let skull = species.skull.applying(place)
        let arms = rig.arms.map { $0.path.applying(CGAffineTransform(translationX: 0, y: -rise * 0.7)) }
        let feet = rig.feet.filter { $0.size > 0.02 }.map(\.path)
        let tail = species.tail(from: t.tailBase(rig.tailSide), swing: life.tail, side: rig.tailSide)
        let behind = rig.armsInFront ? [] : arms

        ground(rig.shadow)

        var body: [(Path, Color)] = []
        if let tail { body.append((tail, coat.line)) }
        body += behind.map { ($0, coat.line) }
        body.append((torso, coat.line))
        body += feet.map { ($0, coat.line) }
        outline(body)

        if let tail { form(tail, coat) }
        for arm in behind { form(arm, coat) }
        form(torso, coat, light: CGPoint(x: t.cx - t.hip * 0.35, y: t.top + (t.bottom - t.top) * 0.3))
        if let tail { crease(torso, inside: tail, coat.crease) }
        for arm in behind { crease(torso, inside: arm, coat.crease) }
        var belly = self
        belly.context.clip(to: torso)
        belly.glow(CGPoint(x: t.cx - 2.5, y: t.top + (t.bottom - t.top) * 0.62), t.hip * 0.62, (t.bottom - t.top) * 0.34, coat.light, 0.55)
        bounce(in: torso, from: t.bottom - 10, to: t.bottom, coat.light)
        shadow(of: skull, onto: torso, coat.deep, opacity: 0.55, offset: CGSize(width: 0.8, height: 2.6), blur: 2.6)
        for foot in feet {
            form(foot, coat)
            crease(foot, inside: torso, coat.crease)
        }

        head(species, fur: fur, mood: mood, life: life, at: place, beneath: [torso])

        var under = [torso, skull]
        if rig.heart > 0.02 {
            let beat = life.clock.map { 1 + 0.035 * CritterLife.heartbeat($0) } ?? 1
            let center = CGPoint(x: 50, y: 75.5 - rise * 0.5)
            shadow(of: CritterPaint.heartShape(center, 21 * rig.heart), onto: torso, coat.deep, opacity: 0.4 * rig.heart, offset: CGSize(width: 0.6, height: 1.6), blur: 1.8)
            under.append(heart(at: center, width: 21 * rig.heart * beat, opacity: min(1, rig.heart * 1.5)))
        }
        if rig.armsInFront {
            outline(arms.map { ($0, coat.line) }, outside: under)
            for arm in arms {
                shadow(of: arm, onto: torso, coat.deep, opacity: 0.4, offset: CGSize(width: 0.5, height: 1.4), blur: 1.5)
                form(arm, coat)
                for u in under { crease(arm, inside: u, coat.crease) }
            }
        }
        floaters(rig: rig, place: place, life: life)
    }

    /// Ears, head and face. `beneath` is whatever the head overlaps, so its edge there turns into a soft crease.
    @discardableResult
    func head(_ species: Species, fur: Fur, mood: CritterMood, life: CritterLife, at place: CGAffineTransform, beneath: [Path] = []) -> Path {
        let coat = fur.coat
        let skull = species.skull.applying(place)
        let ears = species.ears(twitch: life.ears).map { $0.applying(place) }
        let back = ears.filter { !$0.front }, front = ears.filter(\.front)

        outline(back.map { ($0.outer, coat.line) } + [(skull, coat.line)], outside: beneath)
        for ear in back {
            self.ear(ear, fur)
            shadow(of: skull, onto: ear.outer, coat.deep, opacity: 0.35, offset: .zero, blur: 2.2)
        }
        form(skull, coat, light: CGPoint(x: -8, y: -12).applying(place))
        for ear in back { crease(skull, inside: ear.outer, coat.crease) }
        for b in beneath { crease(skull, inside: b, coat.crease) }
        sheen(skull, at: CGPoint(x: -9, y: -9).applying(place), 15, 10, opacity: 0.3)

        var face = self
        face.context.concatenate(place)
        face.face(species, fur: fur, mood: mood, life: life)

        if !front.isEmpty {
            outline(front.map { ($0.outer, fur.accent.line) }, outside: [skull] + beneath)
            for ear in front {
                shadow(of: ear.outer, onto: skull, coat.deep, opacity: 0.35, offset: CGSize(width: 0.4, height: 1.2), blur: 1.6)
                self.ear(ear, fur)
                crease(ear.outer, inside: skull, fur.accent.crease)
            }
        }
        return skull
    }

    /// Two paws gripping an edge at `y`, in front of the head.
    func paws(_ fur: Fur, at y: CGFloat, over skull: Path) {
        let coat = fur.coat
        let paws = [-15.5, 15.5].map { x in Path(ellipseIn: CGRect(x: x - 4.9, y: y - 3.7, width: 9.8, height: 7.4)) }
        outline(paws.map { ($0, coat.line) }, outside: [skull])
        for paw in paws {
            shadow(of: paw, onto: skull, coat.deep, opacity: 0.35, offset: CGSize(width: 0.4, height: 1), blur: 1.2)
            form(paw, coat)
            crease(paw, inside: skull, coat.crease)
            let r = paw.boundingRect
            for dx: CGFloat in [-1.7, 1.7] {
                var toe = Path()
                toe.move(to: CGPoint(x: r.midX + dx, y: r.minY + 4))
                toe.addLine(to: CGPoint(x: r.midX + dx, y: r.minY + 5.4))
                pen(toe, coat.crease)
            }
        }
    }

    func floaters(rig: CritterRig, place: CGAffineTransform, life: CritterLife) {
        if rig.zs > 0.5 {
            if let t = life.clock {
                for i in 0..<3 {
                    let p = CritterLife.cycle(t + Double(i) * 1.15, 3.45)
                    z(at: CGPoint(x: 64 + 13 * p + 1.6 * sin(p * 6.3), y: 54 - 26 * p), size: 3.4 + 3.6 * p, opacity: CritterLife.fade(p) * Double(rig.zs))
                }
            } else {
                for (x, y, s) in [(73.0, 47.0, 4.5), (80, 38.5, 6), (88.5, 28, 7.5)] {
                    z(at: CGPoint(x: x, y: y), size: s, opacity: 1)
                }
            }
        }
        guard let t = life.clock else { return }
        if rig.heart > 0.6 {
            for i in 0..<2 {
                let p = CritterLife.cycle(t + Double(i) * 1.7, 3.4)
                heart(at: CGPoint(x: 50 + 5 * sin(p * 5 + Double(i) * 2), y: 66 - 34 * p), width: 6.4 * (1 - 0.3 * p), outlined: false, opacity: CritterLife.fade(p) * 0.9)
            }
        }
        if let pop = life.pop {
            let start = CGPoint(x: 0, y: -24).applying(place)
            heart(at: CGPoint(x: start.x + 3 * sin(pop * 5), y: start.y - 16 * pop), width: 7.5 + 2 * pop, outlined: false, opacity: CritterLife.fade(Double(pop)))
        }
    }
}
