import SwiftUI
import ROMBuilder
import Shared

struct PianoRollView: View {
    @Binding var pattern: Shared.Pattern
    @State private var selectedTrack: UUID?
    @State private var selectedEvent: UUID?
    @State private var isAddingEvent = false
    @State private var isEditingEvent = false
    @State private var editingEvent: Shared.AnimationEvent?
    let onAdd: (Shared.NoteEffect) -> Void
    
    @State internal var selectedType: Shared.EffectType = .arpeggio
    @State internal var value: String = "0"
    @Environment(\.presentationMode) var presentationMode
    
    private let cellWidth: CGFloat = 40
    private let cellHeight: CGFloat = 40
    private let gridWidth: CGFloat = 1600
    private let gridHeight: CGFloat = 1600
    
    var body: some View {
        HSplitView {
            // Music editor
            VStack {
                ScrollView([.horizontal, .vertical]) {
                    ZStack {
                        PianoRollGrid()
                            .frame(width: gridWidth, height: gridHeight)
                        
                        NotesLayer(notes: pattern.notes.map { note in
                            Shared.Note(
                                pitch: note.pitch,
                                startTime: note.startTime,
                                duration: note.duration,
                                velocity: note.velocity,
                                instrument: note.instrument,
                                effects: note.effects.map { effect in
                                    Shared.NoteEffect(type: effect.type, value: effect.value)
                                }
                            )
                        }, onNoteAdd: { time, pitch in
                            addNote(time, pitch)
                        })
                        .frame(width: gridWidth, height: gridHeight)
                    }
                }
                
                HStack {
                    Picker("Effect Type", selection: $selectedType) {
                        ForEach(Shared.EffectType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Value", text: $value)
                        .frame(width: 60)
                    
                    Button("Add Effect") {
                        addEffect()
                    }
                }
                .padding()
            }
            
            // Animation editor
            VStack {
                List(pattern.animationTracks, id: \.id) { track in
                    AnimationTrackRow(
                        track: track,
                        isSelected: track.id == selectedTrack,
                        onSelect: { selectedTrack = track.id }
                    )
                }
                
                HStack {
                    Button("Add Track") {
                        let newTrack = Shared.AnimationTrack(
                            name: "Track \(pattern.animationTracks.count + 1)",
                            spriteId: UUID(),
                            events: []
                        )
                        var updatedPattern = pattern
                        updatedPattern.animationTracks.append(newTrack)
                        pattern = updatedPattern
                        selectedTrack = newTrack.id
                    }
                    
                    if selectedTrack != nil {
                        Button("Add Event") {
                            isAddingEvent = true
                        }
                    }
                }
            }
            
            // Event editor
            if let selectedTrack = selectedTrack,
               let track = pattern.animationTracks.first(where: { $0.id == selectedTrack }) {
                VStack {
                    List(track.events, id: \.id) { event in
                        AnimationEventRow(
                            event: event,
                            isSelected: event.id == selectedEvent,
                            onSelect: { selectedEvent = event.id },
                            onEdit: {
                                editingEvent = event
                                isEditingEvent = true
                            }
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingEvent) {
            AnimationEventDialog(
                isPresented: $isAddingEvent,
                event: .constant(nil),
                onSave: { event in
                    if let track = pattern.animationTracks.first(where: { $0.id == selectedTrack }) {
                        var updatedTrack = track
                        updatedTrack.events.append(event)
                        updateTrack(updatedTrack)
                    }
                    isAddingEvent = false
                }
            )
        }
        .sheet(isPresented: $isEditingEvent) {
            AnimationEventDialog(
                isPresented: $isEditingEvent,
                event: $editingEvent,
                onSave: { event in
                    if let track = pattern.animationTracks.first(where: { $0.id == selectedTrack }) {
                        var updatedTrack = track
                        if let index = updatedTrack.events.firstIndex(where: { $0.id == event.id }) {
                            updatedTrack.events[index] = event
                            updateTrack(updatedTrack)
                        }
                    }
                    isEditingEvent = false
                }
            )
        }
    }
    
    internal func updateTrack(_ track: Shared.AnimationTrack) {
        var updatedPattern = pattern
        if let index = updatedPattern.animationTracks.firstIndex(where: { $0.id == track.id }) {
            updatedPattern.animationTracks[index] = track
            pattern = updatedPattern
        }
    }
    
    internal func addEffect() {
        guard let valueDouble = Double(value) else { return }
        let effect = Shared.NoteEffect(type: selectedType, value: valueDouble)
        onAdd(effect)
    }
    
    internal func addNote(_ time: Double, _ pitch: Int) {
        let newNote = Shared.Note(
            pitch: pitch,
            startTime: time,
            duration: 1,
            velocity: 127,
            instrument: 0,
            effects: []
        )
        var updatedPattern = pattern
        updatedPattern.notes.append(newNote)
        pattern = updatedPattern
    }
}

struct PianoRollGrid: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Draw vertical lines
                for x in stride(from: 0, to: geometry.size.width, by: 40) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
                
                // Draw horizontal lines
                for y in stride(from: 0, to: geometry.size.height, by: 40) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        }
    }
}

struct NotesLayer: View {
    let notes: [Shared.Note]
    let onNoteAdd: (Double, Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(notes, id: \.id) { note in
                    NoteView(note: note)
                }
                
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let x = value.location.x
                                let y = value.location.y
                                let time = floor(x / 40)
                                let pitch = floor(y / 40)
                                onNoteAdd(time, Int(pitch))
                            }
                    )
            }
        }
    }
}

struct NoteView: View {
    let note: Shared.Note
    
    var body: some View {
        Rectangle()
            .fill(Color.blue.opacity(0.8))
            .frame(width: CGFloat(note.duration) * 40 - 4, height: 36)
            .position(
                x: CGFloat(note.startTime) * 40 + (CGFloat(note.duration) * 40) / 2,
                y: CGFloat(note.pitch) * 40 + 20
            )
    }
}

struct AnimationTrackRow: View {
    let track: Shared.AnimationTrack
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            Text(track.name)
            Spacer()
            Text("\(track.events.count) events")
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .onTapGesture(perform: onSelect)
    }
}

struct AnimationEventRow: View {
    let event: Shared.AnimationEvent
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.type.rawValue)
                Text("Start: \(String(format: "%.2f", event.startTime)) Duration: \(String(format: "%.2f", event.duration))")
                    .font(.caption)
            }
            Spacer()
            Button("Edit", action: onEdit)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .onTapGesture(perform: onSelect)
    }
}

struct EffectsLayer: View {
    let effects: [Shared.NoteEffect]
    
    var body: some View {
        ZStack {
            ForEach(0..<effects.count, id: \.self) { index in
                EffectView(effect: effects[index])
            }
        }
    }
}

struct EffectView: View {
    let effect: Shared.NoteEffect
    
    var body: some View {
        Circle()
            .fill(effectColor(for: effect))
            .frame(width: 8, height: 8)
            .position(
                x: CGFloat(0) * 40 + 20,
                y: CGFloat(effect.value) * 40 + 20
            )
    }
    
    private func effectColor(for effect: Shared.NoteEffect) -> Color {
        switch effect.type {
        case .arpeggio:
            return .blue
        case .pitchBend:
            return .green
        case .vibrato:
            return .red
        case .tremolo:
            return .orange
        case .volumeSlide:
            return .purple
        case .noteSlide:
            return .yellow
        case .noteCut:
            return .black
        case .noteDelay:
            return .gray
        case .dutyCycle:
            return .cyan
        }
    }
} 