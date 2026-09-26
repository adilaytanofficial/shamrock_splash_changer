#!/bin/bash

W=1080
H=1920
PNG="splash/splash.png"
HEADER="lib/header.bin"
OUTPUT="out/splash.img"
ZIP_FILE="lib/base.zip"
OUT_DIR="out"
OUT_ZIP="${OUT_DIR}/splash_image.zip"
WORK_DIR="/tmp/build_splash"

mkdir -p out
rm -rf -- out/*

if [ ! -f "$PNG" ]; then
    echo "ERROR: $PNG not found!"
    echo "Please place the image you wish to replace in the 'splash' folder and name it 'splash.png'."
    exit 1
fi

if [ ! -f "$HEADER" ]; then
    echo "ERROR: $HEADER not found!"
    exit 1
fi

if [ ! -f "$ZIP_FILE" ]; then
    echo "ERROR: $ZIP_FILE not found!"
    exit 1
fi

if ! command -v convert &> /dev/null; then
    echo "ERROR: ImageMagick is not installed !"
    echo "Installation: sudo apt install imagemagick"
    exit 1
fi

EXPECTED=$((W * H * 3))

echo "[1/7] The image is being converted to raw BGR format..."
convert "$PNG" -resize ${W}x${H}! -depth 8 bgr:new_payload.bin

ACTUAL=$(stat -c%s new_payload.bin)
if [ "$ACTUAL" -ne "$EXPECTED" ]; then
    echo "ERROR: Incorrect payload size!" 
    echo "Expected: $EXPECTED bytes"
    echo "Actual:   $ACTUAL bytes"
    exit 1
fi
echo "      Size is correct: $ACTUAL bytes"

echo "[2/7] Creating new splash.img..."
cat "$HEADER" new_payload.bin > "$OUTPUT"

echo "[3/7] Verifying package..."
dd if="$OUTPUT" of=test_payload.bin bs=512 skip=1 2>/dev/null
convert -size ${W}x${H} -depth 8 bgr:test_payload.bin out/verify_splash.png

echo "[4/7] Extracting $ZIP_FILE to $WORK_DIR..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
unzip -q "$ZIP_FILE" -d "$WORK_DIR"

echo "[5/7] Copying splash.img into package and updating build date..."
cp "$OUTPUT" "$WORK_DIR/splash.img"

SCRIPT_PATH="$WORK_DIR/META-INF/com/google/android/update-binary"
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "ERROR: updater-script not found at $SCRIPT_PATH"
    exit 1
fi

BUILD_DATE=$(date +"%d.%m.%Y %H:%M")
sed -i "s|dd\.MM\.yyyy HH:mm|${BUILD_DATE}|g" "$SCRIPT_PATH"
sed -i "s|DD\.MM\.YYYY HH:mm|${BUILD_DATE}|g" "$SCRIPT_PATH"
echo "      Build date set to: $BUILD_DATE"

echo "[6/7] Creating $OUT_ZIP..."
rm -f "$OUT_ZIP"
(
    cd "$WORK_DIR"
    zip -r -X "$OLDPWD/$OUT_ZIP" . > /dev/null
)

echo "[7/7] Cleaning up..."
rm -f new_payload.bin test_payload.bin
rm -rf "$WORK_DIR"

echo ""
echo "============================================"
echo " SUCCESS!"
echo "============================================"
echo " Output file : $OUTPUT"
echo " Package     : $OUT_ZIP"
echo " Verification  : out/verify_splash.png (check it)"
echo ""
echo " To flash to the device:"
echo "   adb reboot bootloader"
echo "   fastboot flash splash $OUTPUT"
echo "   fastboot reboot"
echo ""
echo " To flash via recovery:"
echo "   adb sideload $OUT_ZIP"
echo "============================================"
