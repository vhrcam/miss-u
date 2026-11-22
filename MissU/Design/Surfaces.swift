import SwiftUI

extension View {
    /// Warm white paper with a lit top edge and a soft shadow, in place of an outline.
    func surface(_ tint: Tint? = nil, radius: CGFloat = Radius.card, padding: CGFloat = Space.l + 2) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { Surface(tint: tint, radius: radius) }
    }

    /// A quieter panel washed in one hue, for things that sit inside a screen rather than on it.
    func tinted(_ tint: Tint, radius: CGFloat = 24, padding: CGFloat = Space.l) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
                shape.fill(LinearGradient(colors: [tint.soft.mix(with: .white, by: 0.3), tint.soft], startPoint: .top, endPoint: .bottom))
                    .overlay { shape.strokeBorder(.white.opacity(0.75), lineWidth: 1) }
            }
    }

    func backdrop(_ tint: Tint) -> some View {
        foregroundStyle(Palette.ink)
            .background { Backdrop(tint: tint).ignoresSafeArea() }
    }
}

struct Surface: View {
    var tint: Tint?
    var radius: CGFloat = Radius.card

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        shape.fill(LinearGradient(colors: [Palette.warmWhite, Palette.warmWhite.mix(with: tint?.soft ?? Palette.cream, by: 0.6)], startPoint: .top, endPoint: .bottom))
            .overlay { shape.strokeBorder(LinearGradient(colors: [.white, .white.opacity(0)], startPoint: .top, endPoint: .center), lineWidth: 1) }
            .overlay { shape.strokeBorder(Palette.hairline, lineWidth: 0.5) }
            .shadow(color: (tint?.deep ?? Palette.shadow).opacity(0.14), radius: 20, y: 10)
            .shadow(color: Palette.shadow.opacity(0.05), radius: 1.5, y: 1)
    }
}

/// Warm paper with a few large pools of color, instead of a pattern.
struct Backdrop: View {
    var tint: Tint

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                Palette.paper
                RadialGradient(colors: [tint.fill.opacity(0.55), tint.fill.opacity(0)], center: UnitPoint(x: 0.92, y: 0.05), startRadius: 0, endRadius: w * 0.9)
                RadialGradient(colors: [Tint.peach.fill.opacity(0.32), Tint.peach.fill.opacity(0)], center: UnitPoint(x: 0, y: 0.45), startRadius: 0, endRadius: w * 0.75)
                RadialGradient(colors: [Tint.lavender.fill.opacity(0.3), Tint.lavender.fill.opacity(0)], center: UnitPoint(x: 0.75, y: 1), startRadius: 0, endRadius: w * 0.95)
            }
        }
    }
}
