import XCTest
@testable import MMC5Dev
@testable import Shared
@testable import ROMBuilder

@MainActor
final class ProjectManagerTests: XCTestCase {
    var projectManager: MMC5Dev.ProjectManager!
    var testFileURL: URL!
    
    override func setUp() async throws {
        try await super.setUp()
        projectManager = MMC5Dev.ProjectManager()
        projectManager.newProject()
        
        // Create a temporary file URL for testing
        testFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.mmc5")
    }
    
    override func tearDown() async throws {
        // Clean up the test file
        try? FileManager.default.removeItem(at: testFileURL)
        projectManager = nil
        try await super.tearDown()
    }
    
    func testSaveAndLoad() async throws {
        // Create a test pattern
        let pattern = Shared.Pattern(name: "Test Pattern")
        projectManager.updatePatterns([pattern])
        
        // Save project
        try projectManager.saveProjectAs(to: testFileURL)
        XCTAssertFalse(projectManager.isProjectDirty)
        
        // Load project
        projectManager.newProject()
        await projectManager.openProject(at: testFileURL)
        XCTAssertEqual(projectManager.currentProject?.data.patterns[0].name, "Test Pattern")
    }
    
    func testProjectSettings() {
        projectManager.newProject()
        
        let settings = ProjectSettings(
            romSize: ROMBuilder.ROMSize.size32KB,
            mapperType: ROMBuilder.MapperType.mmc5,
            mirroringType: ROMBuilder.MirroringType.horizontal
        )
        
        projectManager.updateProjectSettings(settings)
        
        XCTAssertEqual(projectManager.currentProject?.settings.romSize, ROMBuilder.ROMSize.size32KB)
        XCTAssertEqual(projectManager.currentProject?.settings.mapperType, ROMBuilder.MapperType.mmc5)
        XCTAssertEqual(projectManager.currentProject?.settings.mirroringType, ROMBuilder.MirroringType.horizontal)
    }
    
    func testProjectDirtyState() {
        projectManager.newProject()
        XCTAssertFalse(projectManager.isProjectDirty)
        
        // Update patterns
        let pattern = Shared.Pattern(name: "Test Pattern")
        projectManager.updatePatterns([pattern])
        XCTAssertTrue(projectManager.isProjectDirty)
        
        // Save project
        try? projectManager.saveProjectAs(to: testFileURL)
        XCTAssertFalse(projectManager.isProjectDirty)
    }
    
    func testRecentProjects() {
        projectManager.newProject()
        
        // Add a project to recent projects
        let projectURL = FileManager.default.temporaryDirectory.appendingPathComponent("recent.mmc5")
        try? projectManager.saveProjectAs(to: projectURL)
        
        XCTAssertTrue(projectManager.recentProjects.contains(projectURL))
        
        // Clear recent projects
        projectManager.clearRecentProjects()
        XCTAssertTrue(projectManager.recentProjects.isEmpty)
        
        // Clean up
        try? FileManager.default.removeItem(at: projectURL)
    }
    
    func testProjectDataUpdates() {
        projectManager.newProject()
        
        // Update patterns
        let pattern = Shared.Pattern(name: "Test Pattern")
        projectManager.updatePatterns([pattern])
        XCTAssertEqual(projectManager.currentProject?.data.patterns.count, 1)
        XCTAssertEqual(projectManager.currentProject?.data.patterns[0].name, "Test Pattern")
        
        // Update tiles
        let tiles: [UInt8] = [1, 2, 3]
        projectManager.updateTiles(tiles)
        XCTAssertEqual(projectManager.currentProject?.data.tiles, tiles)
        
        // Update code
        let code = "test code"
        projectManager.updateCode(code)
        XCTAssertEqual(projectManager.currentProject?.data.code, code)
    }
    
    func testErrorHandling() async throws {
        projectManager.newProject()
        
        // Test opening non-existent file
        let nonExistentURL = FileManager.default.temporaryDirectory.appendingPathComponent("nonexistent.mmc5")
        await projectManager.openProject(at: nonExistentURL)
        XCTAssertNil(projectManager.currentProject)
        XCTAssertFalse(projectManager.isProjectDirty)
    }
} 