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
        #if DEBUG
        .fullScreenCover(isPresented: .constant(CommandLine.arguments.contains("-showcase") || CommandLine.arguments.contains("-home-concept"))) {
            if CommandLine.arguments.contains("-home-concept") { HomeConcept() } else { DesignShowcase() }
        }
        #endif
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
    @Environment(AppModel.self) private var model
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            Tab("Home", systemImage: "house.fill", value: 0) { page(HomeView()) }
            Tab("Customize", systemImage: "paintbrush.fill", value: 1) { page(CustomizeView()) }
            Tab("Activities", systemImage: "sparkles", value: 2) { page(ActivitiesView()) }
            Tab("Settings", systemImage: "gearshape.fill", value: 3) { page(SettingsView()) }
        }
        .tint(Theme.rose)
        .overlay(alignment: .bottom) {
            FloatingTabBar(selection: $tab).padding(.bottom, 2)
        }
        .ignoresSafeArea(.keyboard)
        .overlay {
            if let reaction = model.reaction, let partner = model.state?.partner {
                ReactionOverlay(partner: partner, interaction: reaction)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: model.reaction)
        #if DEBUG
        .onAppear {
            let args = CommandLine.arguments
            if let i = args.firstIndex(of: "-tab"), i + 1 < args.count, let n = Int(args[i + 1]) { tab = n }
        }
        #endif
    }

    private func page(_ content: some View) -> some View {
        content
            .toolbar(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 64) }
    }
}
