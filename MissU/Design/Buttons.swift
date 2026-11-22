import SwiftUI

/// The main action: a soft gradient pillow lit from above, casting a shadow in its own color.
/// It sinks a touch when pressed. A `peek` (usually a `CreaturePeek`) holds on to its top edge.
struct PrimaryButtonStyle<Peek: View>: ButtonStyle {
    var tint: Tint = .pink
    var fullWidth = true
    var peek: Peek
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && enabled
        let shape = RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
        let hue = enabled ? tint : .oat
        return configuration.label
            .font(Typeface.label)
            .foregroundStyle(enabled ? Palette.ink : Palette.cocoa)
            .lineLimit(1)
            .padding(.horizontal, Space.xl)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 54)
            .background(alignment: .topTrailing) {
                peek
                    .frame(width: 60)
                    .padding(.trailing, Space.xl)
                    .alignmentGuide(.top) { $0[.bottom] }
            }
            .background {
                shape.fill(LinearGradient(colors: [hue.glow, hue.fill], startPoint: .top, endPoint: .bottom))
                    .overlay { shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.8), .white.opacity(0)], startPoint: .top, endPoint: .center), lineWidth: 1.2) }
                    .overlay { shape.strokeBorder(hue.deep.opacity(0.2), lineWidth: 0.6) }
                    .shadow(color: hue.deep.opacity(pressed || !enabled ? 0.14 : 0.3), radius: pressed ? 4 : 12, y: pressed ? 2 : 7)
            }
            .scaleEffect(pressed ? 0.975 : 1)
            .animation(Motion.press, value: pressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.6), trigger: pressed) { _, new in new }
    }
}

extension PrimaryButtonStyle where Peek == EmptyView {
    init(tint: Tint = .pink, fullWidth: Bool = true) {
        self.init(tint: tint, fullWidth: fullWidth, peek: EmptyView())
    }
}

/// The second choice: warm white with a hairline edge.
struct SecondaryButtonStyle: ButtonStyle {
    var tint: Tint = .pink
    var fullWidth = true

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let shape = RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
        return configuration.label
            .font(Typeface.label)
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .padding(.horizontal, Space.xl)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 54)
            .background {
                shape.fill(pressed ? tint.soft : Palette.warmWhite.opacity(0.92))
                    .overlay { shape.strokeBorder(Palette.hairline, lineWidth: 0.8) }
                    .shadow(color: Palette.shadow.opacity(pressed ? 0.04 : 0.08), radius: pressed ? 2 : 8, y: pressed ? 1 : 4)
            }
            .scaleEffect(pressed ? 0.975 : 1)
            .animation(Motion.press, value: pressed)
            .sensoryFeedback(.selection, trigger: pressed) { _, new in new }
    }
}

/// Small text actions, underlined with a soft highlighter stroke.
struct QuietButtonStyle: ButtonStyle {
    var tint: Tint = .pink

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typeface.label)
            .foregroundStyle(tint.deep.mix(with: Palette.ink, by: 0.5))
            .padding(.vertical, 6)
            .background(alignment: .bottom) {
                Capsule().fill(tint.fill.opacity(0.75)).frame(height: 6).offset(y: -6)
            }
            .opacity(configuration.isPressed ? 0.55 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

/// A round button that looks like a soft glass bead.
struct OrbButtonStyle: ButtonStyle {
    var tint: Tint?
    var size: CGFloat = 46

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let deep = tint?.deep ?? Palette.shadow
        return configuration.label
            .foregroundStyle(Palette.ink)
            .frame(width: size, height: size)
            .background {
                Circle()
                    .fill(RadialGradient(colors: [tint?.glow ?? .white, tint?.fill ?? Palette.warmWhite], center: UnitPoint(x: 0.36, y: 0.28), startRadius: 0, endRadius: size * 0.78))
                    .overlay { Circle().strokeBorder(LinearGradient(colors: [.white.opacity(0.85), .white.opacity(0)], startPoint: .top, endPoint: .center), lineWidth: 1.2) }
                    .overlay { Circle().strokeBorder(deep.opacity(tint == nil ? 0.1 : 0.16), lineWidth: 0.6) }
                    .shadow(color: deep.opacity(pressed ? 0.14 : 0.26), radius: pressed ? 3 : 10, y: pressed ? 1.5 : 6)
            }
            .scaleEffect(pressed ? 0.93 : 1)
            .animation(Motion.press, value: pressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: pressed) { _, new in new }
    }
}

/// Just a gentle press, for custom-drawn buttons like chips.
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle<EmptyView> {
    static func primary(_ tint: Tint = .pink, fullWidth: Bool = true) -> Self { PrimaryButtonStyle(tint: tint, fullWidth: fullWidth) }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static func secondary(_ tint: Tint = .pink, fullWidth: Bool = true) -> Self { SecondaryButtonStyle(tint: tint, fullWidth: fullWidth) }
}

extension ButtonStyle where Self == QuietButtonStyle {
    static func quiet(_ tint: Tint = .pink) -> Self { QuietButtonStyle(tint: tint) }
}

extension ButtonStyle where Self == OrbButtonStyle {
    static func orb(_ tint: Tint? = nil, size: CGFloat = 46) -> Self { OrbButtonStyle(tint: tint, size: size) }
}
