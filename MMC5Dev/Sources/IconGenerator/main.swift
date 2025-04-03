import Foundation
import AppKit

@available(macOS 14.0, *)
struct IconGenerator {
    static func generateIcon() {
        let size = CGSize(width: 128, height: 128)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Draw background
        let gradient = NSGradient(colors: [
            NSColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0),
            NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        ])
        gradient?.draw(in: NSRect(origin: .zero, size: size), angle: 45)
        
        // Draw rounded rectangle
        let path = NSBezierPath(roundedRect: NSRect(x: 8, y: 8, width: 112, height: 112), xRadius: 12, yRadius: 12)
        path.fill()
        
        // Draw D-pad
        let dpadColor = NSColor.white.withAlphaComponent(0.8)
        dpadColor.setFill()
        
        // Vertical bars
        NSRect(x: 40, y: 32, width: 8, height: 24).fill()
        NSRect(x: 80, y: 32, width: 8, height: 24).fill()
        
        // Horizontal bars
        NSRect(x: 32, y: 40, width: 24, height: 8).fill()
        NSRect(x: 32, y: 80, width: 24, height: 8).fill()
        
        // Draw action buttons
        let redButton = NSBezierPath(ovalIn: NSRect(x: 88, y: 32, width: 12, height: 12))
        NSColor.red.withAlphaComponent(0.8).setFill()
        redButton.fill()
        
        let blueButton = NSBezierPath(ovalIn: NSRect(x: 88, y: 16, width: 12, height: 12))
        NSColor.blue.withAlphaComponent(0.8).setFill()
        blueButton.fill()
        
        // Draw text
        let text = "MMC5"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold),
            .foregroundColor: NSColor.white.withAlphaComponent(0.9)
        ]
        text.draw(at: NSPoint(x: 32, y: 88), withAttributes: attributes)
        
        image.unlockFocus()
        
        // Save the icon
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        let projectRoot = (currentPath as NSString).deletingLastPathComponent
        let iconPath = projectRoot + "/MMC5Dev/Resources/AppIcon.icns"
        
        // Create Resources directory if it doesn't exist
        let resourcesPath = (iconPath as NSString).deletingLastPathComponent
        if !fileManager.fileExists(atPath: resourcesPath) {
            do {
                try fileManager.createDirectory(atPath: resourcesPath, withIntermediateDirectories: true)
            } catch {
                print("Error creating Resources directory: \(error)")
                return
            }
        }
        
        // Create iconset directory
        let iconsetPath = (iconPath as NSString).deletingPathExtension + ".iconset"
        if fileManager.fileExists(atPath: iconsetPath) {
            try? fileManager.removeItem(atPath: iconsetPath)
        }
        try? fileManager.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)
        
        // Save different sizes
        let sizes = [16, 32, 64, 128, 256, 512]
        for size in sizes {
            let regularSize = NSSize(width: size, height: size)
            let retinaSize = NSSize(width: size * 2, height: size * 2)
            
            // Regular size
            if let resizedImage = image.resized(to: regularSize),
               let tiffData = resizedImage.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                let path = "\(iconsetPath)/icon_\(size)x\(size).png"
                try? pngData.write(to: URL(fileURLWithPath: path))
            }
            
            // Retina size
            if let resizedImage = image.resized(to: retinaSize),
               let tiffData = resizedImage.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                let path = "\(iconsetPath)/icon_\(size)x\(size)@2x.png"
                try? pngData.write(to: URL(fileURLWithPath: path))
            }
        }
        
        // Convert to ICNS
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
        process.arguments = ["-c", "icns", "-o", iconPath, iconsetPath]
        
        do {
            try process.run()
            process.waitUntilExit()
            print("Successfully created ICNS file at: \(iconPath)")
            
            // Clean up iconset directory
            try? fileManager.removeItem(atPath: iconsetPath)
        } catch {
            print("Error creating ICNS file: \(error)")
        }
    }
}

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        draw(in: NSRect(origin: .zero, size: newSize),
             from: NSRect(origin: .zero, size: size),
             operation: .copy,
             fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}

@main
struct IconGeneratorTool {
    static func main() {
        if #available(macOS 14.0, *) {
            IconGenerator.generateIcon()
        } else {
            print("This tool requires macOS 14.0 or later")
            exit(1)
        }
    }
} 