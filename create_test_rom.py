import struct

# Create iNES header
header = bytearray([
    0x4E, 0x45, 0x53, 0x1A,  # NES magic number
    0x02,                     # 32KB PRG ROM
    0x01,                     # 8KB CHR ROM
    0x01,                     # Vertical mirroring, no battery
    0x00,                     # Mapper 0
    0x00, 0x00, 0x00, 0x00,  # Unused bytes
    0x00, 0x00, 0x00, 0x00   # Unused bytes
])

# Create PRG ROM data (32KB of incrementing values)
prg_rom = bytearray([i % 256 for i in range(32768)])

# Create CHR ROM data (8KB of incrementing values)
chr_rom = bytearray([i % 256 for i in range(8192)])

# Write to file
with open('MMC5Dev/Tests/MMC5DevTests/test.nes', 'wb') as f:
    f.write(header)
    f.write(prg_rom)
    f.write(chr_rom) 