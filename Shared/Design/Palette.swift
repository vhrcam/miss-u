import SwiftUI

enum Palette {
    static let ink = Color(hex: 0x4A2A17)
    static let cocoa = Color(hex: 0x8C6A5A)
    static let latte = Color(hex: 0xE8D8CB)
    static let warmWhite = Color(hex: 0xFFFCF7)
    static let cream = Color(hex: 0xFFF6EC)
    static let cheek = Color(hex: 0xF79882)
    static let earPink = Color(hex: 0xF9A799)
    static let ground = Color(hex: 0x4A2A17).opacity(0.13)
}

struct Tint: Hashable {
    let soft: Color
    let fill: Color
    let deep: Color

    init(_ soft: UInt32, _ fill: UInt32, _ deep: UInt32) {
        self.soft = Color(hex: soft)
        self.fill = Color(hex: fill)
        self.deep = Color(hex: deep)
    }

    static let pink = Tint(0xFFE3E7, 0xFFB3C6, 0xE98AA3)
    static let peach = Tint(0xFFE7D8, 0xFFC4A3, 0xEE9C74)
    static let butter = Tint(0xFFF4CC, 0xFFE08A, 0xE5B955)
    static let lavender = Tint(0xEDE5FC, 0xCDBBF6, 0xA48EE0)
    static let sky = Tint(0xE1EFFD, 0xAED3F7, 0x7FAEE0)
    static let mint = Tint(0xDFF4E8, 0xAEE3C4, 0x7CC39C)
    static let oat = Tint(0xF5EBE2, 0xE6D4C5, 0xC4A995)

    static let all: [Tint] = [.pink, .peach, .butter, .mint, .sky, .lavender, .oat]
}
