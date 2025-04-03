import XCTest
import ROMBuilder

final class iNESParserTests: XCTestCase {
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
        
        // Add PRG ROM data
        let prgROM = Array(repeating: UInt8(0), count: 16384)
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
    
    func testParseHeader() throws {
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
    
    func testExtractROMs() throws {
        let rom = try Data(contentsOf: testROMURL)
        let parser = try iNESParser(data: rom)
        
        // Extract and verify PRG ROM
        let prgROM = try parser.extractPRGROM()
        print("\nPRG ROM Size: \(prgROM.count) bytes")
        XCTAssertEqual(prgROM.count, 16384) // 16KB
        
        // Extract and verify CHR ROM
        if let chrROM = parser.extractCHRROM() {
            print("\nCHR ROM Size: \(chrROM.count) bytes")
            XCTAssertEqual(chrROM.count, 8192) // 8KB
        } else {
            XCTFail("Failed to extract CHR ROM")
        }
    }
    
    func testInvalidROM() {
        let invalidROM = Data([0x00, 0x01, 0x02]) // Invalid ROM data
        XCTAssertThrowsError(try iNESParser(data: invalidROM)) { error in
            XCTAssertEqual(error as? iNESParserError, .invalidHeader)
        }
    }
} 