import SwiftUI

struct StickerTabBar<Peek: View>: View {
    @Binding var selection: Int
    var items: [(String, Icon)]
    var tint: Tint = .pink
    @ViewBuilder var peek: Peek
    @Namespace private var blob

    private struct Jump {
        var y: CGFloat = 0
        var squash: CGFloat = 1
    }

    var body: some View {
        GeometryReader { geo in
            let slot = (geo.size.width - 12) / CGFloat(items.count)
            ZStack(alignment: .topLeading) {
                peek
                    .frame(width: 44, height: 44)
                    .keyframeAnimator(initialValue: Jump(), trigger: selection) { view, jump in
                        view.offset(y: jump.y).scaleEffect(x: 2 - jump.squash, y: jump.squash, anchor: .bottom)
                    } keyframes: { _ in
                        KeyframeTrack(\.y) {
                            SpringKeyframe(-16, duration: 0.18)
                            SpringKeyframe(0, duration: 0.3)
                        }
                        KeyframeTrack(\.squash) {
                            SpringKeyframe(1.08, duration: 0.18)
                            SpringKeyframe(0.9, duration: 0.12)
                            SpringKeyframe(1, duration: 0.2)
                        }
                    }
                    .offset(x: 6 + slot * (CGFloat(selection) + 0.5) - 22, y: -26)
                    .animation(Motion.hop, value: selection)
                bar
                    .padding(.top, 2)
            }
        }
        .frame(height: 70)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private var bar: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { i in
                let on = selection == i
                Button {
                    withAnimation(Motion.hop) { selection = i }
                } label: {
                    VStack(spacing: 2) {
                        IconView(icon: items[i].1, size: 26)
                            .scaleEffect(on ? 1.1 : 1)
                        Text(items[i].0)
                            .font(Typeface.tiny)
                            .foregroundStyle(on ? Palette.ink : Palette.cocoa)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background {
                        if on {
                            Blob(corner: 20, wobble: 0.6, seed: i).fill(tint.fill)
                                .overlay { Blob(corner: 20, wobble: 0.6, seed: i).stroke(Palette.ink, lineWidth: Line.card) }
                                .padding(.horizontal, 3)
                                .matchedGeometryEffect(id: "blob", in: blob)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(items[i].0)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(6)
        .sticker(Palette.warmWhite, depth: Line.lip, corner: 30, line: Line.control, seed: 21)
    }
}

extension StickerTabBar where Peek == EmptyView {
    init(selection: Binding<Int>, items: [(String, Icon)], tint: Tint = .pink) {
        self.init(selection: selection, items: items, tint: tint) { EmptyView() }
    }
}
