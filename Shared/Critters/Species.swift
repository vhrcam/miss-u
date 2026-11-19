import SwiftUI

enum Species: String, CaseIterable, Codable {
    case cat, bear, dog, rabbit

    var fur: Fur {
        switch self {
        case .cat: .smoke
        case .bear: .honey
        case .dog: .cream
        case .rabbit: .snow
        }
    }
}

struct Fur: Hashable {
    let base: Color
    let shade: Color
    let accent: Color

    init(_ base: UInt32, _ shade: UInt32, _ accent: UInt32) {
        self.base = Color(hex: base)
        self.shade = Color(hex: shade)
        self.accent = Color(hex: accent)
    }

    static let snow = Fur(0xFFFFFF, 0xF3E7E3, 0xFFFFFF)
    static let smoke = Fur(0xC2BAB0, 0xACA399, 0xC2BAB0)
    static let honey = Fur(0xE8C9A9, 0xD6B392, 0xD6B392)
    static let cream = Fur(0xFFF7EC, 0xF1E1CF, 0xE2BD98)
}
