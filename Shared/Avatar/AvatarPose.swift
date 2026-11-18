import SwiftUI

extension AvatarView {
    enum Pose {
        case idle, hold, lift, lie
    }

    static func pose(_ activity: ActivityKind?) -> Pose {
        switch activity {
        case .sleeping: .lie
        case .exercising: .lift
        case .music, nil: .idle
        default: .hold
        }
    }

    static func expression(_ activity: ActivityKind?) -> Expression {
        switch activity {
        case nil, .shopping: .happy
        case .music: .joy
        case .sleeping: .asleep
        case .studying, .working, .gaming: .focus
        case .coffee: .cozy
        case .tv: .grin
        case .exercising: .effort
        case .missingYou: .love
        }
    }

    static func hand(_ activity: ActivityKind?) -> CGPoint {
        switch activity {
        case .shopping: CGPoint(x: 65, y: 68.5)
        case .gaming: CGPoint(x: 62, y: 78.5)
        case .studying: CGPoint(x: 65, y: 72)
        case .working: CGPoint(x: 60, y: 80)
        case .coffee: CGPoint(x: 57.5, y: 82)
        case .tv: CGPoint(x: 62.5, y: 74)
        default: CGPoint(x: 63.5, y: 67.5)
        }
    }

    static var sideArm: Path {
        oval(79.5, 64, 5, 7.6).applying(turn(-52, 79.5, 64))
    }

    static func sleeved(_ arm: Path, _ shoulder: Path, _ skin: Color, _ outfit: Outfit?, _ shirt: Color) -> [Layer] {
        switch outfit {
        case .hoodie?, .sweater?:
            return [.solid(arm, shirt)]
        case .tee?:
            return [.solid(arm, skin), .solid(arm.intersection(shoulder), shirt, 1.6)]
        default:
            return [.solid(arm, skin)]
        }
    }

    static func arms(_ pose: Pose, _ activity: ActivityKind?, _ skin: Color, _ outfit: Outfit?, _ shirt: Color) -> [Layer] {
        switch pose {
        case .idle:
            return sleeved(pair(sideArm), pair(circle(76.5, 60, 6.5)), skin, outfit, shirt)
        case .lie:
            return []
        case .lift:
            return sleeved(sideArm.applying(flip), circle(23.5, 60, 6.5), skin, outfit, shirt)
                + dumbbell
                + sleeved(capsule(74, 59, 86.5, 46.5, 4.8), circle(74, 58, 6.5), skin, outfit, shirt)
        case .hold:
            let hand = hand(activity)
            return sleeved(pair(capsule(72.5, 63, hand.x, hand.y, 5)), pair(circle(72.5, 63, 6.5)), skin, outfit, shirt)
        }
    }

    static let lying = turn(-90, 50, 55).concatenating(CGAffineTransform(translationX: 2, y: 3))
}
