import SwiftUI

enum Palette {
    static let ink = Color(hex: 0x47322B)
    static let cocoa = Color(hex: 0x8A6D61)
    static let latte = Color(hex: 0xE8D8CB)
    static let paper = Color(hex: 0xFFF7F1)
    static let warmWhite = Color(hex: 0xFFFCF8)
    static let cream = Color(hex: 0xFFF6EC)
    static let hairline = Color(hex: 0x47322B).opacity(0.07)
    static let iconLine = Color(hex: 0x6E5145)
    static let cheek = Color(hex: 0xF79882)
    static let earPink = Color(hex: 0xF9A799)
    static let ground = Color(hex: 0x6B4A3A).opacity(0.13)

    static let eye = Color(hex: 0x3F2C25)
    static let mouth = Color(hex: 0x7A5244)
    static let nose = Color(hex: 0xE3978C)
    static let shadow = Color(hex: 0x6B4A3A)
    static let dream = Color(hex: 0xA99BBE)
    static let heartLight = Color(hex: 0xFFC2CE)
    static let heartBase = Color(hex: 0xF78CA1)
    static let heartDeep = Color(hex: 0xE2708A)
    static let heartLine = Color(hex: 0xC85A73)
}

/// One hue in four strengths. `soft` tints a background, `fill` colors a control,
/// `glow` lights its top edge, and `deep` colors its shadow and accents.
struct Tint: Hashable {
    let soft: Color
    let fill: Color
    let deep: Color
    var glow: Color { fill.mix(with: .white, by: 0.45) }

    init(_ soft: UInt32, _ fill: UInt32, _ deep: UInt32) {
        self.soft = Color(hex: soft)
        self.fill = Color(hex: fill)
        self.deep = Color(hex: deep)
    }

    static let pink = Tint(0xFDE6EA, 0xF8BDCA, 0xE1879E)
    static let peach = Tint(0xFEEADF, 0xFBCAAE, 0xE79C7A)
    static let butter = Tint(0xFFF4D5, 0xFAE1A0, 0xD9B15A)
    static let lavender = Tint(0xF0EAFB, 0xD6C8F2, 0xA592DA)
    static let sky = Tint(0xE5F0FA, 0xBBD8F1, 0x83AED8)
    static let mint = Tint(0xE2F3E9, 0xBCE2CB, 0x84BF9E)
    static let oat = Tint(0xF6EEE6, 0xE8D9CB, 0xC4AB96)

    static let all: [Tint] = [.pink, .peach, .butter, .mint, .sky, .lavender, .oat]
}
