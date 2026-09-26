# Shamrock Splash Changer

[![Device](https://img.shields.io/badge/device-shamrock-blue.svg)](https://github.com/adilaytanofficial/shamrock_splash_changer)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Tool for changing the splash screen (bootlogo) on **GM 5 Plus (shamrock)**.

Generates `splash.img`, packages a flashable recovery ZIP, and supports direct `fastboot` flashing.

---

## Features

- PNG → RAW BGR conversion (ImageMagick)
- `splash.img` build (`header.bin` + payload)
- Auto build-date injection into `updater-script`
- Flashable `splash_image.zip` for recovery
- Ready-to-flash `splash.img` for fastboot

---

## Requirements

- Linux (bash)
- ImageMagick, `zip`, `unzip`
- Optional: `adb`, `fastboot`

```bash
sudo apt install imagemagick zip unzip android-tools-adb android-tools-fastboot
```

---

## 🚀 How to Use

1. **🖼️ Prepare your image**
   Place a `1080×1920` PNG at `splash/splash.png`.

2. **🔨 Build**
   ```bash
   chmod +x build_splash_zip.sh
   ./build_splash_zip.sh
   ```
