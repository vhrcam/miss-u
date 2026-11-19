import SwiftUI

extension View {
    func stickerCard(lip: Color = Palette.latte, fill: Color = Palette.warmWhite, seed: Int = 0) -> some View {
        padding(Space.l + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .sticker(fill, lip: lip, depth: 5, corner: 26, line: Line.card, seed: seed)
            .padding(.bottom, 5)
    }

    func softCard(_ tint: Tint, seed: Int = 0) -> some View {
        padding(Space.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .sticker(tint.soft, depth: 0, corner: 22, line: Line.card, seed: seed)
    }

    func backdrop(_ tint: Tint, doodles: Bool = true) -> some View {
        foregroundStyle(Palette.ink)
            .background { Backdrop(tint: tint, doodles: doodles).ignoresSafeArea() }
    }
}

struct Backdrop: View {
    var tint: Tint
    var doodles = true

    var body: some View {
        tint.soft.overlay {
            if doodles {
                Canvas { ctx, size in
                    let cell: CGFloat = 74
                    for row in 0...Int(size.height / cell) {
                        for col in 0...Int(size.width / cell) {
                            let n = row * 37 + col * 11
                            let pick = Blob.random(n, 1)
                            guard pick < 0.42 else { continue }
                            let x = (CGFloat(col) + 0.2 + Blob.random(n, 2) * 0.6) * cell
                            let y = (CGFloat(row) + 0.2 + Blob.random(n, 3) * 0.6) * cell
                            let s = 6 + Blob.random(n, 4) * 6
                            let rect = CGRect(x: x - s / 2, y: y - s / 2, width: s, height: s * 0.92)
                            let path = pick < 0.14 ? HeartShape().path(in: rect)
                                : pick < 0.26 ? SparkleShape().path(in: rect.insetBy(dx: -1, dy: -1))
                                : Path(ellipseIn: rect.insetBy(dx: s * 0.3, dy: s * 0.3))
                            ctx.fill(path, with: .color(tint.deep.opacity(0.28)))
                        }
                    }
                }
            }
        }
    }
}

struct Ground: View {
    var width: CGFloat

    var body: some View {
        Ellipse().fill(Palette.ground).frame(width: width, height: width * 0.16)
    }
}
