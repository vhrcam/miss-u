import SwiftUI

struct CandyButtonStyle<Peek: View>: ButtonStyle {
    var tint: Tint = .pink
    var height: CGFloat = 56
    var fullWidth = true
    var seed = 0
    var peek: Peek
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && enabled
        let shape = Blob(corner: height / 2, wobble: 0.8, seed: seed)
        let sink = pressed ? Line.lip - 1 : 0
        let face = enabled ? tint.fill : Tint.oat.fill
        return configuration.label
            .font(Typeface.label)
            .foregroundStyle(enabled ? Palette.ink : Palette.cocoa)
            .lineLimit(1)
            .padding(.horizontal, 26)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: height)
            .background {
                shape.fill(face)
                    .overlay(alignment: .topLeading) {
                        HStack(spacing: height * 0.08) {
                            Capsule().frame(width: height * 0.5, height: height * 0.11)
                            Circle().frame(width: height * 0.11)
                        }
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.leading, height * 0.4)
                        .padding(.top, height * 0.17)
                    }
                    .overlay { shape.stroke(Palette.ink, lineWidth: Line.control) }
            }
            .offset(y: sink)
            .background(alignment: .topTrailing) {
                peek
                    .offset(x: -height * 0.5, y: -height * 0.42 + sink * 1.6)
                    .scaleEffect(x: pressed ? 1.08 : 1, y: pressed ? 0.86 : 1, anchor: .bottom)
            }
            .background {
                shape.fill(Palette.ink).offset(y: Line.lip)
            }
            .padding(.bottom, Line.lip)
            .animation(Motion.press, value: pressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: pressed) { _, new in new }
    }
}

extension CandyButtonStyle where Peek == EmptyView {
    init(tint: Tint = .pink, height: CGFloat = 56, fullWidth: Bool = true, seed: Int = 0) {
        self.init(tint: tint, height: height, fullWidth: fullWidth, seed: seed, peek: EmptyView())
    }
}

struct SoftButtonStyle: ButtonStyle {
    var tint: Tint = .pink
    var height: CGFloat = 50
    var fullWidth = true
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && enabled
        let shape = Blob(corner: height / 2, wobble: 0.7, seed: 11)
        return configuration.label
            .font(Typeface.label)
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .padding(.horizontal, 22)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: height)
            .background {
                shape.fill(pressed ? tint.soft : Palette.warmWhite)
                    .overlay { shape.stroke(Palette.ink, lineWidth: Line.card) }
            }
            .scaleEffect(pressed ? 0.96 : 1)
            .opacity(enabled ? 1 : 0.5)
            .animation(Motion.press, value: pressed)
            .sensoryFeedback(.selection, trigger: pressed) { _, new in new }
    }
}

struct SquiggleLinkStyle: ButtonStyle {
    var tint: Tint = .pink

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typeface.label)
            .foregroundStyle(Palette.ink)
            .padding(.bottom, 7)
            .overlay(alignment: .bottom) {
                Squiggle().stroke(tint.deep, style: StrokeStyle(lineWidth: 2.5, lineCap: .round)).frame(height: 6)
            }
            .opacity(configuration.isPressed ? 0.55 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

struct RoundButtonStyle: ButtonStyle {
    var tint: Tint? = nil
    var size: CGFloat = 46

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let shape = Blob(corner: size / 2, wobble: 0.5, seed: 5)
        return configuration.label
            .frame(width: size, height: size)
            .background {
                shape.fill(tint?.fill ?? Palette.warmWhite)
                    .overlay { shape.stroke(Palette.ink, lineWidth: Line.control) }
            }
            .offset(y: pressed ? 2 : 0)
            .background { shape.fill(Palette.ink).offset(y: 3) }
            .padding(.bottom, 3)
            .animation(Motion.press, value: pressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.6), trigger: pressed) { _, new in new }
    }
}

struct Squiggle: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let count = max(2, Int(r.width / 12))
        let step = r.width / CGFloat(count)
        p.move(to: CGPoint(x: r.minX, y: r.midY))
        for i in 0..<count {
            let x = r.minX + CGFloat(i) * step
            p.addQuadCurve(to: CGPoint(x: x + step, y: r.midY), control: CGPoint(x: x + step / 2, y: i.isMultiple(of: 2) ? r.minY : r.maxY))
        }
        return p
    }
}

extension ButtonStyle where Self == CandyButtonStyle<EmptyView> {
    static func candy(_ tint: Tint = .pink, fullWidth: Bool = true) -> Self { CandyButtonStyle(tint: tint, fullWidth: fullWidth) }
}

extension ButtonStyle where Self == SoftButtonStyle {
    static func softPill(_ tint: Tint = .pink, fullWidth: Bool = true) -> Self { SoftButtonStyle(tint: tint, fullWidth: fullWidth) }
}

extension ButtonStyle where Self == SquiggleLinkStyle {
    static func squiggle(_ tint: Tint = .pink) -> Self { SquiggleLinkStyle(tint: tint) }
}

extension ButtonStyle where Self == RoundButtonStyle {
    static func round(_ tint: Tint? = nil, size: CGFloat = 46) -> Self { RoundButtonStyle(tint: tint, size: size) }
}
