import SwiftUI

struct ThoughtBubble: View {
    var icon: Icon
    var text: String
    var tint: Tint = .pink
    var tailLeading = true

    var body: some View {
        HStack(spacing: Space.s - 2) {
            IconView(icon: icon, size: 22)
            Text(text).font(Typeface.caption).lineLimit(1)
        }
        .padding(.horizontal, Space.m)
        .padding(.vertical, Space.s)
        .sticker(Palette.warmWhite, lip: tint.deep, depth: 3, corner: 18, line: Line.card, seed: text.count)
        .overlay(alignment: tailLeading ? .bottomLeading : .bottomTrailing) {
            ZStack(alignment: tailLeading ? .topLeading : .topTrailing) {
                dot(9).offset(x: tailLeading ? 18 : -18, y: 8)
                dot(6).offset(x: tailLeading ? 12 : -12, y: 19)
            }
        }
        .padding(.bottom, 22)
    }

    private func dot(_ size: CGFloat) -> some View {
        Circle().fill(Palette.warmWhite)
            .overlay { Circle().stroke(Palette.ink, lineWidth: Line.card) }
            .frame(width: size, height: size)
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
                IconView(icon: icon, size: 24)
                Text(label).font(Typeface.label).lineLimit(1)
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, Space.l)
            .frame(height: 46)
            .sticker(selected ? tint.fill : Palette.warmWhite, depth: selected ? 3 : 0, corner: 23, line: selected ? Line.control : Line.card, seed: label.count)
            .scaleEffect(selected ? 1.04 : 1)
            .animation(Motion.pop, value: selected)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selected)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
