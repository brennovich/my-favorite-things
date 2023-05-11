dotfiles = \
	~/.gitconfig \
	~/.gitignore \
	~/.ctags

golang:
	brew install golang
	source ~/.env-golang
	vim +GoInstallBinaries +qall

rust: ~/.env-rust
	curl https://sh.rustup.rs -sSf \
		| sh -s -- --no-modify-path
	rustup install stable
	rustup default stable
	rustup run stable cargo install rustfmt

logbook: ~/.bin/logbook
	ln -sf ${HOME}/Nextcloud/notes/logbook ${HOME}/logbook
	ln -sf ${HOME}/Nextcloud/notes/links ${HOME}/links

ruby: ~/.env-ruby
	brew install rbenv ruby-build

config_path = ~/.vim
vim: ~/.vimrc
	rm -rf $(config_path)/pack
	mkdir -p $(config_path)/backups $(config_path)/pack/plugins/start
	cd $(config_path)/pack/plugins/start \
		&& git clone https://github.com/brennovich/base16-vim.git \
		&& git clone https://github.com/plan9-for-vimspace/acme-colors \
		&& git clone https://github.com/derekwyatt/vim-scala.git \
		&& git clone https://github.com/fatih/vim-go.git \
		&& git clone https://github.com/tpope/vim-fugitive.git \
		&& git clone https://github.com/tpope/vim-markdown.git \
		&& git clone https://github.com/rust-lang/rust.vim.git \
		&& git clone https://github.com/tpope/vim-sensible.git \
		&& git clone https://github.com/tpope/vim-sleuth.git \
		&& git clone https://github.com/tpope/vim-surround \
		&& git clone https://github.com/tpope/vim-vinegar.git

nvim: ~/.config/nvim/init.lua

colors: ~/.bin/colorscheme
	if ! [ -d ~/.config/base16-shell ]; then git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell; fi
	cd dark-mode-notify/ \
		&& swiftc main.swift -o ~/.bin/colorscheme-notify
	cp dark-mode-notify/colorscheme.plist ~/Library/LaunchAgents/brenno.costa-dark-mode-notify.plist
	launchctl load -w ~/Library/LaunchAgents/brenno.costa-dark-mode-notify.plist

mpv:
	brew install mpv

~/.%: dotfiles/*
	mkdir -p $(@D)
	cp dotfiles/$* $@

/etc/%: etc/*
	sudo mkdir -p $(@D)
	sudo cp etc/$* $@

~/.bin/%: dotfiles/bin/*
	mkdir -p $(@D)
	cp dotfiles/bin/$* $@
	chmod +x $@

clean:
	rm -rf tmp/*
	git submodule foreach git checkout .
	git submodule foreach git clean -f
