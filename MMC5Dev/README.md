# MMC5 Dev

MMC5 Dev is a modern development environment for creating NES games that utilize the MMC5 mapper. It provides a suite of tools for music composition, sprite editing, code development, and ROM building.

## Features

- **Music Tracker**: Create and edit music patterns with an intuitive piano roll interface
- **Sprite Editor**: Design 8x8 pixel tiles with a user-friendly interface
- **Code Editor**: Write assembly code with syntax highlighting
- **ROM Builder**: Build and test your NES ROMs with various configuration options

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later
- An NES emulator for testing ROMs

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mmc5-dev.git
cd mmc5-dev
```

2. Open the project in Xcode:
```bash
xed .
```

3. Build and run the project

## Usage

### Creating a New Project

1. Launch MMC5 Dev
2. Choose File > New Project
3. Enter a project name and choose a save location

### Music Composition

1. Select the Music Tracker tab
2. Create a new pattern using the "New Pattern" button
3. Click on the grid to add notes
4. Adjust tempo and pattern length as needed

### Sprite Editing

1. Select the Sprite Editor tab
2. Create a new tile using the "New Tile" button
3. Use the color palette to select colors
4. Click and drag on the grid to draw pixels

### Code Development

1. Select the Code Editor tab
2. Write your 6502 assembly code
3. The code will be automatically saved with your project

### Building ROMs

1. Select the ROM Builder tab
2. Configure your ROM settings (size, mapper type, mirroring)
3. Click "Build ROM" to generate your NES ROM
4. Test the ROM in your preferred emulator

## Configuration

You can configure various settings in the Preferences window:

- Default ROM settings
- Autosave options
- Emulator path
- Theme preferences

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 