import Foundation

/// A class for parsing iNES format ROM files
public class iNESParser {
    public struct iNESHeader: Equatable {
        public let prgROMSize: Int
        public let chrROMSize: Int
        public let mapper: Int
        public let mirroring: MirroringType
        public let hasBatteryRAM: Bool
        public let hasTrainer: Bool
        public let fourScreen: Bool
        public let vsUnisystem: Bool
        public let playchoice10: Bool
        public let nes2Format: Bool
        public let prgRAMSize: Int
        public let chrRAMSize: Int
        public let cpuPPUTiming: CPUTiming
        public let hardwareType: HardwareType
        
        public enum CPUTiming: Equatable {
            case ntsc
            case pal
            case dual
        }
        
        public enum HardwareType: Equatable {
            case vsSystem
            case playchoice10
            case regular
        }
        
        public enum MirroringType: Equatable {
            case horizontal
            case vertical
            case fourScreen
            case singleScreen
        }
        
        public init(data: Data) throws {
            guard data.count >= 16 else { throw iNESParserError.invalidHeader }
            guard data[0...3] == Data([0x4E, 0x45, 0x53, 0x1A]) else { throw iNESParserError.invalidHeader }
            
            let flags6 = data[6]
            let flags7 = data[7]
            
            // Parse ROM sizes
            prgROMSize = Int(data[4])
            chrROMSize = Int(data[5])
            
            // Parse flags
            hasBatteryRAM = (flags6 & 0x02) != 0
            hasTrainer = (flags6 & 0x04) != 0
            fourScreen = (flags6 & 0x08) != 0
            vsUnisystem = (flags7 & 0x01) != 0
            playchoice10 = (flags7 & 0x02) != 0
            nes2Format = (flags7 & 0x0C) == 0x08
            
            // Parse mapper number
            mapper = Int((flags7 & 0xF0) | (flags6 >> 4))
            
            // Parse mirroring type
            if fourScreen {
                mirroring = .fourScreen
            } else {
                mirroring = (flags6 & 0x01) != 0 ? .vertical : .horizontal
            }
            
            // Parse NES 2.0 specific fields
            if nes2Format {
                prgRAMSize = Int(data[10])
                chrRAMSize = Int(data[11])
                
                let timing = data[12] & 0x03
                switch timing {
                case 0: cpuPPUTiming = .ntsc
                case 1: cpuPPUTiming = .pal
                default: cpuPPUTiming = .dual
                }
                
                let system = data[13] & 0x03
                switch system {
                case 1: hardwareType = .vsSystem
                case 2: hardwareType = .playchoice10
                default: hardwareType = .regular
                }
            } else {
                prgRAMSize = 0
                chrRAMSize = 0
                cpuPPUTiming = .ntsc
                hardwareType = .regular
            }
            
            // Validate sizes
            if prgROMSize == 0 { throw iNESParserError.invalidPRGSize }
            if chrROMSize > 0 && data.count < 16 + (prgROMSize * 16384) + (chrROMSize * 8192) {
                throw iNESParserError.invalidCHRSize
            }
        }
        
        public init(prgROMSize: Int, chrROMSize: Int, mapper: Int, mirroring: MirroringType, hasBatteryRAM: Bool, hasTrainer: Bool, fourScreen: Bool, vsUnisystem: Bool, playchoice10: Bool, nes2Format: Bool, prgRAMSize: Int = 0, chrRAMSize: Int = 0, cpuPPUTiming: CPUTiming = .ntsc, hardwareType: HardwareType = .regular) {
            self.prgROMSize = prgROMSize
            self.chrROMSize = chrROMSize
            self.mapper = mapper
            self.mirroring = mirroring
            self.hasBatteryRAM = hasBatteryRAM
            self.hasTrainer = hasTrainer
            self.fourScreen = fourScreen
            self.vsUnisystem = vsUnisystem
            self.playchoice10 = playchoice10
            self.nes2Format = nes2Format
            self.prgRAMSize = prgRAMSize
            self.chrRAMSize = chrRAMSize
            self.cpuPPUTiming = cpuPPUTiming
            self.hardwareType = hardwareType
        }
    }
    
    private let data: Data
    public let header: iNESHeader
    
    public init(data: Data) throws {
        self.data = data
        self.header = try iNESHeader(data: data)
    }
    
    public func extractPRGROM() throws -> Data {
        let startOffset = 16 + (header.hasTrainer ? 512 : 0)
        let endOffset = startOffset + (header.prgROMSize * 16384)
        guard data.count >= endOffset else { throw iNESParserError.missingPRGData }
        return data[startOffset..<endOffset]
    }
    
    public func extractCHRROM() -> Data? {
        let startOffset = 16 + (header.hasTrainer ? 512 : 0) + (header.prgROMSize * 16384)
        let endOffset = startOffset + (header.chrROMSize * 8192)
        guard data.count >= endOffset else { return nil }
        return data[startOffset..<endOffset]
    }
    
    public func extractTrainer() -> Data? {
        guard header.hasTrainer else { return nil }
        let startOffset = 16
        let endOffset = startOffset + 512
        guard data.count >= endOffset else { return nil }
        return data[startOffset..<endOffset]
    }
    
    public func extractTilesets() -> [[UInt8]]? {
        guard let chrData = extractCHRROM() else { return nil }
        
        // Each tile is 16 bytes (8x8 pixels, 2 bits per pixel)
        let tileSize = 16
        var tilesets: [[UInt8]] = []
        
        var offset = 0
        while offset < chrData.count {
            let remainingBytes = chrData.count - offset
            let tileBytes = min(tileSize, remainingBytes)
            let tile = Array(chrData[offset..<(offset + tileBytes)])
            tilesets.append(tile)
            offset += tileSize
        }
        
        return tilesets
    }
    
    public func extractCode() throws -> String {
        let prgROM = try extractPRGROM()
        // Convert PRG ROM to a hex dump for now
        // In the future, we could add actual 6502 disassembly
        return prgROM.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    public func extractMusic() -> [Pattern] {
        // TODO: Implement music extraction
        // This would require understanding the game's music data format
        // For now, return an empty array
        return []
    }
}

public enum iNESParserError: Error, Equatable {
    case invalidHeader
    case invalidPRGSize
    case invalidCHRSize
    case missingPRGData
    case missingCHRData
    case invalidNES2Format
    case missingTrainerData
    case invalidMapper
    case invalidFlags
} 