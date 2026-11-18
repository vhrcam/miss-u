import SwiftUI

@main
struct MissUApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()
            switch model.phase {
            case .loading:
                ProgressView().tint(Theme.rose)
            case .offline:
                OfflineView()
            case .signedOut:
                WelcomeFlow()
            case .needsUsername:
                NavigationStack {
                    UsernameView { name in
                        Task { await model.createProfile(name) }
                    }
                }
            case .ready:
                if model.setupDone { MainTabs() } else { SetupFlow() }
            }
        }
        .foregroundStyle(Theme.ink)
        .overlay(alignment: .top) { ToastView() }
        .animation(.spring(duration: 0.35), value: model.toast)
        .animation(.easeInOut(duration: 0.3), value: model.phase)
        .animation(.easeInOut(duration: 0.3), value: model.setupDone)
        .task { await model.start() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await model.becameActive() } }
        }
    }
}

struct OfflineView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 18) {
            AvatarView(config: AvatarConfig(), activity: .sleeping, animated: true).frame(width: 160)
            Text("Can't reach Miss U").font(.rounded(22, .heavy))
            Text("Check your connection and try again.").font(.rounded(16, .medium)).opacity(0.6)
            Button("Try again") { Task { await model.retry() } }
                .buttonStyle(.primary)
                .frame(width: 200)
        }
        .padding(32)
    }
}

struct MainTabs: View {
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            Tab("Home", systemImage: "house.fill", value: 0) { HomeView() }
            Tab("Customize", systemImage: "paintbrush.fill", value: 1) { CustomizeView() }
            Tab("Activities", systemImage: "sparkles", value: 2) { ActivitiesView() }
            Tab("Settings", systemImage: "gearshape.fill", value: 3) { SettingsView() }
        }
        .tint(Theme.rose)
        #if DEBUG
        .onAppear {
            let args = CommandLine.arguments
            if let i = args.firstIndex(of: "-tab"), i + 1 < args.count, let n = Int(args[i + 1]) { tab = n }
        }
        #endif
    }
}
