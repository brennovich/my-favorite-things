# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal macOS system configuration and dotfiles repository. The project automates computer setup with a custom workflow using Makefile-based automation. Named after John Coltrane's album "My Favorite Things".

## Build System

This project uses GNU Make for all automation. The Makefile is platform-specific:

```sh
# Run make commands by specifying the platform-specific Makefile
make -f Makefile.macos <target>

# Install multiple components
make -f Makefile.macos dotfiles colors vim

# Clean temporary files
make -f Makefile.macos clean
```

### Key Targets

- `dotfiles` - Installs shell configurations (zshrc, gitconfig, etc.) to home directory
- `colors` - Sets up base16-shell color scheme system
- `vim` - Installs vim from MacPorts and configures plugins
- `golang`, `rust`, `ruby`, `node` - Language environment setup
- `media` - Installs VLC and yt-dlp for media handling
- `feeds` - Installs and configures newsboat RSS reader
- `hammerspoon` - Installs Hammerspoon, copies custom Spoons, downloads external Spoons (RoundedCorners, ToggleMenubar)
- `defaults` - Configures macOS system preferences via defaults command
- `github` - Installs GitHub CLI

## Architecture

### File Organization

- `dotfiles/` - Source configuration files that get copied to home directory
  - `bin/` - Custom shell scripts and utilities
  - `newsboat/` - RSS feed reader configuration
  - `hammerspoon/` - Lua-based macOS automation scripts
    - `Spoons/VirtualSpaces.spoon/` - Custom virtual workspace implementation with test suite
    - `Spoons/WMUtils.spoon/` - Custom window management utilities with test suite
  - Root level dotfiles (zshrc, vimrc, gitconfig, etc.)
- `wallpapers/` - Desktop backgrounds
- `etc/` - System-wide configuration files (copied with sudo)

### Installation Pattern

The Makefile uses pattern rules for copying dotfiles:

```makefile
~/.%: dotfiles/*
    mkdir -p $(@D)
    cp -R dotfiles/$* $@
```

This means files in `dotfiles/` are copied to `~/` with a dot prefix. For example:
- `dotfiles/zshrc` → `~/.zshrc`
- `dotfiles/vimrc` → `~/.vimrc`
- `dotfiles/bin/colorscheme` → `~/.bin/colorscheme`

### Package Management

The project uses both MacPorts and Homebrew:
- MacPorts (`port`): Primary package manager for system tools (vim, newsboat, ruby, etc.)
- Homebrew (`brew`): Used for GitHub CLI and casks (Hammerspoon, VLC)

Environment files (`dotfiles/env-*`) are sourced by zshrc to configure PATH and tool-specific settings.

## Key Components

### Shell Configuration (zshrc)

- Vi mode with custom keybindings
- Sources all `~/.env-*` files on startup
- Newsboat integration that resets ANSI colors after exit

### Vim Configuration (vimrc)

- Classic vim (not neovim) with manual plugin management
- Plugins installed to `~/.vim/pack/plugins/start/`
- vim-go with goimports formatting
- Custom color scheme: marques-de-itu
- No status line, no column ruler (minimal UI)

### Custom Utilities (dotfiles/bin/)

- `colorscheme` - Base16 color scheme switcher
- `ytvlc` - YouTube video player wrapper for VLC
- `ytchrss` - YouTube channel RSS feed helper
- `logbook` - Personal logging tool

### Hammerspoon (init.lua)

Lua-based macOS automation with i3-like window management capabilities. Uses a Spoon-based architecture for modular functionality.

#### Spoons (Custom Modules)

- **VirtualSpaces.spoon** (custom) - i3-like virtual workspace system
  - Provides 4 virtual workspaces using native macOS spaces
  - Tracks window assignments and focus per virtual space
  - Automatically handles window creation/destruction
  - Supports native macOS window switching (Cmd+Tab, Mission Control)
  - Uses two native spaces: one active, one for storage
  - Built with test coverage (SpacesModel, WindowsSort, NativeSpaceManager)

- **WMUtils.spoon** (custom) - Window management utilities
  - Move windows with pixel precision (gap*2 increments = 30px)
  - Center windows on screen
  - Monocle mode (toggle maximize with frame restoration, respects gaps)
  - Fullscreen mode (toggle true fullscreen ignoring gaps and menubar)
  - Resize mode with visual border feedback
  - Configurable gap between windows (15px default)
  - Test coverage for fullscreen feature

- **ToggleMenubar.spoon** (external, v0.4.2) - System UI control
  - Toggle macOS menubar visibility
  - Automatically adjusts grid margins when toggled
  - Downloaded from GitHub releases

- **RoundedCorners** (external) - Visual enhancement for window corners
  - Downloaded from Hammerspoon/Spoons repository

#### Window Management Features

**Grid System:**
- 2x2 grid layout with configurable gaps (15px default)
- No animation for instant window placement
- Grid overlay toggle (Alt+Ctrl+G)

**Window Focus (i3-like):**
- Alt+H/J/K/L - Focus window west/south/north/east

**Window Movement:**
- Alt+Shift+H/J/K/L - Move window by gap increments (30px)

**Window Positioning (grid-based):**
- Alt+Ctrl+H - Left half
- Alt+Ctrl+L - Right half
- Alt+Ctrl+K - Top half
- Alt+Ctrl+J - Bottom half
- Alt+Ctrl+Space - Center window
- Alt+Ctrl+M - Monocle mode (maximize/restore, respects 15px gaps)
- Alt+Ctrl+F - Fullscreen mode (true fullscreen, ignores gaps and covers menubar)

**Resize Mode:**
- Alt+Ctrl+R - Enter resize mode (shows visual border around focused window)
- In resize mode:
  - H/L - Make window slimmer/wider (30px increments)
  - K/J - Make window shorter/taller (30px increments)
  - Escape - Exit resize mode

**Virtual Spaces (i3-like workspaces):**
- Alt+1/2/3/4 - Switch to virtual space 1/2/3/4
- Alt+Shift+1/2/3/4 - Move focused window to virtual space 1/2/3/4
- New windows automatically assigned to current virtual space
- Focus per virtual space is preserved when switching
- Works seamlessly with native macOS window switching (Cmd+Tab, Mission Control)

**System UI:**
- Ctrl+Alt+Cmd+D - Toggle menubar visibility
- Ctrl+Alt+Cmd+R - Reload Hammerspoon configuration

## Development Workflow

When modifying dotfiles:

1. Edit files in `dotfiles/` directory
2. Run `make -f Makefile.macos <target>` to install to home directory
3. Test the configuration
4. Commit changes to git

When adding new dotfiles:

1. Add the source file to `dotfiles/`
2. Add the target path to the appropriate Makefile variable (e.g., `dotfiles = ... ~/.newfile`)
3. The pattern rule will handle installation automatically

## Important Notes

- This is a personal configuration repo - changes are highly opinionated
- MacPorts must be installed before running most targets
- The `defaults` target modifies macOS system settings (Dock, Safari, etc.)
- Vim plugins are managed manually via git clone, not a plugin manager
- Color scheme integration across terminal and vim using base16-shell
