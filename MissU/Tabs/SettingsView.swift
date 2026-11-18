import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmDisconnect = false
    @State private var confirmDelete = false

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            Form {
                if let state = model.state {
                    Section("Account") {
                        LabeledContent("Username", value: "@\(state.me.username)")
                        if !model.email.isEmpty {
                            LabeledContent("Email", value: model.email)
                        }
                        ShareLink(item: "Add me on Miss U! My username is @\(state.me.username)") {
                            Text("Share my username")
                        }
                    }

                    Section("Partner") {
                        if let partner = state.partner {
                            LabeledContent("Connected with", value: "@\(partner.username)")
                            if let since = state.settings.partnerSince {
                                LabeledContent("Since", value: since.formatted(date: .abbreviated, time: .omitted))
                            }
                        } else {
                            Text("Not connected yet").foregroundStyle(.secondary)
                        }
                    }

                    Section {
                        Toggle("Let my partner restyle it", isOn: Binding(
                            get: { state.myWidget.allowPartner },
                            set: { on in Task { await model.allowPartnerChanges(on) } }
                        ))
                        if state.myWidget.byPartner, let partner = state.partner {
                            LabeledContent("Last styled by", value: "@\(partner.username)")
                            Button("Restore my style") { Task { await model.restoreMyWidget() } }
                        }
                        Button("Reset widget to default") { Task { await model.resetMyWidget() } }
                    } header: {
                        Text("My widget")
                    } footer: {
                        Text("Your partner can only change the widget's look, never your account or settings.")
                    }

                    Section("Notifications") {
                        Toggle("Connection requests", isOn: Binding(
                            get: { state.settings.notifyRequests },
                            set: { on in Task { await model.setNotifications(requests: on, widget: state.settings.notifyWidget) } }
                        ))
                        Toggle("Widget changes", isOn: Binding(
                            get: { state.settings.notifyWidget },
                            set: { on in Task { await model.setNotifications(requests: state.settings.notifyRequests, widget: on) } }
                        ))
                    }

                    Section {
                        Toggle("Headphone detection", isOn: $model.headphoneDetection)
                    } header: {
                        Text("Privacy")
                    } footer: {
                        Text("Miss U only checks whether headphones are connected. It never listens, records, or sees what you play, and it doesn't track your location.")
                    }

                    if state.partner != nil {
                        Section {
                            Button("Disconnect from partner", role: .destructive) { confirmDisconnect = true }
                        } footer: {
                            Text("You'll stop seeing each other's characters, and any widget changes they made go back to your own style.")
                        }
                    }

                    Section {
                        Button("Sign out") { Task { await model.signOut() } }
                        Button("Delete account", role: .destructive) { confirmDelete = true }
                    }
                }
            }
            .tint(Theme.rose)
            .font(.rounded(16, .medium))
            .scrollContentBackground(.hidden)
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Settings")
            .confirmationDialog("Disconnect from your partner?", isPresented: $confirmDisconnect, titleVisibility: .visible) {
                Button("Disconnect", role: .destructive) { Task { await model.disconnect() } }
            }
            .confirmationDialog("Delete your account?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete account", role: .destructive) { Task { await model.deleteAccount() } }
            } message: {
                Text("This removes your username, character, activities and widget settings for good.")
            }
        }
    }
}
