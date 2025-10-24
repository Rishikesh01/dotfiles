#!/bin/bash

MONITOR_NAME="HDMI-A-1"
MONITOR_CONFIG="2560x1440@60,0x0,1"

# Check if monitor is currently enabled
if hyprctl monitors | grep -q "$MONITOR_NAME"; then
    # Disable monitor
    hyprctl keyword monitor "$MONITOR_NAME,disable"
else
    # Enable monitor with specified config
    hyprctl keyword monitor "$MONITOR_NAME,$MONITOR_CONFIG"
fi
