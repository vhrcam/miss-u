import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @State private var picking = false
    @State private var styling = false
    @State private var bursts: [InteractionKind: Int] = [:]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    if let state = model.state {
                        if let partner = state.partner {
                            duo(me: state.me, partner: partner)
                            love(for: partner)
                            if state.myWidget.byPartner {
                                restyled(by: partner)
                            }
                            homeScreens(state, partner: partner)
                        } else {
                            solo(me: state.me)
                            Text("Find your person").font(.rounded(22, .heavy)).padding(.top, 4)
                            ConnectPanel()
                        }
                    }
                }
                .padding(20)
            }
            .refreshable { await model.refresh() }
            .screen()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $picking) {
                ActivitySheet()
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(32)
            }
            .sheet(isPresented: $styling) {
                NavigationStack {
                    ScrollView {
                        PartnerWidgetPanel { styling = false }
                            .padding(24)
                    }
                    .screen()
                    .navigationTitle("Their widget")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { styling = false }.tint(Theme.rose)
                        }
                    }
                }
                .presentationCornerRadius(32)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Wordmark()
            if let partner = model.state?.partner {
                Text("you & @\(partner.username)").font(.rounded(16, .semibold)).opacity(0.55)
            }
        }
    }

    private func duo(me: Person, partner: Person) -> some View {
        HStack(alignment: .top, spacing: 6) {
            column(partner, label: partner.username, empty: "No activity yet")
            column(me, label: "you", empty: "Tap to share")
                .contentShape(Rectangle())
                .onTapGesture { picking = true }
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("Choose what you're up to")
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 12)
        .background(
            LinearGradient(colors: [Theme.blush, .white], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 32, style: .continuous)
        )
        .overlay(alignment: .top) {
            HeartShape()
                .fill(Theme.rose)
                .frame(width: 22, height: 20)
                .padding(.top, 14)
        }
        .shadow(color: Theme.ink.opacity(0.06), radius: 16, y: 6)
    }

    private func column(_ person: Person, label: String, empty: String) -> some View {
        VStack(spacing: 10) {
            AvatarView(config: person.avatar, activity: person.activity(), animated: true)
                .frame(height: 150)
            Text(label)
                .font(.rounded(18, .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            ActivityPill(activity: person.activity, empty: empty)
        }
        .frame(maxWidth: .infinity)
    }

    private func solo(me: Person) -> some View {
        VStack(spacing: 10) {
            AvatarView(config: me.avatar, activity: me.activity(), animated: true)
                .frame(height: 170)
            ActivityPill(activity: me.activity, empty: "Tap to share what you're up to")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            LinearGradient(colors: [Theme.blush, .white], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 32, style: .continuous)
        )
        .contentShape(Rectangle())
        .onTapGesture { picking = true }
    }

    private func love(for partner: Person) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Send some love").font(.rounded(22, .heavy))
            HStack(spacing: 0) {
                ForEach(InteractionKind.allCases) { kind in
                    VStack(spacing: 6) {
                        Button {
                            bursts[kind, default: 0] += 1
                            Task { await model.sendInteraction(kind) }
                        } label: {
                            Text(kind.emoji).font(.system(size: 26))
                        }
                        .buttonStyle(.bubble(.white, size: 62))
                        .heartBurst(bursts[kind, default: 0])
                        .accessibilityLabel("Send @\(partner.username) a \(kind.title.lowercased())")
                        Text(kind.title).font(.rounded(13, .bold)).opacity(0.6)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func restyled(by partner: Person) -> some View {
        HStack(spacing: 12) {
            HeartShape().fill(Theme.rose).frame(width: 20, height: 18)
            Text("@\(partner.username) restyled your widget").font(.rounded(15, .bold))
            Spacer()
            Button("Undo") { Task { await model.restoreMyWidget() } }
                .font(.rounded(14, .bold))
                .foregroundStyle(Theme.rose)
        }
        .card()
    }

    private func homeScreens(_ state: AppState, partner: Person) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Home screens").font(.rounded(22, .heavy))
            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 10) {
                    WidgetPreview(snapshot: state.partnerSnapshot())
                    Text("@\(partner.username) sees").font(.rounded(13, .semibold)).opacity(0.55)
                }
                VStack(spacing: 10) {
                    WidgetPreview(snapshot: state.snapshot)
                    Text("You see").font(.rounded(13, .semibold)).opacity(0.55)
                }
            }
            .frame(maxWidth: .infinity)
            Button("Restyle their widget") { styling = true }
                .buttonStyle(.primary)
        }
    }
}

struct ActivitySheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("What are you up to?").font(.rounded(24, .heavy))
                ActivityGrid { dismiss() }
            }
            .padding(24)
        }
        .screen()
    }
}
