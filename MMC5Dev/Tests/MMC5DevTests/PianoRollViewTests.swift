import XCTest
import SwiftUI
@testable import MMC5Dev
@testable import Shared

@MainActor
final class PianoRollViewTests: XCTestCase {
    var pattern: Shared.Pattern!
    var patternBinding: Binding<Shared.Pattern>!
    var pianoRollView: PianoRollView!
    var addedEffects: [Shared.NoteEffect] = []
    
    override func setUp() async throws {
        try await super.setUp()
        pattern = Shared.Pattern(name: "Test Pattern")
        patternBinding = Binding(
            get: { self.pattern },
            set: { self.pattern = $0 }
        )
        pianoRollView = PianoRollView(
            pattern: patternBinding,
            onAdd: { effect in
                self.addedEffects.append(effect)
            }
        )
    }
    
    override func tearDown() async throws {
        pattern = nil
        patternBinding = nil
        pianoRollView = nil
        addedEffects = []
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(pattern.name, "Test Pattern")
        XCTAssertTrue(pattern.notes.isEmpty)
        XCTAssertTrue(pattern.animationTracks.isEmpty)
        XCTAssertEqual(pianoRollView.selectedType, .arpeggio)
        XCTAssertEqual(pianoRollView.value, "0")
    }
    
    func testAddNote() {
        // Initial state
        XCTAssertEqual(pattern.notes.count, 0)
        
        // Add a note
        pianoRollView.addNote(0, 60)
        
        // Verify note was added
        XCTAssertEqual(pattern.notes.count, 1)
        let note = pattern.notes[0]
        XCTAssertEqual(note.pitch, 60)
        XCTAssertEqual(note.startTime, 0)
        XCTAssertEqual(note.duration, 1)
        XCTAssertEqual(note.velocity, 127)
    }
    
    func testAddEffect() {
        // Add an effect with a value within bounds
        let effect = Shared.NoteEffect(type: .arpeggio, value: 10.0)
        pianoRollView.onAdd(effect)
        
        // Verify effect was added
        XCTAssertEqual(addedEffects.count, 1)
        let addedEffect = addedEffects[0]
        XCTAssertEqual(addedEffect.type, .arpeggio)
        XCTAssertEqual(addedEffect.value, 10.0)
    }
    
    func testAddEffectWithInvalidValue() {
        // Add an effect with invalid value
        let effect = Shared.NoteEffect(type: .arpeggio, value: 0.0)
        pianoRollView.onAdd(effect)
        
        // Verify effect was added with clamped value
        XCTAssertEqual(addedEffects.count, 1)
        let addedEffect = addedEffects[0]
        XCTAssertEqual(addedEffect.type, .arpeggio)
        XCTAssertEqual(addedEffect.value, 0.0)
    }
    
    func testAddEffectWithClampedValue() {
        // Add an effect with a value that should be clamped
        let effect = Shared.NoteEffect(type: .arpeggio, value: 20.0)
        pianoRollView.onAdd(effect)
        
        // Verify effect was added with clamped value
        XCTAssertEqual(addedEffects.count, 1)
        let addedEffect = addedEffects[0]
        XCTAssertEqual(addedEffect.type, .arpeggio)
        XCTAssertEqual(addedEffect.value, 15.0)
    }
    
    func testMultipleNotes() {
        // Add notes at different positions
        pianoRollView.addNote(0, 60)
        pianoRollView.addNote(1, 62)
        pianoRollView.addNote(2, 64)
        
        // Verify notes were added
        XCTAssertEqual(pattern.notes.count, 3)
        XCTAssertEqual(pattern.notes[0].pitch, 60)
        XCTAssertEqual(pattern.notes[1].pitch, 62)
        XCTAssertEqual(pattern.notes[2].pitch, 64)
    }
    
    func testNoteWithEffects() {
        // Add a note
        pianoRollView.addNote(0, 60)
        
        // Add multiple effects
        let effect1 = Shared.NoteEffect(type: .arpeggio, value: 10.0)
        let effect2 = Shared.NoteEffect(type: .vibrato, value: 20.0)
        pianoRollView.onAdd(effect1)
        pianoRollView.onAdd(effect2)
        
        // Verify effects were added
        XCTAssertEqual(addedEffects.count, 2)
        XCTAssertEqual(addedEffects[0].type, .arpeggio)
        XCTAssertEqual(addedEffects[0].value, 10.0)
        XCTAssertEqual(addedEffects[1].type, .vibrato)
        XCTAssertEqual(addedEffects[1].value, 20.0)
    }
    
    func testNoteBounds() {
        // Test adding notes at boundaries
        pianoRollView.addNote(0, 0)  // Lowest pitch
        pianoRollView.addNote(1, 127)  // Highest pitch
        
        XCTAssertEqual(pattern.notes.count, 2)
        XCTAssertEqual(pattern.notes[0].pitch, 0)
        XCTAssertEqual(pattern.notes[1].pitch, 127)
    }
    
    func testEffectTypeSelection() {
        // Test selecting different effect types
        let effectTypes: [EffectType] = [.pitchBend, .vibrato, .tremolo, .volumeSlide, .noteSlide, .noteCut, .noteDelay, .dutyCycle]
        
        for effectType in effectTypes {
            let effect = Shared.NoteEffect(type: effectType, value: 10.0)
            pianoRollView.onAdd(effect)
            XCTAssertEqual(addedEffects.last?.type, effectType)
        }
    }
    
    func testEffectValueInput() {
        // Test setting valid value
        let effect = Shared.NoteEffect(type: .arpeggio, value: 5.0)
        pianoRollView.onAdd(effect)
        XCTAssertEqual(addedEffects.last?.value, 5.0)
        
        // Test setting invalid value
        let invalidEffect = Shared.NoteEffect(type: .arpeggio, value: 0.0)
        pianoRollView.onAdd(invalidEffect)
        XCTAssertEqual(addedEffects.last?.value, 0.0)
    }
} 