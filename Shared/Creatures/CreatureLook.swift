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
            Recipe(shadow: 0.5, shadowBlur: 2.6, shadowReach: 6, core: 0, light: 0.4, lightBlur: 3, lightReach: 5,
                   wash: 0.16, edge: 0.5, edgeWidth: 0.9, bounce: 0.2, occlusion: 0.6, occlusionBlur: 1.5, occlusionReach: 2.6, halo: 0.07)
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
    var muzzle: Coat? = nil
}

extension Species {
    var colors: CreatureColors {
        switch self {
        case .cat:
            let coat = Coat(0xDAD3CE, 0xBDB4AE, 0x9E9590, 0x847B77)
            return CreatureColors(coat: coat, accent: coat, inner: Color(hex: 0xEEA7A1), patch: Color(hex: 0xF8F4F0),
                                  muzzle: Coat(0xFFFFFF, 0xF8F4F0, 0xE0D8D2, 0xC9BFB9))
        case .bear:
            let coat = Coat(0xD9A47A, 0xBF8658, 0x9F6A43, 0x855634)
            return CreatureColors(coat: coat, accent: coat, inner: Color(hex: 0xE3B49A), patch: Color(hex: 0xEACFAE),
                                  muzzle: Coat(0xF5E3CD, 0xE8CCA9, 0xD1AF8A, 0xBC9973))
        case .dog:
            return CreatureColors(coat: Coat(0xF0D2AE, 0xE2B888, 0xC9996A, 0xAE7E52), accent: Coat(0xE0B184, 0xCC9764, 0xB07A4A, 0x956138),
                                  inner: Color(hex: 0xF0B3A2), patch: Color(hex: 0xFBF3E9), muzzle: Coat(0xFFFDF8, 0xFBF3E9, 0xE7D7C4, 0xD3C0A9))
        case .rabbit:
            let coat = Coat(0xFFFFFF, 0xF6EFEC, 0xDACBC8, 0xBFACA9)
            return CreatureColors(coat: coat, accent: coat, inner: Color(hex: 0xF3B0B8), patch: Color(hex: 0xFFFFFF),
                                  muzzle: Coat(0xFFFFFF, 0xFFFCFA, 0xEDE3E0, 0xDCCFCC))
        }
    }
}
