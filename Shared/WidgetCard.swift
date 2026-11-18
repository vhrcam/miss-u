import SwiftUI

enum CardSize {
    case small, medium

    var width: CGFloat { self == .small ? 158 : 338 }
}

extension WidgetBackground {
    var color: Color {
        switch self {
        case .cream: Color(hex: 0xFFF3E3)
        case .white: .white
        case .pink: Color(hex: 0xFFD9E4)
        case .lavender: Color(hex: 0xE9E0FB)
        case .sky: Color(hex: 0xDAEDFC)
        }
    }
}

extension CharacterSpot {
    var alignment: Alignment {
        switch self {
        case .left: .leading
        case .center: .center
        case .right: .trailing
        }
    }

    var horizontal: HorizontalAlignment {
        switch self {
        case .left: .leading
        case .center: .center
        case .right: .trailing
        }
    }
}

struct WidgetBackdrop: View {
    var style: WidgetStyle

    private static let marks: [(x: CGFloat, y: CGFloat, size: CGFloat, turn: Double)] = [
        (0.08, 0.12, 0.10, -14), (0.92, 0.10, 0.08, 12), (0.86, 0.52, 0.06, -8), (0.07, 0.58, 0.07, 10),
        (0.50, 0.05, 0.05, 0), (0.24, 0.92, 0.06, -10), (0.74, 0.90, 0.08, 14), (0.95, 0.86, 0.05, -6), (0.03, 0.93, 0.05, 8)
    ]

    var body: some View {
        ZStack {
            style.background.color
            GeometryReader { g in
                let side = min(g.size.width, g.size.height)
                ForEach(Self.marks.indices, id: \.self) { i in
                    let m = Self.marks[i]
                    mark
                        .frame(width: side * m.size, height: side * m.size)
                        .rotationEffect(.degrees(m.turn))
                        .position(x: g.size.width * m.x, y: g.size.height * m.y)
                }
            }
        }
    }

    @ViewBuilder private var mark: some View {
        switch style.pattern {
        case .none: EmptyView()
        case .hearts: HeartShape().fill(Theme.rose.opacity(0.24))
        case .sparkles: SparkleShape().fill(Color(hex: 0xF2B544).opacity(0.5))
        case .dots: Circle().fill(Theme.ink.opacity(0.09)).scaleEffect(0.5)
        }
    }
}

struct WidgetContent: View {
    var snapshot: WidgetSnapshot?
    var size: CardSize
    var date: Date = .now

    private var person: Person? { snapshot?.partner }
    private var style: WidgetStyle { snapshot?.style ?? WidgetStyle() }
    private var activity: ActivityKind? { person?.activity(at: date) }

    private var name: String {
        person?.username ?? "miss u"
    }

    private var status: String {
        if snapshot == nil { return "Open Miss U to start" }
        if person == nil { return "Add your person" }
        return activity?.title ?? ""
    }

    var body: some View {
        Group {
            if size == .medium && style.spot != .center {
                wide
            } else {
                stacked
            }
        }
        .foregroundStyle(Theme.ink)
    }

    private var avatar: some View {
        AvatarView(config: person?.avatar ?? snapshot?.me.avatar ?? AvatarConfig(), activity: activity)
            .opacity(person == nil ? 0.55 : 1)
    }

    private var caption: some View {
        Text(style.caption)
            .font(.system(size: size == .small ? 12 : 13, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.rose)
            .lineLimit(1)
    }

    private var stacked: some View {
        VStack(alignment: style.spot.horizontal, spacing: 3) {
            if !style.caption.isEmpty {
                caption.frame(maxWidth: .infinity, alignment: style.spot.alignment)
            }
            avatar.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: style.spot.alignment)
            VStack(alignment: style.spot.horizontal, spacing: 0) {
                Text(name).font(.system(size: 14, weight: .heavy, design: .rounded))
                if !status.isEmpty {
                    Text(status).font(.system(size: 11, weight: .semibold, design: .rounded)).opacity(0.6)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity, alignment: style.spot.alignment)
        }
        .padding(12)
    }

    private var wide: some View {
        HStack(spacing: 12) {
            if style.spot == .left { avatar }
            VStack(alignment: .leading, spacing: 4) {
                if !style.caption.isEmpty { caption }
                Text(name)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if !status.isEmpty {
                    Label(status, systemImage: activity?.symbol ?? "heart.fill")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .opacity(0.65)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if style.spot == .right { avatar }
        }
        .padding(14)
    }
}

struct WidgetPreview: View {
    var snapshot: WidgetSnapshot?
    var size: CardSize = .small

    var body: some View {
        WidgetContent(snapshot: snapshot, size: size)
            .frame(width: size.width, height: 158)
            .background(WidgetBackdrop(style: snapshot?.style ?? WidgetStyle()))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Theme.ink.opacity(0.12), radius: 14, y: 6)
    }
}
