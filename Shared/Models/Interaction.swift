import Foundation

enum InteractionKind: String, Choice {
    case kiss, hug, poke, heart

    var emoji: String {
        switch self {
        case .kiss: "💋"
        case .hug: "🤗"
        case .poke: "👉"
        case .heart: "💗"
        }
    }

    var sentence: String {
        switch self {
        case .kiss: "sent you a kiss"
        case .hug: "sent you a hug"
        case .poke: "poked you"
        case .heart: "sent you a heart"
        }
    }
}

struct Interaction: Codable, Hashable {
    var kind: InteractionKind
    var createdAt: Date
    var seen: Bool

    func isRecent(at date: Date = .now) -> Bool {
        date.timeIntervalSince(createdAt) < 3 * 60 * 60
    }
}
