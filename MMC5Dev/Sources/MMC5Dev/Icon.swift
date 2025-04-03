import SwiftUI
import AppKit

struct AppIcon: View {
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [Color(red: 0.2, green: 0.2, blue: 0.3),
                            Color(red: 0.1, green: 0.1, blue: 0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            // NES controller symbol
            VStack(spacing: 4) {
                // D-pad
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 8, height: 24)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 24, height: 8)
                        Rectangle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 24, height: 8)
                    }
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 8, height: 24)
                        .rotationEffect(.degrees(90))
                }
                
                // Action buttons
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(12)
            
            // Code symbol overlay
            Text("MMC5")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 40)
        }
        .frame(width: 128, height: 128)
    }
}

extension AppIcon {
    @available(macOS 14.0, *)
    static func saveAsImage() {
        print("=== Generating App Icons ===")
        let sizes = [16, 32, 64, 128, 256, 512, 1024]
        
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        let projectRoot = (currentPath as NSString).deletingLastPathComponent
        let iconsetPath = projectRoot + "/MMC5Dev/Resources/AppIcon.iconset"
        
        // Create iconset directory if it doesn't exist
        if !fileManager.fileExists(atPath: iconsetPath) {
            do {
                try fileManager.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)
                print("Created iconset directory at: \(iconsetPath)")
            } catch {
                print("Error creating iconset directory: \(error)")
                return
            }
        }
        
        // Generate icons for each size
        for size in sizes {
            let icon = AppIcon()
            let renderer = ImageRenderer(content: icon)
            renderer.scale = CGFloat(size) / 128.0 * 2.0 // Retina scale
            
            if let nsImage = renderer.nsImage {
                // Save 1x version
                let filename = size == 1024 ? "icon_512x512@2x.png" : "icon_\(size)x\(size).png"
                let path = (iconsetPath as NSString).appendingPathComponent(filename)
                
                if let tiffData = nsImage.tiffRepresentation,
                   let bitmapImage = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                    do {
                        try pngData.write(to: URL(fileURLWithPath: path))
                        print("Saved \(filename)")
                    } catch {
                        print("Error saving \(filename): \(error)")
                    }
                }
                
                // Save 2x version (except for 1024)
                if size < 512 {
                    let filename2x = "icon_\(size)x\(size)@2x.png"
                    let path2x = (iconsetPath as NSString).appendingPathComponent(filename2x)
                    
                    renderer.scale = CGFloat(size) / 128.0 * 4.0 // 2x Retina scale
                    if let nsImage2x = renderer.nsImage,
                       let tiffData = nsImage2x.tiffRepresentation,
                       let bitmapImage = NSBitmapImageRep(data: tiffData),
                       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                        do {
                            try pngData.write(to: URL(fileURLWithPath: path2x))
                            print("Saved \(filename2x)")
                        } catch {
                            print("Error saving \(filename2x): \(error)")
                        }
                    }
                }
            }
        }
        
        // Convert to icns
        let icnsPath = projectRoot + "/MMC5Dev/Resources/AppIcon.icns"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
        process.arguments = ["-c", "icns", "-o", icnsPath, iconsetPath]
        
        do {
            try process.run()
            process.waitUntilExit()
            print("Successfully created ICNS file at: \(icnsPath)")
        } catch {
            print("Error creating ICNS file: \(error)")
        }
    }
}

#Preview {
    AppIcon()
        .frame(width: 128, height: 128)
        .background(Color.black.opacity(0.1))
} 