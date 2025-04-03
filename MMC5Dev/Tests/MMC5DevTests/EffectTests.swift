import XCTest
import Shared
@testable import MMC5Dev

@MainActor
final class EffectTests: XCTestCase {
    var effect: Shared.NoteEffect!
    
    override func setUp() {
        super.setUp()
        effect = Shared.NoteEffect(type: .arpeggio, value: 1.0)
    }
    
    override func tearDown() {
        effect = nil
        super.tearDown()
    }
    
    func testEffectInitialization() {
        XCTAssertEqual(effect.type, .arpeggio)
        XCTAssertEqual(effect.value, 1.0)
    }
    
    func testEffectEquality() {
        let effect1 = Shared.NoteEffect(type: .arpeggio, value: 1.0)
        let effect2 = Shared.NoteEffect(type: .arpeggio, value: 1.0)
        let effect3 = Shared.NoteEffect(type: .vibrato, value: 1.0)
        let effect4 = Shared.NoteEffect(type: .arpeggio, value: 2.0)
        
        XCTAssertEqual(effect1, effect2)
        XCTAssertNotEqual(effect1, effect3)
        XCTAssertNotEqual(effect1, effect4)
    }
    
    func testEffectCoding() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(effect)
        
        let decoder = JSONDecoder()
        let decodedEffect = try decoder.decode(Shared.NoteEffect.self, from: data)
        
        XCTAssertEqual(decodedEffect.type, effect.type)
        XCTAssertEqual(decodedEffect.value, effect.value)
    }
    
    func testAllEffectTypes() {
        // Test initialization with all effect types
        let effectTypes: [Shared.EffectType] = [
            .arpeggio,
            .pitchBend,
            .vibrato,
            .tremolo,
            .volumeSlide,
            .noteSlide,
            .noteCut,
            .noteDelay,
            .dutyCycle
        ]
        
        for type in effectTypes {
            let effect = Shared.NoteEffect(type: type, value: 1.0)
            XCTAssertEqual(effect.type, type)
            XCTAssertEqual(effect.value, 1.0)
        }
    }
    
    func testEffectValueBounds() {
        let testCases: [(Shared.EffectType, Double, Double, Double)] = [
            (.arpeggio, 0, 15, 1),
            (.pitchBend, -12, 12, 1),
            (.vibrato, 0, 127, 1),
            (.tremolo, 0, 127, 1),
            (.volumeSlide, -127, 127, 1),
            (.noteSlide, -12, 12, 1),
            (.noteCut, 0, 96, 1),
            (.noteDelay, 0, 96, 1),
            (.dutyCycle, 0, 3, 1)
        ]
        
        for (type, min, max, step) in testCases {
            // Test minimum value
            let minEffect = Shared.NoteEffect(type: type, value: min - step)
            XCTAssertEqual(minEffect.value, min, "Effect \(type) should clamp minimum value")
            
            // Test maximum value
            let maxEffect = Shared.NoteEffect(type: type, value: max + step)
            XCTAssertEqual(maxEffect.value, max, "Effect \(type) should clamp maximum value")
        }
    }
    
    func testNoteEffectCreation() {
        let effect = Shared.NoteEffect(type: .arpeggio, value: 3)
        XCTAssertEqual(effect.type, .arpeggio)
        XCTAssertEqual(effect.value, 3)
    }
    
    func testNoteEffectEquality() {
        let effect1 = Shared.NoteEffect(type: .arpeggio, value: 3)
        let effect2 = Shared.NoteEffect(type: .arpeggio, value: 3)
        let effect3 = Shared.NoteEffect(type: .pitchBend, value: 3)
        
        XCTAssertEqual(effect1, effect2)
        XCTAssertNotEqual(effect1, effect3)
    }
    
    func testNoteEffectTypes() {
        let testCases: [(Shared.EffectType, Double)] = [
            (.arpeggio, 3),
            (.pitchBend, 2),
            (.vibrato, 1),
            (.tremolo, 4),
            (.volumeSlide, 5),
            (.noteSlide, 6),
            (.noteCut, 7),
            (.noteDelay, 8),
            (.dutyCycle, 2)
        ]
        
        for (type, value) in testCases {
            let effect = Shared.NoteEffect(type: type, value: value)
            XCTAssertEqual(effect.type, type)
            XCTAssertEqual(effect.value, type.clampValue(value))
        }
    }
} 