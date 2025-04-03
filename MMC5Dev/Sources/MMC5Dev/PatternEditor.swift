import SwiftUI
import Shared

@available(macOS 14.0, *)
struct PatternEditor: View {
    @Binding var patterns: [Shared.Pattern]
    @Binding var currentPattern: Int
    @Binding var currentRow: Int
    @Binding var currentChannel: Int
    
    var body: some View {
        VStack {
            Text("Pattern Editor")
                .font(.title)
            
            if currentPattern < patterns.count {
                let pattern = patterns[currentPattern]
                PatternGrid(
                    pattern: pattern,
                    currentRow: $currentRow,
                    currentChannel: $currentChannel
                )
            }
        }
    }
}

@available(macOS 14.0, *)
struct PatternGrid: View {
    let pattern: Shared.Pattern
    @Binding var currentRow: Int
    @Binding var currentChannel: Int
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<64) { row in
                PatternRow(
                    row: row,
                    pattern: pattern,
                    currentRow: $currentRow,
                    currentChannel: $currentChannel
                )
            }
        }
    }
}

@available(macOS 14.0, *)
struct PatternRow: View {
    let row: Int
    let pattern: Shared.Pattern
    @Binding var currentRow: Int
    @Binding var currentChannel: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { channel in
                PatternCell(
                    row: row,
                    channel: channel,
                    pattern: pattern,
                    currentRow: $currentRow,
                    currentChannel: $currentChannel
                )
            }
        }
    }
}

@available(macOS 14.0, *)
struct PatternCell: View {
    let row: Int
    let channel: Int
    let pattern: Shared.Pattern
    @Binding var currentRow: Int
    @Binding var currentChannel: Int
    
    var noteText: String {
        let note = pattern.notes.first { note in
            Int(note.startTime) == row && note.pitch % 5 == channel
        }
        return note?.description ?? "---"
    }
    
    var isSelected: Bool {
        row == currentRow && channel == currentChannel
    }
    
    var body: some View {
        Button {
            currentRow = row
            currentChannel = channel
        } label: {
            Text(noteText)
                .font(.system(.body, design: .monospaced))
                .frame(width: 40)
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
    }
}

@available(macOS 14.0, *)
struct PatternRowView: View {
    let row: Int
    let pattern: Shared.Pattern
    let currentRow: Int
    let currentChannel: Int
    let onSelect: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(String(format: "%02d", row))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            ForEach(0..<5) { channel in
                Button {
                    onSelect(channel)
                } label: {
                    let note = pattern.notes.first { note in
                        Int(note.startTime) == row && note.pitch % 5 == channel
                    }
                    Text(note?.description ?? "---")
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 40)
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(currentRow == row && currentChannel == channel ? Color.blue.opacity(0.2) : Color.clear)
                )
            }
        }
    }
} 