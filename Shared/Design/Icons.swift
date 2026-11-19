import SwiftUI

enum Icon: String, CaseIterable {
    case heart, kiss, hug, poke, headphones, bag, home, palette, star, gear, music, moon
}

struct IconView: View {
    var icon: Icon
    var size: CGFloat = 28

    var body: some View {
        Canvas { ctx, canvas in
            let s = min(canvas.width, canvas.height)
            let line = max(1.4, s * 0.075)
            let fit = CGAffineTransform(scaleX: s, y: s)
            for part in icon.parts {
                let path = part.path.applying(fit)
                if let fill = part.fill { ctx.fill(path, with: .color(fill)) }
                if part.ink { ctx.stroke(path, with: .color(Palette.ink), style: StrokeStyle(lineWidth: line * part.weight, lineCap: .round, lineJoin: .round)) }
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct IconPart {
    var path: Path
    var fill: Color?
    var ink = true
    var weight: CGFloat = 1
}

private func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

private func oval(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> Path {
    Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
}

private func shine(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) -> IconPart {
    IconPart(path: oval(cx, cy, r, r * 0.75), fill: .white.opacity(0.85), ink: false)
}

private func line(_ points: CGPoint...) -> Path {
    var p = Path()
    p.addLines(points)
    return p
}

private extension Path {
    static func heart(_ cx: CGFloat, _ cy: CGFloat, _ s: CGFloat) -> Path {
        var p = Path()
        func q(_ x: CGFloat, _ y: CGFloat) -> CGPoint { pt(cx + (x - 0.5) * s, cy + (y - 0.5) * s) }
        p.move(to: q(0.5, 0.9))
        p.addCurve(to: q(0.06, 0.4), control1: q(0.3, 0.77), control2: q(0.05, 0.6))
        p.addCurve(to: q(0.5, 0.27), control1: q(0.07, 0.14), control2: q(0.38, 0.08))
        p.addCurve(to: q(0.94, 0.4), control1: q(0.62, 0.08), control2: q(0.93, 0.14))
        p.addCurve(to: q(0.5, 0.9), control1: q(0.95, 0.6), control2: q(0.7, 0.77))
        p.closeSubpath()
        return p
    }
}

extension Icon {
    var parts: [IconPart] {
        switch self {
        case .heart:
            return [IconPart(path: .heart(0.5, 0.52, 0.88), fill: Color(hex: 0xFF8FAB)), shine(0.3, 0.36, 0.07)]

        case .kiss:
            var lips = Path()
            lips.move(to: pt(0.08, 0.52))
            lips.addCurve(to: pt(0.36, 0.27), control1: pt(0.16, 0.38), control2: pt(0.26, 0.26))
            lips.addCurve(to: pt(0.5, 0.36), control1: pt(0.43, 0.27), control2: pt(0.47, 0.32))
            lips.addCurve(to: pt(0.64, 0.27), control1: pt(0.53, 0.32), control2: pt(0.57, 0.27))
            lips.addCurve(to: pt(0.92, 0.52), control1: pt(0.74, 0.26), control2: pt(0.84, 0.38))
            lips.addCurve(to: pt(0.5, 0.8), control1: pt(0.84, 0.7), control2: pt(0.68, 0.8))
            lips.addCurve(to: pt(0.08, 0.52), control1: pt(0.32, 0.8), control2: pt(0.16, 0.7))
            lips.closeSubpath()
            var seam = Path()
            seam.move(to: pt(0.14, 0.52))
            seam.addQuadCurve(to: pt(0.5, 0.55), control: pt(0.32, 0.6))
            seam.addQuadCurve(to: pt(0.86, 0.52), control: pt(0.68, 0.6))
            return [IconPart(path: lips, fill: Color(hex: 0xF7869C)), IconPart(path: seam, fill: nil, weight: 0.8), shine(0.36, 0.68, 0.06)]

        case .hug:
            var left = Path()
            left.move(to: pt(0.1, 0.4))
            left.addQuadCurve(to: pt(0.44, 0.7), control: pt(0.12, 0.72))
            var right = Path()
            right.move(to: pt(0.9, 0.4))
            right.addQuadCurve(to: pt(0.56, 0.7), control: pt(0.88, 0.72))
            let arm = Color(hex: 0xFFD3B5)
            return [
                IconPart(path: .heart(0.5, 0.48, 0.74), fill: Color(hex: 0xFF8FAB)),
                shine(0.33, 0.33, 0.055),
                IconPart(path: left.strokedPath(StrokeStyle(lineWidth: 0.15, lineCap: .round)), fill: arm),
                IconPart(path: right.strokedPath(StrokeStyle(lineWidth: 0.15, lineCap: .round)), fill: arm),
            ]

        case .poke:
            let fur = Color(hex: 0xFFE6CF), bean = Color(hex: 0xFFA3B5)
            return [
                IconPart(path: oval(0.52, 0.64, 0.3, 0.26), fill: fur),
                IconPart(path: oval(0.52, 0.68, 0.15, 0.12), fill: bean, weight: 0.75),
                IconPart(path: oval(0.32, 0.4, 0.075, 0.09), fill: bean, weight: 0.75),
                IconPart(path: oval(0.48, 0.33, 0.075, 0.09), fill: bean, weight: 0.75),
                IconPart(path: oval(0.66, 0.37, 0.075, 0.09), fill: bean, weight: 0.75),
                IconPart(path: line(pt(0.82, 0.14), pt(0.9, 0.06)), fill: nil, weight: 0.8),
                IconPart(path: line(pt(0.9, 0.26), pt(0.97, 0.22)), fill: nil, weight: 0.8),
            ]

        case .headphones:
            var band = Path()
            band.move(to: pt(0.16, 0.6))
            band.addCurve(to: pt(0.84, 0.6), control1: pt(0.12, 0.12), control2: pt(0.88, 0.12))
            let cup = Color(hex: 0xAED3F7), pad = Color(hex: 0xCDBBF6)
            return [
                IconPart(path: band.strokedPath(StrokeStyle(lineWidth: 0.09, lineCap: .round)), fill: pad),
                IconPart(path: Path(roundedRect: CGRect(x: 0.08, y: 0.5, width: 0.22, height: 0.36), cornerRadius: 0.1), fill: cup),
                IconPart(path: Path(roundedRect: CGRect(x: 0.7, y: 0.5, width: 0.22, height: 0.36), cornerRadius: 0.1), fill: cup),
                shine(0.15, 0.6, 0.035),
                shine(0.77, 0.6, 0.035),
            ]

        case .bag:
            var body = Path()
            body.move(to: pt(0.2, 0.34))
            body.addLine(to: pt(0.8, 0.34))
            body.addQuadCurve(to: pt(0.88, 0.84), control: pt(0.86, 0.5))
            body.addQuadCurve(to: pt(0.78, 0.92), control: pt(0.89, 0.92))
            body.addLine(to: pt(0.22, 0.92))
            body.addQuadCurve(to: pt(0.12, 0.84), control: pt(0.11, 0.92))
            body.addQuadCurve(to: pt(0.2, 0.34), control: pt(0.14, 0.5))
            body.closeSubpath()
            var handle = Path()
            handle.move(to: pt(0.34, 0.42))
            handle.addCurve(to: pt(0.66, 0.42), control1: pt(0.32, 0.06), control2: pt(0.68, 0.06))
            return [
                IconPart(path: body, fill: Color(hex: 0xFFC4A3)),
                IconPart(path: handle, fill: nil, weight: 0.9),
                IconPart(path: .heart(0.5, 0.64, 0.26), fill: Color(hex: 0xFF8FAB), weight: 0.7),
            ]

        case .home:
            var house = Path()
            house.move(to: pt(0.5, 0.1))
            house.addQuadCurve(to: pt(0.9, 0.46), control: pt(0.9, 0.38))
            house.addLine(to: pt(0.84, 0.46))
            house.addLine(to: pt(0.84, 0.82))
            house.addQuadCurve(to: pt(0.76, 0.9), control: pt(0.84, 0.9))
            house.addLine(to: pt(0.24, 0.9))
            house.addQuadCurve(to: pt(0.16, 0.82), control: pt(0.16, 0.9))
            house.addLine(to: pt(0.16, 0.46))
            house.addLine(to: pt(0.1, 0.46))
            house.addQuadCurve(to: pt(0.5, 0.1), control: pt(0.1, 0.38))
            house.closeSubpath()
            return [
                IconPart(path: house, fill: Color(hex: 0xFFE08A)),
                IconPart(path: .heart(0.5, 0.64, 0.34), fill: Color(hex: 0xFF8FAB), weight: 0.75),
            ]

        case .palette:
            var board = Path()
            board.move(to: pt(0.5, 0.1))
            board.addCurve(to: pt(0.92, 0.5), control1: pt(0.76, 0.1), control2: pt(0.92, 0.28))
            board.addCurve(to: pt(0.62, 0.9), control1: pt(0.92, 0.74), control2: pt(0.8, 0.9))
            board.addCurve(to: pt(0.5, 0.74), control1: pt(0.5, 0.9), control2: pt(0.58, 0.76))
            board.addCurve(to: pt(0.1, 0.52), control1: pt(0.3, 0.78), control2: pt(0.1, 0.74))
            board.addCurve(to: pt(0.5, 0.1), control1: pt(0.1, 0.28), control2: pt(0.26, 0.1))
            board.closeSubpath()
            return [
                IconPart(path: board, fill: Color(hex: 0xF5EBE2)),
                IconPart(path: oval(0.33, 0.42, 0.08, 0.08), fill: Color(hex: 0xFF8FAB), weight: 0.7),
                IconPart(path: oval(0.52, 0.29, 0.08, 0.08), fill: Color(hex: 0xFFE08A), weight: 0.7),
                IconPart(path: oval(0.71, 0.42, 0.08, 0.08), fill: Color(hex: 0xAED3F7), weight: 0.7),
                IconPart(path: oval(0.72, 0.65, 0.07, 0.07), fill: Color(hex: 0xAEE3C4), weight: 0.7),
            ]

        case .star:
            var star = Path()
            let points = (0..<10).map { i -> CGPoint in
                let a = CGFloat(i) * .pi / 5 - .pi / 2
                let r: CGFloat = i.isMultiple(of: 2) ? 0.44 : 0.24
                return pt(0.5 + r * cos(a), 0.54 + r * sin(a))
            }
            star.move(to: CGPoint(x: (points[9].x + points[0].x) / 2, y: (points[9].y + points[0].y) / 2))
            for i in 0..<10 {
                let next = points[(i + 1) % 10]
                star.addQuadCurve(to: CGPoint(x: (points[i].x + next.x) / 2, y: (points[i].y + next.y) / 2), control: points[i])
            }
            star.closeSubpath()
            return [IconPart(path: star, fill: Color(hex: 0xFFE08A)), shine(0.4, 0.42, 0.05)]

        case .gear:
            var gear = Path()
            let teeth = 8
            let points = (0..<teeth * 2).map { i -> CGPoint in
                let a = CGFloat(i) * .pi / CGFloat(teeth)
                let r: CGFloat = i.isMultiple(of: 2) ? 0.45 : 0.34
                return pt(0.5 + r * cos(a), 0.5 + r * sin(a))
            }
            gear.move(to: CGPoint(x: (points.last!.x + points[0].x) / 2, y: (points.last!.y + points[0].y) / 2))
            for i in points.indices {
                let next = points[(i + 1) % points.count]
                gear.addQuadCurve(to: CGPoint(x: (points[i].x + next.x) / 2, y: (points[i].y + next.y) / 2), control: points[i])
            }
            gear.closeSubpath()
            return [
                IconPart(path: gear, fill: Color(hex: 0xCDBBF6)),
                IconPart(path: oval(0.5, 0.5, 0.13, 0.13), fill: Palette.warmWhite, weight: 0.8),
            ]

        case .music:
            var stem = Path()
            stem.move(to: pt(0.38, 0.72))
            stem.addLine(to: pt(0.38, 0.18))
            stem.addQuadCurve(to: pt(0.82, 0.12), control: pt(0.6, 0.1))
            stem.addLine(to: pt(0.82, 0.62))
            return [
                IconPart(path: stem, fill: nil),
                IconPart(path: oval(0.26, 0.74, 0.14, 0.11), fill: Color(hex: 0xCDBBF6)),
                IconPart(path: oval(0.7, 0.66, 0.14, 0.11), fill: Color(hex: 0xCDBBF6)),
            ]

        case .moon:
            var moon = Path()
            moon.move(to: pt(0.62, 0.1))
            moon.addCurve(to: pt(0.9, 0.66), control1: pt(0.48, 0.3), control2: pt(0.6, 0.66))
            moon.addCurve(to: pt(0.62, 0.1), control1: pt(0.78, 0.98), control2: pt(0.02, 0.92))
            moon.closeSubpath()
            return [IconPart(path: moon, fill: Color(hex: 0xFFE08A)), shine(0.3, 0.5, 0.04)]
        }
    }
}
