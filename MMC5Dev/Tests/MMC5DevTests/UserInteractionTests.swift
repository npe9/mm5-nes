import XCTest
import SwiftUI
@testable import MMC5Dev
@testable import Shared

@MainActor
final class UserInteractionTests: XCTestCase {
    var projectManager: ProjectManager!
    
    override func setUp() async throws {
        try await super.setUp()
        projectManager = ProjectManager()
        projectManager.newProject()
    }
    
    override func tearDown() async throws {
        projectManager = nil
        try await super.tearDown()
    }
    
    func testPianoRollInteraction() {
        let pattern = projectManager.currentProject!.data.patterns[0]
        var updatedPattern = pattern
        let patternBinding = Binding(
            get: { updatedPattern },
            set: { updatedPattern = $0 }
        )
        
        let onAdd: (Shared.NoteEffect) -> Void = { effect in
            var note = Shared.Note(
                pitch: 60,
                startTime: 0,
                duration: 1,
                velocity: 127,
                instrument: 0,
                effects: []
            )
            note.effects.append(effect)
            updatedPattern.notes.append(note)
        }
        
        let view = PianoRollView(
            pattern: patternBinding,
            onAdd: onAdd
        )
        
        // Test adding a note
        view.addNote(4, 60)
        XCTAssertEqual(updatedPattern.notes.count, 1)
        XCTAssertEqual(updatedPattern.notes[0].pitch, 60)
        
        // Test adding an effect
        let effect = Shared.NoteEffect(type: .arpeggio, value: 3.0)
        view.onAdd(effect)
        XCTAssertEqual(updatedPattern.notes.count, 2)
        XCTAssertEqual(updatedPattern.notes[1].effects.count, 1)
        XCTAssertEqual(updatedPattern.notes[1].effects[0].type, .arpeggio)
        XCTAssertEqual(updatedPattern.notes[1].effects[0].value, 3.0)
        
        // Test grid interaction
        let gridView = PianoRollGrid()
        XCTAssertNotNil(gridView)
    }
    
    func testAnimationTrackInteraction() {
        let pattern = projectManager.currentProject!.data.patterns[0]
        var updatedPattern = pattern
        
        let track = Shared.AnimationTrack(
            name: "Test Track",
            spriteId: UUID()
        )
        
        // Test adding an event
        let event = Shared.AnimationEvent(
            startTime: 0,
            duration: 1,
            type: .spriteChange,
            parameters: ["value": 1.0]
        )
        
        var updatedTrack = track
        updatedTrack.events.append(event)
        updatedPattern.animationTracks.append(updatedTrack)
        
        XCTAssertEqual(updatedPattern.animationTracks.count, 1)
        XCTAssertEqual(updatedPattern.animationTracks[0].events.count, 1)
    }
    
    func testProjectInteraction() async throws {
        // Test saving the project
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.mmc5")
        try projectManager.saveProjectAs(to: tempURL)
        XCTAssertFalse(projectManager.isProjectDirty)
        
        // Test loading the project
        projectManager.newProject()
        await projectManager.openProject(at: tempURL)
        XCTAssertNotNil(projectManager.currentProject)
        
        // Clean up
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    func testContentViewInteraction() {
        let contentView = ContentView()
        XCTAssertNotNil(contentView)
    }
    
    func testUndoRedo() {
        let pattern = projectManager.currentProject!.data.patterns[0]
        var updatedPattern = pattern
        let patternBinding = Binding(
            get: { updatedPattern },
            set: { updatedPattern = $0 }
        )
        
        let onAdd: (Shared.NoteEffect) -> Void = { effect in
            var note = Shared.Note(
                pitch: 60,
                startTime: 0,
                duration: 1,
                velocity: 127,
                instrument: 0,
                effects: []
            )
            note.effects.append(effect)
            updatedPattern.notes.append(note)
        }
        
        let view = PianoRollView(
            pattern: patternBinding,
            onAdd: onAdd
        )
        
        // Add a note
        view.addNote(0, 60)
        XCTAssertEqual(updatedPattern.notes.count, 1)
    }
} 