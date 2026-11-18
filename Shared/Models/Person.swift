import Foundation

struct Person: Codable, Hashable, Identifiable {
    var id: UUID
    var username: String
    var avatar: AvatarConfig
    var activity: ActivityState?

    func activity(at date: Date = .now) -> ActivityKind? {
        activity.flatMap { $0.isLive(at: date) ? $0.kind : nil }
    }
}

extension Person {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        username = try c.decode(String.self, forKey: .username)
        avatar = (try? c.decode(AvatarConfig.self, forKey: .avatar)) ?? AvatarConfig()
        activity = try? c.decodeIfPresent(ActivityState.self, forKey: .activity)
    }
}

struct WidgetSnapshot: Codable, Hashable {
    var me: Person
    var partner: Person?
    var interaction: Interaction?
    var style: WidgetStyle
    var byPartner: Bool
}

extension WidgetSnapshot {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        me = try c.decode(Person.self, forKey: .me)
        partner = try c.decodeIfPresent(Person.self, forKey: .partner)
        interaction = try? c.decodeIfPresent(Interaction.self, forKey: .interaction)
        style = (try? c.decode(WidgetStyle.self, forKey: .style)) ?? WidgetStyle()
        byPartner = (try? c.decode(Bool.self, forKey: .byPartner)) ?? false
    }
}
