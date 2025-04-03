import Foundation
import SwiftUI
import ROMBuilder
import Shared

enum Mirroring {
    case horizontal
    case vertical
}

struct ROMInfo {
    let prgROMSize: Int
    let chrROMSize: Int
    let mapper: Int
    let mirroring: Mirroring
    let battery: Bool
    let trainer: Bool
    let fourScreen: Bool
}

@MainActor
class ROMLoaderViewModel: ObservableObject {
    @Published var romInfo: [String] = []
    @Published var tiles: [[UInt8]] = []
    @Published var code: String = ""
    @Published var disassembly: String = ""
    @Published var errorMessage: String?
    
    private let projectManager: ProjectManager
    private var romData: Data?
    
    init(projectManager: ProjectManager) {
        self.projectManager = projectManager
    }
    
    func loadROM(from url: URL) async {
        print("\n=== Starting ROM Loading Process ===")
        print("Loading ROM from: \(url.path)")
        
        do {
            let data = try Data(contentsOf: url)
            print("ROM data size: \(data.count) bytes")
            
            guard data.count >= 16 else {
                print("Error: ROM file is too small")
                errorMessage = "Invalid ROM file: too small"
                return
            }
            
            // Store ROM data
            self.romData = data
            
            let header = data.prefix(16)
            print("ROM header: \(header.map { String(format: "%02X", $0) }.joined())")
            
            let prgROMSize = Int(header[4]) * 16384
            let chrROMSize = Int(header[5]) * 8192
            print("PRG ROM size: \(prgROMSize) bytes")
            print("CHR ROM size: \(chrROMSize) bytes")
            
            let expectedSize = 16 + prgROMSize + chrROMSize
            print("Expected ROM size: \(expectedSize) bytes")
            print("Actual ROM size: \(data.count) bytes")
            
            guard data.count == expectedSize else {
                print("Error: ROM size mismatch")
                errorMessage = "Invalid ROM file: size mismatch"
                return
            }
            
            // Extract and store ROM info
            let mapper = Int(header[6]) >> 4
            let mirroring = (header[6] & 1) == 0 ? "horizontal" : "vertical"
            let battery = (header[6] & 2) != 0
            let trainer = (header[6] & 4) != 0
            let fourScreen = (header[6] & 8) != 0
            
            romInfo = [
                "PRG ROM: \(prgROMSize / 1024)KB",
                "CHR ROM: \(chrROMSize / 1024)KB",
                "Mapper: \(mapper)",
                "Mirroring: \(mirroring)",
                "Battery: \(battery)",
                "Trainer: \(trainer)",
                "Four Screen: \(fourScreen)"
            ]
            
            // Extract and store CHR data
            let startOffset = 16 + (trainer ? 512 : 0) + prgROMSize
            let endOffset = startOffset + chrROMSize
            
            print("Extracting CHR data from offset \(startOffset) to \(endOffset)")
            
            guard endOffset <= data.count else {
                print("Error: Invalid CHR ROM offset")
                errorMessage = "Invalid ROM file: CHR ROM offset out of bounds"
                return
            }
            
            let chrData = data[startOffset..<endOffset]
            print("CHR data size: \(chrData.count) bytes")
            
            // Convert CHR data to tiles (8x8 pixels, 2 bits per pixel)
            var tiles: [[UInt8]] = []
            var currentTile: [UInt8] = []
            
            print("Converting CHR data to tiles...")
            
            for tileIndex in stride(from: 0, to: chrData.count, by: 16) {
                guard tileIndex + 16 <= chrData.count else {
                    print("Warning: Incomplete tile data at index \(tileIndex)")
                    break
                }
                
                currentTile = Array(repeating: 0, count: 64) // 8x8 pixels
                
                // Each tile is 16 bytes: 8 bytes for the low bits, 8 bytes for the high bits
                for row in 0..<8 {
                    let lowByte = chrData[tileIndex + row]
                    let highByte = chrData[tileIndex + row + 8]
                    
                    print("Tile \(tileIndex/16) Row \(row): Low=\(String(format: "%02X", lowByte)) High=\(String(format: "%02X", highByte))")
                    
                    for col in 0..<8 {
                        let lowBit = (lowByte >> (7 - col)) & 1
                        let highBit = (highByte >> (7 - col)) & 1
                        let value = (highBit << 1) | lowBit
                        let index = row * 8 + col
                        currentTile[index] = value
                        
                        print("  Pixel (\(row),\(col)): Low=\(lowBit) High=\(highBit) Value=\(value)")
                    }
                }
                
                tiles.append(currentTile)
                print("Added tile \(tiles.count - 1) with \(currentTile.count) pixels")
            }
            
            print("Created \(tiles.count) tiles")
            self.tiles = tiles
            
            // Update project with the loaded tiles
            projectManager.updateTiles(tiles.flatMap { $0 })
            print("Updated project with \(tiles.count * 64) tile pixels")
            
        } catch {
            print("Error loading ROM: \(error)")
            errorMessage = "Error loading ROM: \(error.localizedDescription)"
        }
    }
    
    func importTilesToProject() async {
        let tileData = tiles.flatMap { $0 }
        projectManager.updateTiles(tileData)
    }
    
    func importCodeToProject() async {
        projectManager.updateCode(code)
    }
}

extension Data {
    func hexDump() -> String {
        var result = ""
        var offset = 0
        
        while offset < count {
            let lineBytes = Swift.min(16, count - offset)
            let line = self[offset..<(offset + lineBytes)]
            
            result += String(format: "%04X: ", offset)
            
            // Hex values
            for (index, byte) in line.enumerated() {
                result += String(format: "%02X ", byte)
                if index == 7 {
                    result += " "
                }
            }
            
            // Padding for incomplete lines
            if lineBytes < 16 {
                let padding = 16 - lineBytes
                for _ in 0..<padding {
                    result += "   "
                }
                if lineBytes <= 8 {
                    result += " "
                }
            }
            
            result += " |"
            
            // ASCII representation
            for byte in line {
                if byte >= 32 && byte <= 126 {
                    result.append(Character(UnicodeScalar(byte)))
                } else {
                    result.append(".")
                }
            }
            
            result += "|\n"
            offset += lineBytes
        }
        
        return result
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
} 