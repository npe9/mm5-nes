import Foundation
import SwiftUI
import ROMBuilder
import AppKit
import UniformTypeIdentifiers

@MainActor
class ROMBuilderViewModel: ObservableObject {
    @Published var romSize: ROMBuilder.ROMSize = .size32KB
    @Published var mapperType: ROMBuilder.MapperType = .mmc5
    @Published var mirroringType: ROMBuilder.MirroringType = .vertical
    @Published var debugSymbols: Bool = false
    @Published var optimizationLevel: Int = 0
    
    @Published var buildProgress: Double = 0
    @Published var buildStatus: String = "Ready"
    @Published var isBuilding: Bool = false
    @Published var buildError: String?
    @Published var lastBuildURL: URL?
    
    private let romBuilder: ROMBuilderService
    private var romData: Data?
    
    init(romBuilder: ROMBuilderService = ROMBuilderService()) {
        self.romBuilder = romBuilder
    }
    
    func buildROM(config: ROMBuilder.Configuration, data: ROMBuilder.ROMData) async {
        buildProgress = 0
        buildStatus = "Building..."
        buildError = nil
        
        do {
            let data = try await ROMBuilder.buildROM(config: config, data: data)
            romData = data
            buildProgress = 1
            buildStatus = "Build complete"
            
            // Save the ROM file
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.nesROM]
            savePanel.canCreateDirectories = true
            savePanel.isExtensionHidden = false
            savePanel.title = "Save ROM"
            savePanel.message = "Choose a location to save the ROM file"
            savePanel.nameFieldLabel = "ROM Name:"
            
            let response = await savePanel.beginSheetModal(for: NSApp.mainWindow!)
            
            if response == .OK, let url = savePanel.url {
                try data.write(to: url)
                lastBuildURL = url
            }
        } catch {
            buildError = error.localizedDescription
            buildProgress = 0
            buildStatus = "Build failed"
        }
    }
    
    func openLastBuild() {
        guard let url = lastBuildURL else { return }
        NSWorkspace.shared.open(url)
    }
    
    func revealLastBuild() {
        guard let url = lastBuildURL else { return }
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }
} 