#!/usr/bin/env bash
# Waybar module to display countdown to IROS 2026 paper deadline
# Paper Deadline: March 1, 2026 12:00 UTC

# CONFIGURE YOUR DEADLINE HERE (in Unix timestamp)
# To get timestamp: date -d "2026-03-01 12:00:00 UTC" +%s
DATE="2026-03-31 12:00:00 UTC"
PAPER_DEADLINE=$(date -d "${DATE}" +%s)
CONF_NAME="RAL 2026"

NOW=$(date +%s)

# Calculate time difference
DIFF=$((PAPER_DEADLINE - NOW))

if [ $DIFF -lt 0 ]; then
    # Deadline has passed
    echo "{\"text\":\"${CONF_NAME} Done\",\"tooltip\":\"Paper deadline passed\",\"class\":\"done\"}"
    exit 0
fi

# Calculate days, hours, minutes
DAYS=$((DIFF / 86400))
HOURS=$(((DIFF % 86400) / 3600))
MINUTES=$(((DIFF % 3600) / 60))

# Format display text based on time remaining
if [ $DAYS -gt 30 ]; then
    TEXT="Paper Due: ${DAYS}d"
elif [ $DAYS -gt 7 ]; then
    TEXT="Paper Due: ${DAYS}d ${HOURS}h"
elif [ $DAYS -gt 0 ]; then
    TEXT="Paper Due: ${DAYS}d ${HOURS}h ${MINUTES}m"
else
    TEXT="Paper Due: ${HOURS}h ${MINUTES}m"
fi

# Build tooltip
TOOLTIP="${CONF_NAME} Paper Deadline\\n\\n$DAYS days, $HOURS hours, $MINUTES minutes"

# Determine CSS class based on urgency
if [ $DAYS -le 3 ]; then
    CLASS="urgent"
elif [ $DAYS -le 14 ]; then
    CLASS="soon"
else
    CLASS="normal"
fi

# Output JSON for Waybar
echo "{\"text\":\"$TEXT\",\"tooltip\":\"$TOOLTIP\",\"class\":\"$CLASS\"}"
