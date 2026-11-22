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

    /// Keeps two characters on screen from breathing and blinking in step.
    var phase: Double {
        switch self {
        case .cat: 0
        case .bear: 1.37
        case .dog: 2.61
        case .rabbit: 0.83
        }
    }
}

/// One coat, lit from the upper left. `line` draws the outer edge and `crease` the softer lines
/// inside it. Both are warm tones of the coat itself instead of one dark ink.
struct Tone: Hashable {
    let light: Color
    let base: Color
    let shade: Color
    let deep: Color
    let line: Color
    let crease: Color

    init(_ light: UInt32, _ base: UInt32, _ shade: UInt32, _ deep: UInt32, line: UInt32, crease: UInt32) {
        self.light = Color(hex: light)
        self.base = Color(hex: base)
        self.shade = Color(hex: shade)
        self.deep = Color(hex: deep)
        self.line = Color(hex: line)
        self.crease = Color(hex: crease)
    }
}

struct Fur: Hashable {
    let coat: Tone
    let accent: Tone
    let ear: Color
    let muzzle: Color?

    static let smoke = Fur(
        coat: Tone(0xEAE4DC, 0xD3CAC0, 0xB9ACA6, 0xA19390, line: 0x86766F, crease: 0xAD9E98),
        accent: Tone(0xD9CEC4, 0xBFB1A7, 0xA49388, 0x8E7D74, line: 0x77655D, crease: 0x9C8B82),
        ear: Color(hex: 0xF2B4A9), muzzle: nil)

    static let honey = Fur(
        coat: Tone(0xF6E2CA, 0xE9C7A3, 0xD5A781, 0xC2906B, line: 0xA0765A, crease: 0xC79B7A),
        accent: Tone(0xF6E2CA, 0xE9C7A3, 0xD5A781, 0xC2906B, line: 0xA0765A, crease: 0xC79B7A),
        ear: Color(hex: 0xF1B5A2), muzzle: Color(hex: 0xFAEBDC))

    static let cream = Fur(
        coat: Tone(0xFFFEFA, 0xFFF5E9, 0xF1DFCA, 0xE3C8AC, line: 0xB8916F, crease: 0xDBBFA2),
        accent: Tone(0xF1D2B1, 0xE4B990, 0xCF9F74, 0xB98760, line: 0xA97A55, crease: 0xC2956D),
        ear: Color(hex: 0xF4B9A8), muzzle: nil)

    static let snow = Fur(
        coat: Tone(0xFFFFFF, 0xFFFCFA, 0xF2E6E3, 0xE5D3D0, line: 0xBA9D99, crease: 0xE0CBC8),
        accent: Tone(0xFFFFFF, 0xFFFCFA, 0xF2E6E3, 0xE5D3D0, line: 0xBA9D99, crease: 0xE0CBC8),
        ear: Color(hex: 0xF8BDC3), muzzle: nil)
}
