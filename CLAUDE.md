# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal macOS system configuration and dotfiles repository. The project automates computer setup with a custom workflow using Makefile-based automation. Named after John Coltrane's album "My Favorite Things".

## Build System

This project uses GNU Make for all automation:

```sh
make <target>

# Install multiple components
make dotfiles colors vim

# Clean temporary files
make clean
```

### Key Targets

- `dotfiles` - Installs shell configurations (zshrc, gitconfig, etc.) to home directory
- `colors` - Sets up base16-shell color scheme system
- `vim` - Installs vim via Homebrew and configures plugins
- `golang`, `rust`, `ruby`, `node`, `lua` - Language environment setup
- `media` - Installs VLC and yt-dlp for media handling
- `feeds` - Installs and configures newsboat RSS reader
- `hammerspoon` - Installs Hammerspoon, copies custom Spoons, downloads external Spoons (RoundedCorners, ToggleMenubar, VirtualSpaces)
- `karabiner` - Installs Karabiner-Elements and copies config; remaps left-option to F18 so it drives Hammerspoon's hyper modal while right-option stays a native Option key for special characters
- `defaults` - Configures macOS system preferences via defaults command
- `github` - Installs GitHub CLI
- `kitty` - Installs kitty terminal with custom theme
- `terminal` - Configures Terminal.app with custom theme (auto-detects dark/light mode)
- `claude` - Installs Claude Code CLI and copies config
- `ctags` - Installs universal-ctags with config
- `wattage` - Compiles the Swift SMC helper in `src/wattage/` to `~/.bin/wattage`; prints total system power draw in watts (SMC key `PSTR`, `PDTR` fallback), consumed by the Pager wattage display in Hammerspoon. The only compiled tool in the repo — everything else in `~/.bin` is copied from `dotfiles/bin/`. Also built as a dependency of `hammerspoon`

## Testing

### Hammerspoon Spoon Tests (Lua)

Tests use `luaunit` (install with `luarocks install luaunit`) and live inside each Spoon's `tests/` directory. Run from the Spoon directory:

```sh
cd dotfiles/hammerspoon/Spoons/WMUtils.spoon
lua tests/test.lua

# Run a single test suite
lua tests/test.lua -p TestWMUtilsTelescope
```

`tests/test.lua` is the aggregating entry point: each test module returns a list of suites that must be `require`d and assigned to a global (e.g. `TestWMUtilsTile`) there. A new test file is not run until it is registered in `tests/test.lua`. The `-p` flag is luaunit's pattern filter on those global suite names.

### Wattage Helper Tests (Swift)

```sh
make test-wattage
```

Assert-based tests for the SMC value decoding in `src/wattage/tests/main.swift`, compiled together with `SMC.swift` into `build/wattage_test` (a multi-file `swiftc` build only allows top-level statements in a file named `main.swift`).

## Architecture

### Installation Pattern

The Makefile uses pattern rules for copying dotfiles:

```makefile
~/.%: dotfiles/*
    mkdir -p $(@D)
    cp -R dotfiles/$* $@
```

Files in `dotfiles/` are copied to `~/` with a dot prefix. For example:
- `dotfiles/zshrc` → `~/.zshrc`
- `dotfiles/vimrc` → `~/.vimrc`
- `dotfiles/bin/colorscheme` → `~/.bin/colorscheme`

Binary files in `dotfiles/bin/` get `chmod +x` via a separate pattern rule.

### Package Management

The project uses Homebrew as its package manager:
- Homebrew (`brew`): For system tools, languages, casks (Hammerspoon, VLC, kitty)

Environment files (`dotfiles/env-*`) are sourced by zshrc to configure PATH and tool-specific settings.

### Hammerspoon (init.lua)

Lua-based macOS automation with i3-like window management. Uses a Spoon-based architecture.

**Spoon Loading:**
Spoons are loaded using `hs.loadSpoon("SpoonName")` and accessed via the global `spoon` table:
- Load: `hs.loadSpoon("WMUtils")`
- Access: `spoon.WMUtils:methodName()`

**Keybinding chain (spans two files):**
Karabiner remaps `left_option` → `F18` (`dotfiles/config/karabiner/karabiner.json`). In `hammerspoon/init.lua`, `F18` enters/exits a `hs.hotkey.modal` named `hyper`. Every window-management, VirtualSpaces, and resize binding is registered on `hyper`, so it is the single entry point for the whole keymap. `caps_lock` is separately remapped to `left_control`. The resize sub-mode is a nested modal entered from `hyper` via `ctrl+R`.

**Custom Spoons (in repo):**
- **WMUtils.spoon** - Window management utilities (move, resize, center, grid positioning with toggle-restore, monocle, telescope mode). Bindings are attached via `bindHotkeys`/`bindResizeHotkeys`, which take the `hyper` modal so all shortcuts live behind it. Has test coverage.

**External Spoons (downloaded during `make hammerspoon`):**
- **VirtualSpaces.spoon** - i3-like virtual workspace system
- **ToggleMenubar.spoon** - Toggle macOS menubar visibility
- **RoundedCorners** - Visual enhancement for window corners

### Vim Configuration

- Classic vim (not neovim) with manual plugin management
- Plugins installed to `~/.vim/pack/plugins/start/` via git clone
- Custom color scheme: marques-de-itu (also used for kitty and Terminal.app themes)

### Custom Utilities (dotfiles/bin/)

- `colorscheme` - Base16 color scheme switcher
- `ytvlc` - YouTube video player wrapper for VLC
- `ytchrss` - YouTube channel RSS feed helper
- `logbook` - Personal logging tool

## Development Workflow

When modifying dotfiles:

1. Edit files in `dotfiles/` directory
2. Run `make <target>` to install to home directory
3. Test the configuration

When adding new dotfiles:

1. Add the source file to `dotfiles/`
2. Add the target path to the appropriate Makefile variable (e.g., `dotfiles = ... ~/.newfile`)
3. The pattern rule will handle installation automatically

## Important Notes

- This is a personal configuration repo - changes are highly opinionated
- Homebrew must be installed before running most targets
- The `defaults` target modifies macOS system settings (Dock, Safari, etc.)
- Color scheme integration across terminal and vim using marques-de-itu theme
