#!/bin/sh
# Keep irqbalance from overriding manual CPU affinity for the ThinkPad ELAN I2C touchpad
irq="$2"
if [ -d "/proc/irq/$irq/i2c_designware.0" ] || [ -d "/proc/irq/$irq/ELAN0676:00" ]; then
    echo "ban=true"
fi
