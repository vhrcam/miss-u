import SwiftUI

extension Font {
    /// Fraunces with its softest corners: warm and a little storybook, for headings.
    static func fraunces(_ size: CGFloat, _ weight: Font.Weight = .semibold, relativeTo style: Font.TextStyle = .title) -> Font {
        .custom(weight == .medium || weight == .regular ? "FrauncesSoft-Medium" : "FrauncesSoft-SemiBold", size: size, relativeTo: style)
    }

    /// Nunito: round and friendly, but calm enough for reading.
    static func nunito(_ size: CGFloat, _ weight: Font.Weight = .medium, relativeTo style: Font.TextStyle = .body) -> Font {
        let name = switch weight {
        case .heavy, .black: "Nunito-ExtraBold"
        case .bold: "Nunito-Bold"
        case .semibold: "Nunito-SemiBold"
        case .medium: "Nunito-Medium"
        default: "Nunito-Regular"
        }
        return .custom(name, size: size, relativeTo: style)
    }
}

enum Typeface {
    static let display = Font.fraunces(34, .medium, relativeTo: .largeTitle)
    static let title = Font.fraunces(26, .semibold, relativeTo: .title)
    static let headline = Font.fraunces(20, .semibold, relativeTo: .title3)
    static let body = Font.nunito(17, .medium)
    static let label = Font.nunito(16, .bold)
    static let caption = Font.nunito(14, .semibold, relativeTo: .subheadline)
    static let tiny = Font.nunito(12, .bold, relativeTo: .caption2)
}
