ASM=nasm
SRC_DIR=src
BUILD_DIR=build

all: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/main.bin
	if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)
	copy $(BUILD_DIR)\main.bin $(BUILD_DIR)\main_floppy.img
	fsutil file createnew $(BUILD_DIR)\main_floppy.img 1474560
	copy /b $(BUILD_DIR)\main.bin+$(BUILD_DIR)\main_floppy.img $(BUILD_DIR)\main_floppy.img

$(BUILD_DIR)/main.bin: $(SRC_DIR)/main.asm
	if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)
	$(ASM) -f bin -o $(BUILD_DIR)/main.bin $(SRC_DIR)/main.asm

clean:
	if exist $(BUILD_DIR) rmdir /S /Q $(BUILD_DIR)
