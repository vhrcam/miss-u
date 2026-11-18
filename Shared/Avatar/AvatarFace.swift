import SwiftUI

extension AvatarView {
    enum Expression {
        case happy, joy, asleep, focus, cozy, love, effort, grin
    }

    enum Eyes {
        case dot, glossy, shut, smile, squeeze, blink
    }

    enum Mouth {
        case smile, open, snore, flat
    }

    static func face(_ expression: Expression, _ presentation: Presentation, blink: Bool = false) -> [Layer] {
        var eyes = Eyes.dot
        var mouth = Mouth.smile
        var blush = 0.45
        switch expression {
        case .happy: break
        case .joy: eyes = .smile; mouth = .open
        case .asleep: eyes = .shut; mouth = .snore
        case .focus: mouth = .flat
        case .cozy: eyes = .shut; blush = 0.6
        case .love: eyes = .glossy; blush = 0.7
        case .effort: eyes = .squeeze; mouth = .open
        case .grin: mouth = .open
        }
        if blink && (eyes == .dot || eyes == .glossy) {
            eyes = .blink
        }
        let drop: CGFloat = expression == .focus ? 1.4 : 0

        var layers: [Layer] = [.flat(pair(oval(33, 53, 4.8, 3)), Color(hex: 0xFF7F9C).opacity(blush))]
        layers += eyeLayers(eyes, drop)
        layers += mouthLayer(mouth)
        switch presentation {
        case .feminine: layers += lashes(eyes, drop)
        case .masculine: layers += brows(expression)
        case .neutral: break
        }
        return layers
    }

    static func eyeLayers(_ eyes: Eyes, _ drop: CGFloat) -> [Layer] {
        var pen = Pen()
        switch eyes {
        case .dot:
            return [.flat(pair(circle(40.5, 46 + drop, 3.3)), Theme.ink)]
        case .glossy:
            return [
                .flat(pair(circle(40.5, 46, 3.8)), Theme.ink),
                .flat(pair(circle(39.3, 44.7, 1.3)), .white)
            ]
        case .shut:
            pen.move(37, 46)
            pen.curve(38, 49.2, 43, 49.2, 44, 46)
        case .smile:
            pen.move(37, 47.5)
            pen.curve(38, 43.2, 43, 43.2, 44, 47.5)
        case .squeeze:
            pen.move(37.5, 43.4)
            pen.line(43.2, 46.4)
            pen.line(37.5, 49.4)
        case .blink:
            pen.move(37.3, 46.4)
            pen.quad(40.5, 47.6, 43.7, 46.4)
        }
        return [.ink(pair(pen.path), 2.3)]
    }

    static func mouthLayer(_ mouth: Mouth) -> [Layer] {
        var pen = Pen()
        switch mouth {
        case .smile:
            pen.move(46.6, 50.8)
            pen.curve(46.9, 55.2, 53.1, 55.2, 53.4, 50.8)
            return [.ink(pen.path, 2.1)]
        case .open:
            pen.move(45.6, 50.6)
            pen.curve(46, 57.4, 54, 57.4, 54.4, 50.6)
            pen.close()
            return [
                Layer(path: pen.path, fill: Theme.ink, stroke: Theme.ink, width: 1.2),
                .flat(oval(50, 54.6, 2.5, 1.3), Color(hex: 0xFF8FA6))
            ]
        case .snore:
            return [.flat(oval(50, 52.6, 1.7, 2), Theme.ink)]
        case .flat:
            pen.move(47.6, 52.4)
            pen.quad(50, 53.4, 52.4, 52.4)
            return [.ink(pen.path, 2.1)]
        }
    }

    static func lashes(_ eyes: Eyes, _ drop: CGFloat) -> [Layer] {
        var pen = Pen()
        switch eyes {
        case .dot, .glossy:
            pen.move(37.9, 43.9 + drop)
            pen.line(35.6, 42.4 + drop)
            pen.move(39.2, 43 + drop)
            pen.line(37.9, 40.8 + drop)
        case .shut, .blink:
            pen.move(37.6, 47.2)
            pen.line(35.4, 48.4)
            pen.move(38.6, 48.3)
            pen.line(37.2, 50.2)
        case .smile:
            pen.move(37.2, 46.6)
            pen.line(34.9, 45.6)
            pen.move(37.8, 45.2)
            pen.line(35.8, 43.5)
        case .squeeze:
            return []
        }
        return [.ink(pair(pen.path), 1.7)]
    }

    static func brows(_ expression: Expression) -> [Layer] {
        var pen = Pen()
        switch expression {
        case .effort:
            pen.move(36.8, 38.6)
            pen.line(43.6, 40.6)
        case .love:
            pen.move(37, 40.4)
            pen.quad(40.6, 38.4, 43.8, 38.9)
        default:
            pen.move(37.2, 40.2)
            pen.quad(40.5, 38.6, 43.8, 40)
        }
        return [.ink(pair(pen.path), 2.5)]
    }
}
