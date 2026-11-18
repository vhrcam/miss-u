import Foundation

enum WidgetBackground: String, Choice {
    case cream, white, pink, lavender, sky
}

enum WidgetPattern: String, Choice {
    case none, hearts, sparkles, dots
}

enum CharacterSpot: String, Choice {
    case left, center, right
}

struct WidgetStyle: Codable, Hashable {
    var background: WidgetBackground = .cream
    var pattern: WidgetPattern = .hearts
    var spot: CharacterSpot = .center
    var caption: String = ""
}

extension WidgetStyle {
    static let captionLimit = 30

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = WidgetStyle()
        background = c.choice(.background, d.background)
        pattern = c.choice(.pattern, d.pattern)
        spot = c.choice(.spot, d.spot)
        caption = (try? c.decode(String.self, forKey: .caption)) ?? ""
    }
}
