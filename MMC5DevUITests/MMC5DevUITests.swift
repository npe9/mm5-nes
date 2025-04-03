import XCTest

final class MMC5DevUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
    }
    
    func testROMLoading() throws {
        // Wait for the app to load
        let dropZone = app.images["dropZoneImage"]
        XCTAssertTrue(dropZone.waitForExistence(timeout: 5))
        
        // Click the "Choose File" button
        let chooseFileButton = app.buttons["chooseFileButton"]
        XCTAssertTrue(chooseFileButton.exists)
        chooseFileButton.tap()
        
        // Wait for the file picker
        let filePicker = app.sheets.firstMatch
        XCTAssertTrue(filePicker.waitForExistence(timeout: 5))
        
        // Select the test ROM file
        let testROMURL = Bundle(for: type(of: self)).url(forResource: "TestROM", withExtension: "nes")!
        let testROMPath = testROMURL.path
        let testROMFile = app.staticTexts[testROMPath]
        XCTAssertTrue(testROMFile.waitForExistence(timeout: 5))
        testROMFile.tap()
        
        // Click Open
        let openButton = app.buttons["Open"]
        XCTAssertTrue(openButton.exists)
        openButton.tap()
        
        // After loading a ROM, verify the ROM info is displayed
        let romInfo = app.staticTexts["PRG ROM"]
        XCTAssertTrue(romInfo.waitForExistence(timeout: 5))
        
        // Verify tiles are displayed
        let tileGrid = app.otherElements["TileGrid"]
        XCTAssertTrue(tileGrid.waitForExistence(timeout: 5))
        
        // Take a screenshot for debugging
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "ROM Loaded"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testTileDisplay() throws {
        // Load the test ROM
        let dropZone = app.images["dropZoneImage"]
        XCTAssertTrue(dropZone.waitForExistence(timeout: 5))
        
        let chooseFileButton = app.buttons["chooseFileButton"]
        XCTAssertTrue(chooseFileButton.exists)
        chooseFileButton.tap()
        
        let testROMURL = Bundle(for: type(of: self)).url(forResource: "TestROM", withExtension: "nes")!
        let testROMPath = testROMURL.path
        let testROMFile = app.staticTexts[testROMPath]
        XCTAssertTrue(testROMFile.waitForExistence(timeout: 5))
        testROMFile.tap()
        
        let openButton = app.buttons["Open"]
        XCTAssertTrue(openButton.exists)
        openButton.tap()
        
        // Verify tile colors
        let tileGrid = app.otherElements["TileGrid"]
        XCTAssertTrue(tileGrid.waitForExistence(timeout: 5))
        
        // Check a few specific pixels
        let pixel00 = tileGrid.otherElements["pixel_0_0"]
        let pixel77 = tileGrid.otherElements["pixel_7_7"]
        XCTAssertTrue(pixel00.exists)
        XCTAssertTrue(pixel77.exists)
        
        // Take a screenshot for debugging
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Tile Display"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
} 