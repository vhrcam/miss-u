import SwiftUI

struct LoveButton: View {
    var icon: Icon
    var label: String
    var tint: Tint
    var size: CGFloat = 66
    var action: () -> Void = {}
    @State private var sent = 0

    private struct Pop {
        var scale: CGFloat = 1
        var angle: Double = 0
    }

    var body: some View {
        VStack(spacing: Space.s) {
            Button {
                sent += 1
                action()
            } label: {
                IconView(icon: icon, size: size * 0.52)
                    .keyframeAnimator(initialValue: Pop(), trigger: sent) { view, pop in
                        view.scaleEffect(pop.scale).rotationEffect(.degrees(pop.angle))
                    } keyframes: { _ in
                        KeyframeTrack(\.scale) {
                            SpringKeyframe(1.38, duration: 0.16)
                            SpringKeyframe(0.9, duration: 0.14)
                            SpringKeyframe(1, duration: 0.3)
                        }
                        KeyframeTrack(\.angle) {
                            SpringKeyframe(-12, duration: 0.12)
                            SpringKeyframe(9, duration: 0.14)
                            SpringKeyframe(0, duration: 0.3)
                        }
                    }
            }
            .buttonStyle(.round(tint, size: size))
            .loveBurst(sent, icon: icon == .kiss ? .kiss : .heart)
            .sensoryFeedback(.success, trigger: sent)
            Text(label).font(Typeface.caption)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Send a \(label.lowercased())")
        .accessibilityAddTraits(.isButton)
    }
}

struct LoveBurst: ViewModifier {
    let trigger: Int
    var icon: Icon = .heart

    private struct Puff {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var scale: CGFloat = 0.2
        var opacity: Double = 0
    }

    func body(content: Content) -> some View {
        content.overlay {
            ZStack {
                ForEach(0..<7, id: \.self) { i in
                    let angle = -Double.pi / 2 + Double(i - 3) * 0.42
                    let reach = 58 + CGFloat(i % 3) * 14
                    IconView(icon: i == 3 ? icon : .heart, size: i.isMultiple(of: 2) ? 18 : 14)
                        .keyframeAnimator(initialValue: Puff(), trigger: trigger) { view, puff in
                            view.offset(x: puff.x, y: puff.y).scaleEffect(puff.scale).opacity(puff.opacity)
                        } keyframes: { _ in
                            KeyframeTrack(\.x) { SpringKeyframe(cos(angle) * reach, duration: 0.85) }
                            KeyframeTrack(\.y) { SpringKeyframe(sin(angle) * reach, duration: 0.85) }
                            KeyframeTrack(\.scale) {
                                SpringKeyframe(1.1, duration: 0.3)
                                LinearKeyframe(0.7, duration: 0.55)
                            }
                            KeyframeTrack(\.opacity) {
                                LinearKeyframe(trigger == 0 ? 0 : 1, duration: 0.06)
                                LinearKeyframe(trigger == 0 ? 0 : 1, duration: 0.44)
                                LinearKeyframe(0, duration: 0.35)
                            }
                        }
                }
            }
            .allowsHitTesting(false)
        }
    }
}

extension View {
    func loveBurst(_ trigger: Int, icon: Icon = .heart) -> some View {
        modifier(LoveBurst(trigger: trigger, icon: icon))
    }
}
