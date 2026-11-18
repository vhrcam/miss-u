import SwiftUI

struct AvatarView: View {
    var config: AvatarConfig
    var activity: ActivityKind? = nil
    var animated: Bool = false

    var body: some View {
        let rig = Rig(config: config, activity: activity)
        Group {
            if animated {
                TimelineView(.animation(minimumInterval: 1 / 30)) { context in
                    rig.frame(at: context.date.timeIntervalSinceReferenceDate)
                }
            } else {
                rig.frame(at: nil)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

extension AvatarView {
    struct Motion {
        var sx: CGFloat = 1
        var sy: CGFloat = 1
        var tilt: Double = 0
        var hop: CGFloat = 0
    }

    struct Rig {
        var base: [Layer] = []
        var face: [Layer] = []
        var blink: [Layer] = []
        var top: [Layer] = []
        var activity: ActivityKind?

        init(config: AvatarConfig, activity: ActivityKind?) {
            self.activity = activity
            let pose = AvatarView.pose(activity)
            let mood = expression(activity)
            let sporty = activity == .exercising
            let hat = config.accessory == .beanie || config.accessory == .cap
            let clothes: Outfit? = sporty ? nil : config.outfit
            let arms = AvatarView.arms(pose, activity, config.color.fill, clothes, config.shirt.fill)

            base += hairBack(config.hair, config.color.deep, hatted: hat && !sporty)
            base += behind(activity)
            base += feet(config.color)
            if pose != .hold {
                base += arms
            }
            base += body(config.color)
            base += sporty ? tank(config.shirt) : outfit(config.outfit, config.shirt)
            base += hairFront(config.hair, config.color.deep)
            if !(sporty && hat) {
                base += accessory(config.accessory, config.shirt)
            }
            if sporty {
                base += sweatband(config.shirt)
            }
            if pose == .hold {
                base += activity == .working ? arms + prop(activity) : prop(activity) + arms
            }
            if config.accessory == .glasses {
                top += glasses
            }
            if activity == .music {
                top += headphones
            }
            face = AvatarView.face(mood, config.presentation)
            blink = AvatarView.face(mood, config.presentation, blink: true)

            if pose == .lie {
                base = pillow + base.map { $0.applying(lying) } + blanket(config.shirt)
                face = face.map { $0.applying(lying) }
                blink = blink.map { $0.applying(lying) }
                top = top.map { $0.applying(lying) }
            }
        }

        @ViewBuilder
        func frame(at t: Double?) -> some View {
            if let t {
                let m = motion(at: t)
                ZStack {
                    ZStack {
                        Stack(layers: base)
                        Stack(layers: blinking(at: t) ? blink : face)
                        Stack(layers: top)
                    }
                    .visualEffect { content, proxy in
                        content
                            .offset(y: -m.hop * proxy.size.height / 100)
                            .scaleEffect(x: m.sx, y: m.sy, anchor: UnitPoint(x: 0.5, y: 0.9))
                            .rotationEffect(.degrees(m.tilt), anchor: UnitPoint(x: 0.5, y: 0.9))
                    }
                    Stack(layers: effects(at: t))
                }
            } else {
                ZStack {
                    Stack(layers: base)
                    Stack(layers: face)
                    Stack(layers: top)
                    Stack(layers: effects(at: nil))
                }
            }
        }

        func motion(at t: Double) -> Motion {
            let breath = sin(t * 2 * .pi / 3.2)
            return Motion(sx: 1 - 0.012 * breath, sy: 1 + 0.02 * breath)
        }

        func blinking(at t: Double) -> Bool {
            t.truncatingRemainder(dividingBy: 4.4) < 0.14
        }

        func effects(at t: Double?) -> [Layer] {
            []
        }
    }
}
