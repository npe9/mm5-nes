import Foundation
import SwiftUI
import UniformTypeIdentifiers
import ROMBuilder
import Shared

@MainActor
class ProjectManager: ObservableObject {
    static let shared = ProjectManager()
    
    @Published private(set) var currentProject: Project?
    @Published private(set) var isProjectDirty: Bool = false
    @Published var recentProjects: [URL] = []
    
    private let defaults = UserDefaults.standard
    private let recentProjectsKey = "recentProjects"
    
    init() {
        print("=== ProjectManager Initializing ===")
        loadRecentProjects()
        print("Loaded \(recentProjects.count) recent projects")
    }
    
    // MARK: - Project Operations
    
    func newProject() {
        print("=== Creating New Project ===")
        currentProject = Project()
        isProjectDirty = false
        print("New project created successfully")
    }
    
    func openProject() async {
        print("=== Opening Project Dialog ===")
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.json]
        
        if panel.runModal() == .OK, let url = panel.url {
            print("Selected project file: \(url.path)")
            await openProject(at: url)
        } else {
            print("Project selection cancelled")
        }
    }
    
    func openProject(at url: URL) async {
        print("=== Opening Project at \(url.path) ===")
        do {
            let data = try Data(contentsOf: url)
            print("Project file size: \(data.count) bytes")
            var project = try JSONDecoder().decode(Project.self, from: data)
            project.fileURL = url
            currentProject = project
            isProjectDirty = false
            addRecentProject(url)
            print("Project loaded successfully")
        } catch {
            print("Error opening project: \(error)")
            currentProject = nil
            isProjectDirty = false
        }
    }
    
    func saveProject() throws {
        print("=== Saving Project ===")
        guard var project = currentProject else {
            print("No project to save")
            return
        }
        
        if project.fileURL == nil {
            print("No file URL set, opening save panel")
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.init(filenameExtension: "mmc5")!]
            savePanel.canCreateDirectories = true
            savePanel.isExtensionHidden = false
            savePanel.nameFieldLabel = "Project Name:"
            
            let response = savePanel.runModal()
            guard response == .OK, let url = savePanel.url else {
                print("Save cancelled")
                return
            }
            print("Selected save location: \(url.path)")
            project.fileURL = url
        }
        
        print("Saving to \(project.fileURL?.path ?? "unknown")")
        let data = try JSONEncoder().encode(project)
        try data.write(to: project.fileURL!)
        isProjectDirty = false
        addRecentProject(project.fileURL!)
        print("Project saved successfully")
    }
    
    func saveProjectAs() throws {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.init(filenameExtension: "mmc5")!]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.nameFieldLabel = "Project Name:"
        
        let response = savePanel.runModal()
        guard response == .OK, let url = savePanel.url else { return }
        try saveProjectAs(to: url)
    }
    
    func saveProjectAs(to url: URL) throws {
        guard var project = currentProject else { return }
        project.fileURL = url
        let data = try JSONEncoder().encode(project)
        try data.write(to: url)
        isProjectDirty = false
        addRecentProject(url)
    }
    
    // MARK: - Private Methods
    
    private func loadRecentProjects() {
        if let urls = defaults.array(forKey: recentProjectsKey) as? [String] {
            recentProjects = urls.compactMap { URL(string: $0) }
        }
    }
    
    private func saveRecentProjects() {
        let urls = recentProjects.map { $0.absoluteString }
        defaults.set(urls, forKey: recentProjectsKey)
    }
    
    private func addRecentProject(_ url: URL) {
        if let index = recentProjects.firstIndex(of: url) {
            recentProjects.remove(at: index)
        }
        recentProjects.insert(url, at: 0)
        if recentProjects.count > 10 {
            recentProjects.removeLast()
        }
        saveRecentProjects()
    }
    
    func updatePatterns(_ patterns: [Shared.Pattern]) {
        currentProject?.data.patterns = patterns
        isProjectDirty = true
    }
    
    func updateTiles(_ tiles: [UInt8]) {
        currentProject?.data.tiles = tiles
        isProjectDirty = true
    }
    
    func updateCode(_ code: String) {
        currentProject?.data.code = code
        isProjectDirty = true
    }
    
    func updateProjectSettings(_ settings: ProjectSettings) {
        currentProject?.settings = settings
        isProjectDirty = true
    }
    
    func clearRecentProjects() {
        recentProjects.removeAll()
        saveRecentProjects()
    }
}

// MARK: - UTType Extension

extension UTType {
    static var mmc5Project: UTType {
        UTType(exportedAs: "com.mmc5dev.project")
    }
} 