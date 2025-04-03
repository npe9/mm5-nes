#!/bin/bash

# Assemble the test file
ca65 tests/player_test.s -o tests/player_test.o

# Link the test file with the main program
ld65 tests/player_test.o -C nes.cfg -o tests/player_test.nes

# Run the test ROM in an emulator (assuming you have one installed)
# You'll need to modify this line based on your emulator
# For example, with FCEUX:
# fceux tests/player_test.nes

echo "Tests assembled successfully. Please run the test ROM in your preferred emulator." 