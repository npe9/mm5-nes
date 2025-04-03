import XCTest
import Foundation

class MMC5DevUITests: XCTestCase {
    var process: Process!
    var outputPipe: Pipe!
    var errorPipe: Pipe!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Get the path to the built executable
        let buildPath = FileManager.default.currentDirectoryPath + "/.build/debug/MMC5Dev"
        
        guard FileManager.default.fileExists(atPath: buildPath) else {
            XCTFail("Could not find executable at path: \(buildPath)")
            return
        }
        
        // Initialize process and pipes
        process = Process()
        process.executableURL = URL(fileURLWithPath: buildPath)
        
        outputPipe = Pipe()
        errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
    }
    
    override func tearDownWithError() throws {
        if process.isRunning {
            process.terminate()
        }
        process = nil
        outputPipe = nil
        errorPipe = nil
    }
    
    func testHelpCommand() throws {
        // Set up help command
        process.arguments = ["--help"]
        
        // Run the process
        try process.run()
        process.waitUntilExit()
        
        // Get the output
        let outputData = try XCTUnwrap(outputPipe.fileHandleForReading.readDataToEndOfFile())
        let output = String(data: outputData, encoding: .utf8)
        
        // Verify help output
        XCTAssertNotNil(output, "Help output should not be nil")
        XCTAssertTrue(output?.contains("USAGE:") ?? false, "Help output should contain usage information")
        XCTAssertTrue(output?.contains("MMC5Dev") ?? false, "Help output should contain application name")
    }
    
    func testVersionCommand() throws {
        // Set up version command
        process.arguments = ["--version"]
        
        // Run the process
        try process.run()
        process.waitUntilExit()
        
        // Get the output
        let outputData = try XCTUnwrap(outputPipe.fileHandleForReading.readDataToEndOfFile())
        let output = String(data: outputData, encoding: .utf8)
        
        // Verify version output
        XCTAssertNotNil(output, "Version output should not be nil")
        XCTAssertTrue(output?.contains("MMC5Dev") ?? false, "Version output should contain application name")
    }
} 