import SwiftUI

enum Space {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 36
}

enum Radius {
    static let control: CGFloat = 20
    static let card: CGFloat = 28
}

/// Springs with very little overshoot: things settle instead of wobbling.
enum Motion {
    static let press = Animation.spring(response: 0.26, dampingFraction: 0.82)
    static let settle = Animation.spring(response: 0.45, dampingFraction: 0.86)
    static let glide = Animation.spring(response: 0.55, dampingFraction: 0.8)
}
