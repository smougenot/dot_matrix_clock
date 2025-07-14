# ESP8266 Dot Matrix Project

![Build PlatformIO project](https://github.com/smougenot/dot_matrix_clock/actions/workflows/build-platformio.yml/badge.svg?branch=master)
![Super-Linter Light](https://github.com/smougenot/dot_matrix_clock/actions/workflows/super-linter.yml/badge.svg?branch=master)

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
3. **Configure WiFi credentials**:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your WiFi credentials and timezone settings.
4. Open the folder in PlatformIO or VS Code.
5. Connect the ESP8266 and upload the firmware:
   ```bash
   pio run --target upload
   ```

## Configuration

### WiFi and Secrets Management with PlatformIO
The project offers flexible configuration methods to set your WiFi credentials and NTP server settings:

#### Default Configuration (No Setup Required)
The project will compile and run with default placeholder values:
- **WIFI_SSID**: "YOUR_WIFI_SSID"  
- **WIFI_PASSWORD**: "YOUR_WIFI_PASSWORD"
- **NTP_SERVER**: "europe.pool.ntp.org"
- **GMT_OFFSET_SEC**: 3600

#### Custom Configuration via Environment Variables
For personalized configuration, copy the environment template and edit it with your credentials:

1. **Copy the example environment file**:
   ```bash
   cp .env.example .env
   ```

2. **Edit your configuration** in `.env` (note the escaped quotes):
   ```bash
   PLATFORMIO_BUILD_FLAGS=-DWIFI_SSID=\\"Your_WiFi_Network\\" -DWIFI_PASSWORD=\\"Your_WiFi_Password\\" -DNTP_SERVER=\\"europe.pool.ntp.org\\" -DGMT_OFFSET_SEC=3600
   ```

3. **Security**: The `.env` file is ignored by git, so your credentials won't be committed.

#### Build Commands
- **Default build**: `pio run` (uses default values or `.env` file if present)
- **Upload**: `pio run --target upload`

#### Alternative Configuration Methods
- **Command line**: `PLATFORMIO_BUILD_FLAGS="-DWIFI_SSID=\\"MyNetwork\\"" pio run`
- **GitHub Secrets**: For CI/CD, use repository secrets and environment variables

## Hardware Wiring

### MAX7219 LED Matrix Connection
Connect the MAX7219 module to your ESP8266 (NodeMCU v2) as follows:

| MAX7219 Pin | ESP8266 Pin | NodeMCU Pin | Description |
|-------------|-------------|-------------|-------------|
| VCC         | 5V          | Vin         | Power supply (3.3V) |
| GND         | GND         | GND         | Ground |
| DIN         | GPIO13      | D7          | Data input (MOSI) |
| CS          | GPIO12      | D6          | Chip select |
| CLK         | GPIO14      | D5          | Clock signal (SCK) |

### Configuration in Code
The pin configuration is defined in the source code:
```cpp
#define PIN_CLOCK 14  // GPIO14 (D5)
#define PIN_DATA  13  // GPIO13 (D7) 
#define PIN_CS    12  // GPIO12 (D6)
```

### Matrix Configuration
- **Display dimensions**: 32x8 pixels (4 modules of 8x8)
- **Module type**: MAX7219 controlled LED matrix
- **Communication**: SPI (Software SPI implementation)

## Usage
The source code in `src/MAX7219_U8g2.ino` shows how to initialize and display patterns on the LED matrix.

## Security Features

This project includes comprehensive security measures to prevent accidental exposure of sensitive information:

### Automated Secret Detection with git-leaks
- **git-leaks Integration**: Fast and efficient secret scanning optimized for CI/CD pipelines
- **Custom IoT Configuration**: Specialized rules for ESP8266/IoT projects detecting WiFi credentials, API keys, and network identifiers
- **CI/CD Security Scan**: Automatic detection of secrets in all commits and pull requests
- **Daily Security Scans**: Scheduled scans to catch any newly introduced secrets

### Quick Setup
1. **Install git-leaks locally**:
   ```bash
   ./install-gitleaks.sh
   ```

2. **Install the pre-commit hook**:
   ```bash
   ./install-hooks.sh
   ```

### Local Secret Scanning
- **Full repository scan**: `gitleaks detect --config=.gitleaks.toml`
- **Staged files only**: `gitleaks protect --staged --config=.gitleaks.toml`
- **Specific file**: `gitleaks detect --config=.gitleaks.toml --source=filename`

### Detection Capabilities
The git-leaks configuration automatically detects:
- WiFi credentials (SSID/passwords)
- API keys and authentication tokens
- Real ISP network names (Livebox, Freebox, SFR, Orange, Bouygues)
- MAC addresses and IP addresses
- Long hexadecimal strings (potential encryption keys)
- Hardcoded secrets in source files

### Security Best Practices
- ✅ Always use `.env` files for local secrets (automatically ignored by git)
- ✅ Use placeholder values like `YOUR_WIFI_SSID` in examples
- ✅ Review security scan results in CI/CD
- ✅ Change any credentials that were accidentally committed
- ✅ Use the pre-commit hook to catch issues early

### CI/CD Workflows
This project includes multiple specialized GitHub Actions workflows:

#### 🔨 Build Workflow (`build-platformio.yml`)
- **Purpose**: Fast compilation and firmware generation
- **Triggers**: Push/PR to master branch
- **Features**: 
  - Caching for faster builds
  - Artifact upload (firmware files)
  - Focused on compilation only

#### 🔒 Security Workflow (`security-scan.yml`)
- **Purpose**: Comprehensive security scanning
- **Triggers**: Push/PR, daily at 2 AM, manual dispatch
- **Features**:
  - git-leaks secret detection
  - .env file protection verification
  - Security TODO detection

#### 🎯 Quality Assurance Workflow (`quality-assurance.yml`)
- **Purpose**: Code quality and documentation checks
- **Triggers**: Push/PR to master branch, manual dispatch
- **Features**:
  - Code style and formatting checks
  - Documentation completeness
  - Dependency security analysis
  - TODO/FIXME tracking

### Configuration Files
- **`.gitleaks.toml`**: Custom git-leaks configuration for ESP8266/IoT projects
- **`.gitignore`**: Enhanced protection against committing sensitive files
- **`install-gitleaks.sh`**: Automated git-leaks installation script
- **`install-hooks.sh`**: Pre-commit hook installation script

## License
This project is open source, under MIT license.
