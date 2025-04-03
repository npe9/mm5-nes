import XCTest
import Shared
@testable import MMC5Dev

@MainActor
final class PatternTests: XCTestCase {
    var pattern: Shared.Pattern!
    
    override func setUp() async throws {
        try await super.setUp()
        pattern = Shared.Pattern(name: "Test Pattern")
    }
    
    override func tearDown() async throws {
        pattern = nil
        try await super.tearDown()
    }
    
    func testPatternInitialization() {
        XCTAssertEqual(pattern.name, "Test Pattern")
        XCTAssertTrue(pattern.notes.isEmpty)
        XCTAssertTrue(pattern.animationTracks.isEmpty)
    }
    
    func testAddNote() {
        let note = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        pattern.notes.append(note)
        
        XCTAssertEqual(pattern.notes.count, 1)
        XCTAssertEqual(pattern.notes[0].pitch, 60)
        XCTAssertEqual(pattern.notes[0].startTime, 0)
        XCTAssertEqual(pattern.notes[0].duration, 1)
    }
    
    func testAddAnimationEvent() {
        let track = Shared.AnimationTrack(
            name: "Test Track",
            spriteId: UUID(),
            events: []
        )
        let event = Shared.AnimationEvent(
            startTime: 0,
            duration: 1,
            type: .spriteChange,
            parameters: ["value": 0.5]
        )
        
        pattern.animationTracks.append(track)
        var updatedTrack = track
        updatedTrack.events.append(event)
        pattern.animationTracks[0] = updatedTrack
        
        XCTAssertEqual(pattern.animationTracks.count, 1)
        XCTAssertEqual(pattern.animationTracks[0].events.count, 1)
        XCTAssertEqual(pattern.animationTracks[0].events[0].startTime, 0)
        XCTAssertEqual(pattern.animationTracks[0].events[0].duration, 1)
        XCTAssertEqual(pattern.animationTracks[0].events[0].type, .spriteChange)
        XCTAssertEqual(pattern.animationTracks[0].events[0].parameters["value"], 0.5)
    }
    
    func testRemoveNote() {
        let note = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        pattern.notes.append(note)
        pattern.notes.removeAll { $0.id == note.id }
        
        XCTAssertTrue(pattern.notes.isEmpty)
    }
    
    func testRemoveAnimationEvent() {
        let track = Shared.AnimationTrack(
            name: "Test Track",
            spriteId: UUID(),
            events: []
        )
        let event = Shared.AnimationEvent(
            startTime: 0,
            duration: 1,
            type: .spriteChange,
            parameters: ["value": 0.5]
        )
        
        pattern.animationTracks.append(track)
        var updatedTrack = track
        updatedTrack.events.append(event)
        pattern.animationTracks[0] = updatedTrack
        
        updatedTrack.events.removeAll { $0.id == event.id }
        pattern.animationTracks[0] = updatedTrack
        
        XCTAssertTrue(pattern.animationTracks[0].events.isEmpty)
    }
    
    func testPatternCoding() {
        let note = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        let track = Shared.AnimationTrack(
            name: "Test Track",
            spriteId: UUID(),
            events: []
        )
        let event = Shared.AnimationEvent(
            startTime: 0,
            duration: 1,
            type: .spriteChange,
            parameters: ["value": 0.5]
        )
        
        pattern.notes.append(note)
        pattern.animationTracks.append(track)
        var updatedTrack = track
        updatedTrack.events.append(event)
        pattern.animationTracks[0] = updatedTrack
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(pattern)
            let decodedPattern = try decoder.decode(Shared.Pattern.self, from: data)
            
            XCTAssertEqual(decodedPattern.name, pattern.name)
            XCTAssertEqual(decodedPattern.notes.count, pattern.notes.count)
            XCTAssertEqual(decodedPattern.animationTracks.count, pattern.animationTracks.count)
            
            XCTAssertEqual(decodedPattern.notes[0].pitch, note.pitch)
            XCTAssertEqual(decodedPattern.animationTracks[0].events[0].startTime, event.startTime)
            XCTAssertEqual(decodedPattern.animationTracks[0].events[0].duration, event.duration)
            XCTAssertEqual(decodedPattern.animationTracks[0].events[0].type, event.type)
            XCTAssertEqual(decodedPattern.animationTracks[0].events[0].parameters["value"], 0.5)
        } catch {
            XCTFail("Failed to encode/decode pattern: \(error)")
        }
    }
} 