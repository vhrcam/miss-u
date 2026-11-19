import SwiftUI

struct HomeConcept: View {
    var close: (() -> Void)?
    @State private var tab = 0
    @State private var doing = 0

    private let chips: [(Icon, String, Tint)] = [
        (.music, "Music", .lavender), (.cup, "Coffee", .peach), (.book, "Studying", .sky),
        (.controller, "Gaming", .mint), (.bag, "Shopping", .butter), (.moon, "Sleeping", .lavender),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hi, alex").font(Typeface.title)
                    Text("You and blake").font(Typeface.caption).foregroundStyle(Palette.cocoa)
                }
                Spacer()
                if let close {
                    Button(action: close) { Text("Done").font(Typeface.caption) }.buttonStyle(.round(size: 52))
                }
            }
            CoupleStage(me: .bear, partner: .cat, partnerName: "blake", bubble: (.headphones, "listening to music"))
            VStack(alignment: .leading, spacing: Space.m) {
                Text("Send some love").font(Typeface.headline)
                HStack {
                    LoveButton(icon: .kiss, label: "Kiss", tint: .pink)
                    Spacer()
                    LoveButton(icon: .hug, label: "Hug", tint: .peach)
                    Spacer()
                    LoveButton(icon: .poke, label: "Poke", tint: .butter)
                    Spacer()
                    LoveButton(icon: .heart, label: "Heart", tint: .lavender)
                }
            }
            VStack(alignment: .leading, spacing: Space.m) {
                Text("What are you up to?").font(Typeface.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Space.s) {
                        ForEach(chips.indices, id: \.self) { i in
                            ActivityChip(icon: chips[i].0, label: chips[i].1, tint: chips[i].2, selected: doing == i) { doing = i }
                        }
                    }
                    .padding(.vertical, Space.s)
                    .padding(.horizontal, Space.xl)
                }
                .padding(.horizontal, -Space.xl)
            }
            Spacer(minLength: 0)
            StickerTabBar(selection: $tab, items: [("Home", .home), ("Style", .palette), ("Activities", .star), ("Settings", .gear)]) {
                CritterHead(.bear)
            }
        }
        .padding(.horizontal, Space.xl)
        .padding(.top, Space.l)
        .backdrop(.pink)
    }
}
