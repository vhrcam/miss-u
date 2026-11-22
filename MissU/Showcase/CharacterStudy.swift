import SwiftUI

/// Three outline-free finishes for the characters, shown on the same cat and on the bear holding the cat close.
struct CharacterStudy: View {
    var close: (() -> Void)?
    @State private var finish = CreatureFinish.tonal

    private let pose = CreaturePose(tilt: 5, turn: 0.22, ears: (left: -5, right: 0))

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xxl) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Character study").font(Typeface.display)
                        Text("No outlines. Three ways to finish them.").font(Typeface.body).foregroundStyle(Palette.cocoa)
                    }
                    Spacer()
                    if let close {
                        Button(action: close) { Text("Done").font(Typeface.tiny) }.buttonStyle(.orb(size: 52))
                    }
                }

                VStack(spacing: Space.l) {
                    CuddleScene(finish: finish, animated: true)
                        .frame(maxWidth: 360)
                        .frame(maxWidth: .infinity)
                    HStack(spacing: Space.s) {
                        ForEach(CreatureFinish.allCases) { f in
                            ActivityChip(icon: icon(f), label: f.short, tint: tint(f), selected: finish == f) {
                                withAnimation(Motion.settle) { finish = f }
                            }
                        }
                    }
                    Text(finish.title).font(Typeface.caption).foregroundStyle(Palette.cocoa)
                }

                VStack(alignment: .leading, spacing: Space.m) {
                    Text("Same cat, three finishes").font(Typeface.title)
                    HStack(alignment: .bottom, spacing: Space.s) {
                        ForEach(Array(CreatureFinish.allCases.enumerated()), id: \.offset) { i, f in
                            VStack(spacing: Space.xs) {
                                CreatureView(.cat, pose: pose, finish: f, animated: true, seed: Double(i) * 1.7)
                                Text(f.title).font(Typeface.tiny).foregroundStyle(Palette.cocoa)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(Space.xl)
        }
        .backdrop(.pink)
    }

    private func icon(_ f: CreatureFinish) -> Icon {
        switch f {
        case .shape: .palette
        case .tonal: .star
        case .soft: .moon
        }
    }

    private func tint(_ f: CreatureFinish) -> Tint {
        switch f {
        case .shape: .peach
        case .tonal: .pink
        case .soft: .lavender
        }
    }
}
