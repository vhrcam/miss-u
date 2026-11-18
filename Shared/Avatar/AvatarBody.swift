import SwiftUI

extension AvatarView {
    static var bodyPath: Path {
        var pen = Pen()
        pen.move(50, 16)
        pen.curve(68.5, 16, 79, 37, 79, 61)
        pen.curve(79, 79, 68, 86, 50, 86)
        pen.curve(32, 86, 21, 79, 21, 61)
        pen.curve(21, 37, 31.5, 16, 50, 16)
        pen.close()
        return pen.path
    }

    static func body(_ color: AvatarColor) -> [Layer] {
        let shape = bodyPath
        return [
            .flat(shape, color.fill),
            .flat(shape.subtracting(shape.offsetBy(dx: -3.5, dy: -4.5)), Theme.ink.opacity(0.07)),
            .flat(oval(35, 29, 4.6, 2.6).applying(turn(-42, 35, 29)), .white.opacity(0.8)),
            Layer(path: shape, stroke: Theme.ink, width: line, outer: true)
        ]
    }

    static func feet(_ color: AvatarColor) -> [Layer] {
        [.solid(pair(oval(41, 86, 7, 4.8)), color.fill)]
    }

    static func sideArms(_ skin: Color, _ outfit: Outfit, _ shirt: Color) -> [Layer] {
        let arm = pair(oval(79.5, 64, 5, 7.6).applying(turn(-52, 79.5, 64)))
        switch outfit {
        case .hoodie, .sweater:
            return [.solid(arm, shirt)]
        case .tee:
            return [.solid(arm, skin), .solid(arm.intersection(pair(circle(76.5, 60, 6.5))), shirt, 1.6)]
        case .overalls, .dress:
            return [.solid(arm, skin)]
        }
    }
}
