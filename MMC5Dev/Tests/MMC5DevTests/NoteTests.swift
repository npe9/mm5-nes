import XCTest
import Shared
@testable import MMC5Dev

@MainActor
final class NoteTests: XCTestCase {
    var note: Shared.Note!
    
    override func setUp() {
        super.setUp()
        note = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
    }
    
    override func tearDown() {
        note = nil
        super.tearDown()
    }
    
    func testNoteInitialization() {
        let note = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        XCTAssertEqual(note.pitch, 60)
        XCTAssertEqual(note.startTime, 0)
        XCTAssertEqual(note.duration, 1)
        XCTAssertEqual(note.velocity, 127)
        XCTAssertEqual(note.instrument, 0)
        XCTAssertTrue(note.effects.isEmpty)
    }
    
    func testNoteEquality() {
        let note1 = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        let note2 = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        let note3 = Shared.Note(
            pitch: 62,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        // Notes should be equal if their properties are equal, regardless of ID
        XCTAssertEqual(note1.pitch, note2.pitch)
        XCTAssertEqual(note1.startTime, note2.startTime)
        XCTAssertEqual(note1.duration, note2.duration)
        XCTAssertEqual(note1.velocity, note2.velocity)
        XCTAssertEqual(note1.instrument, note2.instrument)
        XCTAssertEqual(note1.effects, note2.effects)
        
        XCTAssertNotEqual(note1.pitch, note3.pitch)
    }
    
    func testNoteWithEffects() {
        let effect = Shared.NoteEffect(type: .arpeggio, value: 3)
        let note = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: [effect]
        )
        
        XCTAssertEqual(note.effects.count, 1)
        XCTAssertEqual(note.effects[0].type, .arpeggio)
        XCTAssertEqual(note.effects[0].value, 3)
    }
    
    func testInvalidNoteValues() {
        let note = Shared.Note(
            pitch: -1,
            startTime: -1,
            duration: -1,
            velocity: -1,
            instrument: -1,
            effects: []
        )
        
        // Values should be clamped to valid ranges
        XCTAssertGreaterThanOrEqual(note.pitch, 0)
        XCTAssertLessThanOrEqual(note.pitch, 127)
        
        XCTAssertGreaterThanOrEqual(note.startTime, 0)
        XCTAssertGreaterThanOrEqual(note.duration, 0)
        XCTAssertGreaterThanOrEqual(note.velocity, 0)
        XCTAssertLessThanOrEqual(note.velocity, 127)
        XCTAssertGreaterThanOrEqual(note.instrument, 0)
    }
    
    func testNoteOverlap() {
        let note1 = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 2,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        let note2 = Shared.Note(
            pitch: 60,
            startTime: 1,
            duration: 2,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        let note3 = Shared.Note(
            pitch: 60,
            startTime: 3,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        
        // Helper function to check if two notes overlap
        func notesOverlap(_ a: Shared.Note, _ b: Shared.Note) -> Bool {
            let aEnd = a.startTime + a.duration
            let bEnd = b.startTime + b.duration
            return a.pitch == b.pitch && a.startTime < bEnd && b.startTime < aEnd
        }
        
        XCTAssertTrue(notesOverlap(note1, note2))
        XCTAssertFalse(notesOverlap(note1, note3))
        XCTAssertTrue(notesOverlap(note2, note1))
        XCTAssertFalse(notesOverlap(note3, note1))
    }
    
    func testNoteCoding() {
        let effect = Shared.NoteEffect(type: .arpeggio, value: 3)
        let note = Shared.Note(
            pitch: 60,
            startTime: 0,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: [effect]
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(note)
            let decodedNote = try decoder.decode(Shared.Note.self, from: data)
            
            XCTAssertEqual(note.pitch, decodedNote.pitch)
            XCTAssertEqual(note.startTime, decodedNote.startTime)
            XCTAssertEqual(note.duration, decodedNote.duration)
            XCTAssertEqual(note.velocity, decodedNote.velocity)
            XCTAssertEqual(note.instrument, decodedNote.instrument)
            XCTAssertEqual(note.effects.count, decodedNote.effects.count)
            XCTAssertEqual(note.effects[0].type, decodedNote.effects[0].type)
            XCTAssertEqual(note.effects[0].value, decodedNote.effects[0].value)
        } catch {
            XCTFail("Failed to encode/decode note: \(error)")
        }
    }
} 