import SwiftUI

extension Font {
    static func fredoka(_ size: CGFloat, _ weight: Font.Weight = .semibold, relativeTo style: Font.TextStyle = .body) -> Font {
        let name = switch weight {
        case .bold, .heavy, .black: "Fredoka-Bold"
        case .semibold: "Fredoka-SemiBold"
        case .medium: "Fredoka-Medium"
        default: "Fredoka-Regular"
        }
        return .custom(name, size: size, relativeTo: style)
    }
}

enum Typeface {
    static let display = Font.fredoka(36, .bold, relativeTo: .largeTitle)
    static let title = Font.fredoka(27, .bold, relativeTo: .title)
    static let headline = Font.fredoka(20, .semibold, relativeTo: .headline)
    static let body = Font.fredoka(17, .medium)
    static let label = Font.fredoka(18, .semibold)
    static let caption = Font.fredoka(14, .medium, relativeTo: .caption)
    static let tiny = Font.fredoka(12, .semibold, relativeTo: .caption2)
}
