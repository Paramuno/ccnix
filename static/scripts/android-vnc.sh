#!/bin/bash

# --- 2. CHECK ENVIRONMENT ---
# We are running as USER now, so we can find the signature easily.
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    # Try to find it manually in the new location
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1t /run/user/$(id -u)/hypr/ | head -n 1)
fi

if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "[X] Error: Hyprland not found. Are you running this from a TTY?"
    exit 1
fi

# --- Configuration ---
OUTPUT_NAME="phone"
LAPTOP_DISPLAY="eDP-1"
# Moto G9 Native Resolution. 
WIDTH=720
HEIGHT=1540
FPS=60
PORT=5901
killall hypridle

cleanup() {
    echo -e "\n[!] Restoring normal screen setup..."

    # 1. Wake screen
    echo "[*] Waking up laptop screen..."
    hyprctl keyword monitor "$LAPTOP_DISPLAY, preferred, 0x0, 1"
    hyprctl dispatch dpms on $LAPTOP_DISPLAY

    # Wait for display to wake up and close virtual monitor
    sleep 1
    hyprctl output remove $OUTPUT_NAME
    
    # 2. Close the ADB tunnel
    adb reverse --remove tcp:$PORT

    # 3. Restart hypridle
    hypridle &

    # 4. Restore Android status bar and adb reverse clean
    adb shell settings put global policy_control null*
    adb reverse --remove tcp:$PORT
    
    # 5. Re-enable USB power saving (optional, good for battery)
    echo "auto" | sudo tee /sys/bus/usb/devices/usb*/power/control > /dev/null
    
    echo "[✓] Done Disconnected."
    exit
}

# Trap Ctrl+C
trap cleanup SIGINT

echo "🤖 Android VNC monitor 🤖"

# 1. Check for ADB Device
echo "[*] Looking for phone..."
if ! adb devices | grep -w "device" > /dev/null; then
    echo "[X] Error: Phone not found or unauthorized."
    echo "    1. Plug in USB cable."
    echo "    2. Enable USB Debugging."
    echo "    3. Accept the popup on your phone."
    exit 1
fi
echo "[✓] Phone found."


# 3. Max out USB power (Requires Sudo)
echo "[*] Sudo disabling USB autosuspend and maxing our USB power..."
echo "on" | /sys/bus/usb/devices/usb*/power/control > /dev/null
echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend > /dev/null


# 2. Setup Reverse Tunnel
# This forwards the phone's "localhost:5901" to your laptop's "localhost:5901"
echo "[*] Opening ADB reverse tunnel..."
adb reverse tcp:$PORT tcp:$PORT
echo "[*] Hiding Android status bar..."
adb shell settings put global policy_control immersive.status=*



# 4. Create the Virtual Display
echo "[*] Turning off laptop display and creating headless monitor ($WIDTH x $HEIGHT)..."
# Remove any old instance first just in case
# hyprctl output remove $OUTPUT_NAME 2>/dev/null
# Create the new headless output
hyprctl output create headless $OUTPUT_NAME
# Places the phone to the RIGHT of your current screen automatically
hyprctl keyword monitor $OUTPUT_NAME,${WIDTH}x${HEIGHT}@$FPS,auto,1
# Disable laptop screen
hyprctl keyword monitor "$LAPTOP_DISPLAY, disable"



# 6. Start WayVNC
echo "-------------------------------------------------------"
echo "[✓] SYSTEM READY!"
echo "    1. Open AVNC / RealVNC on your phone."
echo "    2. Connect to: 127.0.0.1:$PORT"
echo "-------------------------------------------------------"

# export WLR_DRM_NO_ATOMIC=1
# Keep the ADB tunnel open aggressively
while true; do
    echo "[*] Starting VNC Server..."
    wayvnc 127.0.0.1 $PORT --output=$OUTPUT_NAME --log-level=info
    echo "[!] VNC Server stopped. Restarting in 1 second..."
    sleep 1
done

# Start the server (listening on localhost is safer/faster with ADB)
# wayvnc 127.0.0.1 $PORT --output=$OUTPUT_NAME --log-level=info
