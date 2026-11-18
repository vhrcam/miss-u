import SwiftUI

struct AvatarEditor: View {
    @Binding var config: AvatarConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            OptionRow(title: "Color") {
                ForEach(AvatarColor.allCases) { color in
                    Button { config.color = color } label: {
                        Swatch(color: color.fill, selected: config.color == color)
                    }
                    .accessibilityLabel(color.title)
                }
            }
            OptionRow(title: "Look") {
                ForEach(Presentation.allCases) { look in
                    Button { config.presentation = look } label: {
                        Chip(text: look.title, selected: config.presentation == look)
                    }
                }
            }
            OptionRow(title: "Hair") { tiles(\.hair) }
            OptionRow(title: "Outfit") { tiles(\.outfit) }
            OptionRow(title: "Shirt") {
                ForEach(ShirtColor.allCases) { shirt in
                    Button { config.shirt = shirt } label: {
                        Swatch(color: shirt.fill, selected: config.shirt == shirt)
                    }
                    .accessibilityLabel(shirt.title)
                }
            }
            OptionRow(title: "Accessory") { tiles(\.accessory) }
        }
        .sensoryFeedback(.selection, trigger: config)
    }

    private func tiles<T: Choice>(_ key: WritableKeyPath<AvatarConfig, T>) -> some View {
        ForEach(Array(T.allCases)) { option in
            Button { config[keyPath: key] = option } label: {
                Tile(selected: config[keyPath: key] == option) {
                    AvatarView(config: preview(key, option)).padding(7)
                }
            }
            .accessibilityLabel(option.title)
        }
    }

    private func preview<T>(_ key: WritableKeyPath<AvatarConfig, T>, _ value: T) -> AvatarConfig {
        var copy = config
        copy[keyPath: key] = value
        return copy
    }
}

struct WidgetEditor: View {
    @Binding var style: WidgetStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            OptionRow(title: "Background") {
                ForEach(WidgetBackground.allCases) { background in
                    Button { style.background = background } label: {
                        Swatch(color: background.color, selected: style.background == background)
                    }
                    .accessibilityLabel(background.title)
                }
            }
            OptionRow(title: "Pattern") {
                ForEach(WidgetPattern.allCases) { pattern in
                    Button { style.pattern = pattern } label: {
                        Tile(selected: style.pattern == pattern) {
                            WidgetBackdrop(style: WidgetStyle(background: style.background, pattern: pattern))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .padding(7)
                        }
                    }
                    .accessibilityLabel(pattern.title)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Character").font(.rounded(15, .bold)).opacity(0.65)
                PillPicker(selection: $style.spot, options: CharacterSpot.allCases) { $0.title }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Message").font(.rounded(15, .bold)).opacity(0.65)
                    Spacer()
                    Text("\(style.caption.count)/\(WidgetStyle.captionLimit)").font(.rounded(12, .semibold)).opacity(0.4)
                }
                TextField("Say something sweet", text: $style.caption)
                    .font(.rounded(17, .semibold))
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .onChange(of: style.caption) { _, new in
                        if new.count > WidgetStyle.captionLimit { style.caption = String(new.prefix(WidgetStyle.captionLimit)) }
                    }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: style.background)
        .sensoryFeedback(.selection, trigger: style.pattern)
    }
}

struct WidgetPreviews: View {
    let snapshot: WidgetSnapshot?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                WidgetPreview(snapshot: snapshot)
                WidgetPreview(snapshot: snapshot, size: .medium)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
        }
        .padding(.horizontal, -24)
    }
}
