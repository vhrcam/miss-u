import SwiftUI

struct LoveButton: View {
    var icon: Icon
    var label: String
    var tint: Tint
    var size: CGFloat = 64
    var action: () -> Void = {}
    @State private var sent = 0

    private struct Bloom {
        var scale: CGFloat = 1
    }

    var body: some View {
        VStack(spacing: Space.s) {
            Button {
                sent += 1
                action()
            } label: {
                IconView(icon: icon, size: size * 0.48)
                    .keyframeAnimator(initialValue: Bloom(), trigger: sent) { view, bloom in
                        view.scaleEffect(bloom.scale)
                    } keyframes: { _ in
                        KeyframeTrack(\.scale) {
                            CubicKeyframe(1.14, duration: 0.14)
                            SpringKeyframe(1, duration: 0.45, spring: Spring(response: 0.4, dampingRatio: 0.62))
                        }
                    }
            }
            .buttonStyle(.orb(tint, size: size))
            .floatUp(sent, icon: icon == .kiss ? .kiss : .heart)
            .sensoryFeedback(.impact(weight: .light), trigger: sent)
            Text(label).font(Typeface.caption).foregroundStyle(Palette.cocoa)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Send a \(label.lowercased())")
        .accessibilityAddTraits(.isButton)
    }
}

/// A few hearts drifting up and fading, staggered, instead of a burst.
struct FloatUp: ViewModifier {
    let trigger: Int
    var icon: Icon = .heart

    private struct Drift {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var scale: CGFloat = 0.6
        var opacity: Double = 0
    }

    func body(content: Content) -> some View {
        content.overlay {
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    IconView(icon: i == 0 ? icon : .heart, size: i == 0 ? 20 : 13)
                        .keyframeAnimator(initialValue: Drift(), trigger: trigger) { view, d in
                            view.offset(x: d.x, y: d.y).scaleEffect(d.scale).opacity(d.opacity)
                        } keyframes: { _ in
                            let delay = Double(i) * 0.13
                            let side: CGFloat = i == 1 ? -1 : (i == 2 ? 1 : 0)
                            let shown: Double = trigger == 0 ? 0 : 1
                            KeyframeTrack(\.y) {
                                LinearKeyframe(0, duration: delay)
                                CubicKeyframe(-56 - CGFloat(i) * 10, duration: 1.1)
                            }
                            KeyframeTrack(\.x) {
                                LinearKeyframe(0, duration: delay)
                                CubicKeyframe(side * 10, duration: 0.5)
                                CubicKeyframe(side * 4, duration: 0.6)
                            }
                            KeyframeTrack(\.scale) {
                                LinearKeyframe(0.6, duration: delay)
                                CubicKeyframe(1, duration: 0.3)
                                CubicKeyframe(0.85, duration: 0.8)
                            }
                            KeyframeTrack(\.opacity) {
                                LinearKeyframe(0, duration: delay)
                                LinearKeyframe(shown, duration: 0.12)
                                LinearKeyframe(shown, duration: 0.5)
                                LinearKeyframe(0, duration: 0.45)
                            }
                        }
                }
            }
            .allowsHitTesting(false)
        }
    }
}

extension View {
    func floatUp(_ trigger: Int, icon: Icon = .heart) -> some View {
        modifier(FloatUp(trigger: trigger, icon: icon))
    }
}
