import SwiftUI

struct ThoughtBubble: View {
    var icon: Icon
    var text: String
    var tint: Tint = .pink
    var tailLeading = true

    var body: some View {
        HStack(spacing: Space.s) {
            IconView(icon: icon, size: 22)
            Text(text).font(Typeface.caption).lineLimit(1)
        }
        .padding(.horizontal, Space.m + 2)
        .padding(.vertical, Space.s + 2)
        .background {
            let shape = UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: tailLeading ? 8 : 20,
                                               bottomTrailingRadius: tailLeading ? 20 : 8, topTrailingRadius: 20, style: .continuous)
            shape.fill(Palette.warmWhite)
                .overlay { shape.stroke(Palette.hairline, lineWidth: 0.5) }
                .shadow(color: tint.deep.opacity(0.18), radius: 14, y: 6)
        }
        .overlay(alignment: tailLeading ? .bottomLeading : .bottomTrailing) {
            ZStack(alignment: tailLeading ? .topLeading : .topTrailing) {
                dot(8).offset(x: tailLeading ? 10 : -10, y: 7)
                dot(5).offset(x: tailLeading ? 5 : -5, y: 16)
            }
        }
        .padding(.bottom, 18)
    }

    private func dot(_ size: CGFloat) -> some View {
        Circle().fill(Palette.warmWhite)
            .frame(width: size, height: size)
            .shadow(color: tint.deep.opacity(0.18), radius: 4, y: 2)
    }
}

struct ActivityChip: View {
    var icon: Icon
    var label: String
    var tint: Tint
    var selected: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: Space.s) {
                IconView(icon: icon, size: 22)
                Text(label).font(Typeface.label).lineLimit(1)
            }
            .foregroundStyle(Palette.ink)
            .padding(.leading, Space.m)
            .padding(.trailing, Space.l)
            .frame(height: 44)
            .background {
                Capsule()
                    .fill(selected ? AnyShapeStyle(LinearGradient(colors: [tint.glow, tint.fill], startPoint: .top, endPoint: .bottom))
                                   : AnyShapeStyle(Palette.warmWhite.opacity(0.85)))
                    .overlay { Capsule().strokeBorder(selected ? tint.deep.opacity(0.22) : Palette.hairline, lineWidth: selected ? 0.8 : 0.5) }
                    .shadow(color: (selected ? tint.deep : Palette.shadow).opacity(selected ? 0.28 : 0.06), radius: selected ? 10 : 4, y: selected ? 5 : 2)
            }
            .animation(Motion.settle, value: selected)
        }
        .buttonStyle(PressStyle())
        .sensoryFeedback(.selection, trigger: selected)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
