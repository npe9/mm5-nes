import Foundation
import Shared

public enum ROMSize: String, Codable, Equatable {
    case size16KB = "16KB"
    case size32KB = "32KB"
    case size64KB = "64KB"
    case size128KB = "128KB"
    case size256KB = "256KB"
    case size512KB = "512KB"
}

public enum MapperType: String, Codable, Equatable {
    case nrom = "NROM"
    case mmc1 = "MMC1"
    case mmc3 = "MMC3"
    case mmc5 = "MMC5"
}

public enum MirroringType: String, Codable, Equatable {
    case horizontal = "Horizontal"
    case vertical = "Vertical"
    case fourScreen = "Four Screen"
    case singleScreen = "Single Screen"
}

public typealias Pattern = Shared.Pattern