#!/bin/bash
# Removes Claude Desktop's native messaging host so Claude Code keeps control
# of the Chrome extension. Desktop recreates this file on launch.

HOST_FILE="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_browser_extension.json"

if [ -f "$HOST_FILE" ]; then
    rm "$HOST_FILE"
    logger "fix-chrome-native-host: Removed Claude Desktop native messaging host"
fi
