#!/bin/bash

# Claude Code Plugin Setup Script
# Automatically installs plugins listed in settings.json

set -e

echo "🔧 Setting up Claude Code plugins..."

# Check if marketplace is configured
if ! claude plugin marketplace list | grep -q "claude-plugins-official"; then
    echo "📦 Adding official marketplace..."
    claude plugin marketplace add anthropics/claude-plugins-official
else
    echo "✓ Marketplace already configured"
fi

# Extract plugin names from settings.json
if [ -f "$HOME/.claude/settings.json" ]; then
    echo "📋 Reading settings.json for plugin list..."

    # Parse enabled plugins from settings.json
    PLUGINS=$(cat "$HOME/.claude/settings.json" | \
        grep -o '"[^"]*@claude-plugins-official"' | \
        sed 's/"//g' | \
        sed 's/@claude-plugins-official//')

    if [ -z "$PLUGINS" ]; then
        echo "⚠️  No plugins found in settings.json"
        exit 0
    fi

    echo "Found plugins to install:"
    echo "$PLUGINS" | sed 's/^/  - /'
    echo ""

    # Install each plugin
    for plugin in $PLUGINS; do
        if claude plugin list 2>/dev/null | grep -q "^  ❯ $plugin@"; then
            echo "✓ $plugin already installed"
        else
            echo "📥 Installing $plugin..."
            claude plugin install "$plugin" || echo "⚠️  Failed to install $plugin"
        fi
    done

    echo ""
    echo "🔄 Setting plugin states from settings.json..."

    # Parse and apply enabled/disabled state
    while IFS= read -r line; do
        if [[ $line =~ \"([^\"]+)@claude-plugins-official\":\ *(true|false) ]]; then
            plugin_name="${BASH_REMATCH[1]}"
            enabled="${BASH_REMATCH[2]}"

            if [ "$enabled" = "false" ]; then
                echo "  Disabling $plugin_name..."
                claude plugin disable "$plugin_name" 2>/dev/null || true
            fi
        fi
    done < "$HOME/.claude/settings.json"

    echo ""
    echo "✅ Plugin setup complete!"
    echo ""
    claude plugin list

else
    echo "❌ settings.json not found at $HOME/.claude/settings.json"
    exit 1
fi
