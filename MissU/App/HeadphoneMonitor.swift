import AVFoundation

@MainActor
final class HeadphoneMonitor {
    var onChange: (() -> Void)?
    private var observer: NSObjectProtocol?

    static var connected: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains {
            [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains($0.portType)
        }
    }

    func start() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        observer = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.onChange?() }
        }
    }
}
