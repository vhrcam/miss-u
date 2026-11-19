import SwiftUI

enum CritterMood: CaseIterable {
    case happy, love, sleepy, surprised
}

extension CritterInk {
    func face(_ mood: CritterMood) {
        for s: CGFloat in [-1, 1] {
            context.fill(Path(ellipseIn: CGRect(x: s * 17 - 4.3, y: 5.7, width: 8.6, height: 5.6)), with: .color(Palette.cheek.opacity(mood == .love ? 0.95 : 0.7)))
            let x = s * 10.5, y: CGFloat = 3
            switch mood {
            case .happy, .surprised:
                let r: CGFloat = mood == .surprised ? 2.9 : 2.5
                context.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(Palette.ink))
                context.fill(Path(ellipseIn: CGRect(x: x + 0.1, y: y - r + 0.6, width: 1.3, height: 1.3)), with: .color(.white))
            case .love:
                var eye = Path()
                eye.move(to: CGPoint(x: x - 2.8, y: y + 1.2))
                eye.addQuadCurve(to: CGPoint(x: x + 2.8, y: y + 1.2), control: CGPoint(x: x, y: y - 2.8))
                pen(eye)
            case .sleepy:
                var eye = Path()
                eye.move(to: CGPoint(x: x - 2.8, y: y))
                eye.addQuadCurve(to: CGPoint(x: x + 2.8, y: y), control: CGPoint(x: x, y: y + 3))
                pen(eye)
            }
        }
        var mouth = Path()
        switch mood {
        case .happy:
            mouth.move(to: CGPoint(x: -2.3, y: 7.4))
            mouth.addQuadCurve(to: CGPoint(x: 2.3, y: 7.4), control: CGPoint(x: 0, y: 9.8))
            pen(mouth)
        case .love:
            mouth.move(to: CGPoint(x: -2.6, y: 7.2))
            mouth.addQuadCurve(to: CGPoint(x: 2.6, y: 7.2), control: CGPoint(x: 0, y: 12))
            mouth.closeSubpath()
            context.fill(mouth, with: .color(Palette.ink))
            pen(mouth)
        case .sleepy:
            mouth.move(to: CGPoint(x: -1.6, y: 7.6))
            mouth.addQuadCurve(to: CGPoint(x: 1.6, y: 7.6), control: CGPoint(x: 0, y: 9))
            pen(mouth)
        case .surprised:
            pen(Path(ellipseIn: CGRect(x: -1.6, y: 6.8, width: 3.2, height: 3.8)))
        }
    }
}
