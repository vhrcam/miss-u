import SwiftUI

enum Space {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 36
}

enum Line {
    static let control: CGFloat = 2.5
    static let card: CGFloat = 2
    static let lip: CGFloat = 4
}

enum Motion {
    static let press = Animation.spring(response: 0.2, dampingFraction: 0.6)
    static let pop = Animation.spring(response: 0.34, dampingFraction: 0.42)
    static let hop = Animation.spring(response: 0.42, dampingFraction: 0.55)
    static let settle = Animation.spring(response: 0.5, dampingFraction: 0.82)
}
