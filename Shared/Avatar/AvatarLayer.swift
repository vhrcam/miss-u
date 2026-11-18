import SwiftUI

extension AvatarView {
    static let line: CGFloat = 2.2
    static let rim: CGFloat = 4.8

    struct Layer: Equatable {
        var path: Path
        var fill: Color?
        var stroke: Color?
        var width: CGFloat = 0
        var outer = false

        static func solid(_ path: Path, _ fill: Color, _ width: CGFloat = AvatarView.line) -> Layer {
            Layer(path: path, fill: fill, stroke: Theme.ink, width: width, outer: true)
        }

        static func flat(_ path: Path, _ fill: Color) -> Layer {
            Layer(path: path, fill: fill)
        }

        static func ink(_ path: Path, _ width: CGFloat, _ color: Color = Theme.ink) -> Layer {
            Layer(path: path, stroke: color, width: width)
        }

        func applying(_ transform: CGAffineTransform) -> Layer {
            var layer = self
            layer.path = path.applying(transform)
            return layer
        }
    }

    struct Unit: Shape {
        var path: Path

        func path(in rect: CGRect) -> Path {
            let s = min(rect.width, rect.height) / 100
            return path.applying(CGAffineTransform(a: s, b: 0, c: 0, d: s, tx: rect.midX - 50 * s, ty: rect.midY - 50 * s))
        }
    }

    struct Stack: View, Equatable {
        var layers: [Layer]

        var body: some View {
            ZStack {
                ForEach(layers.indices, id: \.self) { i in
                    if layers[i].outer {
                        Unit(path: Self.outline(layers[i].path, AvatarView.rim)).fill(Theme.ink)
                    }
                }
                ForEach(layers.indices, id: \.self) { i in
                    let layer = layers[i]
                    if let fill = layer.fill {
                        Unit(path: layer.path).fill(fill)
                    }
                    if let stroke = layer.stroke {
                        Unit(path: Self.outline(layer.path, layer.width)).fill(stroke)
                    }
                }
            }
        }

        static func outline(_ path: Path, _ width: CGFloat) -> Path {
            path.strokedPath(StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
        }
    }

    struct Pen {
        var path = Path()

        mutating func move(_ x: CGFloat, _ y: CGFloat) {
            path.move(to: CGPoint(x: x, y: y))
        }

        mutating func line(_ x: CGFloat, _ y: CGFloat) {
            path.addLine(to: CGPoint(x: x, y: y))
        }

        mutating func curve(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, _ x: CGFloat, _ y: CGFloat) {
            path.addCurve(to: CGPoint(x: x, y: y), control1: CGPoint(x: x1, y: y1), control2: CGPoint(x: x2, y: y2))
        }

        mutating func quad(_ cx: CGFloat, _ cy: CGFloat, _ x: CGFloat, _ y: CGFloat) {
            path.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: cx, y: cy))
        }

        mutating func close() {
            path.closeSubpath()
        }
    }

    static func oval(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
    }

    static func circle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) -> Path {
        oval(cx, cy, r, r)
    }

    static func capsule(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, _ r: CGFloat) -> Path {
        var pen = Pen()
        pen.move(x1, y1)
        pen.line(x2, y2)
        return pen.path.strokedPath(StrokeStyle(lineWidth: r * 2, lineCap: .round))
    }

    static func pair(_ path: Path) -> Path {
        var both = path
        both.addPath(path.applying(flip))
        return both
    }

    static let flip = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: 100, ty: 0)

    static func turn(_ degrees: CGFloat, _ cx: CGFloat, _ cy: CGFloat) -> CGAffineTransform {
        CGAffineTransform(translationX: cx, y: cy).rotated(by: degrees * .pi / 180).translatedBy(x: -cx, y: -cy)
    }

    static func grow(_ sx: CGFloat, _ sy: CGFloat, _ cx: CGFloat, _ cy: CGFloat) -> CGAffineTransform {
        CGAffineTransform(translationX: cx, y: cy).scaledBy(x: sx, y: sy).translatedBy(x: -cx, y: -cy)
    }
}
