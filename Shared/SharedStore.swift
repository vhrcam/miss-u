import Foundation

enum Server {
    #if targetEnvironment(simulator)
    static let url = URL(string: "http://127.0.0.1:54321")!
    static let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
    #else
    static let url = URL(string: "https://dhgbwetsdidunexucrmq.supabase.co")!
    static let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRoZ2J3ZXRzZGlkdW5leHVjcm1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTUwNDIyMDcsImV4cCI6MjExMDYxODIwN30.u8Y3a3CRhXHXGiCBhebGiSCZL_8Dx9olXjkwvr96OnE"
    #endif
}

enum MissUJSON {
    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .secondsSince1970
        return d
    }()

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        e.dateEncodingStrategy = .secondsSince1970
        return e
    }()
}

enum SharedStore {
    static let defaults = UserDefaults(suiteName: "group.tot.mgmt.MissU") ?? .standard

    static var widgetToken: String? {
        get { defaults.string(forKey: "widgetToken") }
        set { defaults.set(newValue, forKey: "widgetToken") }
    }

    static var snapshot: WidgetSnapshot? {
        get { defaults.data(forKey: "snapshot").flatMap { try? MissUJSON.decoder.decode(WidgetSnapshot.self, from: $0) } }
        set { defaults.set(newValue.flatMap { try? MissUJSON.encoder.encode($0) }, forKey: "snapshot") }
    }

    static func fetchSnapshot() async throws -> WidgetSnapshot? {
        guard let token = widgetToken else { return nil }
        var request = URLRequest(url: Server.url.appending(path: "rest/v1/rpc/widget_snapshot"))
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue(Server.key, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(Server.key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["p_token": token])
        let (data, _) = try await URLSession.shared.data(for: request)
        return try MissUJSON.decoder.decode(WidgetSnapshot?.self, from: data)
    }
}
