import Foundation

enum ActivityKind: String, Choice {
    case sleeping, music, shopping, gaming, studying, working, coffee, tv, exercising
    case missingYou = "missing_you"

    var title: String {
        switch self {
        case .sleeping: "Sleeping"
        case .music: "Listening to music"
        case .shopping: "Shopping"
        case .gaming: "Gaming"
        case .studying: "Studying"
        case .working: "Working"
        case .coffee: "Drinking coffee"
        case .tv: "Watching TV"
        case .exercising: "Exercising"
        case .missingYou: "Missing you"
        }
    }

    var symbol: String {
        switch self {
        case .sleeping: "moon.zzz.fill"
        case .music: "headphones"
        case .shopping: "basket.fill"
        case .gaming: "gamecontroller.fill"
        case .studying: "book.fill"
        case .working: "laptopcomputer"
        case .coffee: "cup.and.saucer.fill"
        case .tv: "tv.fill"
        case .exercising: "figure.run"
        case .missingYou: "heart.fill"
        }
    }
}

enum ActivitySource: String, Codable {
    case manual, headphones
}

struct ActivityState: Codable, Hashable {
    var kind: ActivityKind
    var source: ActivitySource
    var startedAt: Date
    var expiresAt: Date?

    func isLive(at date: Date = .now) -> Bool {
        expiresAt.map { $0 > date } ?? true
    }
}
