import SwiftUI

/// Three original character concepts, each shown being affectionate first, then on its own.
struct CharacterConcepts: View {
    var close: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 48) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Character concepts").font(Typeface.display)
                        Text("Three different ideas for who they are.").font(Typeface.body).foregroundStyle(Palette.cocoa)
                    }
                    Spacer()
                    if let close {
                        Button(action: close) { Text("Done").font(Typeface.tiny) }.buttonStyle(.orb(size: 52))
                    }
                }
                concept("A · Tied by a thread", "Little ink-drawn beans with stick limbs, colored slightly off the line. A red thread ties every couple together.",
                        pair: (ThreadConcept.pairSize, ThreadConcept.together),
                        solos: [(ThreadConcept.soloSize, ThreadConcept.curious), (ThreadConcept.soloSize, ThreadConcept.listening)])
                concept("B · Sewn keepsakes", "Cut from felt and sewn by hand, with embroidered faces. A couple is sewn together with one heart patch.",
                        pair: (FeltConcept.pairSize, FeltConcept.together),
                        solos: [(FeltConcept.soloSize, FeltConcept.waving), (FeltConcept.soloSize, FeltConcept.cocoa)])
                concept("C · Stretch", "Stretchy animals in one clean line. When they miss someone they stretch, so a hug can wrap all the way around.",
                        pair: (StretchConcept.pairSize, StretchConcept.together),
                        solos: [(StretchConcept.soloSize, StretchConcept.stretch), (StretchConcept.soloSize, StretchConcept.reading)])
                concept("C, drawn with A's pen", "The stretch idea with the hand-inked line and off-register color of concept A.",
                        pair: (StretchConcept.pairSize, { c in StretchConcept.inked = true; StretchConcept.together(&c); StretchConcept.inked = false }),
                        solos: [(StretchConcept.soloSize, { c in StretchConcept.inked = true; StretchConcept.stretch(&c); StretchConcept.inked = false })])
            }
            .padding(Space.xl)
        }
        .backdrop(.pink)
    }

    private func concept(_ title: String, _ note: String, pair: (CGSize, (inout GraphicsContext) -> Void), solos: [(CGSize, (inout GraphicsContext) -> Void)]) -> some View {
        VStack(alignment: .leading, spacing: Space.m) {
            Text(title).font(Typeface.title)
            Text(note).font(Typeface.caption).foregroundStyle(Palette.cocoa).fixedSize(horizontal: false, vertical: true)
            ConceptCanvas(size: pair.0, draw: pair.1)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                .shadow(color: Palette.shadow.opacity(0.12), radius: 14, y: 6)
            HStack(spacing: Space.m) {
                ForEach(solos.indices, id: \.self) { i in
                    ConceptCanvas(size: solos[i].0, draw: solos[i].1)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Palette.shadow.opacity(0.1), radius: 10, y: 4)
                }
            }
        }
    }
}
