import Foundation

public class ROMBuilderService {
    private let ca65Path: String
    private let ld65Path: String
    
    public init() {
        // TODO: Make these configurable
        self.ca65Path = "/usr/local/bin/ca65"
        self.ld65Path = "/usr/local/bin/ld65"
    }
    
    public func buildROM(config: ROMBuilder.Configuration, data: ROMBuilder.ROMData, progress: @escaping (Double) -> Void) async throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        // Generate source files
        let sourceFile = tempDir.appendingPathComponent("main.s")
        try generateSourceFile(from: data, to: sourceFile)
        
        // Generate configuration file
        let cfgFile = tempDir.appendingPathComponent("nes.cfg")
        try generateConfigFile(config: config, to: cfgFile)
        
        // Assemble
        let objFile = tempDir.appendingPathComponent("main.o")
        try await assemble(sourceFile: sourceFile, objectFile: objFile)
        
        // Link
        let binFile = tempDir.appendingPathComponent("game.nes")
        try await link(objectFile: objFile, outputFile: binFile, configFile: cfgFile)
        
        // Copy to final location
        let outputFile = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent("game.nes")
        try FileManager.default.copyItem(at: binFile, to: outputFile)
        
        return outputFile
    }
    
    private func generateSourceFile(from data: ROMBuilder.ROMData, to file: URL) throws {
        let content = """
        .include "mmc5.inc"
        
        .segment "HEADER"
            .byte "NES", $1A   ; iNES header identifier
            .byte $02          ; 16KB PRG ROM size
            .byte $01          ; 8KB CHR ROM size
            .byte $01          ; Mapper 0, vertical mirroring
            .byte $00          ; Mapper 0, playchoice, vs.
            .byte $00          ; No PRG RAM
            .byte $00          ; NTSC format
        """
        try content.write(to: file, atomically: true, encoding: .utf8)
    }
    
    private func generateConfigFile(config: ROMBuilder.Configuration, to file: URL) throws {
        let cfgContent = """
        MEMORY {
            ZP:     start = $00,    size = $0100, type = rw, file = "";
            RAM:    start = $0200,  size = $0600, type = rw, file = "";
            HDR:    start = $0000,  size = $0010, type = ro, file = %O, fill = yes;
            PRG:    start = $8000,  size = $8000, type = ro, file = %O, fill = yes;
            CHR:    start = $0000,  size = $2000, type = ro, file = %O, fill = yes;
        }

        SEGMENTS {
            ZEROPAGE: load = ZP,  type = zp;
            HEADER:   load = HDR, type = ro;
            CODE:     load = PRG, type = ro,  start = $8000;
            VECTORS:  load = PRG, type = ro,  start = $FFFA;
            CHARS:    load = CHR, type = ro;
        }
        """
        
        try cfgContent.write(to: file, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func assemble(sourceFile: URL, objectFile: URL) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ca65Path)
        process.arguments = ["-o", objectFile.path, sourceFile.path]
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw ROMBuilderError.assemblyFailed
        }
    }
    
    private func link(objectFile: URL, outputFile: URL, configFile: URL) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ld65Path)
        process.arguments = [
            "-C", configFile.path,
            "-o", outputFile.path,
            objectFile.path
        ]
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw ROMBuilderError.linkingFailed
        }
    }
}

enum ROMBuilderError: Error {
    case assemblyFailed
    case linkingFailed
} 