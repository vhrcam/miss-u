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
        VStack(alignment: .leading, spacing: 44) {
            header
            ShowcaseSection(title: "Home", note: "The two of you are the heart of the screen. Everything else is there to support them.") {
                Button("Open the home concept") { concept = true }.buttonStyle(.primary(.peach))
            }
            ShowcaseSection(title: "Characters", note: "Simple, natural and soft. They breathe and blink on their own; tap one and it beams.") { CharacterBoard() }
            ShowcaseSection(title: "Presence", note: "Characters hold on to the edges of things instead of floating on top of them.") { PresenceBoard() }
            ShowcaseSection(title: "Colors", note: "Every hue comes soft, glowing, filled and deep. Color goes where it means something.") { PaletteBoard() }
            ShowcaseSection(title: "Type", note: "Fraunces for headings, soft and a little storybook. Nunito for everything you read.") { TypeBoard() }
            ShowcaseSection(title: "Buttons", note: "Lit from above with a shadow in their own color. They sink a little when pressed instead of bouncing.") { ButtonBoard() }
            ShowcaseSection(title: "Send love", note: "Each one swells gently and lets a few hearts drift up.") { LoveBoard() }
            ShowcaseSection(title: "Surfaces", note: "Warm paper with a soft shadow, or a quiet wash of color. No outlines.") { CardBoard() }
            ShowcaseSection(title: "Icons", note: "Drawn by hand with thin, warm lines.") { IconBoard() }
            ShowcaseSection(title: "In the app", note: "Empty and loading screens, activity picks and the tab bar all have a character in them.") { InAppBoard() }
            ShowcaseSection(title: "Widgets", note: "Your partner's character, what they're up to, and their colors.") { WidgetBoard() }
            ShowcaseSection(title: "Notifications", note: "iOS draws the banner, but the picture and the thumbnail can be your partner's character and our artwork.") { NotificationBoard() }
        }
        .sheet(isPresented: $concept) { HomeConcept { concept = false } }

    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: Space.s) {
                    Text("miss u").font(Typeface.display)
                    IconView(icon: .heart, size: 24)
                }
                Text("Design preview").font(Typeface.body).foregroundStyle(Palette.cocoa)
            }
            Spacer()
            if let close {
                Button(action: close) { Text("Done").font(Typeface.tiny) }.buttonStyle(.orb(size: 52))
            }
        }
    }
}

struct ShowcaseSection<Content: View>: View {
    var title: String
    var note: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Space.l) {
            VStack(alignment: .leading, spacing: Space.xs) {
                Text(title).font(Typeface.title)
                Text(note).font(Typeface.caption).foregroundStyle(Palette.cocoa).fixedSize(horizontal: false, vertical: true)
            }
            content
        }
    }
}

private struct CharacterBoard: View {
    var body: some View {
        VStack(spacing: Space.l) {
            CoupleScene(.cat, .bear, animated: true).frame(maxWidth: 320).frame(maxWidth: .infinity)
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(Species.allCases, id: \.self) { species in
                    StandingCreature(species, pose: CreaturePose(turn: species == .bear || species == .rabbit ? -0.15 : 0.2)).frame(maxWidth: .infinity)
                }
            }
        }
        .surface()
    }
}

private struct PresenceBoard: View {
    var body: some View {
        VStack(spacing: Space.l) {
            HStack(spacing: Space.m) {
                IconView(icon: .headphones, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text("blake is listening").font(Typeface.headline)
                    Text("Changed 3 min ago").font(Typeface.caption).foregroundStyle(Palette.cocoa)
                }
            }
            .surface(.pink)
            .overlay(alignment: .topTrailing) {
                CreaturePeek(.cat)
                    .frame(width: 76)
                    .padding(.trailing, Space.xl)
                    .alignmentGuide(.top) { $0[.bottom] }
            }
            .padding(.top, 44)
            Button("Send blake a kiss") {}
                .buttonStyle(PrimaryButtonStyle(tint: .pink, peek: CreaturePeek(.cat)))
                .padding(.top, 40)
        }
    }
}

private struct PaletteBoard: View {
    private let names = ["pink", "peach", "butter", "mint", "sky", "lavender", "oat"]

    var body: some View {
        VStack(spacing: Space.l) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: Space.m)], spacing: Space.m) {
                ForEach(Tint.all.indices, id: \.self) { i in
                    let tint = Tint.all[i]
                    VStack(spacing: 0) {
                        LinearGradient(colors: [tint.glow, tint.fill], startPoint: .top, endPoint: .bottom).frame(height: 46)
                        HStack(spacing: 0) {
                            tint.soft
                            tint.deep
                        }
                        .frame(height: 14)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: tint.deep.opacity(0.22), radius: 8, y: 4)
                    .overlay(alignment: .topLeading) { Text(names[i]).font(Typeface.tiny).padding(Space.s) }
                }
            }
            HStack(spacing: Space.m) {
                ForEach([("ink", Palette.ink), ("cocoa", Palette.cocoa), ("paper", Palette.paper), ("white", Palette.warmWhite), ("cheek", Palette.cheek)], id: \.0) { name, color in
                    VStack(spacing: Space.xs) {
                        Circle().fill(color).frame(width: 36)
                            .overlay { Circle().strokeBorder(Palette.hairline, lineWidth: 0.5) }
                            .shadow(color: Palette.shadow.opacity(0.1), radius: 4, y: 2)
                        Text(name).font(Typeface.tiny).foregroundStyle(Palette.cocoa)
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
            Text("Good evening, blake").font(Typeface.display)
            Text("Send some love").font(Typeface.title)
            Text("They're listening to music").font(Typeface.headline)
            Text("Your partner can restyle your widget whenever they miss you.").font(Typeface.body)
            Text("Changed 3 min ago").font(Typeface.caption).foregroundStyle(Palette.cocoa)
            Text("RIGHT NOW").font(Typeface.tiny).tracking(1.2).foregroundStyle(Palette.cocoa)
        }
        .surface()
    }
}

private struct ButtonBoard: View {
    var body: some View {
        VStack(spacing: Space.l) {
            Button("Restyle their widget") {}.buttonStyle(.primary(.pink))
            HStack(spacing: Space.m) {
                Button("Not now") {}.buttonStyle(.secondary())
                Button("Next") {}.buttonStyle(.primary(.butter))
            }
            HStack(spacing: Space.l) {
                Button {} label: { IconView(icon: .gear, size: 22) }.buttonStyle(.orb())
                Button {} label: { IconView(icon: .palette, size: 22) }.buttonStyle(.orb(.mint))
                Button {} label: { IconView(icon: .music, size: 22) }.buttonStyle(.orb(.lavender))
                Spacer()
                Button("See all") {}.buttonStyle(.quiet(.pink))
            }
            Button("Waiting for blake") {}.buttonStyle(.primary(.sky)).disabled(true)
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
                IconView(icon: .headphones, size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text("blake is listening").font(Typeface.headline)
                    Text("Changed 3 min ago").font(Typeface.caption).foregroundStyle(Palette.cocoa)
                }
            }
            .surface(.pink)
            HStack(spacing: Space.m) {
                IconView(icon: .bag, size: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Shopping").font(Typeface.headline)
                    Text("Shows on blake's widget for 2 hours").font(Typeface.caption).foregroundStyle(Palette.cocoa)
                }
            }
            .tinted(.peach)
        }
    }
}

private struct IconBoard: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Space.l) {
            ForEach(Icon.allCases, id: \.self) { icon in
                IconView(icon: icon, size: 34)
            }
        }
        .surface()
    }
}

private struct InAppBoard: View {
    @State private var tab = 2
    @State private var doing = 0

    var body: some View {
        VStack(spacing: Space.l) {
            EmptyState(species: .rabbit, title: "No activity yet", message: "When blake shares what they're up to, it shows up here.")
                .surface()
            HStack {
                CritterLoader(species: .dog)
                Spacer()
                ThoughtBubble(icon: .cup, text: "coffee break", tint: .peach, tailLeading: false)
            }
            .surface()
            HStack(spacing: Space.s) {
                ActivityChip(icon: .music, label: "Music", tint: .lavender, selected: doing == 0) { doing = 0 }
                ActivityChip(icon: .tv, label: "TV", tint: .butter, selected: doing == 1) { doing = 1 }
                ActivityChip(icon: .sneaker, label: "Gym", tint: .mint, selected: doing == 2) { doing = 2 }
            }
            SoftTabBar(selection: $tab, items: [("Home", .home), ("Style", .palette), ("Activities", .star), ("Settings", .gear)], tint: .butter) {
                CreaturePeek(.rabbit).padding(.horizontal, 4)
            }
            .padding(.top, 56)
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
            StandingCreature(species, pose: pose == .sleeping ? CreaturePose(turn: -0.2, eyes: .content) : CreaturePose(turn: 0.2), animated: false).frame(width: 82).padding(.top, 4)
            HStack(spacing: Space.xs) {
                IconView(icon: icon, size: 16)
                Text(name).font(Typeface.caption)
            }
            .padding(.horizontal, Space.s + 2)
            .padding(.vertical, 5)
            .background(Capsule().fill(Palette.warmWhite.opacity(0.92)).shadow(color: tint.deep.opacity(0.2), radius: 6, y: 3))
            .offset(y: -12)
        }
        .frame(width: 158, height: 158)
        .background {
            ZStack {
                LinearGradient(colors: [tint.soft.mix(with: .white, by: 0.25), tint.fill.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [.white.opacity(0.7), .white.opacity(0)], center: UnitPoint(x: 0.5, y: 0.55), startRadius: 0, endRadius: 80)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: tint.deep.opacity(0.2), radius: 14, y: 8)
    }
}

private struct NotificationBoard: View {
    var body: some View {
        VStack(spacing: Space.m) {
            banner(.cat, tint: .pink, name: "blake", text: "sent you a kiss", icon: .kiss)
            banner(.cat, tint: .pink, name: "blake", text: "restyled your widget", icon: .palette)
        }
    }

    private func banner(_ species: Species, tint: Tint, name: String, text: String, icon: Icon) -> some View {
        HStack(spacing: Space.m) {
            CreatureHead(species)
                .frame(width: 34, height: 34)
                .padding(5)
                .background(Circle().fill(LinearGradient(colors: [tint.glow, tint.soft], startPoint: .top, endPoint: .bottom)))
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text(name).font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("now").font(.system(size: 13)).foregroundStyle(.secondary)
                }
                Text(text).font(.system(size: 15))
            }
            IconView(icon: icon, size: 30)
        }
        .padding(Space.m)
        .foregroundStyle(.black)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Palette.shadow.opacity(0.1), radius: 12, y: 4)
    }
}
