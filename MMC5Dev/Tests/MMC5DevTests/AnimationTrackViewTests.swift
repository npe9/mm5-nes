import XCTest
import SwiftUI
@testable import MMC5Dev
@testable import Shared

@MainActor
final class AnimationTrackViewTests: XCTestCase {
    var selectedTrackId: UUID?
    
    func testTrackRow() {
        let track = Shared.AnimationTrack(
            name: "Test Track",
            spriteId: UUID()
        )
        
        let row = AnimationTrackRow(
            track: track,
            isSelected: track.id == selectedTrackId,
            onSelect: { [weak self] in
                self?.selectedTrackId = track.id
            }
        )
        
        XCTAssertNotNil(row)
        row.onSelect()
        XCTAssertEqual(selectedTrackId, track.id)
    }
    
    func testEventRow() {
        let event = Shared.AnimationEvent(
            startTime: 0,
            duration: 1,
            type: .spriteChange,
            parameters: ["value": 1.0]
        )
        
        let row = AnimationEventRow(
            event: event,
            isSelected: false,
            onSelect: { },
            onEdit: { }
        )
        
        XCTAssertNotNil(row)
        XCTAssertEqual(event.type, .spriteChange)
        let value = event.parameters["value"]
        XCTAssertNotNil(value)
        XCTAssertEqual(value as Any as? Double, 1.0)
    }
    
    func testEventDialog() {
        let isPresented = Binding(get: { true }, set: { _ in })
        let event = Binding<Shared.AnimationEvent?>(
            get: { nil },
            set: { _ in }
        )
        
        let dialog = AnimationEventDialog(
            isPresented: isPresented,
            event: event,
            onSave: { _ in }
        )
        
        XCTAssertNotNil(dialog)
    }
    
    func testEventDialogWithExistingEvent() {
        var existingEvent = Shared.AnimationEvent(
            startTime: 0,
            duration: 1,
            type: .spriteChange,
            parameters: ["value": 1.0]
        )
        
        let isPresented = Binding(get: { true }, set: { _ in })
        let event = Binding<Shared.AnimationEvent?>(
            get: { existingEvent },
            set: { existingEvent = $0 ?? existingEvent }
        )
        
        let dialog = AnimationEventDialog(
            isPresented: isPresented,
            event: event,
            onSave: { _ in }
        )
        
        XCTAssertNotNil(dialog)
        XCTAssertEqual(event.wrappedValue?.type, .spriteChange)
        XCTAssertEqual(event.wrappedValue?.parameters["value"] as? Double, 1.0)
    }
}