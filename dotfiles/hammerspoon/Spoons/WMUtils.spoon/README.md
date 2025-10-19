# WMUtils.spoon

Window management utilities for Hammerspoon.

## Overview

WMUtils provides essential window manipulation functions including precise pixel-based movement, window centering, and monocle mode (maximize/restore toggle).

## Features

### Move Window
Move the focused window by specified pixel offsets.

```lua
wmUtils:moveWindow(dx, dy)
```

**Parameters:**
- `dx` - Horizontal offset in pixels (positive = right, negative = left)
- `dy` - Vertical offset in pixels (positive = down, negative = up)

**Example:**
```lua
wmUtils:moveWindow(30, 0)  -- Move 30px right
wmUtils:moveWindow(-30, 0) -- Move 30px left
```

### Center Window
Center the focused window on its current screen without changing size.

```lua
wmUtils:centerWindow()
```

### Monocle Mode
Toggle between maximized and restored window states. Caches the original frame when maximizing so it can be restored to the exact previous position and size.

```lua
wmUtils:monocle()
```

**Behavior:**
- First call: Saves current frame and maximizes window to fill the grid
- Second call: Restores window to cached frame
- Uses grid-based maximization (respects grid margins)

## Configuration

### Gap Size
Set the gap increment used for window movement operations (default: 15px).

```lua
wmUtils.gap = 15
```

This value is typically used in keybindings for movement commands.

## Internal State

### windowFrameCache
Stores original window frames for monocle mode restoration. Keyed by window ID.

```lua
wmUtils.windowFrameCache = {}
```

## Metadata

- **Version:** 1.0
- **Author:** brnnc
- **License:** MIT
