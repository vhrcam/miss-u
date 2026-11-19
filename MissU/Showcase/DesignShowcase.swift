import SwiftUI

struct DesignShowcase: View {
    var close: (() -> Void)?

    var body: some View {
        ScrollView {
            ShowcaseBody(close: close)
                .padding(.horizontal, Space.xl)
                .padding(.vertical, Space.xl)
        }
        .backdrop(.pink)
    }
}

struct ShowcaseBody: View {
    var close: (() -> Void)?
    @State private var concept = false

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xxl) {
            header
            ShowcaseSection(title: "Home concept", note: "The two of you are the main thing on screen. Everything else supports them.") {
                Button("Open the home concept") { concept = true }.buttonStyle(.candy(.peach))
            }
            ShowcaseSection(title: "Characters", note: "Four animals, one family: standing, sitting, sleeping and holding a heart.") { CritterGallery() }
            ShowcaseSection(title: "Colors", note: "Every hue comes as soft, fill and deep. Screens pick one as their personality.") { PaletteBoard() }
            ShowcaseSection(title: "Type", note: "Fredoka, round and chunky like the characters.") { TypeBoard() }
            ShowcaseSection(title: "Buttons", note: "Candy for the main action, soft for the second, a squiggle for small links.") { ButtonBoard() }
            ShowcaseSection(title: "Send love", note: "Each one pops and throws little hearts.") { LoveBoard() }
            ShowcaseSection(title: "Cards", note: "Warm white stickers with a colored edge, or soft tinted panels.") { CardBoard() }
            ShowcaseSection(title: "Icons", note: "Drawn with the same brown ink as the characters.") { IconBoard() }
            ShowcaseSection(title: "Characters in the UI", note: "Empty and loading screens, activity picks and the tab bar all use the characters.") { InAppBoard() }
            ShowcaseSection(title: "Widgets", note: "Your partner's character, what they're up to, and their colors.") { WidgetBoard() }
        }
        .sheet(isPresented: $concept) { HomeConcept { concept = false } }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Space.xs) {
                HStack(alignment: .firstTextBaseline, spacing: Space.s) {
                    Text("miss u").font(Typeface.display)
                    IconView(icon: .heart, size: 26)
                }
                Text("Design preview").font(Typeface.body).foregroundStyle(Palette.cocoa)
            }
            Spacer()
            if let close {
                Button(action: close) { Text("Done").font(Typeface.caption) }.buttonStyle(.round(size: 52))
            }
        }
    }
}

struct ShowcaseSection<Content: View>: View {
    var title: String
    var note: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Space.m) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Typeface.title)
                Text(note).font(Typeface.caption).foregroundStyle(Palette.cocoa).fixedSize(horizontal: false, vertical: true)
            }
            content
        }
    }
}

private struct PaletteBoard: View {
    private let names = ["pink", "peach", "butter", "mint", "sky", "lavender", "oat"]

    var body: some View {
        VStack(spacing: Space.m) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: Space.m)], spacing: Space.m) {
                ForEach(Tint.all.indices, id: \.self) { i in
                    let tint = Tint.all[i]
                    VStack(spacing: 0) {
                        tint.soft.frame(height: 22)
                        tint.fill.frame(height: 26)
                        tint.deep.frame(height: 18)
                    }
                    .clipShape(Blob(corner: 16, seed: i))
                    .overlay { Blob(corner: 16, seed: i).stroke(Palette.ink, lineWidth: Line.card) }
                    .overlay(alignment: .bottomLeading) {
                        Text(names[i]).font(Typeface.tiny).foregroundStyle(Palette.ink).padding(.leading, 10).padding(.bottom, 2)
                    }
                }
            }
            HStack(spacing: Space.m) {
                ForEach([("ink", Palette.ink), ("cocoa", Palette.cocoa), ("cream", Palette.cream), ("white", Palette.warmWhite), ("cheek", Palette.cheek)], id: \.0) { name, color in
                    VStack(spacing: Space.xs) {
                        Circle().fill(color).frame(width: 38).overlay { Circle().stroke(Palette.ink, lineWidth: Line.card) }
                        Text(name).font(Typeface.tiny)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

private struct TypeBoard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Space.s) {
            Text("Hi, blake").font(Typeface.display)
            Text("Send some love").font(Typeface.title)
            Text("They're listening to music").font(Typeface.headline)
            Text("Your partner can restyle your widget whenever they miss you.").font(Typeface.body)
            Text("Changed 3 min ago").font(Typeface.caption).foregroundStyle(Palette.cocoa)
            Text("RIGHT NOW").font(Typeface.tiny).tracking(1.2).foregroundStyle(Palette.cocoa)
        }
        .stickerCard()
    }
}

private struct ButtonBoard: View {
    var body: some View {
        VStack(spacing: Space.l) {
            Button("Restyle their widget") {}.buttonStyle(.candy(.pink))
            Button("Send blake a kiss") {}
                .buttonStyle(CandyButtonStyle(tint: .peach, peek: CritterHead(.cat).frame(width: 44, height: 44)))
                .padding(.top, Space.l)
            HStack(spacing: Space.m) {
                Button("Not now") {}.buttonStyle(.softPill())
                Button("Next") {}.buttonStyle(.candy(.butter))
            }
            HStack(spacing: Space.l) {
                Button {} label: { IconView(icon: .gear, size: 24) }.buttonStyle(.round())
                Button {} label: { IconView(icon: .palette, size: 24) }.buttonStyle(.round(.mint))
                Button {} label: { IconView(icon: .music, size: 24) }.buttonStyle(.round(.lavender))
                Spacer()
                Button("See all") {}.buttonStyle(.squiggle(.pink))
            }
            Button("Waiting for blake") {}.buttonStyle(.candy(.sky)).disabled(true)
        }
    }
}

private struct LoveBoard: View {
    var body: some View {
        HStack {
            LoveButton(icon: .kiss, label: "Kiss", tint: .pink)
            Spacer()
            LoveButton(icon: .hug, label: "Hug", tint: .peach)
            Spacer()
            LoveButton(icon: .poke, label: "Poke", tint: .butter)
            Spacer()
            LoveButton(icon: .heart, label: "Heart", tint: .lavender)
        }
        .padding(.vertical, Space.s)
    }
}

private struct CardBoard: View {
    var body: some View {
        VStack(spacing: Space.l) {
            HStack(spacing: Space.m) {
                IconView(icon: .headphones, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("blake is listening").font(Typeface.headline)
                    Text("Changed 3 min ago").font(Typeface.caption).foregroundStyle(Palette.cocoa)
                }
            }
            .stickerCard(lip: Tint.pink.deep)
            HStack(spacing: Space.m) {
                IconView(icon: .bag, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Shopping").font(Typeface.headline)
                    Text("Shows on blake's widget for 2 hours").font(Typeface.caption).foregroundStyle(Palette.cocoa)
                }
            }
            .softCard(.peach)
        }
    }
}

private struct IconBoard: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Space.l) {
            ForEach(Icon.allCases, id: \.self) { icon in
                IconView(icon: icon, size: 36)
            }
        }
        .stickerCard()
    }
}

private struct InAppBoard: View {
    @State private var tab = 2
    @State private var doing = 0

    var body: some View {
        VStack(spacing: Space.l) {
            EmptyState(species: .rabbit, pose: .sleeping, title: "No activity yet", message: "When blake shares what they're up to, it shows up here.")
                .stickerCard()
            HStack {
                CritterLoader(species: .dog)
                Spacer()
                ThoughtBubble(icon: .cup, text: "coffee break", tint: .peach, tailLeading: false)
            }
            .stickerCard()
            HStack(spacing: Space.s) {
                ActivityChip(icon: .music, label: "Music", tint: .lavender, selected: doing == 0) { doing = 0 }
                ActivityChip(icon: .tv, label: "TV", tint: .butter, selected: doing == 1) { doing = 1 }
                ActivityChip(icon: .sneaker, label: "Gym", tint: .mint, selected: doing == 2) { doing = 2 }
            }
            StickerTabBar(selection: $tab, items: [("Home", .home), ("Style", .palette), ("Activities", .star), ("Settings", .gear)], tint: .butter)
                .padding(.top, Space.xl)
        }
    }
}

private struct WidgetBoard: View {
    var body: some View {
        HStack(spacing: Space.l) {
            tile(.cat, pose: .idle, name: "blake", icon: .headphones, tint: .sky)
            tile(.rabbit, pose: .sleeping, name: "sam", icon: .moon, tint: .lavender)
        }
    }

    private func tile(_ species: Species, pose: CritterPose, name: String, icon: Icon, tint: Tint) -> some View {
        VStack(spacing: 0) {
            CritterView(species, pose: pose).frame(width: 132).padding(.top, -8)
            HStack(spacing: Space.xs) {
                IconView(icon: icon, size: 18)
                Text(name).font(Typeface.caption)
            }
            .padding(.horizontal, Space.s)
            .padding(.vertical, Space.xs)
            .sticker(Palette.warmWhite, depth: 0, corner: 14, line: Line.card, seed: name.count)
            .offset(y: -14)
        }
        .frame(width: 158, height: 158)
        .background(Backdrop(tint: tint))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(Palette.ink.opacity(0.12), lineWidth: 1) }
    }
}
