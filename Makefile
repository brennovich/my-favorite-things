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
		&& sudo make clean install

slstatus:
	cp slstatus.h slstatus/config.h
	cd slstatus \
		&& git co . \
		&& for p in ../patches/slstatus/*; do git apply $$p; done \
		&& sudo make clean install
slock: /etc/systemd/system/locker.service
	yay -S xautolock --needed
	cp slock.h slock/config.h
	cd slock \
		&& git co . \
		&& sudo make clean install
	sudo systemctl enable locker.service
	sudo systemctl start locker.service
dmenu:
	cp dmenu.h dmenu/config.h
	cd dmenu \
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

launcher: ~/.bin/launcher
	sudo pacman -S --noconfirm --needed \
		dmenu

newsboat: ~/.bin/url_handler.sh ~/.newsboat/config
	sudo pacman -S --noconfirm --needed \
		newsboat

youtube: applications/newsboat applications/mpv
	sudo pacman -S --noconfirm --needed \
		mps-youtube \
		youtube-dl


dunst: ~/.config/dunst/dunstrc
	yay -S --noconfirm --needed \
		dunst-git
	systemctl --user enable dunst.service
	systemctl --user start dunst.service

nextcloud:
	yay -S --noconfirm --needed \
		gnome-keyring \
		nextcloud-client

config_path = ~/.vim
vim: ~/.vimrc
	sudo pacman -S --noconfirm --needed \
		ctags \
		gvim \
		vim-spell-en
	rm -rf $(config_path)/pack
	mkdir -p $(config_path)/backups $(config_path)/pack/plugins/start
	cd $(config_path)/pack/plugins/start \
		&& git clone https://github.com/chriskempson/base16-vim.git \
		&& git clone https://github.com/derekwyatt/vim-scala.git \
		&& git clone https://github.com/fatih/vim-go.git \
		&& git clone https://github.com/tpope/vim-apathy.git \
		&& git clone https://github.com/tpope/vim-fugitive.git \
		&& git clone https://github.com/tpope/vim-markdown.git \
		&& git clone https://github.com/tpope/vim-repeat.git \
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

zathura:
	sudo pacman -S --noconfirm --needed \
		zathura \
		zathura-pdf-mupdf

termite: ~/.bin/colorful-termite ~/.config/termite/config ~/.config/gtk-3.0/gtk.css
	if ! [ -d ~/.config/base16-termite ]; then git clone https://github.com/khamer/base16-termite.git ~/.config/base16-termite; fi
	sudo pacman -S --noconfirm --needed \
		termite

utils:
	sudo pacman -S --noconfirm \
		bash-completion \
		ctags \
		git-core \
		openssh  \
		unzip \
		xclip \
		xsel

xorg: 
	sudo mkdir -p /etc/X11/xorg.conf.d
	$(MAKE) /etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/00-keyboard.conf
	- sudo pacman -S --noconfirm --needed \
		libva-intel-driver \
		xf86-input-libinput \
		xf86-video-intel \
		xorg-server \
		xorg-xinit \
		xorg-xrandr \
		xorg-xrdb

# System
#

power: /etc/modprobe.d/i915.conf
	sudo pacman -S --noconfirm \
		ethtool \
		powertop \
		rfkill \
		tlp \
		x86_energy_perf_policy
	sudo systemctl enable tlp.service tlp-sleep.service
	sudo systemctl start tlp.service tlp-sleep.service

sound: /etc/modprobe.d/blacklist.conf /etc/modprobe.d/snd_hda_intel.conf
	pacaur -S --noconfirm --needed \
		pulsemixer \
		pulseaudio \
		pulseaudio-bluetooth
	pulseaudio -D

bluetooth:
	sudo pacman -S --noconfirm --needed \
		bluez \
		bluez-utils
	sudo systemctl enable bluetooth.service
	sudo systemctl start bluetooth.service

x200: /etc/thinkfan.conf
	sudo pacaur -S --noconfirm --needed \
		acpi_call \
		libva-intel-driver-g45-h264 \
		tp_smapi

/etc/vconsole.conf: templates/etc/vconsole.conf
	sudo pacman -S --noconfirm terminus-font
	sudo cp ./templates/vconsole.conf /etc/vconsole.conf

~/.%: dotfiles/*
	mkdir -p $(@D)
	cp dotfiles/$* $@

/etc/systemd/system/%: etc/systemd/system/*
	sudo mkdir -p $(@D)
	sudo cp etc/systemd/system/$* $@

~/.bin/%: dotfiles/bin/*
	mkdir -p $(@D)
	cp dotfiles/bin/$* $@
	chmod +x $@

.PHONY: dwm slstatus slock dmenu
