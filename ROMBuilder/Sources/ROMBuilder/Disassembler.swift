import Foundation

public enum DisassemblerError: Error {
    case invalidOpcode
    case invalidAddress
    case invalidData
}

public struct Instruction {
    public let address: Int
    public let opcode: UInt8
    public let mnemonic: String
    public let operand: String?
    
    public init(address: Int, opcode: UInt8, mnemonic: String, operand: String?) {
        self.address = address
        self.opcode = opcode
        self.mnemonic = mnemonic
        self.operand = operand
    }
}

public class Disassembler {
    private let prgROM: [UInt8]
    private var currentAddress: UInt16 = 0x8000 // NES PRG ROM starts at $8000
    private var instructions: [Instruction] = []
    
    // 6502 instruction set
    private let opcodes: [UInt8: (String, String)] = [
        0x00: ("BRK", "IMPL"),
        0x01: ("ORA", "INDX"),
        0x05: ("ORA", "ZP"),
        0x06: ("ASL", "ZP"),
        0x08: ("PHP", "IMPL"),
        0x09: ("ORA", "IMM"),
        0x0A: ("ASL", "IMPL"),
        0x0D: ("ORA", "ABS"),
        0x0E: ("ASL", "ABS"),
        0x10: ("BPL", "REL"),
        0x11: ("ORA", "INDY"),
        0x15: ("ORA", "ZPX"),
        0x16: ("ASL", "ZPX"),
        0x18: ("CLC", "IMPL"),
        0x19: ("ORA", "ABSY"),
        0x1D: ("ORA", "ABSX"),
        0x1E: ("ASL", "ABSX"),
        0x20: ("JSR", "ABS"),
        0x21: ("AND", "INDX"),
        0x24: ("BIT", "ZP"),
        0x25: ("AND", "ZP"),
        0x26: ("ROL", "ZP"),
        0x28: ("PLP", "IMPL"),
        0x29: ("AND", "IMM"),
        0x2A: ("ROL", "IMPL"),
        0x2C: ("BIT", "ABS"),
        0x2D: ("AND", "ABS"),
        0x2E: ("ROL", "ABS"),
        0x30: ("BMI", "REL"),
        0x31: ("AND", "INDY"),
        0x35: ("AND", "ZPX"),
        0x36: ("ROL", "ZPX"),
        0x38: ("SEC", "IMPL"),
        0x39: ("AND", "ABSY"),
        0x3D: ("AND", "ABSX"),
        0x3E: ("ROL", "ABSX"),
        0x40: ("RTI", "IMPL"),
        0x41: ("EOR", "INDX"),
        0x45: ("EOR", "ZP"),
        0x46: ("LSR", "ZP"),
        0x48: ("PHA", "IMPL"),
        0x49: ("EOR", "IMM"),
        0x4A: ("LSR", "IMPL"),
        0x4C: ("JMP", "ABS"),
        0x4D: ("EOR", "ABS"),
        0x4E: ("LSR", "ABS"),
        0x50: ("BVC", "REL"),
        0x51: ("EOR", "INDY"),
        0x55: ("EOR", "ZPX"),
        0x56: ("LSR", "ZPX"),
        0x58: ("CLI", "IMPL"),
        0x59: ("EOR", "ABSY"),
        0x5D: ("EOR", "ABSX"),
        0x5E: ("LSR", "ABSX"),
        0x60: ("RTS", "IMPL"),
        0x61: ("ADC", "INDX"),
        0x65: ("ADC", "ZP"),
        0x66: ("ROR", "ZP"),
        0x68: ("PLA", "IMPL"),
        0x69: ("ADC", "IMM"),
        0x6A: ("ROR", "IMPL"),
        0x6C: ("JMP", "IND"),
        0x6D: ("ADC", "ABS"),
        0x6E: ("ROR", "ABS"),
        0x70: ("BVS", "REL"),
        0x71: ("ADC", "INDY"),
        0x75: ("ADC", "ZPX"),
        0x76: ("ROR", "ZPX"),
        0x78: ("SEI", "IMPL"),
        0x79: ("ADC", "ABSY"),
        0x7D: ("ADC", "ABSX"),
        0x7E: ("ROR", "ABSX"),
        0x81: ("STA", "INDX"),
        0x84: ("STY", "ZP"),
        0x85: ("STA", "ZP"),
        0x86: ("STX", "ZP"),
        0x88: ("DEY", "IMPL"),
        0x8A: ("TXA", "IMPL"),
        0x8C: ("STY", "ABS"),
        0x8D: ("STA", "ABS"),
        0x8E: ("STX", "ABS"),
        0x90: ("BCC", "REL"),
        0x91: ("STA", "INDY"),
        0x94: ("STY", "ZPX"),
        0x95: ("STA", "ZPX"),
        0x96: ("STX", "ZPY"),
        0x98: ("TYA", "IMPL"),
        0x99: ("STA", "ABSY"),
        0x9A: ("TXS", "IMPL"),
        0x9D: ("STA", "ABSX"),
        0xA0: ("LDY", "IMM"),
        0xA1: ("LDA", "INDX"),
        0xA2: ("LDX", "IMM"),
        0xA4: ("LDY", "ZP"),
        0xA5: ("LDA", "ZP"),
        0xA6: ("LDX", "ZP"),
        0xA8: ("TAY", "IMPL"),
        0xA9: ("LDA", "IMM"),
        0xAA: ("TAX", "IMPL"),
        0xAC: ("LDY", "ABS"),
        0xAD: ("LDA", "ABS"),
        0xAE: ("LDX", "ABS"),
        0xB0: ("BCS", "REL"),
        0xB1: ("LDA", "INDY"),
        0xB4: ("LDY", "ZPX"),
        0xB5: ("LDA", "ZPX"),
        0xB6: ("LDX", "ZPY"),
        0xB8: ("CLV", "IMPL"),
        0xB9: ("LDA", "ABSY"),
        0xBA: ("TSX", "IMPL"),
        0xBC: ("LDY", "ABSX"),
        0xBD: ("LDA", "ABSX"),
        0xBE: ("LDX", "ABSY"),
        0xC0: ("CPY", "IMM"),
        0xC1: ("CMP", "INDX"),
        0xC4: ("CPY", "ZP"),
        0xC5: ("CMP", "ZP"),
        0xC6: ("DEC", "ZP"),
        0xC8: ("INY", "IMPL"),
        0xC9: ("CMP", "IMM"),
        0xCA: ("DEX", "IMPL"),
        0xCC: ("CPY", "ABS"),
        0xCD: ("CMP", "ABS"),
        0xCE: ("DEC", "ABS"),
        0xD0: ("BNE", "REL"),
        0xD1: ("CMP", "INDY"),
        0xD5: ("CMP", "ZPX"),
        0xD6: ("DEC", "ZPX"),
        0xD8: ("CLD", "IMPL"),
        0xD9: ("CMP", "ABSY"),
        0xDD: ("CMP", "ABSX"),
        0xDE: ("DEC", "ABSX"),
        0xE0: ("CPX", "IMM"),
        0xE1: ("SBC", "INDX"),
        0xE4: ("CPX", "ZP"),
        0xE5: ("SBC", "ZP"),
        0xE6: ("INC", "ZP"),
        0xE8: ("INX", "IMPL"),
        0xE9: ("SBC", "IMM"),
        0xEA: ("NOP", "IMPL"),
        0xEC: ("CPX", "ABS"),
        0xED: ("SBC", "ABS"),
        0xEE: ("INC", "ABS"),
        0xF0: ("BEQ", "REL"),
        0xF1: ("SBC", "INDY"),
        0xF5: ("SBC", "ZPX"),
        0xF6: ("INC", "ZPX"),
        0xF8: ("SED", "IMPL"),
        0xF9: ("SBC", "ABSY"),
        0xFD: ("SBC", "ABSX"),
        0xFE: ("INC", "ABSX")
    ]
    
    public init(prgROM: [UInt8]) {
        self.prgROM = prgROM
    }
    
    private func formatOperand(format: String, index: Int) -> (String?, Int) {
        let prgROMSize = prgROM.count
        
        func getOperandByte(at offset: Int) -> UInt8? {
            let adjustedOffset = if prgROMSize == 16384 {
                offset % 16384
            } else {
                offset
            }
            guard adjustedOffset < prgROM.count else {
                print("Invalid operand byte access at offset \(offset) (adjusted: \(adjustedOffset))")
                return nil
            }
            return prgROM[adjustedOffset]
        }
        
        switch format {
        case "IMPL":
            return (nil, 0)
            
        case "IMM":
            guard let byte = getOperandByte(at: index + 1) else {
                print("Failed to get immediate operand at index \(index + 1)")
                return ("??", 1)
            }
            return ("#$\(String(format: "%02X", byte))", 1)
            
        case "ZP":
            guard let byte = getOperandByte(at: index + 1) else {
                print("Failed to get zero page operand at index \(index + 1)")
                return ("??", 1)
            }
            return ("$\(String(format: "%02X", byte))", 1)
            
        case "ZPX":
            guard let byte = getOperandByte(at: index + 1) else {
                print("Failed to get zero page X operand at index \(index + 1)")
                return ("??", 1)
            }
            return ("$\(String(format: "%02X", byte)),X", 1)
            
        case "ZPY":
            guard let byte = getOperandByte(at: index + 1) else {
                print("Failed to get zero page Y operand at index \(index + 1)")
                return ("??", 1)
            }
            return ("$\(String(format: "%02X", byte)),Y", 1)
            
        case "ABS":
            guard let lowByte = getOperandByte(at: index + 1),
                  let highByte = getOperandByte(at: index + 2) else {
                print("Failed to get absolute operand at index \(index + 1)")
                return ("????", 2)
            }
            return ("$\(String(format: "%04X", UInt16(highByte) << 8 | UInt16(lowByte)))", 2)
            
        case "ABSX":
            guard let lowByte = getOperandByte(at: index + 1),
                  let highByte = getOperandByte(at: index + 2) else {
                print("Failed to get absolute X operand at index \(index + 1)")
                return ("????", 2)
            }
            return ("$\(String(format: "%04X", UInt16(highByte) << 8 | UInt16(lowByte))),X", 2)
            
        case "ABSY":
            guard let lowByte = getOperandByte(at: index + 1),
                  let highByte = getOperandByte(at: index + 2) else {
                print("Failed to get absolute Y operand at index \(index + 1)")
                return ("????", 2)
            }
            return ("$\(String(format: "%04X", UInt16(highByte) << 8 | UInt16(lowByte))),Y", 2)
            
        case "INDX":
            guard let byte = getOperandByte(at: index + 1) else {
                print("Failed to get indirect X operand at index \(index + 1)")
                return ("??", 1)
            }
            return ("($\(String(format: "%02X", byte)),X)", 1)
            
        case "INDY":
            guard let byte = getOperandByte(at: index + 1) else {
                print("Failed to get indirect Y operand at index \(index + 1)")
                return ("??", 1)
            }
            return ("($\(String(format: "%02X", byte))),Y", 1)
            
        case "IND":
            guard let lowByte = getOperandByte(at: index + 1),
                  let highByte = getOperandByte(at: index + 2) else {
                print("Failed to get indirect operand at index \(index + 1)")
                return ("????", 2)
            }
            return ("($\(String(format: "%04X", UInt16(highByte) << 8 | UInt16(lowByte))))", 2)
            
        case "REL":
            guard let byte = getOperandByte(at: index + 1) else {
                print("Failed to get relative operand at index \(index + 1)")
                return ("??", 1)
            }
            let offset = Int8(bitPattern: byte)
            let currentAddress = UInt16(0x8000 + index)
            let nextAddress = currentAddress &+ 2
            let targetAddress = UInt16(Int(nextAddress) + Int(offset))
            
            // For 16KB ROM, handle bank crossing
            let currentBank = currentAddress / 16384
            let targetBank = targetAddress / 16384
            
            if prgROMSize == 16384 && currentBank != targetBank {
                print("Branch crosses bank boundary at address \(String(format: "$%04X", currentAddress))")
                // Mirror the target address back to the first bank
                let mirroredTarget = targetAddress % 16384 + 0x8000
                return ("$\(String(format: "%04X", mirroredTarget))", 1)
            }
            
            return ("$\(String(format: "%04X", targetAddress))", 1)
            
        default:
            print("Unknown operand format: \(format)")
            return (nil, 0)
        }
    }
    
    public func disassemble() throws -> [Instruction] {
        var instructions: [Instruction] = []
        var index = 0
        let prgROMBase = 0x8000  // NES PRG ROM starts at $8000
        let prgROMSize = prgROM.count
        
        print("Starting disassembly of \(prgROMSize) bytes")
        
        while index < prgROMSize {
            let currentAddress = prgROMBase + index
            
            // For 16KB PRG ROM, we need to handle mirroring
            let prgROMIndex = if prgROMSize == 16384 {
                // If we're in the second bank ($C000-$FFFF), mirror back to the first bank
                index % 16384
            } else {
                index
            }
            
            guard prgROMIndex < prgROM.count else {
                print("Index \(prgROMIndex) exceeds ROM size \(prgROM.count)")
                break
            }
            
            let opcode = prgROM[prgROMIndex]
            
            // Get the instruction info from our opcode map
            guard let (mnemonic, operandFormat) = opcodes[opcode] else {
                print("Unknown opcode \(String(format: "%02X", opcode)) at address \(String(format: "$%04X", currentAddress))")
                // Skip this byte and continue
                index += 1
                continue
            }
            
            // Check if we have enough bytes for the operand before trying to format it
            let (operandSize, _) = getOperandSize(format: operandFormat)
            
            // For 16KB ROM, check if the operand crosses a bank boundary
            let currentBank = prgROMIndex / 16384
            let nextBank = (prgROMIndex + operandSize) / 16384
            
            if prgROMSize == 16384 && currentBank != nextBank {
                print("Operand crosses bank boundary at address \(String(format: "$%04X", currentAddress))")
                index += 1
                continue
            }
            
            if prgROMIndex + operandSize >= prgROM.count {
                print("Not enough bytes for operand at address \(String(format: "$%04X", currentAddress))")
                index += 1
                continue
            }
            
            let (formattedOperand, operandBytesUsed) = formatOperand(format: operandFormat, index: prgROMIndex)
            
            instructions.append(Instruction(address: currentAddress, opcode: opcode, mnemonic: mnemonic, operand: formattedOperand))
            
            // Move to the next instruction
            index += operandBytesUsed + 1
        }
        
        print("Disassembly complete, found \(instructions.count) instructions")
        return instructions
    }
    
    private func getOperandSize(format: String) -> (Int, Bool) {
        switch format {
        case "IMPL":
            return (0, false)
        case "IMM", "ZP", "ZPX", "ZPY", "INDX", "INDY", "REL":
            return (1, false)
        case "ABS", "ABSX", "ABSY", "IND":
            return (2, false)
        default:
            return (0, false)
        }
    }
    
    public func getDisassembly() throws -> String {
        var result = ""
        
        let instructions = try disassemble()
        
        for instruction in instructions {
            let addressStr = String(format: "$%04X", instruction.address)
            let operandStr = instruction.operand.map { " \($0)" } ?? ""
            result += "\(addressStr): \(instruction.mnemonic)\(operandStr)\n"
        }
        
        return result
    }
} 