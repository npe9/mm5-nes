import Foundation
import Shared

public class ROMBuilder {
    private let assemblyPath: String
    
    public init(assemblyPath: String? = nil) {
        if let assemblyPath = assemblyPath {
            self.assemblyPath = assemblyPath
        } else {
            // Get the current bundle
            let bundle = Bundle(for: type(of: self))
            if let resourcePath = bundle.path(forResource: "main", ofType: "s", inDirectory: "Assembly") {
                self.assemblyPath = resourcePath
            } else {
                fatalError("Could not find assembly resource")
            }
        }
    }
    
    public func buildROM() throws -> Data {
        // TODO: Implement ROM building logic
        // 1. Call ca65 to assemble the code
        // 2. Call ld65 to link the object file
        // 3. Read the resulting NES ROM file
        // 4. Return the ROM data
        return Data()
    }
    
    public struct Configuration: Codable, Equatable {
        public var romSize: ROMSize
        public var mapperType: MapperType
        public var mirroringType: MirroringType
        public var debugSymbols: Bool
        public var optimizationLevel: Int
        
        public init(
            romSize: ROMSize = .size32KB,
            mapperType: MapperType = .mmc5,
            mirroringType: MirroringType = .vertical,
            debugSymbols: Bool = false,
            optimizationLevel: Int = 0
        ) {
            self.romSize = romSize
            self.mapperType = mapperType
            self.mirroringType = mirroringType
            self.debugSymbols = debugSymbols
            self.optimizationLevel = optimizationLevel
        }
    }
    
    public struct ROMData: Codable, Equatable {
        public var code: String
        public var patterns: [Shared.Pattern]
        public var tiles: [UInt8]
        
        public init(code: String = "", patterns: [Shared.Pattern] = [], tiles: [UInt8] = []) {
            self.code = code
            self.patterns = patterns
            self.tiles = tiles
        }
        
        public static func == (lhs: ROMData, rhs: ROMData) -> Bool {
            lhs.code == rhs.code &&
            lhs.patterns == rhs.patterns &&
            lhs.tiles == rhs.tiles
        }
    }
    
    public enum ROMSize: String, Codable, CaseIterable, Equatable {
        case size16KB = "16 KB"
        case size32KB = "32 KB"
        case size64KB = "64 KB"
        case size128KB = "128 KB"
        case size256KB = "256 KB"
        case size512KB = "512 KB"
        
        public var bytes: Int {
            switch self {
            case .size16KB: return 16 * 1024
            case .size32KB: return 32 * 1024
            case .size64KB: return 64 * 1024
            case .size128KB: return 128 * 1024
            case .size256KB: return 256 * 1024
            case .size512KB: return 512 * 1024
            }
        }
    }
    
    public enum MapperType: String, Codable, CaseIterable, Equatable {
        case nrom = "NROM"
        case mmc1 = "MMC1"
        case mmc3 = "MMC3"
        case mmc5 = "MMC5"
        
        var number: Int {
            switch self {
            case .nrom: return 0
            case .mmc1: return 1
            case .mmc3: return 4
            case .mmc5: return 5
            }
        }
    }
    
    public enum MirroringType: String, Codable, CaseIterable, Equatable {
        case horizontal = "Horizontal"
        case vertical = "Vertical"
        case fourScreen = "Four Screen"
    }
    
    public enum BuildError: Error, Equatable {
        case assemblyError(String)
        case linkingError(String)
        case invalidConfiguration
        case invalidData
        
        public static func == (lhs: BuildError, rhs: BuildError) -> Bool {
            switch (lhs, rhs) {
            case (.assemblyError(let lhsStr), .assemblyError(let rhsStr)):
                return lhsStr == rhsStr
            case (.linkingError(let lhsStr), .linkingError(let rhsStr)):
                return lhsStr == rhsStr
            case (.invalidConfiguration, .invalidConfiguration):
                return true
            case (.invalidData, .invalidData):
                return true
            default:
                return false
            }
        }
    }
    
    public static func buildROM(config: Configuration, data: ROMData) async throws -> Data {
        var romData = Data()
        
        // Generate source files
        let sourceCode = data.code
        let musicData = try generateMusicData(from: data.patterns)
        
        // Generate configuration files
        let linkerConfig = generateLinkerConfig(config: config)
        
        // Write files
        try sourceCode.write(to: FileManager.default.temporaryDirectory.appendingPathComponent("game.s"), atomically: true, encoding: .utf8)
        try musicData.write(to: FileManager.default.temporaryDirectory.appendingPathComponent("music.bin"))
        try linkerConfig.write(to: FileManager.default.temporaryDirectory.appendingPathComponent("nes.cfg"), atomically: true, encoding: .utf8)
        
        // Assemble
        let assemblerProcess = Process()
        assemblerProcess.executableURL = URL(fileURLWithPath: "/usr/local/bin/ca65")
        assemblerProcess.arguments = [
            "-o", "game.o",
            "-g" // Debug symbols
        ]
        if config.debugSymbols {
            assemblerProcess.arguments?.append("-g")
        }
        assemblerProcess.arguments?.append("game.s")
        try assemblerProcess.run()
        assemblerProcess.waitUntilExit()
        
        // Link
        let linkerProcess = Process()
        linkerProcess.executableURL = URL(fileURLWithPath: "/usr/local/bin/ld65")
        linkerProcess.arguments = [
            "-o", "game.nes",
            "-C", "nes.cfg",
            "game.o"
        ]
        try linkerProcess.run()
        linkerProcess.waitUntilExit()
        
        // Read output file
        romData = try Data(contentsOf: FileManager.default.temporaryDirectory.appendingPathComponent("game.nes"))
        
        // Add iNES header
        romData.insert(contentsOf: generateHeader(romSize: config.romSize, mapperType: config.mapperType, mirroringType: config.mirroringType), at: 0)
        
        return romData
    }
    
    private static func generateMusicData(from patterns: [Shared.Pattern]) throws -> Data {
        let data = Data()
        // TODO: Implement music data generation
        return data
    }
    
    private static func generateHeader(romSize: ROMSize, mapperType: MapperType, mirroringType: MirroringType) -> Data {
        var header = Data([0x4E, 0x45, 0x53, 0x1A]) // NES header magic
        
        // PRG ROM size in 16KB units
        header.append(UInt8(romSize.bytes / 16384))
        
        // CHR ROM size in 8KB units (0 for CHR RAM)
        header.append(0)
        
        // Flags 6
        var flags6: UInt8 = 0
        switch mirroringType {
        case .horizontal: flags6 |= 0
        case .vertical: flags6 |= 1
        case .fourScreen: flags6 |= 8
        }
        
        // Set mapper number in flags 6 and 7
        let mapperNumber: UInt8
        switch mapperType {
        case .nrom: mapperNumber = 0
        case .mmc1: mapperNumber = 1
        case .mmc3: mapperNumber = 4
        case .mmc5: mapperNumber = 5
        }
        
        flags6 |= (mapperNumber & 0x0F) << 4
        header.append(flags6)
        
        // Flags 7
        let flags7: UInt8 = (mapperNumber & 0xF0)
        header.append(flags7)
        
        // Flags 8-15 (unused)
        header.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0])
        
        return header
    }
    
    private static func generateLinkerConfig(config: Configuration) -> String {
        """
        MEMORY {
            ZP:     start = $0000, size = $0100, type = rw, file = "";
            RAM:    start = $0200, size = $0600, type = rw, file = "";
            HDR:    start = $0000, size = $0010, type = ro, file = %O, fill = yes;
            PRG:    start = $8000, size = \(config.romSize.bytes), type = ro, file = %O, fill = yes;
            CHR:    start = $0000, size = $2000, type = ro, file = %O, fill = yes;
        }

        SEGMENTS {
            ZEROPAGE: load = ZP,  type = zp;
            BSS:      load = RAM, type = bss;
            HEADER:   load = HDR, type = ro;
            CODE:     load = PRG, type = ro,  start = $8000;
            VECTORS:  load = PRG, type = ro,  start = $FFFA;
            CHARS:    load = CHR, type = ro;
        }
        """
    }
} 