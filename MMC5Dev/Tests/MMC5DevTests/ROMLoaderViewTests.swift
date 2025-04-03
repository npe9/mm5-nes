import XCTest
import SwiftUI
import UniformTypeIdentifiers
@testable import MMC5Dev
@testable import ROMBuilder

@MainActor
final class ROMLoaderViewTests: XCTestCase {
    var projectManager: ProjectManager!
    var view: ROMLoaderView!
    var testROMURL: URL!
    
    override func setUp() async throws {
        try await super.setUp()
        projectManager = ProjectManager()
        view = ROMLoaderView(projectManager: projectManager)
        
        // Create a test ROM file
        let tempDir = FileManager.default.temporaryDirectory
        testROMURL = tempDir.appendingPathComponent("test.nes")
        
        // Create a minimal valid iNES ROM
        var romData = Data([
            0x4E, 0x45, 0x53, 0x1A,  // NES magic number
            0x01,                     // 16KB PRG ROM
            0x01,                     // 8KB CHR ROM
            0x00,                     // Horizontal mirroring, no battery, no trainer
            0x00,                     // Mapper 0 (NROM)
            0x00, 0x00, 0x00, 0x00,  // Unused bytes
            0x00, 0x00, 0x00, 0x00   // Unused bytes
        ])
        
        // Add PRG ROM data
        var prgROM = Array(repeating: UInt8(0), count: 16384)
        
        // Add a simple NES initialization sequence at $8000
        let initCode: [UInt8] = [
            0x78,        // SEI - Disable interrupts
            0xD8,        // CLD - Clear decimal mode
            0xA2, 0xFF,  // LDX #$FF
            0x9A,        // TXS - Set stack pointer
            0xA9, 0x00,  // LDA #$00
            0x8D, 0x00, 0x20,  // STA $2000 - Clear PPU control
            0x8D, 0x01, 0x20,  // STA $2001 - Clear PPU mask
            0xA9, 0x40,  // LDA #$40
            0x8D, 0x17, 0x40,  // STA $4017 - Disable APU frame IRQ
            0xA9, 0x0F,  // LDA #$0F
            0x8D, 0x15, 0x40,  // STA $4015 - Enable all sound channels
            0xA9, 0x80,  // LDA #$80
            0x8D, 0x00, 0x20,  // STA $2000 - Enable NMI
            0x4C, 0x20, 0x80   // JMP $8020 - Jump to main code
        ]
        prgROM.replaceSubrange(0..<initCode.count, with: initCode)
        
        // Add main code at $8020
        let mainCode: [UInt8] = [
            0xA9, 0x00,        // LDA #$00
            0x85, 0x00,        // STA $00
            0xA9, 0x02,        // LDA #$02
            0x85, 0x01,        // STA $01
            0xA0, 0x00,        // LDY #$00
            0xB1, 0x00,        // LDA ($00),Y
            0x4C, 0x40, 0x80   // JMP $8040
        ]
        prgROM.replaceSubrange(0x20..<(0x20 + mainCode.count), with: mainCode)
        
        // Add interrupt handlers at $8040
        let nmiCode: [UInt8] = [
            0x48,              // PHA
            0x8A,              // TXA
            0x48,              // PHA
            0x98,              // TYA
            0x48,              // PHA
            0xA9, 0x00,        // LDA #$00
            0x8D, 0x05, 0x20,  // STA $2005
            0x8D, 0x05, 0x20,  // STA $2005
            0x68,              // PLA
            0xA8,              // TAY
            0x68,              // PLA
            0xAA,              // TAX
            0x68,              // PLA
            0x40               // RTI
        ]
        prgROM.replaceSubrange(0x40..<(0x40 + nmiCode.count), with: nmiCode)
        
        // Add reset vector at $FFFC (last 4 bytes of PRG ROM)
        prgROM[16380] = 0x00  // Low byte of reset vector
        prgROM[16381] = 0x80  // High byte of reset vector ($8000)
        
        // Add NMI vector at $FFFA
        prgROM[16378] = 0x40  // Low byte of NMI vector
        prgROM[16379] = 0x80  // High byte of NMI vector ($8040)
        
        // Add IRQ vector at $FFFE
        prgROM[16382] = 0x40  // Low byte of IRQ vector
        prgROM[16383] = 0x80  // High byte of IRQ vector ($8040)
        
        romData.append(contentsOf: prgROM)
        
        // Add CHR ROM data
        let chrROM = Array(repeating: UInt8(0), count: 8192)
        romData.append(contentsOf: chrROM)
        
        // Write ROM file and verify it exists
        try romData.write(to: testROMURL)
        guard FileManager.default.fileExists(atPath: testROMURL.path) else {
            throw NSError(domain: "ROMLoaderViewTests", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create test ROM file"])
        }
        
        // Verify ROM file size
        let attributes = try FileManager.default.attributesOfItem(atPath: testROMURL.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        XCTAssertEqual(fileSize, Int64(romData.count), "ROM file size mismatch")
    }
    
    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: testROMURL)
        projectManager = nil
        view = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        let viewModel = view.viewModel
        XCTAssertTrue(viewModel.romInfo.isEmpty)
        XCTAssertTrue(viewModel.tiles.isEmpty)
    }
    
    func testLoadValidROM() async throws {
        let viewModel = view.viewModel
        
        // Verify ROM file exists before loading
        guard FileManager.default.fileExists(atPath: testROMURL.path) else {
            XCTFail("Test ROM file does not exist at path: \(testROMURL.path)")
            return
        }
        
        // Load ROM
        await viewModel.loadROM(from: testROMURL)
        
        // Verify ROM info was loaded
        XCTAssertFalse(viewModel.romInfo.isEmpty, "ROM info should not be empty")
        XCTAssertFalse(viewModel.tiles.isEmpty, "Tiles should not be empty")
        
        // Verify ROM info content
        let romInfo = viewModel.romInfo.joined(separator: "\n")
        XCTAssertTrue(romInfo.contains("PRG ROM: 16KB"), "ROM info should contain PRG ROM size")
        XCTAssertTrue(romInfo.contains("CHR ROM: 8KB"), "ROM info should contain CHR ROM size")
        XCTAssertTrue(romInfo.contains("Mapper: 0"), "ROM info should contain mapper number")
    }
    
    func testLoadInvalidROM() async throws {
        let viewModel = view.viewModel
        let invalidROMURL = URL(string: "file:///invalid.nes")!
        await viewModel.loadROM(from: invalidROMURL)
        
        XCTAssertTrue(viewModel.romInfo.isEmpty)
        XCTAssertTrue(viewModel.tiles.isEmpty)
    }
    
    func testProjectIntegration() async throws {
        let viewModel = view.viewModel
        await viewModel.loadROM(from: testROMURL)
        
        // Test importing tiles
        await viewModel.importTilesToProject()
        
        // Test importing code
        await viewModel.importCodeToProject()
    }
}

extension Array {
    func chunks(ofCount count: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: count).map {
            Array(self[$0..<Swift.min($0 + count, self.count)])
        }
    }
}