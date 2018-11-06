dotfiles = \
	~/.gitconfig \
	~/.gitignore \
	~/.config/user-dirs.dirs \
	~/.compton.conf \
	~/.ctags \
	~/.bashrc \
	~/.bash_profile \

dwm:
	mkdir -p ~/.my-favorite-things/ \
		&& cp wallpapers/cats.png ~/.my-favorite-things/wallpaper.png
	cp dwm.h dwm/config.h
	cd dwm \
		&& git checkout . \
		&& for p in ../patches/dwm/*; do git apply $$p; done \
		&& sudo make clean install

slstatus:
	cp slstatus.h slstatus/config.h
	cd slstatus \
		&& git checkout . \
		&& for p in ../patches/slstatus/*; do git apply $$p; done \
		&& sudo make clean install

slock: /etc/systemd/system/locker.service
	- sudo xbps-install -SAy xautolock libXrandr-devel
	cp slock.h slock/config.h
	cd slock \
		&& git co . \
		&& sudo make clean install

dmenu:
	cp dmenu.h dmenu/config.h
	cd dmenu \
		&& sudo make clean install

st:
	cp st.h st/config.h
	cd st \
		&& git checkout . \
		&& for p in ../patches/st/*; do git apply $$p; done \
		&& sudo make clean install

scala:
	sudo pacman -S --noconfirm --needed \
		sbt

golang: ~/.env-golang
	sudo pacman -S --noconfirm --needed \
		go \
		go-tools
	source ~/.env-golang
	vim +GoInstallBinaries +qall
	curl https://glide.sh/get | sh

js:
	sudo pacman -S --noconfirm --needed \
		nodejs-lts-boron \
		npm

rust: ~/.env-rust
	curl https://sh.rustup.rs -sSf \
		| sh -s -- --no-modify-path
	rustup install stable
	rustup default stable
	rustup run stable cargo install rustfmt

config_path = ~/.vim
vim: ~/.vimrc
	- sudo xbps-install -S \
		ctags
	rm -rf $(config_path)/pack
	mkdir -p $(config_path)/backups $(config_path)/pack/plugins/start
	cd $(config_path)/pack/plugins/start \
		&& git clone https://github.com/chriskempson/base16-vim.git \
		&& git clone https://github.com/derekwyatt/vim-scala.git \
		&& git clone https://github.com/fatih/vim-go.git \
		&& git clone https://github.com/tpope/vim-fugitive.git \
		&& git clone https://github.com/tpope/vim-markdown.git \
		&& git clone https://github.com/rust-lang/rust.vim.git \
		&& git clone https://github.com/tpope/vim-sensible.git \
		&& git clone https://github.com/tpope/vim-sleuth.git \
		&& git clone https://github.com/tpope/vim-vinegar.git

mpd: ~/.config/mpd/mpd.conf ~/.config/systemd/user/mpd.service
	sudo pacman -S --noconfirm --needed mpd mpc
	mkdir -p ~/.mpd/playlists
	systemctl --user daemon-reload
	systemctl --user enable mpd.service
	systemctl --user start mpd.service

ncmpcpp: ~/.ncmpcpp/bindings ~/.ncmpcpp/config
	sudo pacman -S --noconfirm --needed ncmpcpp

mpv:
	sudo pacman -S --noconfirm --needed \
		mpv

ranger: ~/.config/ranger/rc.conf ~/.bin/previewer ~/.bin/imgt
	sudo pacman -S --noconfirm --needed \
		highlight \
		ranger \
		w3m

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

.PHONY: dwm slstatus slock dmenu st
