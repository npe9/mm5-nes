import Foundation
import ROMBuilder

@MainActor
class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    private enum Keys {
        static let emulatorPath = "emulatorPath"
        static let defaultROMSize = "defaultROMSize"
        static let defaultMapperType = "defaultMapperType"
        static let defaultMirroringType = "defaultMirroringType"
        static let autosaveEnabled = "autosaveEnabled"
        static let autosaveInterval = "autosaveInterval"
        static let theme = "theme"
    }
    
    private let defaults = UserDefaults.standard
    
    @Published var emulatorPath: String? {
        didSet {
            defaults.set(emulatorPath, forKey: Keys.emulatorPath)
        }
    }
    
    @Published var defaultROMSize: ROMBuilder.ROMSize {
        didSet {
            defaults.set(defaultROMSize.rawValue, forKey: Keys.defaultROMSize)
        }
    }
    
    @Published var defaultMapperType: ROMBuilder.MapperType {
        didSet {
            defaults.set(defaultMapperType.rawValue, forKey: Keys.defaultMapperType)
        }
    }
    
    @Published var defaultMirroringType: ROMBuilder.MirroringType {
        didSet {
            defaults.set(defaultMirroringType.rawValue, forKey: Keys.defaultMirroringType)
        }
    }
    
    @Published var autosaveEnabled: Bool {
        didSet {
            defaults.set(autosaveEnabled, forKey: Keys.autosaveEnabled)
        }
    }
    
    @Published var autosaveInterval: TimeInterval {
        didSet {
            defaults.set(autosaveInterval, forKey: Keys.autosaveInterval)
        }
    }
    
    @Published var theme: Theme {
        didSet {
            defaults.set(theme.rawValue, forKey: Keys.theme)
        }
    }
    
    private init() {
        // Initialize theme first since it's used in other initializations
        let themeString = defaults.string(forKey: Keys.theme) ?? Theme.system.rawValue
        self.theme = Theme(rawValue: themeString) ?? .system
        
        // Initialize other properties
        self.emulatorPath = defaults.string(forKey: Keys.emulatorPath)
        
        let romSizeString = defaults.string(forKey: Keys.defaultROMSize) ?? ROMBuilder.ROMSize.size32KB.rawValue
        self.defaultROMSize = ROMBuilder.ROMSize(rawValue: romSizeString) ?? .size32KB
        
        let mapperTypeString = defaults.string(forKey: Keys.defaultMapperType) ?? ROMBuilder.MapperType.mmc5.rawValue
        self.defaultMapperType = ROMBuilder.MapperType(rawValue: mapperTypeString) ?? .mmc5
        
        let mirroringTypeString = defaults.string(forKey: Keys.defaultMirroringType) ?? ROMBuilder.MirroringType.vertical.rawValue
        self.defaultMirroringType = ROMBuilder.MirroringType(rawValue: mirroringTypeString) ?? .vertical
        
        self.autosaveEnabled = defaults.bool(forKey: Keys.autosaveEnabled)
        
        let interval = defaults.double(forKey: Keys.autosaveInterval)
        self.autosaveInterval = interval > 0 ? interval : 300 // 5 minutes default
    }
    
    func showPreferences() {
        NotificationCenter.default.post(name: NSNotification.Name("ShowPreferences"), object: nil)
    }
} 