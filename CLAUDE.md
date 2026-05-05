# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal macOS system configuration and dotfiles repository. Named after John Coltrane's album "My Favorite Things". Highly opinionated — changes should match the existing workflow rather than introduce new conventions.

## Build System

GNU Make drives everything. The root `Makefile` is the only Makefile; older docs (including `README.md`) still reference `Makefile.macos` — that's stale, use `Makefile`.

```sh
make <target>                    # e.g. make dotfiles
make dotfiles colors vim         # multiple targets
make clean                       # rm -rf tmp/*
```

### Targets

- `dotfiles` — copies shell/git configs (zshrc, gitconfig, env-*, ctags, hushlogin) to `~/`; depends on `colors`
- `colors` — installs `~/.bin/colorscheme` and `~/.env-theme` (base16 switcher)
- `vim` — installs vim via brew, wipes `~/.vim/pack`, clones plugins fresh
- `kitty`, `ghostty`, `terminal` — install terminal emulators and copy `marques-de-itu` themes from the cloned vim plugin
- `hammerspoon` — installs Hammerspoon, copies local Spoons, downloads `RoundedCorners`, `ToggleMenubar`, and `VirtualSpaces` Spoons from GitHub releases
- `golang`, `rust`, `ruby`, `node`, `lua`, `k8s` — language toolchains
- `claude` — installs Claude Code CLI and copies `dotfiles/claude/` into `~/.claude/`
- `ctags` — installs universal-ctags and reload helper
- `media` — installs VLC; downloads `yt-dlp` binary via curl into `~/.bin/`
- `feeds` — installs newsboat and copies its config
- `github` — installs `gh`
- `defaults` — writes macOS preferences (Dock, Safari, etc.); has destructive side effects (`killall Dock`)

### Pattern Rules

```makefile
~/.bin/%: dotfiles/bin/*    # files in dotfiles/bin/ → ~/.bin/<name> (chmod +x)
~/.%:     dotfiles/*        # files in dotfiles/<x> → ~/.<x>
/etc/%:   etc/*             # files in etc/<x> → /etc/<x> (sudo)
```

Adding a new dotfile: drop it in `dotfiles/`, add the target path to the appropriate variable in the Makefile (e.g. add `~/.newrc` to the `dotfiles` variable). The pattern rule handles the copy.

`~/.config/...` paths work with the same `~/.%` rule because the source lives at `dotfiles/config/...` (e.g. `~/.config/ghostty/config` ← `dotfiles/config/ghostty/config`).

## Package Management

Homebrew is the sole package manager. MacPorts references in older commits are gone. Some tools are installed outside brew:
- `yt-dlp` — curled directly from GitHub releases
- `rust` — `rustup` installer script
- `ToggleMenubar`, `VirtualSpaces`, `RoundedCorners` Spoons — downloaded as release zips

Environment files (`dotfiles/env-*`) are sourced by `zshrc` to set up PATH and per-tool config.

## Hammerspoon

`dotfiles/hammerspoon/init.lua` is the entry point. Spoons are loaded via `hs.loadSpoon("Name")` and accessed as `spoon.Name:method()`.

### Local Spoons

- `dotfiles/hammerspoon/Spoons/WMUtils.spoon/` — window management (movement, grid halves with toggle-restore, monocle/telescope modes, resize modal). Has a luaunit test suite — see below.

### External Spoons (downloaded by `make hammerspoon`)

- `RoundedCorners` — Hammerspoon/Spoons official repo
- `ToggleMenubar` — `brennovich/ToggleMenubar.spoon` releases
- `VirtualSpaces` — `brennovich/VirtualSpaces.spoon` releases (i3-like virtual workspaces; previously vendored here, now external)

Keybindings live in `init.lua` — read it directly rather than relying on docs. The grid is 6×6 with `gap = 20`.

### Running WMUtils Tests

```sh
cd dotfiles/hammerspoon/Spoons/WMUtils.spoon
luarocks test                                            # runs all tests via rockspec
eval $(luarocks --local path) && lua tests/test.lua      # direct invocation
```

`tests/test.lua` aggregates the suite; individual files (`test_wmutils.lua`, `test_bind_hotkeys.lua`, `test_tile.lua`, `test_tiled_resize.lua`, `test_virtualspaces_integration.lua`) use mocks for `hs.*` APIs so they run without Hammerspoon.

## Development Workflow

1. Edit files under `dotfiles/`
2. Run `make <target>` to install into `~/`
3. Reload as appropriate (Hammerspoon: Ctrl+Alt+Cmd+R; shell: new session; vim: restart)
4. Commit

The `defaults` target is destructive (modifies system preferences and kills Dock/SystemUIServer) — don't run it speculatively.
