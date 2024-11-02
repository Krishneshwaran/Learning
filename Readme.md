

# Simple Bootloader OS

This project is a simple bootloader operating system implemented in x86 assembly language. It demonstrates basic input/output operations, including displaying messages, capturing user input, and clearing the screen.

## Features

- Displays a welcome message on boot.
- Prompts the user to type something.
- Supports a "clear" command to clear the screen.
- Echoes back user input.

## Requirements

- [NASM](https://www.nasm.us/) (Netwide Assembler) to assemble the assembly code.
- [QEMU](https://www.qemu.org/) to emulate the booting process.
- Windows operating system (tested on Windows with Mingw32).

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Krishneshwaran/Learning
   cd Learning
   ```

2. Install NASM and QEMU if you haven't already.

3. Open a command prompt and navigate to the project directory.

4. Build the project:
   ```bash
   mingw32-make all
   ```

5. Run the OS in QEMU:
   ```bash
   qemu-system-x86_64 -drive file=build/main_floppy.img,format=raw
   ```

## Usage

- Upon booting, the OS will display a welcome message.
- You can type any text, and it will be echoed back to you.
- Typing the command `clear` will clear the screen.

## Code Structure

- `src/main.asm`: The main assembly source file containing the bootloader code.
- `Makefile`: A Makefile to automate the building process.
- `build/`: Directory where the compiled files are generated.

## Contributing

Feel free to contribute to this project by submitting issues or pull requests.
