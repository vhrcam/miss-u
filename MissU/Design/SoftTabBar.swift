import SwiftUI

/// A floating bar of warm paper. The selected tab sits in a soft pill, and `peek`
/// (usually your character) holds on to the bar's top edge above it, gliding along when you switch.
struct SoftTabBar<Peek: View>: View {
    @Binding var selection: Int
    var items: [(String, Icon)]
    var tint: Tint = .pink
    @ViewBuilder var peek: Peek
    @Namespace private var pill

    private struct Lift {
        var y: CGFloat = 0
    }

    var body: some View {
        GeometryReader { geo in
            let slot = (geo.size.width - 16) / CGFloat(items.count)
            bar.overlay(alignment: .topLeading) {
                peek
                    .frame(width: 58)
                    .keyframeAnimator(initialValue: Lift(), trigger: selection) { view, lift in
                        view.offset(y: lift.y)
                    } keyframes: { _ in
                        KeyframeTrack(\.y) {
                            CubicKeyframe(-7, duration: 0.2)
                            SpringKeyframe(0, duration: 0.4, spring: Spring(response: 0.4, dampingRatio: 0.78))
                        }
                    }
                    .alignmentGuide(.top) { $0[.bottom] }
                    .offset(x: 8 + slot * (CGFloat(selection) + 0.5) - 29)
                    .animation(Motion.glide, value: selection)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 68)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private var bar: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { i in
                let on = selection == i
                Button {
                    withAnimation(Motion.glide) { selection = i }
                } label: {
                    VStack(spacing: 3) {
                        IconView(icon: items[i].1, size: 25)
                            .scaleEffect(on ? 1 : 0.9)
                            .opacity(on ? 1 : 0.75)
                        Text(items[i].0)
                            .font(Typeface.tiny)
                            .foregroundStyle(on ? Palette.ink : Palette.cocoa)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background {
                        if on {
                            Capsule()
                                .fill(LinearGradient(colors: [tint.soft.mix(with: .white, by: 0.2), tint.soft], startPoint: .top, endPoint: .bottom))
                                .overlay { Capsule().strokeBorder(tint.fill.opacity(0.7), lineWidth: 0.8) }
                                .padding(.horizontal, 4)
                                .matchedGeometryEffect(id: "pill", in: pill)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(items[i].0)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(8)
        .background {
            Capsule()
                .fill(Palette.warmWhite.opacity(0.95))
                .overlay { Capsule().strokeBorder(LinearGradient(colors: [.white, .white.opacity(0)], startPoint: .top, endPoint: .center), lineWidth: 1) }
                .overlay { Capsule().strokeBorder(Palette.hairline, lineWidth: 0.5) }
                .shadow(color: Palette.shadow.opacity(0.13), radius: 22, y: 10)
        }
    }
}

extension SoftTabBar where Peek == EmptyView {
    init(selection: Binding<Int>, items: [(String, Icon)], tint: Tint = .pink) {
        self.init(selection: selection, items: items, tint: tint) { EmptyView() }
    }
}
