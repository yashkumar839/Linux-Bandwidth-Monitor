#!/bin/bash

INTERFACE="${1}"
LOG_FILE="$HOME/bandwidth-monitor/log/log/bandwidth.log"
INTERVAL=1

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

if ! grep -q "$INTERFACE" /proc/net/dev; then
	echo "ERROR: Interface '$INTERFACE' not found."
	exit 1
fi

get_bytes() {
	grep "$1:" /proc/net/dev | awk '{print $2, $10}'
}

format_speed(){
	local bytes=$1
	if ((bytes>=1073741824)); then printf "%.2f GB/s" "$(echo "scale=2; $bytes/1073741824" | bc -l)"
	elif ((bytes>=1048576)); then printf "%.2f MB/s" "$(echo "scale=2; $bytes/1048576" | bc -l)"
	elif ((bytes>=1024)); then printf "%.2f KB/s" "$(echo "scale=2; $bytes/1024" | bc -l)"
        else printf "%d B/s" "$bytes"
        fi
}

clear
echo -e "${BOLD}${CYAN}Bandwidth Monitor - INTERFACE: ${YELLOW}$INTERFACE${RESET}"
echo -e "${CYAN}Press Ctrl+c to stop. Loggint to: $LOG_FILE${RESET}\n"

read -r prev_rx prev_tx <<< "$(get_bytes "$INTERFACE")"

while true; do
sleep "$INTERVAL"
read -r curr_rx curr_tx <<< "$(get_bytes "$INTERFACE")"
rx_speed=$(( (curr_rx - prev_rx)/INTERVAL))
tx_speed=$(( (curr_tx - prev_tx)/INTERVAL))

rx_fmt=$(format_speed $rx_speed)
tx_fmt=$(format_speed $tx_speed)
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

printf "\r${BOLD}[%s]${RESET} ${GREEN}DOWN: %-15s${RESET} ${RED} UP: %-15s${RESET}" \ "$timestamp" "$rx_fmt" "$tx_fmt"

echo "${timestamp} | DOWN: $rx_fmt | UP: $tx_fmt" >> "$LOG_FILE"
prev_rx=$curr_rx
prev_tx=$curr_tx

done

