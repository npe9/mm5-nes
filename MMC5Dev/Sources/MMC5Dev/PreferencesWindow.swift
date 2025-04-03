import SwiftUI
import ROMBuilder

@available(macOS 14.0, *)
class PreferencesWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Preferences"
        window.center()
        
        let contentView = PreferencesView()
        window.contentView = NSHostingView(rootView: contentView)
        
        self.init(window: window)
    }
}

@available(macOS 14.0, *)
struct PreferencesView: View {
    @EnvironmentObject var preferencesManager: PreferencesManager
    
    var body: some View {
        Form {
            Section(header: Text("ROM Settings")) {
                Picker("Default ROM Size", selection: $preferencesManager.defaultROMSize) {
                    ForEach(ROMBuilder.ROMSize.allCases, id: \.self) { size in
                        Text(String(describing: size)).tag(size)
                    }
                }
                
                Picker("Default Mapper Type", selection: $preferencesManager.defaultMapperType) {
                    ForEach(ROMBuilder.MapperType.allCases, id: \.self) { type in
                        Text(String(describing: type)).tag(type)
                    }
                }
                
                Picker("Default Mirroring Type", selection: $preferencesManager.defaultMirroringType) {
                    ForEach(ROMBuilder.MirroringType.allCases, id: \.self) { type in
                        Text(String(describing: type)).tag(type)
                    }
                }
            }
            
            Section(header: Text("Autosave")) {
                Stepper(value: $preferencesManager.autosaveInterval, in: 60...3600, step: 60) {
                    Text("Autosave Interval: \(Int(preferencesManager.autosaveInterval)) seconds")
                }
            }
            
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $preferencesManager.theme) {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        Text(String(describing: theme)).tag(theme)
                    }
                }
            }
        }
        .padding()
        .frame(width: 400)
    }
} 