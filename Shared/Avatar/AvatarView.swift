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
        var activity: ActivityKind?

        init(config: AvatarConfig, activity: ActivityKind?) {
            self.activity = activity
            base += feet(config.color)
            base += sideArms(config.color.fill)
            base += body(config.color)
        }

        @ViewBuilder
        func frame(at t: Double?) -> some View {
            if let t {
                let m = motion(at: t)
                ZStack {
                    ZStack {
                        Stack(layers: base)
                        Stack(layers: blinking(at: t) ? blink : face)
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
