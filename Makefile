SHELL := /bin/bash

dotfiles = \
	~/.zshrc \
	~/.gitconfig \
	~/.gitignore \
	~/.env-brew \
	~/.env-ports \
	~/.env-claude \
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
	gem install ripper-tags

node: ~/.env-node
	brew install nvm
	. "$$(brew --prefix nvm)/nvm.sh" \
		&& nvm install --lts

lua:
	brew install lua luarocks

k8s: ~/.env-k8s

claude: ~/.env-claude ~/.claude/CLAUDE.md ~/.claude/commands/commit.md ~/.claude/skills/writing-commit-messages/SKILL.md
	curl -fsSL https://claude.ai/install.sh | bash

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
		&& git clone --depth 1 https://github.com/jxnblk/vim-mdx-js.git \
		&& git clone --depth 1 https://github.com/rust-lang/rust.vim.git \
		&& git clone --depth 1 https://github.com/tpope/vim-bundler.git \
		&& git clone --depth 1 https://github.com/tpope/vim-fugitive.git \
		&& git clone --depth 1 https://github.com/tpope/vim-markdown.git \
		&& git clone --depth 1 https://github.com/tpope/vim-repeat.git \
		&& git clone --depth 1 https://github.com/vim-ruby/vim-ruby.git \
		&& git clone --depth 1 https://github.com/tpope/vim-sensible.git \
		&& git clone --depth 1 https://github.com/tpope/vim-sleuth.git \
		&& git clone --depth 1 https://github.com/tpope/vim-surround \
		&& git clone --depth 1 https://github.com/tpope/vim-projectionist.git \
		&& git clone --depth 1 https://github.com/tpope/vim-rails.git \
		&& git clone --depth 1 https://github.com/tpope/vim-vinegar.git \
		&& git clone --depth 1 https://github.com/yasuhiroki/github-actions-yaml.vim \
		&& git clone --depth 1 https://github.com/aareman/shellspec.vim

kitty: ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.app.icns
	brew install --cask kitty
	mkdir -p ~/.config/kitty/themes
	cp ~/.vim/pack/plugins/start/marques-de-itu/kitty/marques-de-itu-dark.conf ~/.config/kitty/themes/marques-de-itu-dark.conf
	cp ~/.vim/pack/plugins/start/marques-de-itu/kitty/marques-de-itu-light.conf ~/.config/kitty/themes/marques-de-itu-light.conf

ghostty: ~/.config/ghostty/config
	brew install --cask ghostty
	mkdir -p ~/.config/ghostty/themes
	cp ~/.vim/pack/plugins/start/marques-de-itu/ghostty/marques-de-itu-dark ~/.config/ghostty/themes/marques-de-itu-dark
	cp ~/.vim/pack/plugins/start/marques-de-itu/ghostty/marques-de-itu-light ~/.config/ghostty/themes/marques-de-itu-light

terminal_plist = $(HOME)/Library/Preferences/com.apple.Terminal.plist
theme_path = $(HOME)/.vim/pack/plugins/start/marques-de-itu/terminalapp
terminal:
	brew install --cask font-go font-fira-code font-jetbrains-mono
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

colors: ~/.bin/colorscheme ~/.env-theme

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

ctags: ~/.ctags ~/.bin/reload-ctags
	brew install universal-ctags

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
