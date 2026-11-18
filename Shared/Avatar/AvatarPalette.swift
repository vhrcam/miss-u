import SwiftUI

extension AvatarColor {
    var fill: Color {
        switch self {
        case .vanilla: Color(hex: 0xFFF1D6)
        case .peach: Color(hex: 0xFFD2B3)
        case .blush: Color(hex: 0xFFC7D3)
        case .lavender: Color(hex: 0xDCCBFA)
        case .sky: Color(hex: 0xC6E2FA)
        case .mint: Color(hex: 0xC6EDD8)
        case .lemon: Color(hex: 0xFFEE9E)
        case .cocoa: Color(hex: 0xC89A7F)
        }
    }

    var deep: Color {
        switch self {
        case .vanilla: Color(hex: 0xE8B87D)
        case .peach: Color(hex: 0xF29C76)
        case .blush: Color(hex: 0xEE89A4)
        case .lavender: Color(hex: 0xA487E0)
        case .sky: Color(hex: 0x7FB0E6)
        case .mint: Color(hex: 0x6FC29B)
        case .lemon: Color(hex: 0xF0C447)
        case .cocoa: Color(hex: 0x85563F)
        }
    }
}

extension ShirtColor {
    var fill: Color {
        switch self {
        case .cream: Color(hex: 0xFFF6E6)
        case .rose: Color(hex: 0xF59AB1)
        case .coral: Color(hex: 0xFF9478)
        case .butter: Color(hex: 0xFFDD80)
        case .sage: Color(hex: 0xA3C79E)
        case .sky: Color(hex: 0x94C4EE)
        case .grape: Color(hex: 0xA58AD6)
        case .charcoal: Color(hex: 0x5B5262)
        }
    }
}
