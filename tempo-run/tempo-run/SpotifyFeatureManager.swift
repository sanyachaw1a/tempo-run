import Foundation

class SpotifyFeatureManager {
    static let shared = SpotifyFeatureManager()
    
    private init() {}

    private var featuresDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("SpotifyFeatures")
    }

    func saveFeatures(_ features: [String: [String: Any]]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: features, options: .prettyPrinted)
            try FileManager.default.createDirectory(at: featuresDirectory, withIntermediateDirectories: true)
            let fileURL = featuresDirectory.appendingPathComponent("features.json")
            try data.write(to: fileURL)
            print("✅ Saved features to disk at \(fileURL)")
        } catch {
            print("❌ Failed to save features: \(error)")
        }
    }

    func loadFeatures() -> [String: [String: Any]]? {
        let fileURL = featuresDirectory.appendingPathComponent("features.json")
        do {
            let data = try Data(contentsOf: fileURL)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]]
            print("✅ Loaded features from disk")
            return json
        } catch {
            print("❌ Failed to load features: \(error)")
            return nil
        }
    }

    func deleteFeatures() {
        let fileURL = featuresDirectory.appendingPathComponent("features.json")
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("🗑️ Deleted saved features")
        } catch {
            print("❌ Failed to delete features: \(error)")
        }
    }
}
