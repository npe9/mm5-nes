import SwiftUI
import Shared
import ROMBuilder

extension View {
    func debugLog(_ message: String) -> some View {
        print(message)
        return self
    }
}

struct ContentView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @State private var selectedDestination: String? = "rom_loader"
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedDestination) {
                NavigationLink(value: "rom_loader") {
                    Label("ROM Loader", systemImage: "square.and.arrow.down")
                }
                NavigationLink(value: "project_editor") {
                    Label("Project Editor", systemImage: "pencil")
                }
                NavigationLink(value: "piano_roll") {
                    Label("Piano Roll", systemImage: "music.note")
                }
                NavigationLink(value: "chr_editor") {
                    Label("CHR Editor", systemImage: "paintbrush")
                }
                NavigationLink(value: "code_editor") {
                    Label("Code Editor", systemImage: "chevron.left.forwardslash.chevron.right")
                }
            }
            .navigationTitle("MMC5 Dev")
        } detail: {
            Group {
                switch selectedDestination {
                case "rom_loader":
                    ROMLoaderView(projectManager: projectManager)
                case "project_editor":
                    Text("Project Editor")
                case "piano_roll":
                    Text("Piano Roll")
                case "chr_editor":
                    Text("CHR Editor")
                case "code_editor":
                    CodeEditorView()
                default:
                    Text("Select a tool from the sidebar")
                }
            }
            .debugLog("Building Detail View for \(selectedDestination ?? "none")")
        }
        .debugLog("Building ContentView")
        .onAppear {
            print("=== ContentView Appeared ===")
        }
    }
} 