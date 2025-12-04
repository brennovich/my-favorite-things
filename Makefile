SHELL := /bin/bash

dotfiles = \
	~/.zshrc \
	~/.gitconfig \
	~/.gitignore \
	~/.env-brew \
	~/.env-ports \
	~/.ctags \
	~/.hushlogin

dotfiles: $(dotfiles) colors

golang: ~/.env-golang
	brew install golang
	source ~/.env-golang
	vim +GoInstallBinaries +qall

rust: ~/.env-rust
	curl https://sh.rustup.rs -sSf \
		| sh -s -- --no-modify-path
	rustup install stable
	rustup default stable
	rustup run stable cargo install rustfmt

ruby: ~/.env-ruby ~/.gemrc
	brew install rbenv ruby-build

node: ~/.env-node
	brew install nvm
	. "$$(brew --prefix nvm)/nvm.sh" \
		&& nvm install --lts

lua:
	brew install lua luarocks

k8s: ~/.env-k8s

claude: node ~/.claude/CLAUDE.md ~/.claude/commands/commit.md
	npm install -g @anthropic-ai/claude-code

config_path = ~/.vim
vim: ~/.vimrc
	brew install vim
	rm -rf $(config_path)/pack
	mkdir -p $(config_path)/backups $(config_path)/pack/plugins/start
	cd $(config_path)/pack/plugins/start \
		&& git clone --depth 1 https://github.com/brennovich/marques-de-itu.git \
		&& git clone --depth 1 https://github.com/clojure-vim/clojure.vim.git \
		&& git clone --depth 1 https://github.com/derekwyatt/vim-scala.git \
		&& git clone --depth 1 https://github.com/fatih/vim-go.git \
		&& git clone --depth 1 https://github.com/github/copilot.vim.git \
		&& git clone --depth 1 https://github.com/rust-lang/rust.vim.git \
		&& git clone --depth 1 https://github.com/tpope/vim-fugitive.git \
		&& git clone --depth 1 https://github.com/tpope/vim-markdown.git \
		&& git clone --depth 1 https://github.com/tpope/vim-repeat.git \
		&& git clone --depth 1 https://github.com/tpope/vim-sensible.git \
		&& git clone --depth 1 https://github.com/tpope/vim-sleuth.git \
		&& git clone --depth 1 https://github.com/tpope/vim-surround \
		&& git clone --depth 1 https://github.com/tpope/vim-vinegar.git \
		&& git clone --depth 1 https://github.com/yasuhiroki/github-actions-yaml.vim \
		&& git clone --depth 1 https://github.com/aareman/shellspec.vim

terminal: ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.app.icns
	brew install --cask kitty font-go
	mkdir -p ~/.config/kitty/themes
	cp ~/.vim/pack/plugins/start/marques-de-itu/kitty/marques-de-itu-dark.conf ~/.config/kitty/themes/marques-de-itu-dark.conf
	cp ~/.vim/pack/plugins/start/marques-de-itu/kitty/marques-de-itu-light.conf ~/.config/kitty/themes/marques-de-itu-light.conf

colors: ~/.bin/colorscheme ~/.env-theme

defaults:
	defaults write com.apple.dock autohide-time-modifier -float 0
	defaults write -g NSWindowShouldDragOnGesture -bool true
	defaults write -g ApplePressAndHoldEnabled -bool false
	defaults write com.apple.dock "mru-spaces" -bool "false"
	defaults write com.apple.Music "userWantsPlaybackNotifications" -bool "false"
	defaults write com.apple.dock "autohide" -bool "true"
	defaults write com.apple.dock "show-recents" -bool "false"
	defaults write com.apple.dock launchanim -bool false
	defaults write com.apple.dock mru-spaces -bool false
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

github:
	brew install gh

media: ~/.bin/ytvlc
	which yt-dls &> /dev/null || curl -SsL -o ~/.bin/yt-dlp 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos'; chmod a+rx ~/.bin/yt-dlp
	brew install --cask qlvideo vlc

feeds: ~/.newsboat/config ~/.newsboat/urls
	which newsboat &> /dev/null || brew install newsboat

hammerspoon: ~/.hammerspoon/init.lua dotfiles/hammerspoon/init.lua
	which hs &> /dev/null || brew install --cask hammerspoon
	rm -rf ~/.hammerspoon/Spoons
	mkdir -p ~/.hammerspoon/Spoons
	cp -R dotfiles/hammerspoon/Spoons/* ~/.hammerspoon/Spoons/
	cd ~/.hammerspoon/Spoons \
		&& curl -LO https://github.com/Hammerspoon/Spoons/raw/master/Spoons/RoundedCorners.spoon.zip \
		&& curl -LO https://github.com/brennovich/ToggleMenubar.spoon/releases/latest/download/ToggleMenubar.spoon.zip \
		&& curl -LO https://github.com/brennovich/VirtualSpaces.spoon/releases/latest/download/VirtualSpaces.spoon.zip \
		&& unzip -o \*.zip \
		&& rm *.zip


~/.bin/%: dotfiles/bin/*
	mkdir -p $(@D)
	cp dotfiles/bin/$* $@
	chmod +x $@

~/.%: dotfiles/*
	mkdir -p $(@D)
	cp -R dotfiles/$* $@

/etc/%: etc/*
	sudo mkdir -p $(@D)
	sudo cp etc/$* $@

clean:
	rm -rf tmp/*
