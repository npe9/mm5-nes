# NES platformer build configuration
ASM = ca65
LINK = ld65
CFLAGS = -t nes -U __DEBUG__

# Source files
SRC = src/main.s
OBJ = $(SRC:.s=.o)

# Output files
TARGET = game.nes

# Default target
all: $(TARGET)

# Link the final ROM
$(TARGET): $(OBJ)
	$(LINK) $(CFLAGS) -C cfg/mmc5.cfg -o $(TARGET) $(OBJ)

# Assemble source files
%.o: %.s
	$(ASM) $(CFLAGS) -o $@ $<

# Clean build files
clean:
	rm -f $(OBJ) $(TARGET)

.PHONY: all clean 