import AppKit
import SwiftUI
import Shared

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var romLoaderViewModel: ROMLoaderViewModel?
    let projectManager = ProjectManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("=== Application Did Finish Launching ===")
        
        let contentView = ContentView()
            .environmentObject(projectManager)
            .environmentObject(PreferencesManager.shared)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.title = "MMC5 Dev"
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        self.window = window
        print("=== Window Created and Shown ===")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("=== Application Will Terminate ===")
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}