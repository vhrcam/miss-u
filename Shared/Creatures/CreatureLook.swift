import SwiftUI

/// The three outline-free finishes compared in the character study.
enum CreatureFinish: String, CaseIterable, Identifiable {
    case shape, tonal, soft

    var id: Self { self }

    var short: String {
        switch self {
        case .shape: "Shape"
        case .tonal: "Tonal"
        case .soft: "Soft"
        }
    }

    var title: String {
        switch self {
        case .shape: "Color and shape"
        case .tonal: "Soft tonal edges"
        case .soft: "Softly rendered"
        }
    }

    struct Recipe {
        var shadow: Double
        var shadowBlur: CGFloat
        var shadowReach: CGFloat
        var core: Double
        var light: Double
        var lightBlur: CGFloat
        var lightReach: CGFloat
        var wash: Double
        var edge: Double
        var edgeWidth: CGFloat
        var bounce: Double
        var occlusion: Double
        var occlusionBlur: CGFloat
        var occlusionReach: CGFloat
        var halo: Double
    }

    /// How each finish paints light and shade. Reaches and blurs are in character units.
    var recipe: Recipe {
        switch self {
        case .shape:
            Recipe(shadow: 0.62, shadowBlur: 0.35, shadowReach: 9, core: 0, light: 0, lightBlur: 0.35, lightReach: 4.5,
                   wash: 0, edge: 0, edgeWidth: 0, bounce: 0, occlusion: 0.42, occlusionBlur: 0.5, occlusionReach: 4, halo: 0)
        case .tonal:
            Recipe(shadow: 0.42, shadowBlur: 3, shadowReach: 6, core: 0, light: 0.35, lightBlur: 3.5, lightReach: 5,
                   wash: 0.22, edge: 1, edgeWidth: 0.95, bounce: 0.15, occlusion: 0.6, occlusionBlur: 1.8, occlusionReach: 2.8, halo: 0.06)
        case .soft:
            Recipe(shadow: 1, shadowBlur: 6.5, shadowReach: 11, core: 0.65, light: 0.9, lightBlur: 6, lightReach: 8,
                   wash: 0.35, edge: 0.1, edgeWidth: 2.2, bounce: 0.8, occlusion: 0.9, occlusionBlur: 3, occlusionReach: 3.2, halo: 0.12)
        }
    }
}

/// One coat lit from the upper left, from its lightest to its deepest tone.
struct Coat {
    let light: Color
    let base: Color
    let shade: Color
    let deep: Color

    init(_ light: UInt32, _ base: UInt32, _ shade: UInt32, _ deep: UInt32) {
        self.light = Color(hex: light)
        self.base = Color(hex: base)
        self.shade = Color(hex: shade)
        self.deep = Color(hex: deep)
    }
}

struct CreatureColors {
    let coat: Coat
    let accent: Coat
    let inner: Color
    let patch: Color
}

extension Species {
    var colors: CreatureColors {
        switch self {
        case .cat:
            let coat = Coat(0xE8DCD4, 0xC4B3A9, 0x9F8B83, 0x826D67)
            return CreatureColors(coat: coat, accent: coat, inner: Color(hex: 0xF0A7A0), patch: Color(hex: 0xEDE5DE))
        case .bear:
            let coat = Coat(0xF7DDC1, 0xE5B98F, 0xCA986E, 0xAE7D57)
            return CreatureColors(coat: coat, accent: coat, inner: Color(hex: 0xF0AC9B), patch: Color(hex: 0xF8E6D2))
        case .dog:
            return CreatureColors(coat: Coat(0xFFFBF5, 0xF7E9DA, 0xE2C8AE, 0xCBAB8D), accent: Coat(0xEECBA6, 0xDCA87B, 0xC1885B, 0xA67049),
                                  inner: Color(hex: 0xF4B2A3), patch: Color(hex: 0xFFFAF4))
        case .rabbit:
            let coat = Coat(0xFFFFFF, 0xFBF4F1, 0xE8D7D5, 0xD2BDBB)
            return CreatureColors(coat: coat, accent: coat, inner: Color(hex: 0xF5B2BA), patch: Color(hex: 0xFFFFFF))
        }
    }
}
