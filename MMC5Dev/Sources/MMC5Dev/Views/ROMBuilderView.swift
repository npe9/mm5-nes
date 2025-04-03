import SwiftUI
import ROMBuilder

struct ROMBuilderView: View {
    @EnvironmentObject var projectManager: ProjectManager
    @StateObject private var viewModel = ROMBuilderViewModel()
    
    var body: some View {
        VStack {
            if let project = projectManager.currentProject {
                Button("Build ROM") {
                    Task {
                        let config = ROMBuilder.Configuration(
                            romSize: project.settings.romSize,
                            mapperType: project.settings.mapperType,
                            mirroringType: project.settings.mirroringType
                        )
                        await viewModel.buildROM(config: config, data: project.data)
                    }
                }
                .disabled(viewModel.isBuilding)
                
                if viewModel.isBuilding {
                    ProgressView()
                        .frame(width: 100)
                }
                
                if let error = viewModel.buildError {
                    Text(error)
                        .foregroundColor(.red)
                }
            } else {
                Text("No project loaded")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
} 