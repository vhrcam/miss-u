import WidgetKit
import SwiftUI

struct PartnerEntry: TimelineEntry {
    let date: Date
}

struct PartnerProvider: TimelineProvider {
    func placeholder(in context: Context) -> PartnerEntry {
        PartnerEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (PartnerEntry) -> Void) {
        completion(PartnerEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PartnerEntry>) -> Void) {
        completion(Timeline(entries: [PartnerEntry(date: .now)], policy: .never))
    }
}

struct PartnerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PartnerWidget", provider: PartnerProvider()) { _ in
            AvatarView(config: AvatarConfig())
                .containerBackground(Color.white, for: .widget)
        }
        .configurationDisplayName("Your person")
        .description("See what your partner is up to.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct MissUWidgetBundle: WidgetBundle {
    var body: some Widget {
        PartnerWidget()
    }
}
