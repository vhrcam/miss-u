import SwiftUI
import Supabase
import WidgetKit

let supabase = SupabaseClient(
    supabaseURL: Server.url,
    supabaseKey: Server.key,
    options: .init(auth: .init(emitLocalSessionAsInitialSession: true))
)

@MainActor
@Observable
final class AppModel {
    enum Phase {
        case loading, offline, signedOut, needsUsername, ready
    }

    var phase: Phase = .loading
    var state: AppState?
    var email = ""
    var pendingUsername: String?
    var toast: String?
    var headphonesConnected = false

    var setupDone = UserDefaults.standard.bool(forKey: "setupDone") {
        didSet { UserDefaults.standard.set(setupDone, forKey: "setupDone") }
    }

    var headphoneDetection = UserDefaults.standard.object(forKey: "headphoneDetection") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(headphoneDetection, forKey: "headphoneDetection")
            Task { await checkHeadphones() }
        }
    }

    @ObservationIgnored private var channel: RealtimeChannelV2?
    @ObservationIgnored private var listeners: [Task<Void, Never>] = []
    @ObservationIgnored private var pendingRefresh: Task<Void, Never>?
    @ObservationIgnored private var justSignedIn = false
    @ObservationIgnored private let headphones = HeadphoneMonitor()

    func start() async {
        headphones.onChange = { [weak self] in
            Task { await self?.checkHeadphones() }
        }
        headphones.start()
        #if DEBUG
        await debugLogin()
        #endif
        for await change in supabase.auth.authStateChanges {
            switch change.event {
            case .initialSession, .signedIn:
                if change.session == nil { await signedOut() } else { await refresh() }
            case .signedOut:
                await signedOut()
            default:
                break
            }
        }
    }

    func becameActive() async {
        guard phase == .ready else { return }
        await refresh()
        await checkHeadphones()
    }

    func retry() async {
        phase = .loading
        await refresh()
    }

    func refresh() async {
        do {
            let data = try await supabase.rpc("get_state").execute().data
            apply(try MissUJSON.decoder.decode(AppState?.self, from: data))
        } catch {
            if phase == .loading { phase = .offline }
            show(error)
        }
    }

    private func apply(_ new: AppState?) {
        email = supabase.auth.currentUser?.email ?? email
        guard let new else {
            state = nil
            if let name = pendingUsername {
                phase = .loading
                Task { await createProfile(name) }
            } else {
                phase = .needsUsername
            }
            return
        }
        if justSignedIn {
            setupDone = true
            justSignedIn = false
        }
        let firstLoad = phase != .ready
        state = new
        phase = .ready
        syncWidget()
        if firstLoad {
            Task {
                await connectRealtime()
                await ensureWidgetToken()
                await checkHeadphones()
            }
        }
    }

    // MARK: Account

    func usernameAvailable(_ name: String) async -> Bool? {
        guard let data = try? await supabase.rpc("username_available", params: ["p_username": AnyJSON.string(name)]).execute().data else { return nil }
        return try? JSONDecoder().decode(Bool.self, from: data)
    }

    func sendCode(to address: String) async -> Bool {
        do {
            try await supabase.auth.signInWithOTP(email: address)
            email = address
            return true
        } catch {
            show(error)
            return false
        }
    }

    func verify(_ code: String) async -> Bool {
        justSignedIn = true
        do {
            try await supabase.auth.verifyOTP(email: email, token: code, type: .email)
            return true
        } catch {
            justSignedIn = false
            toast = "That code didn't work. Check it and try again."
            return false
        }
    }

    func createProfile(_ name: String) async {
        pendingUsername = nil
        justSignedIn = false
        if await call("create_profile", ["p_username": .string(name)]) {
            setupDone = false
            await refresh()
        } else {
            phase = .needsUsername
        }
    }

    func saveAvatar(_ config: AvatarConfig) async {
        state?.me.avatar = config
        if await call("save_avatar", ["p_config": json(config)]) { await refresh() }
    }

    func setNotifications(requests: Bool, widget: Bool) async {
        state?.settings.notifyRequests = requests
        state?.settings.notifyWidget = widget
        if await call("set_notifications", ["p_requests": .bool(requests), "p_widget": .bool(widget)]) { await refresh() }
    }

    func signOut() async {
        if let token = SharedStore.widgetToken {
            _ = try? await supabase.rpc("revoke_widget_token", params: ["p_token": AnyJSON.string(token)]).execute()
        }
        try? await supabase.auth.signOut()
        setupDone = false
        await signedOut()
    }

    func deleteAccount() async {
        guard await call("delete_account") else { return }
        try? await supabase.auth.signOut(scope: .local)
        setupDone = false
        await signedOut()
    }

    private func signedOut() async {
        await disconnectRealtime()
        SharedStore.widgetToken = nil
        SharedStore.snapshot = nil
        WidgetCenter.shared.reloadAllTimelines()
        state = nil
        phase = .signedOut
    }

    // MARK: Partner

    func sendRequest(to username: String) async -> Bool {
        do {
            let data = try await supabase.rpc("send_request", params: ["p_username": AnyJSON.string(username)]).execute().data
            let result = try? JSONDecoder().decode(String.self, from: data)
            toast = result == "connected" ? "You're connected!" : "Request sent to @\(username)"
            await refresh()
            return true
        } catch {
            show(error)
            return false
        }
    }

    func respond(to request: AppState.ConnectionRequest, accept: Bool) async {
        if await call("respond_request", ["p_request": .string(request.id.uuidString), "p_accept": .bool(accept)]) {
            await refresh()
        }
    }

    func cancel(_ request: AppState.ConnectionRequest) async {
        if await call("cancel_request", ["p_request": .string(request.id.uuidString)]) { await refresh() }
    }

    func disconnect() async {
        if await call("disconnect_partner") { await refresh() }
    }

    // MARK: Activity

    func setActivity(_ kind: ActivityKind?) async {
        state?.me.activity = kind.map { ActivityState(kind: $0, source: .manual, startedAt: .now, expiresAt: nil) }
        if await call("set_activity", ["p_kind": kind.map { .string($0.rawValue) } ?? .null]) { await refresh() }
    }

    func checkHeadphones() async {
        headphonesConnected = HeadphoneMonitor.connected
        guard phase == .ready, let me = state?.me else { return }
        let connected = headphoneDetection && headphonesConnected
        let showing = me.activity?.source == .headphones && me.activity?.isLive() == true
        guard connected || showing else { return }
        if await call("headphones_changed", ["p_connected": .bool(connected)]) { await refresh() }
    }

    // MARK: Widgets

    func styleMyWidget(_ style: WidgetStyle) async -> Bool {
        guard await call("style_my_widget", ["p_style": json(style)]) else { return false }
        await refresh()
        return true
    }

    func stylePartnerWidget(_ style: WidgetStyle) async -> Bool {
        guard await call("style_partner_widget", ["p_style": json(style)]) else { return false }
        await refresh()
        return true
    }

    func restoreMyWidget() async {
        if await call("restore_my_widget") { await refresh() }
    }

    func resetMyWidget() async {
        if await call("reset_my_widget") { await refresh() }
    }

    func allowPartnerChanges(_ allowed: Bool) async {
        state?.myWidget.allowPartner = allowed
        if await call("allow_partner_changes", ["p_allowed": .bool(allowed)]) { await refresh() }
    }

    private func syncWidget() {
        guard let snapshot = state?.snapshot, snapshot != SharedStore.snapshot else { return }
        SharedStore.snapshot = snapshot
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func ensureWidgetToken() async {
        guard SharedStore.widgetToken == nil,
              let data = try? await supabase.rpc("issue_widget_token").execute().data,
              let token = try? JSONDecoder().decode(String.self, from: data) else { return }
        SharedStore.widgetToken = token
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: Live updates

    private func connectRealtime() async {
        guard channel == nil else { return }
        let channel = supabase.channel("state")
        let streams = ["profiles", "avatars", "activities", "widget_configs", "connection_requests"].map {
            channel.postgresChange(AnyAction.self, schema: "public", table: $0)
        }
        self.channel = channel
        listeners = streams.map { stream in
            Task { [weak self] in
                for await _ in stream { self?.scheduleRefresh() }
            }
        }
        try? await channel.subscribeWithError()
    }

    private func disconnectRealtime() async {
        listeners.forEach { $0.cancel() }
        listeners = []
        if let channel { await supabase.removeChannel(channel) }
        channel = nil
    }

    private func scheduleRefresh() {
        pendingRefresh?.cancel()
        pendingRefresh = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await refresh()
        }
    }

    // MARK: Calls

    @discardableResult
    private func call(_ fn: String, _ params: [String: AnyJSON] = [:]) async -> Bool {
        do {
            try await supabase.rpc(fn, params: params).execute()
            return true
        } catch {
            show(error)
            return false
        }
    }

    private func json<T: Encodable>(_ value: T) -> AnyJSON {
        (try? JSONDecoder().decode(AnyJSON.self, from: JSONEncoder().encode(value))) ?? .null
    }

    func show(_ error: Error) {
        if error is CancellationError { return }
        if let e = error as? PostgrestError {
            toast = Self.messages[e.message] ?? "Something went wrong. Try again."
        } else if let e = error as? URLError, e.code != .cancelled {
            toast = "Can't reach Miss U right now."
        } else if let e = error as? AuthError {
            toast = e.message
        } else if (error as? URLError)?.code != .cancelled {
            toast = "Something went wrong. Try again."
        }
    }

    private static let messages = [
        "username_taken": "That username is taken. Try another one.",
        "invalid_username": "Use 3–20 lowercase letters, numbers, dots or underscores.",
        "user_not_found": "No one has that username.",
        "cannot_add_self": "That's your own username!",
        "already_connected": "You're already connected to someone.",
        "user_unavailable": "That person can't get requests right now.",
        "request_pending": "You already have a request waiting.",
        "request_not_found": "That request isn't there anymore.",
        "no_partner": "You're not connected to anyone yet.",
        "partner_changes_off": "Your partner turned off widget changes.",
        "unknown_activity": "That activity isn't available yet."
    ]

    #if DEBUG
    private func debugLogin() async {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "-debugLogin"), i + 1 < args.count else { return }
        let parts = args[i + 1].split(separator: ":").map(String.init)
        guard parts.count == 2 else { return }
        justSignedIn = true
        _ = try? await supabase.auth.signIn(email: parts[0], password: parts[1])
    }
    #endif
}
