# WMUtils.spoon

Window management utilities for Hammerspoon.

## Overview

WMUtils provides window manipulation functions including precise pixel-based movement, grid positioning with toggle-restore, window centering, monocle mode, telescope mode, and resize mode with visual feedback.

## Features

### Window Movement
Move the focused window by gap increments (gap * 2 pixels).

```lua
wmUtils:moveLeft()
wmUtils:moveRight()
wmUtils:moveUp()
wmUtils:moveDown()
```

**Default:** Moves window by 30px (gap=15 * 2)

### Center Window
Center the focused window on its current screen without changing size.

```lua
wmUtils:centerWindow()
```

### Grid Positioning (Toggle-Restore)
Position windows to grid halves with toggle-restore behavior. Second call restores original frame.

```lua
wmUtils:leftHalf()   -- Left half of screen
wmUtils:rightHalf()  -- Right half of screen
wmUtils:topHalf()    -- Top half of screen
wmUtils:bottomHalf() -- Bottom half of screen
```

**Behavior:**
- First call: Saves current frame and positions window to grid half
- Second call: Restores window to cached frame
- All grid positions share a single cache per window

### Monocle Mode
Toggle between grid-maximized and restored window states. Uses grid-based maximization (respects grid margins).

```lua
wmUtils:monocle()
```

**Behavior:**
- First call: Saves current frame and maximizes window to fill the grid
- Second call: Restores window to cached frame
- Respects grid margins (default: 15px gap)

### Telescope Mode
Toggle between fully maximized and restored window states. Uses native window maximize (no margins).

```lua
wmUtils:telescope()
```

**Behavior:**
- First call: Saves current frame and maximizes window using `win:maximize()`
- Second call: Restores window to cached frame
- Works with constrained windows (Terminal.app) with 30px height tolerance
- Automatically clears cache when window is in fullscreen mode

### Resize Mode
Interactive resize mode with visual border feedback and directional resizing.

```lua
wmUtils:setupResizeModal()
```

**Resize Modal Commands:**
- `H` - Make window slimmer (decrease width by 30px)
- `L` - Make window wider (increase width by 30px)
- `K` - Make window shorter (decrease height by 30px)
- `J` - Make window taller (increase height by 30px)
- `Escape` - Exit resize mode

**Features:**
- Visual border around focused window while in resize mode
- Border updates automatically when window moves or changes focus
- Dual-layer border with outer and inner strokes

## Configuration

### Gap Size
Set the gap increment used for window movement operations (default: 15px).

```lua
wmUtils.gap = 15
```

This value is typically used in keybindings for movement commands.

## Internal State

### monocleFrameCache
Stores original window frames for monocle mode restoration. Keyed by window ID.

```lua
wmUtils.monocleFrameCache = {}
```

### telescopeFrameCache
Stores original window frames for telescope mode restoration. Keyed by window ID.

```lua
wmUtils.telescopeFrameCache = {}
```

### gridFrameCache
Stores original window frames for grid position restoration. Shared across all grid positions (leftHalf, rightHalf, topHalf, bottomHalf). Keyed by window ID.

```lua
wmUtils.gridFrameCache = {}
```

## Metadata

- **Version:** 1.0
- **Author:** brnnc
- **License:** MIT
