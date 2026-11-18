import WidgetKit
import SwiftUI

struct PartnerEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct PartnerProvider: TimelineProvider {
    func placeholder(in context: Context) -> PartnerEntry {
        PartnerEntry(date: .now, snapshot: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (PartnerEntry) -> Void) {
        let saved = SharedStore.snapshot
        completion(PartnerEntry(date: .now, snapshot: context.isPreview ? saved ?? .sample : saved))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PartnerEntry>) -> Void) {
        Task {
            var snapshot = SharedStore.snapshot
            if let fresh = try? await SharedStore.fetchSnapshot() {
                snapshot = fresh
                SharedStore.snapshot = fresh
            }
            let now = Date.now
            let next = now.addingTimeInterval(15 * 60)
            var entries = [PartnerEntry(date: now, snapshot: snapshot)]
            if let ends = snapshot?.partner?.activity?.expiresAt, ends > now, ends < next {
                entries.append(PartnerEntry(date: ends, snapshot: snapshot))
            }
            completion(Timeline(entries: entries, policy: .after(next)))
        }
    }
}

struct PartnerWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PartnerEntry

    var body: some View {
        WidgetContent(snapshot: entry.snapshot, size: family == .systemMedium ? .medium : .small, date: entry.date)
            .containerBackground(for: .widget) {
                WidgetBackdrop(style: entry.snapshot?.style ?? WidgetStyle())
            }
    }
}

struct PartnerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PartnerWidget", provider: PartnerProvider()) { entry in
            PartnerWidgetView(entry: entry)
        }
        .configurationDisplayName("Your person")
        .description("Your partner's character and what they're up to.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

extension WidgetSnapshot {
    static let sample: WidgetSnapshot = {
        let you = Person(id: UUID(), username: "you", avatar: AvatarConfig())
        let them = Person(
            id: UUID(),
            username: "your person",
            avatar: AvatarConfig(color: .lavender, presentation: .feminine, hair: .bob, outfit: .sweater, shirt: .butter),
            activity: ActivityState(kind: .missingYou, source: .manual, startedAt: .now, expiresAt: nil)
        )
        return WidgetSnapshot(me: you, partner: them, style: WidgetStyle(background: .pink, caption: "miss u"), byPartner: false)
    }()
}

@main
struct MissUWidgetBundle: WidgetBundle {
    var body: some Widget {
        PartnerWidget()
    }
}
