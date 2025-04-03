import UniformTypeIdentifiers

extension UTType {
    static let nesROM: UTType = {
        if let customType = UTType("com.mmc5dev.nes") {
            return customType
        }
        // Fallback to using the file extension
        return UTType(filenameExtension: "nes")!
    }()
} 