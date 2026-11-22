import SwiftUI

extension CritterPaint {
    /// Tiny eyes, a small nose and mouth, and soft blush. Drawn in head space.
    func face(_ species: Species, fur: Fur, mood: CritterMood, life: CritterLife) {
        let eyes: CritterMood = life.glee > 0.35 && mood != .sleepy ? .love : mood
        let gx = life.gaze.x * 1.4, gy = life.gaze.y * 0.8

        if let muzzle = fur.muzzle {
            let m = Path(ellipseIn: CGRect(x: -7.2 + gx * 0.5, y: 1.8, width: 14.4, height: 10))
            context.fill(m, with: .linearGradient(Gradient(colors: [muzzle, muzzle.opacity(0.7)]), startPoint: CGPoint(x: 0, y: 1.8), endPoint: CGPoint(x: 0, y: 11.8)))
        }

        let blush = 0.5 + (mood == .love ? 0.2 : 0) + 0.25 * Double(life.glee)
        for s: CGFloat in [-1, 1] {
            glow(CGPoint(x: s * 16.2 + gx * 0.4, y: 6.6), 5.8, 3.7, Palette.cheek, blush)
        }

        let open = 1 - life.blink
        for s: CGFloat in [-1, 1] {
            let x = s * 10.4 + gx, y = 2.4 + gy
            switch eyes {
            case .happy, .surprised:
                if open > 0.2 {
                    let rx: CGFloat = eyes == .surprised ? 2.5 : 2.2
                    let ry = (eyes == .surprised ? 2.9 : 2.55) * open
                    context.fill(Path(ellipseIn: CGRect(x: x - rx, y: y - ry, width: rx * 2, height: ry * 2)), with: .color(Palette.eye))
                    if open > 0.75 {
                        context.fill(Path(ellipseIn: CGRect(x: x + 0.3, y: y - ry + 0.55, width: 1.2, height: 1.2)), with: .color(.white.opacity(0.95)))
                    }
                } else {
                    var lid = Path()
                    lid.move(to: CGPoint(x: x - 2.4, y: y))
                    lid.addQuadCurve(to: CGPoint(x: x + 2.4, y: y), control: CGPoint(x: x, y: y + 1.2))
                    pen(lid, Palette.eye, width: fine * 1.15)
                }
            case .love:
                var eye = Path()
                eye.move(to: CGPoint(x: x - 2.6, y: y + 1.1))
                eye.addQuadCurve(to: CGPoint(x: x + 2.6, y: y + 1.1), control: CGPoint(x: x, y: y - 2.6))
                pen(eye, Palette.eye, width: fine * 1.2)
            case .sleepy:
                var eye = Path()
                eye.move(to: CGPoint(x: x - 2.6, y: y))
                eye.addQuadCurve(to: CGPoint(x: x + 2.6, y: y), control: CGPoint(x: x, y: y + 2.6))
                pen(eye, Palette.eye, width: fine * 1.2)
            }
        }

        let nx = gx * 0.6
        switch species {
        case .cat, .rabbit:
            let k: CGFloat = species == .cat ? 1 : 0.8
            var nose = Path()
            nose.addLines([CGPoint(x: nx - 1.3 * k, y: 4.7), CGPoint(x: nx + 1.3 * k, y: 4.7), CGPoint(x: nx, y: 4.7 + 1.25 * k)])
            nose.closeSubpath()
            context.fill(nose, with: .color(Palette.nose))
            context.stroke(nose, with: .color(Palette.nose), style: StrokeStyle(lineWidth: 0.7, lineJoin: .round))
        case .bear, .dog:
            let rx: CGFloat = species == .dog ? 2.3 : 2, ry: CGFloat = species == .dog ? 1.55 : 1.4
            context.fill(Path(ellipseIn: CGRect(x: nx - rx, y: 5 - ry, width: rx * 2, height: ry * 2)), with: .color(Palette.eye))
            context.fill(Path(ellipseIn: CGRect(x: nx - rx * 0.45, y: 5 - ry * 0.7, width: rx * 0.5, height: ry * 0.45)), with: .color(.white.opacity(0.55)))
        }

        let top: CGFloat = species == .bear || species == .dog ? 6.5 : 6
        var mouth = Path()
        switch mood {
        case .happy:
            mouth.move(to: CGPoint(x: nx - 2.3, y: top + 0.6))
            mouth.addQuadCurve(to: CGPoint(x: nx, y: top + 0.7), control: CGPoint(x: nx - 1.2, y: top + 2.4))
            mouth.addQuadCurve(to: CGPoint(x: nx + 2.3, y: top + 0.6), control: CGPoint(x: nx + 1.2, y: top + 2.4))
            mouth.move(to: CGPoint(x: nx, y: top - 0.6))
            mouth.addLine(to: CGPoint(x: nx, y: top + 0.7))
            pen(mouth, Palette.mouth)
        case .love:
            mouth.move(to: CGPoint(x: nx - 2.3, y: top + 0.7))
            mouth.addQuadCurve(to: CGPoint(x: nx + 2.3, y: top + 0.7), control: CGPoint(x: nx, y: top + 5))
            mouth.closeSubpath()
            context.fill(mouth, with: .color(Palette.mouth))
            var tongue = context
            tongue.clip(to: mouth)
            tongue.fill(Path(ellipseIn: CGRect(x: nx - 1.3, y: top + 2, width: 2.6, height: 1.8)), with: .color(Palette.heartBase))
            pen(mouth, Palette.mouth, width: fine * 0.8)
        case .sleepy:
            mouth.move(to: CGPoint(x: nx - 1.5, y: top + 1))
            mouth.addQuadCurve(to: CGPoint(x: nx + 1.5, y: top + 1), control: CGPoint(x: nx, y: top + 2.2))
            pen(mouth, Palette.mouth)
        case .surprised:
            pen(Path(ellipseIn: CGRect(x: nx - 1.4, y: top + 0.6, width: 2.8, height: 3.2)), Palette.mouth)
        }
    }
}
