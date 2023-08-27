#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit
export DEFAULT_NETWORK_INTERFACE
DEFAULT_NETWORK_INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
echo $DEFAULT_NETWORK_INTERFACE
# Launch bar1 and bar2
echo "---" |

polybar music & polybar workspaces & polybar status
#polybar info


echo "Bars launched..."
