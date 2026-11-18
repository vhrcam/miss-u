import SwiftUI

extension Font {
    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.rounded(17, .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Theme.rose.opacity(enabled ? 1 : 0.4), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.25), value: configuration.isPressed)
    }
}

struct SoftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.rounded(16, .bold))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(.white, in: Capsule())
            .overlay(Capsule().stroke(Theme.ink.opacity(0.1), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.25), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SoftButtonStyle {
    static var soft: SoftButtonStyle { SoftButtonStyle() }
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
