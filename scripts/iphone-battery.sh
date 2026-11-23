#!/usr/bin/env bash
set -euo pipefail

if ! command -v idevicediagnostics >/dev/null 2>&1; then
    echo "Error: idevicediagnostics not found. Install libimobiledevice-utils." >&2
    exit 1
fi

DEVICE_NAME=$(ideviceinfo -k DeviceName 2>/dev/null || true)
if [ -z "$DEVICE_NAME" ]; then
    echo "Error: No paired iPhone found. Connect your iPhone and run 'idevicepair pair'." >&2
    exit 1
fi

PRODUCT_TYPE=$(ideviceinfo -k ProductType 2>/dev/null || echo "Unknown")
IOS_VERSION=$(ideviceinfo -k ProductVersion 2>/dev/null || echo "Unknown")

echo "=========================================="
echo " Device:      $DEVICE_NAME ($PRODUCT_TYPE - iOS $IOS_VERSION)"
echo "=========================================="

idevicediagnostics ioregentry AppleSmartBattery | python3 -c "
import sys, plistlib

raw = sys.stdin.buffer.read()
data = plistlib.loads(raw).get('IORegistry', {})

design = data.get('DesignCapacity', 0)
nominal = data.get('NominalChargeCapacity', 0)
raw_max = data.get('AppleRawMaxCapacity', 0)
ios_health = data.get('MaxCapacity', 'N/A')
cycles = data.get('CycleCount', 'N/A')
current_pct = data.get('CurrentCapacity', 'N/A')
current_mah = data.get('AppleRawCurrentCapacity', 'N/A')
is_charging = data.get('IsCharging', False)
amperage = data.get('InstantAmperage', 0)
voltage = data.get('Voltage', 0)
temp = data.get('Temperature', 0)
serial = data.get('Serial', 'N/A')

actual_health = (nominal / design * 100) if design and nominal else 0

print(f'Current Charge:      {current_pct}% ({current_mah} mAh)')
print(f'Charging Status:     {\"Charging\" if is_charging else \"Not Charging\"} ({amperage} mA @ {voltage/1000:.2f} V)')
print(f'Cycle Count:         {cycles}')
print(f'Design Capacity:     {design} mAh')
print(f'Nominal Max Cap:     {nominal} mAh (Raw: {raw_max} mAh)')
print(f'iOS Reported Health: {ios_health}%')
print(f'Actual Health Ratio: {actual_health:.1f}%')
if temp:
    print(f'Temperature:         {temp / 100:.1f} °C')
print(f'Battery Serial:      {serial}')
"
echo "=========================================="
