import SwiftUI
import Shared
import ROMBuilder

struct SpriteEditorView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @State private var tiles: [[UInt8]] = []
    @State private var selectedTileIndex: Int = 0
    
    var body: some View {
        VStack {
            if !tiles.isEmpty {
                HStack {
                    List(tiles.indices, id: \.self) { index in
                        TileView(tile: .constant(tiles[index]))
                            .frame(width: 64, height: 64)
                            .onTapGesture {
                                selectedTileIndex = index
                            }
                    }
                    .frame(width: 200)
                    
                    if selectedTileIndex < tiles.count {
                        TileEditorView(tile: Binding(
                            get: { tiles[selectedTileIndex] },
                            set: { newValue in
                                tiles[selectedTileIndex] = newValue
                                updateProjectTiles()
                            }
                        ))
                    }
                }
            } else {
                Text("No tiles")
            }
            
            HStack {
                Button("New Tile") {
                    tiles.append(Array(repeating: 0, count: 64))
                    updateProjectTiles()
                }
                
                if !tiles.isEmpty {
                    Button("Delete Tile") {
                        tiles.remove(at: selectedTileIndex)
                        selectedTileIndex = min(selectedTileIndex, tiles.count - 1)
                        updateProjectTiles()
                    }
                }
            }
        }
        .padding()
        .onAppear {
            if let project = projectManager.currentProject {
                tiles = stride(from: 0, to: project.data.tiles.count, by: 64).map {
                    Array(project.data.tiles[$0..<min($0 + 64, project.data.tiles.count)])
                }
            }
        }
    }
    
    private func updateProjectTiles() {
        let allTiles = tiles.flatMap { $0 }
        projectManager.updateTiles(allTiles)
    }
}

struct TileView: View {
    @Binding var tile: [UInt8]
    
    var body: some View {
        TileGrid(tile: tile)
    }
}

struct TileGrid: View {
    let tile: [UInt8]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8) { col in
                        let index = row * 8 + col
                        let value = index < tile.count ? tile[index] : 0
                        Rectangle()
                            .fill(colorForValue(value))
                            .frame(width: 8, height: 8)
                            .accessibilityIdentifier("pixel_\(row)_\(col)")
                    }
                }
            }
        }
    }
    
    private func colorForValue(_ value: UInt8) -> Color {
        switch value {
        case 0: return Color(white: 1.0)   // White
        case 1: return Color(white: 0.66)  // Light gray
        case 2: return Color(white: 0.33)  // Dark gray
        case 3: return Color(white: 0.0)   // Black
        default: return Color(white: 1.0)  // Default to white
        }
    }
}

struct TileEditorView: View {
    @Binding var tile: [UInt8]
    
    var body: some View {
        TileGrid(tile: tile)
            .onTapGesture { location in
                // Handle tap to edit tile
            }
    }
} 