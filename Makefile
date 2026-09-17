SHELL := /bin/bash

arch := $(shell uname -m)
PKG ?= $(if $(filter arm64,$(arch)),brew,port)
pkg_install = $(if $(filter brew,$(PKG)),brew install $(1),port -N install $(2))
pkg_env = $(if $(filter brew,$(PKG)),~/.env-brew,~/.env-ports)

dotfiles = \
	~/.zshrc \
	~/.gitconfig \
	~/.gitignore \
	$(pkg_env) \
	~/.env-claude \
	~/.ctags.d/swift.ctags \
	~/.ctags.d/scala.ctags \
	~/.ctags.d/exclude.ctags \
	~/.hushlogin

dotfiles: $(dotfiles) colors

pkg: pkg/$(PKG)

pkg/brew:
	which brew &> /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

macports_version = 2.12.6
macports_src = tmp/MacPorts-$(macports_version)
pkg/port: /opt/local/bin/port
	$< selfupdate

/opt/local/bin/port: $(macports_src).tar.bz2
	[ -w /opt/local ] || { sudo mkdir -p /opt/local && sudo chown $$(id -un):$$(id -gn) /opt/local; }
	mkdir -p /Applications/MacPorts
	tar -xjf $< -C tmp
	cd $(macports_src) \
		&& env PATH=/usr/bin:/bin:/usr/sbin:/sbin ./configure \
			--prefix=/opt/local \
			--with-no-root-privileges \
			--without-startupitems \
			--with-applications-dir=/Applications/MacPorts \
		&& make \
		&& make install

$(macports_src).tar.bz2:
	mkdir -p $(@D)
	curl -fsSL -o $@ https://github.com/macports/macports-base/releases/download/v$(macports_version)/MacPorts-$(macports_version).tar.bz2

golang: ~/.env-golang
	$(call pkg_install,golang,go)
	source ~/.env-golang
	vim +GoInstallBinaries +qall

rust: ~/.env-rust
	curl https://sh.rustup.rs -sSf \
		| sh -s -- --no-modify-path
	rustup install stable
	rustup default stable
	rustup run stable cargo install rustfmt

ruby: ~/.env-ruby ~/.gemrc
	$(call pkg_install,rbenv ruby-build,rbenv ruby-build)
	version=$$(rbenv install -l 2> /dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$$' | tail -1) \
		&& rbenv install -s $$version \
		&& rbenv global $$version
	rbenv exec gem install ripper-tags

nvm_sh = $(if $(filter brew,$(PKG)),$$(brew --prefix nvm)/nvm.sh,/opt/local/share/nvm/init-nvm.sh)
node: ~/.env-node
	$(call pkg_install,nvm,nvm)
	. "$(nvm_sh)" \
		&& nvm install --lts

lua:
	$(call pkg_install,lua luarocks,lua54 lua54-luarocks)

k8s: ~/.env-k8s

claude_settings = $(HOME)/.claude/settings.json
claude: ~/.env-claude ~/.claude/CLAUDE.md ~/.claude/commands/commit.md ~/.claude/skills/writing-commit-messages/SKILL.md ~/.bin/claude-statusline
	curl -fsSL https://claude.ai/install.sh | bash
	[ -s $(claude_settings) ] || echo '{}' > $(claude_settings)
	jq '.statusLine = { type: "command", command: "~/.bin/claude-statusline" }' \
		$(claude_settings) > $(claude_settings).new \
		&& mv $(claude_settings).new $(claude_settings)

config_path = ~/.vim
vim: ~/.vimrc
	$(call pkg_install,vim,vim)
	rm -rf $(config_path)/pack
	mkdir -p $(config_path)/backups $(config_path)/pack/plugins/start
	cd $(config_path)/pack/plugins/start \
		&& git clone --depth 1 https://github.com/aareman/shellspec.vim \
		&& git clone --depth 1 https://github.com/brennovich/marques-de-itu.git \
		&& git clone --depth 1 https://github.com/clojure-vim/clojure.vim.git \
		&& git clone --depth 1 https://github.com/derekwyatt/vim-scala.git \
		&& git clone --depth 1 https://github.com/fatih/vim-go.git \
		&& git clone --depth 1 https://github.com/github/copilot.vim.git \
		&& git clone --depth 1 https://github.com/jxnblk/vim-mdx-js.git \
		&& git clone --depth 1 https://github.com/keith/swift.vim \
		&& git clone --depth 1 https://github.com/pgr0ss/vim-github-url \
		&& git clone --depth 1 https://github.com/rust-lang/rust.vim.git \
		&& git clone --depth 1 https://github.com/tpope/vim-bundler.git \
		&& git clone --depth 1 https://github.com/tpope/vim-fugitive.git \
		&& git clone --depth 1 https://github.com/tpope/vim-markdown.git \
		&& git clone --depth 1 https://github.com/tpope/vim-projectionist.git \
		&& git clone --depth 1 https://github.com/tpope/vim-rails.git \
		&& git clone --depth 1 https://github.com/tpope/vim-repeat.git \
		&& git clone --depth 1 https://github.com/tpope/vim-sensible.git \
		&& git clone --depth 1 https://github.com/tpope/vim-sleuth.git \
		&& git clone --depth 1 https://github.com/tpope/vim-surround \
		&& git clone --depth 1 https://github.com/tpope/vim-vinegar.git \
		&& git clone --depth 1 https://github.com/vim-ruby/vim-ruby.git \
		&& git clone --depth 1 https://github.com/yasuhiroki/github-actions-yaml.vim

kitty: fonts ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.app.icns
	$(call pkg_install,--cask kitty,kitty)
	mkdir -p ~/.config/kitty/themes
	cp ~/.vim/pack/plugins/start/marques-de-itu/kitty/marques-de-itu-dark.conf ~/.config/kitty/themes/marques-de-itu-dark.conf
	cp ~/.vim/pack/plugins/start/marques-de-itu/kitty/marques-de-itu-light.conf ~/.config/kitty/themes/marques-de-itu-light.conf

ghostty: fonts /Applications/Ghostty.app ~/.config/ghostty/config
	mkdir -p ~/.config/ghostty/themes
	cp ~/.vim/pack/plugins/start/marques-de-itu/ghostty/marques-de-itu-dark ~/.config/ghostty/themes/marques-de-itu-dark
	cp ~/.vim/pack/plugins/start/marques-de-itu/ghostty/marques-de-itu-light ~/.config/ghostty/themes/marques-de-itu-light

terminal_plist = $(HOME)/Library/Preferences/com.apple.Terminal.plist
theme_path = $(HOME)/.vim/pack/plugins/start/marques-de-itu/terminalapp
terminal: fonts
	defaults write com.apple.Terminal ShowDocumentProxyIcon -bool false
	defaults write -g NSToolbarTitleViewRolloverDelay -float 0.5
	defaults write com.apple.Terminal ShowLineMarks -bool false
	-/usr/libexec/PlistBuddy -c "Delete ':Window Settings:Marques de Itu Dark'" $(terminal_plist)
	/usr/libexec/PlistBuddy \
		-c "Add ':Window Settings:Marques de Itu Dark' dict" \
		-c "Merge '$(theme_path)/Marques de Itu Dark.terminal' ':Window Settings:Marques de Itu Dark'" \
		$(terminal_plist)
	-/usr/libexec/PlistBuddy -c "Delete ':Window Settings:Marques de Itu Light'" $(terminal_plist)
	/usr/libexec/PlistBuddy \
		-c "Add ':Window Settings:Marques de Itu Light' dict" \
		-c "Merge '$(theme_path)/Marques de Itu Light.terminal' ':Window Settings:Marques de Itu Light'" \
		$(terminal_plist)
	if defaults read -g AppleInterfaceStyle &> /dev/null; then \
		defaults write com.apple.Terminal "Default Window Settings" -string "Marques de Itu Dark"; \
		defaults write com.apple.Terminal "Startup Window Settings" -string "Marques de Itu Dark"; \
	else \
		defaults write com.apple.Terminal "Default Window Settings" -string "Marques de Itu Light"; \
		defaults write com.apple.Terminal "Startup Window Settings" -string "Marques de Itu Light"; \
	fi

ghostty_cask = $(shell curl -fsSL https://formulae.brew.sh/api/cask/ghostty.json)
/Applications/Ghostty.app:
	mkdir -p tmp/ghostty
	curl -fsSL -o tmp/ghostty.dmg $(shell echo '$(ghostty_cask)' | jq -r .url)
	echo "$(shell echo '$(ghostty_cask)' | jq -r .sha256)  tmp/ghostty.dmg" | shasum -a 256 -c
	hdiutil attach -quiet -nobrowse -readonly -mountpoint tmp/ghostty tmp/ghostty.dmg
	cp -R tmp/ghostty/Ghostty.app $@ || { hdiutil detach -quiet tmp/ghostty; exit 1; }
	hdiutil detach -quiet tmp/ghostty

colors: ~/.bin/colorscheme ~/.env-theme
	git -C ~/.vim/pack/plugins/start/marques-de-itu pull --rebase

defaults:
	defaults write -g NSMenuEnableActionImages -bool NO
	defaults write -g NSWindowShouldDragOnGesture -bool true
	defaults write -g ApplePressAndHoldEnabled -bool false
	defaults write com.apple.dock "mru-spaces" -bool "false"
	defaults write com.apple.Music "userWantsPlaybackNotifications" -bool "false"
	defaults write com.apple.dock "autohide" -bool "true"
	defaults write com.apple.dock "show-recents" -bool "false"
	defaults write com.apple.dock launchanim -bool false
	defaults write com.apple.dock mru-spaces -bool false
	defaults write -g EnableTilingByEdgeDrag -bool false
	defaults write -g EnableTopTilingByEdgeDrag -bool false
	defaults write -g EnableTilingOptionInWindowMenu -bool false
	defaults write com.apple.dock expose-group-apps -bool true
	- defaults write com.apple.screencapture disable-shadow -bool true; killall SystemUIServer
	- defaults write com.apple.Safari UniversalSearchEnabled -bool false
	- defaults write com.apple.Safari SuppressSearchSuggestions -bool true
	- defaults write com.apple.Safari IncludeDevelopMenu -bool true
	- defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	- defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
	- defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
	- defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
	- defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
	- defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
	killall Dock

defaults/powersaving:
	sudo pmset -a womp 0
	sudo pmset -a powernap 0
	sudo pmset -a tcpkeepalive 0
	sudo pmset -a standbydelayhigh 3600
	sudo pmset -a standbydelaylow 1800
	sudo pmset -b lowpowermode 1
	which blueutil &> /dev/null || $(call pkg_install,blueutil,blueutil)
	blueutil --power 0

ctags: ~/.ctags.d/swift.ctags ~/.ctags.d/scala.ctags ~/.ctags.d/exclude.ctags ~/.bin/reload-ctags
	$(call pkg_install,universal-ctags,universal-ctags)

github:
	$(call pkg_install,gh,gh)

media: ~/.bin/ytvlc /Applications/VLC.app qlvideo
	which yt-dlp &> /dev/null || curl -SsL -o ~/.bin/yt-dlp 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos'; chmod a+rx ~/.bin/yt-dlp

qlvideo_app = QuickLook Video.app
qlvideo_release = $(shell curl -fsSL https://api.github.com/repos/Marginal/QLVideo/releases/latest)
qlvideo_dmg = $(shell echo '$(qlvideo_release)' | jq -r .assets[0].browser_download_url)
qlvideo_sha = $(shell echo '$(qlvideo_release)' | jq -r '.assets[0].digest | sub("sha256:"; "")')
qlvideo:
	[ -d "/Applications/$(qlvideo_app)" ] || { \
		mkdir -p tmp/qlvideo \
		&& curl -fsSL -o tmp/qlvideo.dmg $(qlvideo_dmg) \
		&& echo "$(qlvideo_sha)  tmp/qlvideo.dmg" | shasum -a 256 -c \
		&& hdiutil attach -quiet -nobrowse -readonly -mountpoint tmp/qlvideo tmp/qlvideo.dmg \
		&& { cp -R "tmp/qlvideo/$(qlvideo_app)" /Applications/; hdiutil detach -quiet tmp/qlvideo; }; \
	}

vlc_url = https://get.videolan.org/vlc/last/macosx
vlc_dmg = $(shell curl -fsSL $(vlc_url)/ | grep -oE 'vlc-[0-9.]+-$(if $(filter arm64,$(arch)),arm64,intel64)\.dmg' | head -1)
/Applications/VLC.app:
	mkdir -p tmp/vlc
	curl -fsSL -o tmp/$(vlc_dmg) $(vlc_url)/$(vlc_dmg)
	cd tmp && curl -fsSL $(vlc_url)/$(vlc_dmg).sha256 | shasum -a 256 -c
	hdiutil attach -quiet -nobrowse -readonly -mountpoint tmp/vlc tmp/$(vlc_dmg)
	cp -R tmp/vlc/VLC.app $@ || { hdiutil detach -quiet tmp/vlc; exit 1; }
	hdiutil detach -quiet tmp/vlc

feeds: ~/.newsboat/config ~/.newsboat/urls
	which newsboat &> /dev/null || $(call pkg_install,newsboat,newsboat)

wattage: ~/.bin/wattage

~/.bin/wattage: src/wattage/SMC.swift src/wattage/main.swift
	mkdir -p $(@D)
	swiftc -O -o $@ $^

test-wattage: src/wattage/SMC.swift src/wattage/tests/main.swift
	mkdir -p build
	swiftc -o build/wattage_test $^
	./build/wattage_test

~/.bin/%: dotfiles/bin/*
	mkdir -p $(@D)
	cp dotfiles/bin/$* $@
	chmod +x $@

~/.%: dotfiles/*
	mkdir -p $(@D)
	cp -R dotfiles/$* $@

go_fonts = \
	Go-Regular Go-Italic Go-Medium Go-Medium-Italic Go-Bold Go-Bold-Italic \
	Go-Smallcaps Go-Smallcaps-Italic Go-Mono Go-Mono-Italic Go-Mono-Bold Go-Mono-Bold-Italic
fonts: $(go_fonts:%=~/Library/Fonts/%.ttf)

~/Library/Fonts/Go-%.ttf:
	mkdir -p $(@D)
	curl -fsSL -o $@ https://raw.githubusercontent.com/golang/image/master/font/gofont/ttfs/Go-$*.ttf

/etc/%: etc/*
	sudo mkdir -p $(@D)
	sudo cp etc/$* $@

clean:
	rm -rf tmp/* build
