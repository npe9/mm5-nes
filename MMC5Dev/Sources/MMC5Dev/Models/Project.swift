import Foundation
import SwiftUI
import ROMBuilder
import Shared

struct Project: Codable, Equatable {
    var name: String
    var settings: ProjectSettings
    var data: ROMBuilder.ROMData
    var fileURL: URL?
    var createdAt: Date
    var modifiedAt: Date
    
    init(name: String = "Untitled Project") {
        self.name = name
        self.settings = ProjectSettings()
        self.data = ROMBuilder.ROMData(
            code: "",
            patterns: [Shared.Pattern(name: "Pattern 1", notes: [])],
            tiles: []
        )
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

extension Project {
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.name == rhs.name &&
        lhs.settings == rhs.settings &&
        lhs.data == rhs.data
    }
}

public enum ROMSize: String, Codable, CaseIterable {
    case kb16 = "16KB"
    case kb32 = "32KB"
    case kb64 = "64KB"
    case kb128 = "128KB"
    case kb256 = "256KB"
    case kb512 = "512KB"
    case mb1 = "1MB"
}

public enum MapperType: String, Codable, CaseIterable {
    case nrom = "NROM"
    case mmc1 = "MMC1"
    case mmc3 = "MMC3"
    case mmc5 = "MMC5"
}

public enum MirroringType: String, Codable, CaseIterable {
    case horizontal = "Horizontal"
    case vertical = "Vertical"
    case fourScreen = "Four Screen"
    case singleScreen = "Single Screen"
}

struct ProjectSettings: Codable, Equatable {
    var romSize: ROMBuilder.ROMSize
    var mapperType: ROMBuilder.MapperType
    var mirroringType: ROMBuilder.MirroringType
    
    init(
        romSize: ROMBuilder.ROMSize = .size32KB,
        mapperType: ROMBuilder.MapperType = .mmc5,
        mirroringType: ROMBuilder.MirroringType = .vertical
    ) {
        self.romSize = romSize
        self.mapperType = mapperType
        self.mirroringType = mirroringType
    }
}

struct BuildSettings: Codable {
    var optimizationLevel: Int
    var debugSymbols: Bool
    var emulatorPath: String?
    
    init() {
        self.optimizationLevel = 2
        self.debugSymbols = true
    }
} 