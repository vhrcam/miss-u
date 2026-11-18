import Foundation

struct AppState: Decodable, Equatable {
    var me: Person
    var settings: Settings
    var partner: Person?
    var myWidget: MyWidget
    var partnerWidget: PartnerWidget?
    var incoming: [ConnectionRequest]
    var outgoing: [ConnectionRequest]

    struct Settings: Decodable, Equatable {
        var notifyRequests: Bool
        var notifyWidget: Bool
        var partnerSince: Date?
    }

    struct MyWidget: Decodable, Equatable {
        var style: WidgetStyle
        var ownStyle: WidgetStyle
        var allowPartner: Bool
        var byPartner: Bool
        var updatedAt: Date
    }

    struct PartnerWidget: Decodable, Equatable {
        var style: WidgetStyle
        var allowPartner: Bool
        var byMe: Bool
        var updatedAt: Date
    }

    struct ConnectionRequest: Decodable, Equatable, Identifiable {
        var id: UUID
        var username: String
        var avatar: AvatarConfig?
        var createdAt: Date
    }

    enum CodingKeys: String, CodingKey {
        case me, partner, myWidget, partnerWidget, incoming, outgoing
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        me = try c.decode(Person.self, forKey: .me)
        settings = try c.decode(Settings.self, forKey: .me)
        partner = try c.decodeIfPresent(Person.self, forKey: .partner)
        myWidget = try c.decode(MyWidget.self, forKey: .myWidget)
        partnerWidget = try c.decodeIfPresent(PartnerWidget.self, forKey: .partnerWidget)
        incoming = try c.decode([ConnectionRequest].self, forKey: .incoming)
        outgoing = try c.decode([ConnectionRequest].self, forKey: .outgoing)
    }

    var snapshot: WidgetSnapshot {
        WidgetSnapshot(me: me, partner: partner, style: myWidget.style, byPartner: myWidget.byPartner)
    }

    func partnerSnapshot(style: WidgetStyle? = nil) -> WidgetSnapshot? {
        guard let partner else { return nil }
        return WidgetSnapshot(me: partner, partner: me, style: style ?? partnerWidget?.style ?? WidgetStyle(), byPartner: partnerWidget?.byMe ?? false)
    }
}
