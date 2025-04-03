import XCTest
import Foundation

class CommandLineTests: XCTestCase {
    var process: Process!
    var pipe: Pipe!
    var buildPath: String!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        process = Process()
        pipe = Pipe()
        
        // Get the path to the built executable
        buildPath = FileManager.default.currentDirectoryPath + "/.build/debug/MMC5Dev"
        
        guard FileManager.default.fileExists(atPath: buildPath) else {
            XCTFail("Could not find executable at path: \(String(describing: buildPath))")
            return
        }
        
        process.executableURL = URL(fileURLWithPath: buildPath)
        process.standardOutput = pipe
        process.standardError = pipe
    }
    
    override func tearDownWithError() throws {
        if process.isRunning {
            process.terminate()
        }
        process = nil
        pipe = nil
        buildPath = nil
    }
    
    func readProcessOutput() throws -> String {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func testCommandLineMode() throws {
        // Test with --help flag
        process.arguments = ["--help"]
        
        let expectation = XCTestExpectation(description: "Process completion")
        process.terminationHandler = { _ in
            expectation.fulfill()
        }
        
        try process.run()
        
        // Wait for a short time to let the process start
        Thread.sleep(forTimeInterval: 0.1)
        
        // If the process is still running after a short time, terminate it
        if process.isRunning {
            process.terminate()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        let output = try readProcessOutput()
        
        // Verify help text contains expected information
        XCTAssertTrue(output.contains("MMC5Dev"), "Help text should contain application name")
        XCTAssertTrue(output.contains("--help"), "Help text should contain --help option")
        
        // Test with invalid arguments
        process = Process()
        pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: buildPath)
        process.standardOutput = pipe
        process.standardError = pipe
        
        process.arguments = ["--invalid-flag"]
        
        let errorExpectation = XCTestExpectation(description: "Error process completion")
        process.terminationHandler = { _ in
            errorExpectation.fulfill()
        }
        
        try process.run()
        
        // Wait for a short time to let the process start
        Thread.sleep(forTimeInterval: 0.1)
        
        // If the process is still running after a short time, terminate it
        if process.isRunning {
            process.terminate()
        }
        
        wait(for: [errorExpectation], timeout: 1.0)
        
        let errorOutput = try readProcessOutput()
        
        // Verify error message
        XCTAssertTrue(errorOutput.contains("error") || errorOutput.contains("Error"), 
                     "Error output should contain error message")
    }
} 