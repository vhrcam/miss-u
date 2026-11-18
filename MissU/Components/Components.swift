import SwiftUI

extension Font {
    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

struct SquishyButtonStyle<S: Shape>: ButtonStyle {
    var shape: S
    var fill: Color
    var lip: Color
    var text: Color
    var height: CGFloat = 54
    var width: CGFloat? = nil
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && enabled
        ZStack {
            shape.fill(lip).offset(y: 5)
            configuration.label
                .font(.rounded(17, .bold))
                .foregroundStyle(text)
                .frame(maxWidth: width ?? .infinity)
                .frame(width: width, height: height)
                .background {
                    shape.fill(fill)
                        .overlay(alignment: .top) {
                            shape.fill(.white.opacity(0.25))
                                .frame(height: height * 0.32)
                                .padding(.horizontal, height * 0.32)
                                .padding(.top, height * 0.1)
                        }
                }
                .offset(y: pressed ? 5 : 0)
        }
        .frame(width: width, height: height)
        .padding(.bottom, 5)
        .scaleEffect(x: pressed ? 1.02 : 1, y: pressed ? 0.98 : 1, anchor: .bottom)
        .opacity(enabled ? 1 : 0.45)
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: pressed)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.7), trigger: pressed) { _, new in new }
    }
}

extension ButtonStyle where Self == SquishyButtonStyle<Capsule> {
    static var primary: Self {
        SquishyButtonStyle(shape: Capsule(), fill: Theme.rose, lip: Color(hex: 0xC9486E), text: .white)
    }

    static var soft: Self {
        SquishyButtonStyle(shape: Capsule(), fill: .white, lip: Color(hex: 0xEADCD2), text: Theme.ink, height: 50)
    }
}

extension ButtonStyle where Self == SquishyButtonStyle<Circle> {
    static func bubble(_ fill: Color, size: CGFloat = 44) -> Self {
        let lip = fill == Theme.rose ? Color(hex: 0xC9486E) : Color(hex: 0xEADCD2)
        return SquishyButtonStyle(shape: Circle(), fill: fill, lip: lip, text: fill == Theme.rose ? .white : Theme.ink, height: size, width: size)
    }
}

struct PillPicker<T: Hashable>: View {
    @Binding var selection: T
    let options: [T]
    let title: (T) -> String
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let on = selection == option
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) { selection = option }
                } label: {
                    Text(title(option))
                        .font(.rounded(14, .bold))
                        .foregroundStyle(on ? .white : Theme.ink.opacity(0.55))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background {
                            if on {
                                Capsule().fill(Theme.rose).matchedGeometryEffect(id: "pill", in: pill)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.white, in: Capsule())
        .overlay(Capsule().stroke(Theme.ink.opacity(0.06), lineWidth: 1))
        .sensoryFeedback(.selection, trigger: selection)
    }
}

struct FloatingTabBar: View {
    @Binding var selection: Int
    @Namespace private var blob

    private let items = [("Home", "house.fill"), ("Customize", "paintbrush.fill"), ("Activities", "sparkles"), ("Settings", "gearshape.fill")]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(items.indices, id: \.self) { i in
                let on = selection == i
                Button {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) { selection = i }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: items[i].1).font(.system(size: 17, weight: .bold))
                        if on {
                            Text(items[i].0).font(.rounded(14, .bold)).fixedSize()
                        }
                    }
                    .foregroundStyle(on ? .white : Theme.ink.opacity(0.4))
                    .padding(.horizontal, on ? 18 : 15)
                    .frame(height: 48)
                    .background {
                        if on {
                            Capsule().fill(Theme.rose).matchedGeometryEffect(id: "blob", in: blob)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(items[i].0)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(6)
        .background(.white, in: Capsule())
        .shadow(color: Theme.ink.opacity(0.14), radius: 20, y: 8)
        .sensoryFeedback(.selection, trigger: selection)
    }
}

struct HeartBurst: ViewModifier {
    let trigger: Int

    private struct Puff {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var scale: CGFloat = 0.3
        var opacity: Double = 0
    }

    func body(content: Content) -> some View {
        content.overlay {
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    let spread = CGFloat(i - 4) * 16 + 8
                    let rise = -54 - CGFloat(i % 3) * 18
                    HeartShape()
                        .fill(i.isMultiple(of: 3) ? Color(hex: 0xF7A8BD) : Theme.rose)
                        .frame(width: 14, height: 13)
                        .keyframeAnimator(initialValue: Puff(), trigger: trigger) { view, puff in
                            view.offset(x: puff.x, y: puff.y).scaleEffect(puff.scale).opacity(puff.opacity)
                        } keyframes: { _ in
                            KeyframeTrack(\.x) { SpringKeyframe(spread, duration: 0.8) }
                            KeyframeTrack(\.y) { SpringKeyframe(rise, duration: 0.8) }
                            KeyframeTrack(\.scale) {
                                SpringKeyframe(1.15, duration: 0.3)
                                LinearKeyframe(0.8, duration: 0.5)
                            }
                            KeyframeTrack(\.opacity) {
                                LinearKeyframe(1, duration: 0.08)
                                LinearKeyframe(1, duration: 0.42)
                                LinearKeyframe(0, duration: 0.3)
                            }
                        }
                }
            }
            .allowsHitTesting(false)
        }
    }
}

extension View {
    func heartBurst(_ trigger: Int) -> some View {
        modifier(HeartBurst(trigger: trigger))
    }
}

extension View {
    func card() -> some View {
        padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: Theme.ink.opacity(0.06), radius: 16, y: 6)
    }

    func screen() -> some View {
        foregroundStyle(Theme.ink)
            .background(Theme.cream.ignoresSafeArea())
    }
}

struct Wordmark: View {
    var size: CGFloat = 34

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: size * 0.12) {
            Text("miss u").font(.rounded(size, .black))
            HeartShape()
                .fill(Theme.rose)
                .frame(width: size * 0.46, height: size * 0.42)
        }
        .foregroundStyle(Theme.ink)
    }
}

struct ScreenTitle: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.rounded(32, .heavy))
            if let subtitle {
                Text(subtitle).font(.rounded(16, .medium)).opacity(0.6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Swatch: View {
    let color: Color
    let selected: Bool

    var body: some View {
        Circle()
            .fill(color)
            .overlay(Circle().stroke(Theme.ink.opacity(0.12), lineWidth: 1))
            .frame(width: 38, height: 38)
            .padding(4)
            .overlay(Circle().stroke(selected ? Theme.rose : .clear, lineWidth: 3))
    }
}

struct Tile<Content: View>: View {
    let selected: Bool
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(width: 70, height: 70)
            .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? Theme.rose : Theme.ink.opacity(0.08), lineWidth: selected ? 3 : 1)
            )
    }
}

struct Chip: View {
    let text: String
    let selected: Bool

    var body: some View {
        Text(text)
            .font(.rounded(15, .bold))
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(selected ? Theme.blush : .white, in: Capsule())
            .overlay(Capsule().stroke(selected ? Theme.rose : Theme.ink.opacity(0.1), lineWidth: selected ? 2 : 1))
    }
}

struct OptionRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.rounded(15, .bold)).opacity(0.65)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) { content }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ActivityPill: View {
    let activity: ActivityState?
    let empty: String

    var body: some View {
        let live = activity.flatMap { $0.isLive() ? $0 : nil }
        HStack(spacing: 6) {
            Image(systemName: live?.kind.symbol ?? "plus.circle.fill")
                .foregroundStyle(Theme.rose)
            Text(live?.kind.title ?? empty)
            if live?.source == .headphones {
                Text("auto").font(.rounded(11, .bold)).opacity(0.45)
            }
        }
        .font(.rounded(13, .semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.white, in: Capsule())
        .overlay(Capsule().stroke(Theme.ink.opacity(0.06), lineWidth: 1))
    }
}

struct ToastView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let text = model.toast {
            Text(text)
                .font(.rounded(15, .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Theme.ink, in: Capsule())
                .padding(.horizontal, 24)
                .padding(.top, 6)
                .transition(.move(edge: .top).combined(with: .opacity))
                .task(id: text) {
                    try? await Task.sleep(for: .seconds(2.8))
                    model.toast = nil
                }
                .onTapGesture { model.toast = nil }
        }
    }
}
