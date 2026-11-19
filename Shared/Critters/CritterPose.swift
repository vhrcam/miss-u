import SwiftUI

enum CritterPose: CaseIterable {
    case idle, sitting

    var mood: CritterMood {
        switch self {
        case .idle, .sitting: .happy
        }
    }

    var rig: CritterRig {
        switch self {
        case .idle:
            CritterRig(body: .standing, head: CGPoint(x: 50, y: 43),
                       back: [.init(36, 63, 30, 76), .init(64, 63, 70, 76)],
                       shadow: CGRect(x: 29, y: 90, width: 42, height: 6))
        case .sitting:
            CritterRig(body: .sitting, head: CGPoint(x: 50, y: 50),
                       back: [.init(35.5, 68, 27.5, 80.5), .init(64.5, 68, 72.5, 80.5)],
                       shadow: CGRect(x: 26, y: 90, width: 48, height: 6))
        }
    }
}

struct CritterRig {
    enum Body { case standing, sitting }

    struct Limb {
        var from: CGPoint
        var to: CGPoint
        var width: CGFloat

        init(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, width: CGFloat = 8.6) {
            from = CGPoint(x: x1, y: y1)
            to = CGPoint(x: x2, y: y2)
            self.width = width
        }
    }

    var body: Body
    var head: CGPoint
    var tilt: Angle = .zero
    var back: [Limb] = []
    var front: [Limb] = []
    var shadow: CGRect
}
