import XCTest
import ROMBuilder

final class ROMBuilderTests: XCTestCase {
    var testROMURL: URL!
    
    override func setUp() {
        super.setUp()
        
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
        
        // Add PRG ROM data with some valid 6502 instructions
        var prgROM = [UInt8]()
        // SEI (Disable interrupts)
        prgROM.append(0x78)
        // CLD (Clear decimal mode)
        prgROM.append(0xD8)
        // LDA #$00 (Load accumulator with 0)
        prgROM.append(0xA9)
        prgROM.append(0x00)
        // STA $2000 (Store accumulator to PPU control register)
        prgROM.append(0x8D)
        prgROM.append(0x00)
        prgROM.append(0x20)
        // Fill the rest with NOPs
        while prgROM.count < 16384 {
            prgROM.append(0xEA)  // NOP
        }
        romData.append(contentsOf: prgROM)
        
        // Add CHR ROM data
        let chrROM = Array(repeating: UInt8(0), count: 8192)
        romData.append(contentsOf: chrROM)
        
        try? romData.write(to: testROMURL)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: testROMURL)
        super.tearDown()
    }
    
    func testROMBuilding() async throws {
        guard FileManager.default.fileExists(atPath: "/usr/local/bin/ca65") else {
            print("Skipping testROMBuilding: ca65 not installed")
            return
        }
        
        let config = ROMBuilder.Configuration()
        let data = ROMBuilder.ROMData()
        let result = try await ROMBuilder.buildROM(config: config, data: data)
        XCTAssertGreaterThan(result.count, 0)
    }
    
    func testInvalidConfiguration() async throws {
        guard FileManager.default.fileExists(atPath: "/usr/local/bin/ca65") else {
            print("Skipping testInvalidConfiguration: ca65 not installed")
            return
        }
        
        let config = ROMBuilder.Configuration(romSize: .size16KB)
        let data = ROMBuilder.ROMData()
        
        do {
            _ = try await ROMBuilder.buildROM(config: config, data: data)
            XCTFail("Expected build to fail with invalid configuration")
        } catch let error as ROMBuilder.BuildError {
            XCTAssertEqual(error, .invalidConfiguration)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testHeaderParsing() throws {
        let rom = try Data(contentsOf: testROMURL)
        let parser = try iNESParser(data: rom)
        let header = parser.header
        
        XCTAssertEqual(header.prgROMSize, 1) // 16KB
        XCTAssertEqual(header.chrROMSize, 1) // 8KB
        XCTAssertEqual(header.mirroring, .horizontal)
        XCTAssertFalse(header.hasBatteryRAM)
        XCTAssertFalse(header.hasTrainer)
        XCTAssertFalse(header.vsUnisystem)
        XCTAssertFalse(header.nes2Format)
        XCTAssertEqual(header.mapper, 0)
    }
    
    func testROMSizes() throws {
        let rom = try Data(contentsOf: testROMURL)
        let parser = try iNESParser(data: rom)
        let header = parser.header
        
        XCTAssertEqual(header.prgROMSize, 1) // 16KB
        XCTAssertEqual(header.chrROMSize, 1) // 8KB
        
        let prgROM = try parser.extractPRGROM()
        let chrROM = parser.extractCHRROM() ?? Data()
        
        XCTAssertEqual(prgROM.count, 16384) // 16KB
        XCTAssertEqual(chrROM.count, 8192)  // 8KB
    }
    
    func testDisassembly() throws {
        let prgROM = Array(repeating: UInt8(0xEA), count: 16384) // Fill with NOPs
        let disassembler = Disassembler(prgROM: prgROM)
        
        print("Getting disassembly string...")
        let disassembly = try disassembler.getDisassembly()
        print("Disassembly string length: \(disassembly.count)")
        print("Disassembly:\n\(disassembly)")
        
        XCTAssertTrue(disassembly.contains("NOP"), "Disassembly should contain NOP instructions")
    }
} 