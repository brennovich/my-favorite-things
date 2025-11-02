dotfiles = \
	~/.zshrc \
	~/.gitconfig \
	~/.gitignore \
	~/.env-brew \
	~/.env-ports \
	~/.ctags

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
	sudo port install ruby34
	sudo port select --set ruby ruby34

node: ~/.env-node
	sudo port install nvm

k8s: ~/.env-k8s

config_path = ~/.vim
vim: ~/.vimrc
	sudo port install vim +huge
	rm -rf $(config_path)/pack
	mkdir -p $(config_path)/backups $(config_path)/pack/plugins/start
	cd $(config_path)/pack/plugins/start \
		&& git clone https://github.com/brennovich/marques-de-itu.git \
		&& git clone https://github.com/clojure-vim/clojure.vim.git \
		&& git clone https://github.com/derekwyatt/vim-scala.git \
		&& git clone https://github.com/fatih/vim-go.git \
		&& git clone https://github.com/github/copilot.vim.git \
		&& git clone https://github.com/rust-lang/rust.vim.git \
		&& git clone https://github.com/tpope/vim-fugitive.git \
		&& git clone https://github.com/tpope/vim-markdown.git \
		&& git clone https://github.com/tpope/vim-repeat.git \
		&& git clone https://github.com/tpope/vim-sensible.git \
		&& git clone https://github.com/tpope/vim-sleuth.git \
		&& git clone https://github.com/tpope/vim-surround \
		&& git clone https://github.com/tpope/vim-vinegar.git \
		&& git clone https://github.com/yasuhiroki/github-actions-yaml.vim \
		&& git clone https://github.com/aareman/shellspec.vim

colors: ~/.bin/colorscheme ~/.env-theme
	if ! [ -d ~/.config/base16-shell ]; then git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell; fi

defaults:
	defaults write com.apple.dock autohide-time-modifier -float 0
	defaults write -g NSWindowShouldDragOnGesture -bool true
	defaults write -g ApplePressAndHoldEnabled -bool false
	defaults write com.apple.dock "mru-spaces" -bool "false"
	defaults write com.apple.Music "userWantsPlaybackNotifications" -bool "false" && killall Music
	defaults write com.apple.dock "autohide" -bool "true"
	defaults write com.apple.dock "show-recents" -bool "false"
	defaults write com.apple.dock launchanim -bool false
	defaults write com.apple.dock mru-spaces -bool false
	defaults write com.apple.Safari UniversalSearchEnabled -bool false
	defaults write com.apple.Safari SuppressSearchSuggestions -bool true
	defaults write com.apple.Safari IncludeDevelopMenu -bool true
	defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
	defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
	defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
	defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
	defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
	killall Dock

github:
	brew install gh

media: vlc ~/.bin/ytvlc
	which yt-dls &> /dev/null || curl -SsL -o ~/.bin/yt-dlp 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos'; chmod a+rx ~/.bin/yt-dlp
	brew install --cask qlvideo vlc

feeds: ~/.newsboat/config ~/.newsboat/urls
	which newsboat &> /dev/null || sudo port install newsboat

hammerspoon: ~/.hammerspoon/init.lua
	which hs &> /dev/null || brew install --cask hammerspoon
	mkdir -p ~/.hammerspoon/Spoons
	cp -R dotfiles/hammerspoon/Spoons/* ~/.hammerspoon/Spoons/
	cd ~/.hammerspoon/Spoons \
		&& curl -LO https://github.com/Hammerspoon/Spoons/raw/master/Spoons/RoundedCorners.spoon.zip \
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
