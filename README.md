# ESP8266 Dot Matrix Project

![Build PlatformIO project](https://github.com/username/dotMatrix/workflows/build-platformio.yml/badge.svg?branch=master)

This project uses an ESP8266 board to control an LED matrix via the MAX7219 module. It is designed to be compiled and uploaded with PlatformIO.

## Project Structure
- `src/` : Contains the main source code (e.g., `MAX7219_U8g2.ino`).
- `lib/` : Additional libraries.
- `include/` : Header files.
- `test/` : Unit or integration tests.
- `platformio.ini` : PlatformIO configuration.

## Quick Start
1. Install [PlatformIO](https://platformio.org/install).
2. Clone this repository:
   ```bash
   git clone <repo-url>
   ```
3. Open the folder in PlatformIO or VS Code.
4. Connect the ESP8266 and upload the firmware:
   ```bash
   pio run --target upload
   ```

## Usage
The source code in `src/MAX7219_U8g2.ino` shows how to initialize and display patterns on the LED matrix.

## License
This project is open source, under MIT license.
