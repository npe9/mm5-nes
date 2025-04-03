import SwiftUI
import Shared
import ROMBuilder
import AppKit

@main
struct MMC5DevApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var projectManager = ProjectManager.shared
    @StateObject private var preferencesManager = PreferencesManager.shared
    
    init() {
        print("=== MMC5DevApp Initializing ===")
        if #available(macOS 14.0, *) {
            print("Generating app icon...")
            AppIcon.saveAsImage()
        }
        
        // Check if we're in UI testing mode
        if CommandLine.arguments.contains("-UITesting") {
            print("Running in UI testing mode")
            // Disable animations for UI tests
            NSAnimationContext.current.duration = 0
        }
    }
    
    var body: some Scene {
        print("=== Building Main Scene ===")
        return WindowGroup {
            ContentView()
                .environmentObject(projectManager)
                .environmentObject(preferencesManager)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("New") {
                            print("Creating new project")
                            projectManager.newProject()
                        }
                        .accessibilityIdentifier("newProjectButton")
                        
                        Button("Open") {
                            print("Opening project dialog")
                            Task {
                                await projectManager.openProject()
                            }
                        }
                        .accessibilityIdentifier("openProjectButton")
                        
                        Button("Save") {
                            print("Saving project")
                            do {
                                try projectManager.saveProject()
                            } catch {
                                print("Error saving project: \(error)")
                            }
                        }
                        .accessibilityIdentifier("saveProjectButton")
                        
                        Button("Save As...") {
                            print("Opening save as dialog")
                            do {
                                try projectManager.saveProjectAs()
                            } catch {
                                print("Error saving project: \(error)")
                            }
                        }
                        .accessibilityIdentifier("saveAsProjectButton")
                    }
                }
                .onAppear {
                    print("=== ContentView Appeared ===")
                    print("Creating initial project")
                    projectManager.newProject()
                }
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Project") {
                    print("Creating new project (menu)")
                    projectManager.newProject()
                }
                .accessibilityIdentifier("newProjectMenuItem")
                
                Button("Open Project...") {
                    print("Opening project dialog (menu)")
                    Task {
                        await projectManager.openProject()
                    }
                }
                .accessibilityIdentifier("openProjectMenuItem")
                
                Button("Save Project") {
                    print("Saving project (menu)")
                    do {
                        try projectManager.saveProject()
                    } catch {
                        print("Error saving project: \(error)")
                    }
                }
                .accessibilityIdentifier("saveProjectMenuItem")
                
                Button("Save Project As...") {
                    print("Opening save as dialog (menu)")
                    do {
                        try projectManager.saveProjectAs()
                    } catch {
                        print("Error saving project: \(error)")
                    }
                }
                .accessibilityIdentifier("saveAsProjectMenuItem")
            }
        }
    }
} 