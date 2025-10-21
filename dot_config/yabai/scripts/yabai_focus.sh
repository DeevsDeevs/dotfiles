#!/usr/bin/env bash

# This script provides helper functions for yabai window management

# Get current window information
window=$(yabai -m query --windows --window)
app=$(echo $window | jq -r '.app')
title=$(echo $window | jq -r '.title')

# Send update to sketchybar
sketchybar --trigger window_focus APP="$app" TITLE="$title"
