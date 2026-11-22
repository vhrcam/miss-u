import SwiftUI

struct HomeConcept: View {
    var close: (() -> Void)?
    var scrolls = true
    @State private var tab = 0
    @State private var doing = 0
    @State private var sent = 0

    private let chips: [(Icon, String, Tint)] = [
        (.music, "Music", .lavender), (.cup, "Coffee", .peach), (.book, "Studying", .sky),
        (.controller, "Gaming", .mint), (.bag, "Shopping", .butter), (.moon, "Sleeping", .lavender),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Good evening,").font(Typeface.body).foregroundStyle(Palette.cocoa)
                    Text("alex").font(Typeface.display)
                }
                Spacer()
                if let close {
                    Button(action: close) { Text("Done").font(Typeface.tiny) }.buttonStyle(.orb(size: 52))
                }
            }
            .padding(.horizontal, Space.xl)

            CoupleStage(me: .bear, partner: .cat, partnerName: "blake", bubble: (.headphones, "listening to music"), react: sent)
                .padding(.top, Space.l)

            VStack(alignment: .leading, spacing: Space.m) {
                Text("Send some love").font(Typeface.headline)
                HStack {
                    LoveButton(icon: .kiss, label: "Kiss", tint: .pink) { sent += 1 }
                    Spacer()
                    LoveButton(icon: .hug, label: "Hug", tint: .peach) { sent += 1 }
                    Spacer()
                    LoveButton(icon: .poke, label: "Poke", tint: .butter) { sent += 1 }
                    Spacer()
                    LoveButton(icon: .heart, label: "Heart", tint: .lavender) { sent += 1 }
                }
            }
            .padding(.horizontal, Space.xl)
            .padding(.top, Space.xxl)

            VStack(alignment: .leading, spacing: Space.xs) {
                Text("What are you up to?").font(Typeface.headline).padding(.horizontal, Space.xl)
                if scrolls {
                    ScrollView(.horizontal, showsIndicators: false) { chipRow }.scrollClipDisabled()
                } else {
                    Color.clear.frame(height: 68).overlay(alignment: .leading) { chipRow.fixedSize() }.clipped()
                }
            }
            .padding(.top, Space.xxl)

            Spacer(minLength: 0)
            SoftTabBar(selection: $tab, items: [("Home", .home), ("Style", .palette), ("Activities", .star), ("Settings", .gear)]) {
                CritterPeek(.bear)
            }
            .padding(.horizontal, Space.xl)
        }
        .padding(.top, Space.l)
        .backdrop(.pink)
    }

    private var chipRow: some View {
        HStack(spacing: Space.s) {
            ForEach(chips.indices, id: \.self) { i in
                ActivityChip(icon: chips[i].0, label: chips[i].1, tint: chips[i].2, selected: doing == i) { doing = i }
            }
        }
        .padding(.vertical, Space.m)
        .padding(.horizontal, Space.xl)
    }
}
