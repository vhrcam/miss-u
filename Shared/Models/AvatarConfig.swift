import Foundation

enum AvatarColor: String, Choice {
    case vanilla, peach, blush, lavender, sky, mint, lemon, cocoa
}

enum Presentation: String, Choice {
    case feminine, masculine, neutral
}

enum HairStyle: String, Choice {
    case none, tuft, swoop, bob, long, bun
}

enum Outfit: String, Choice {
    case tee, hoodie, sweater, overalls, dress
}

enum ShirtColor: String, Choice {
    case cream, rose, coral, butter, sage, sky, grape, charcoal
}

enum Accessory: String, Choice {
    case none, glasses, bow, flower, beanie, cap
}

struct AvatarConfig: Codable, Hashable {
    var color: AvatarColor = .peach
    var presentation: Presentation = .neutral
    var hair: HairStyle = .tuft
    var outfit: Outfit = .tee
    var shirt: ShirtColor = .rose
    var accessory: Accessory = .none
}

extension AvatarConfig {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = AvatarConfig()
        color = c.choice(.color, d.color)
        presentation = c.choice(.presentation, d.presentation)
        hair = c.choice(.hair, d.hair)
        outfit = c.choice(.outfit, d.outfit)
        shirt = c.choice(.shirt, d.shirt)
        accessory = c.choice(.accessory, d.accessory)
    }
}
