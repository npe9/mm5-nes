import XCTest

final class MMC5DevUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    func testBasicNavigation() throws {
        // Test that we can access the main menu items
        XCTAssertTrue(app.menuBars.menuBarItems["File"].exists)
        XCTAssertTrue(app.menuBars.menuBarItems["Edit"].exists)
        XCTAssertTrue(app.menuBars.menuBarItems["View"].exists)
        XCTAssertTrue(app.menuBars.menuBarItems["Window"].exists)
        XCTAssertTrue(app.menuBars.menuBarItems["Help"].exists)
    }
    
    func testPreferencesWindow() throws {
        // Open preferences
        app.menuBars.menuBarItems["MMC5Dev"].click()
        app.menuBars.menuBarItems["Preferences..."].click()
        
        // Verify preferences window appears
        let preferencesWindow = app.windows["Preferences"]
        XCTAssertTrue(preferencesWindow.exists)
        
        // Test preferences tabs
        XCTAssertTrue(preferencesWindow.tabGroups["General"].exists)
        XCTAssertTrue(preferencesWindow.tabGroups["Editor"].exists)
        XCTAssertTrue(preferencesWindow.tabGroups["Emulator"].exists)
    }
    
    func testPatternEditor() throws {
        // Create a new project
        app.menuBars.menuBarItems["File"].click()
        app.menuBars.menuBarItems["New Project"].click()
        
        // Wait for the pattern editor to appear
        let patternEditor = app.windows["Pattern Editor"]
        XCTAssertTrue(patternEditor.waitForExistence(timeout: 5))
        
        // Test basic pattern editor functionality
        let canvas = patternEditor.otherElements["CHRCanvas"]
        XCTAssertTrue(canvas.exists)
        
        // Test color palette
        let colorPalette = patternEditor.otherElements["ColorPalette"]
        XCTAssertTrue(colorPalette.exists)
    }
    
    func testPianoRoll() throws {
        // Create a new project
        app.menuBars.menuBarItems["File"].click()
        app.menuBars.menuBarItems["New Project"].click()
        
        // Wait for the piano roll to appear
        let pianoRoll = app.windows["Piano Roll"]
        XCTAssertTrue(pianoRoll.waitForExistence(timeout: 5))
        
        // Test basic piano roll functionality
        let grid = pianoRoll.otherElements["PianoRollGrid"]
        XCTAssertTrue(grid.exists)
        
        // Test note insertion
        grid.tap()
        XCTAssertTrue(pianoRoll.otherElements["Note"].exists)
    }
    
    func testAnimationTrack() throws {
        // Create a new project
        app.menuBars.menuBarItems["File"].click()
        app.menuBars.menuBarItems["New Project"].click()
        
        // Wait for the animation track to appear
        let animationTrack = app.windows["Animation Track"]
        XCTAssertTrue(animationTrack.waitForExistence(timeout: 5))
        
        // Test basic animation track functionality
        let timeline = animationTrack.otherElements["Timeline"]
        XCTAssertTrue(timeline.exists)
        
        // Test frame navigation
        let nextFrameButton = animationTrack.buttons["Next Frame"]
        XCTAssertTrue(nextFrameButton.exists)
        nextFrameButton.click()
    }
} 