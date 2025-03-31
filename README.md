# MMC5 NES Platformer

A platformer game for the Nintendo Entertainment System (NES) utilizing the MMC5 mapper chip. This project demonstrates the advanced capabilities of the MMC5 mapper, including:

- Extended RAM
- Split-screen capabilities
- Advanced sound features
- Enhanced graphics modes
- Vertical and horizontal scrolling

## Requirements

- cc65 (6502 C compiler)
- ca65 (6502 assembler)
- ld65 (6502 linker)
- make

## Building

```bash
make
```

This will generate `game.nes` in the root directory.

## Features

- Smooth scrolling platformer gameplay
- Multiple background layers
- Advanced sound effects and music
- Dynamic sprite management
- Split-screen effects
- Extended RAM for complex game states

## Project Structure

- `src/` - Source code files
  - `main.s` - Main game logic
  - `graphics.s` - Graphics and sprite handling
  - `sound.s` - Sound and music system
  - `mmc5.s` - MMC5 mapper configuration
- `inc/` - Include files
- `res/` - Resource files (graphics, music, etc.)
- `cfg/` - Configuration files 