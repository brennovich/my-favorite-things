# VirtualSpaces.spoon

Virtual workspace/desktop management system for macOS.

## Overview

VirtualSpaces implements a virtual workspace system similar to traditional Linux window managers. It creates multiple logical workspaces on a single macOS desktop by managing window visibility across two macOS spaces: one active and one for storage. Its goal is to provide a instant switching experience between workspaces without the overhead of managing multiple physical desktops and superfulous macOS transition effects.

## Architecture

- **Active Space:** Where visible workspace windows are displayed
- **Storage Space:** Where hidden workspace windows are kept
- **Virtual Workspaces:** Logical groupings that map to physical spaces

When switching workspaces, windows are moved between active and storage spaces to simulate independent desktops.

## Features

### Workspace Management

#### Switch to Workspace
Switch to a different virtual workspace.

```lua
virtualSpaces:switchToWorkspace(workspaceNum)
```

**Behavior:**
1. Saves currently focused window for the current workspace
2. Moves all visible windows to storage space
3. Retrieves windows belonging to target workspace from storage
4. Moves them to active space and raises them
5. Updates current workspace tracking

#### Move Window to Workspace
Assign a window to a different workspace.

```lua
virtualSpaces:moveWindowToWorkspace(window, workspaceNum)
```

**Parameters:**
- `window` - Hammerspoon window object
- `workspaceNum` - Target workspace (1 to numWorkspaces)

**Behavior:**
- If target is current workspace: moves to active space
- If target is different workspace: moves to storage space
- Updates workspace mapping

### Window Tracking

#### Get Current Workspace
Returns the currently active workspace number.

```lua
local current = virtualSpaces:getCurrentWorkspace()
```

### Automatic Window Management

The spoon automatically:
- Assigns new windows to the current workspace
- Tracks window creation via window filter
- Cleans up destroyed windows
- Scans and assigns existing windows on initialization

## Internal Components

### Window Identification
Windows are identified by a composite key: `ApplicationName::WindowTitle`

```lua
local key = virtualSpaces:getWindowKey(window)
```

### Space Management
Ensures two macOS spaces exist on initialization:
- One for active workspace display
- One for window storage

```lua
virtualSpaces:ensureTwoSpaces()
```

### Window Filters
Uses Hammerspoon window filters to monitor:
- `windowCreated` - Auto-assign to current workspace
- `windowDestroyed` - Clean up tracking data

### State Tracking

**Per-workspace window lists:**
```lua
virtualSpaces.workspaces = {
    [1] = {windowId1, windowId2, ...},
    [2] = {...},
    [3] = {...}
}
```

**Window-to-workspace mapping:**
```lua
virtualSpaces.windowWorkspaceMap = {
    [windowKey] = workspaceNum
}
```

**Focused window tracking:**
```lua
virtualSpaces.workspaceFocusedWindow = {
    [workspaceNum] = windowKey
}
```

## Typical Usage

```lua
hs.loadSpoon("VirtualSpaces")
spoon.VirtualSpaces:init()

-- Switch to workspaces
hs.hotkey.bind({"alt"}, "1", function()
    virtualSpaces:switchToWorkspace(1)
end)

hs.hotkey.bind({"alt"}, "2", function()
    virtualSpaces:switchToWorkspace(2)
end)

-- Move window to workspace
hs.hotkey.bind({"alt", "shift"}, "1", function()
    local win = hs.window.focusedWindow()
    virtualSpaces:moveWindowToWorkspace(win, 1)
end)
```

## Limitations

- Only works with standard windows (fullscreen windows are excluded)
- Requires at least two macOS spaces to function (automatically created if missing)
