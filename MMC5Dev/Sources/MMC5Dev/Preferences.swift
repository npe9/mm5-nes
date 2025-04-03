import Foundation
import ROMBuilder

struct Preferences: Codable, Equatable {
    var emulatorPath: String?
    var defaultROMSize: ROMBuilder.ROMSize
    var defaultMapperType: ROMBuilder.MapperType
    var defaultMirroringType: ROMBuilder.MirroringType
    var autosaveEnabled: Bool
    var autosaveInterval: TimeInterval
    var theme: Theme
    
    init() {
        self.emulatorPath = nil
        self.defaultROMSize = .size32KB
        self.defaultMapperType = .mmc5
        self.defaultMirroringType = .vertical
        self.autosaveEnabled = true
        self.autosaveInterval = 300 // 5 minutes
        self.theme = .system
    }
    
    static func load() -> Preferences {
        if let data = UserDefaults.standard.data(forKey: "preferences"),
           let preferences = try? JSONDecoder().decode(Preferences.self, from: data) {
            return preferences
        }
        return Preferences()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "preferences")
        }
    }
}

enum Theme: String, Codable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
} 