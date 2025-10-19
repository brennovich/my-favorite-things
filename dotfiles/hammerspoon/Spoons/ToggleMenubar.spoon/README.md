# ToggleMenubar.spoon

Toggle macOS menubar visibility with automatic grid margin adjustment.

## Overview

ToggleMenubar provides a simple interface to show/hide the macOS menubar while maintaining consistent grid margins for window management.

## Features

### Toggle Menubar
Toggle the menubar visibility state and refresh grid configuration.

```lua
toggleMenubar:toggle()
```

**Behavior:**
- Reads current menubar state from system defaults
- Toggles menubar visibility using AppleScript
- Waits 0.5 seconds for system animation
- Reapplies grid configuration with margins

This ensures the grid system accounts for the menubar space, keeping window positioning consistent whether the menubar is visible or hidden.

## Configuration

### Gap Size
Set the margin size applied to the grid after toggling (default: 10px).

```lua
toggleMenubar.gap = 10
```

## Implementation Details

The spoon uses multiple methods to ensure reliable operation:

1. **State Detection:** Reads `NSGlobalDomain _HIHideMenuBar` preference to determine current state
2. **Toggle Operation:** Uses AppleScript via System Events to toggle the autohide preference
3. **Grid Refresh:** Reapplies grid configuration after a delay to account for system animations

## Typical Usage

```lua
local toggleMenubar = hs.loadSpoon("ToggleMenubar")
toggleMenubar.gap = 10
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "D", function()
    toggleMenubar:toggle()
end)
```

## Metadata

- **Version:** 1.0
- **Author:** brnnc
- **License:** MIT
