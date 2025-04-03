import SwiftUI
import ROMBuilder

struct CodeEditorView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @State private var code: String = ""
    
    var body: some View {
        TextEditor(text: $code)
            .font(.system(.body, design: .monospaced))
            .onAppear {
                code = projectManager.currentProject?.data.code ?? ""
            }
            .onChange(of: projectManager.currentProject) { _, project in
                code = project?.data.code ?? ""
            }
            .onChange(of: code) { _, newCode in
                projectManager.updateCode(newCode)
            }
    }
} 