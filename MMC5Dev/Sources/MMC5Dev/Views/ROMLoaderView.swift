import SwiftUI
import ROMBuilder
import UniformTypeIdentifiers

struct ROMLoaderView: View {
    @StateObject var viewModel: ROMLoaderViewModel
    @State private var isDropTargetActive = false
    
    init(projectManager: ProjectManager) {
        _viewModel = StateObject(wrappedValue: ROMLoaderViewModel(projectManager: projectManager))
    }
    
    var body: some View {
        VStack {
            if viewModel.romInfo.isEmpty {
                dropZone
            } else {
                romInfoView
            }
        }
        .padding()
    }
    
    private var dropZone: some View {
        VStack {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 48))
                .foregroundColor(.blue)
                .accessibilityIdentifier("dropZoneImage")
            
            Text("Drop NES ROM here")
                .font(.title2)
            
            Button("Choose File") {
                let panel = NSOpenPanel()
                panel.allowedContentTypes = [.nesROM]
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                
                if panel.runModal() == .OK {
                    if let url = panel.url {
                        Task {
                            await viewModel.loadROM(from: url)
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .accessibilityIdentifier("chooseFileButton")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                .foregroundColor(isDropTargetActive ? .blue : .gray)
        )
        .onDrop(of: [.nesROM], isTargeted: $isDropTargetActive) { providers in
            guard let provider = providers.first else { return false }
            
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                if let url = url {
                    Task {
                        await viewModel.loadROM(from: url)
                    }
                }
            }
            return true
        }
    }
    
    private var romInfoView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox("ROM Information") {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.romInfo, id: \.self) { info in
                            Text(info)
                                .font(.system(.body, design: .monospaced))
                                .accessibilityIdentifier(info.components(separatedBy: ":").first ?? "")
                        }
                    }
                }
                
                GroupBox("Tiles") {
                    if !viewModel.tiles.isEmpty {
                        // Test with a single tile first
                        let testTile = viewModel.tiles[0]
                        VStack {
                            Text("Tile size: \(testTile.count) bytes")
                            TileGrid(tile: testTile)
                                .frame(width: 64, height: 64)
                                .accessibilityIdentifier("TileGrid")
                        }
                    } else {
                        Text("No tiles loaded")
                    }
                }
                
                GroupBox("Code") {
                    ScrollView(.horizontal) {
                        Text(viewModel.code)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    Button("Import Code to Project") {
                        Task {
                            await viewModel.importCodeToProject()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.code.isEmpty)
                }
                
                GroupBox("Disassembly") {
                    ScrollView(.horizontal) {
                        Text(viewModel.disassembly)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .padding()
        }
    }
} 