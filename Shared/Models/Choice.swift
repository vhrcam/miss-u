import Foundation

protocol Choice: CaseIterable, Identifiable, Hashable, Codable, RawRepresentable where RawValue == String {
    var title: String { get }
}

extension Choice {
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

extension KeyedDecodingContainer {
    func choice<T: Choice>(_ key: Key, _ fallback: T) -> T {
        (try? decode(String.self, forKey: key)).flatMap(T.init(rawValue:)) ?? fallback
    }
}
