import SwiftUI

struct CritterInk {
    var context: GraphicsContext
    let line: CGFloat
    let fine: CGFloat

    init(_ context: GraphicsContext, scale: CGFloat) {
        self.context = context
        line = max(2.3, 1.6 / scale)
        fine = max(1.7, 1.1 / scale)
    }

    func at(_ point: CGPoint, tilt: Angle = .zero) -> CritterInk {
        var ink = self
        ink.context.translateBy(x: point.x, y: point.y)
        ink.context.rotate(by: tilt)
        return ink
    }

    func shape(_ path: Path, _ color: Color) {
        context.fill(path, with: .color(color))
        outline(path)
    }

    func outline(_ path: Path) {
        context.stroke(path, with: .color(Palette.ink), style: StrokeStyle(lineWidth: line, lineCap: .round, lineJoin: .round))
    }

    func pen(_ path: Path) {
        context.stroke(path, with: .color(Palette.ink), style: StrokeStyle(lineWidth: fine, lineCap: .round, lineJoin: .round))
    }

    func tube(_ path: Path, width: CGFloat, _ color: Color) {
        context.stroke(path, with: .color(Palette.ink), style: StrokeStyle(lineWidth: width + line * 2, lineCap: .round, lineJoin: .round))
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }
}
