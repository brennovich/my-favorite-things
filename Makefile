dotfiles = \
	~/.gitconfig \
	~/.gitignore \
	~/.config/user-dirs.dirs \
	~/.compton.conf \
	~/.ctags \
	~/.bashrc \
	~/.config/fontconfig/conf.d/20-custom-overrides.conf \
	~/.inputrc

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

ruby: ~/.env-ruby
	sudo pacman --noconfirm --needed -S ruby
	if ! [ -d ~/.rbenv ]; then git clone https://github.com/rbenv/rbenv.git ~/.rbenv; fi
	if ! [ -d ~/.rbenv/plugins/ruby-build ]; then mkdir -p ~/.rbenv/plugins/ruby-build/ && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build/; fi
	cd ~/.rbenv \
		&& git pull --rebase \
		&& src/configure \
		&& make -C src
	cd ~/.rbenv/plugins/ruby-build/ \
		&& git pull --rebase
	mkdir -p ~/.rbenv/plugins
	git clone git://github.com/tpope/rbenv-ctags.git ~/.rbenv/plugins/rbenv-ctags

mft: xorg \
	dotfiles \
	dwm \
	slstatus \
	slock \
	dmenu \
	st \
	~/.xinitrc \
	~/.bin/random-gradient-wallpaper
	sudo pacman --noconfirm --needed -S \
		gnome-keyring \
		hsetroot \
		light \
		xsel \
		compton \
		maim

dwm:
	mkdir -p ~/.my-favorite-things/ \
		&& cp wallpapers/cats.png ~/.my-favorite-things/wallpaper.png
	cp dwm.h dwm/config.h
	cd dwm \
		&& git checkout . \
		&& for p in ../patches/dwm/*; do echo $$p && git apply $$p; done \
		&& sudo make clean install

slstatus:
	cp slstatus.h slstatus/config.h
	cd slstatus \
		&& git checkout . \
		&& for p in ../patches/slstatus/*; do git apply $$p; done \
		&& sudo make clean install

slock: /etc/systemd/system/locker.service
	sudo pacman -S xautolock --needed
	cp slock.h slock/config.h
	cd slock \
		&& git co . \
		&& sudo make clean install
	sudo systemctl enable locker.service

dmenu: ~/.dmenu_exclude
	cp dmenu.h dmenu/config.h
	cd dmenu \
		&& git checkout . \
		&& for p in ../patches/dmenu/*; do git apply $$p; done \
		&& sudo make clean install

st:
	cp st.h st/config.h
	cd st \
		&& git checkout . \
		&& for p in ../patches/st/*; do git apply $$p; done \
		&& sudo make clean install
	if ! [ -d ~/.config/base16-shell ]; then git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell; fi

keybase: ~/.config/bash-completion/bash_completion
	sudo pacman -S --noconfirm --needed \
		keybase
	mkdir -p ~/.config/bash-completion/completions
	curl -o ~/.config/bash-completion/completions/keybase "https://raw.githubusercontent.com/tiersch/keybase-completion/master/keybase"

newsboat: ~/.bin/url_handler.sh ~/.newsboat/config
	sudo pacman -S --noconfirm --needed \
		newsboat

youtube: newsboat applications/mpv
	sudo pacman -S --noconfirm --needed \
		mps-youtube \
		youtube-dl

dunst: ~/.config/dunst/dunstrc
	yay -S --noconfirm --needed \
		dunst-git
	systemctl --user enable dunst.service
	systemctl --user start dunst.service

config_path = ~/.vim
vim: ~/.vimrc
	rm -rf $(config_path)/pack
	mkdir -p $(config_path)/backups $(config_path)/pack/plugins/start
	cd $(config_path)/pack/plugins/start \
		&& git clone https://github.com/brennovich/base16-vim.git \
		&& git clone https://github.com/derekwyatt/vim-scala.git \
		&& git clone https://github.com/fatih/vim-go.git \
		&& git clone https://github.com/tpope/vim-fugitive.git \
		&& git clone https://github.com/tpope/vim-markdown.git \
		&& git clone https://github.com/rust-lang/rust.vim.git \
		&& git clone https://github.com/tpope/vim-sensible.git \
		&& git clone https://github.com/tpope/vim-sleuth.git \
		&& git clone https://github.com/tpope/vim-surround \
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

fonts: ~/.config/fontconfig/conf.d/20-custom-overrides.conf
	sudo pacman -S --noconfirm --needed \
		cantarell-fonts \
		ttf-dejavu \
		ttf-fira-code \
		ttf-fira-mono \
		ttf-fira-sans \
		ttf-opensans \
		noto-fonts \
		noto-fonts-cjk \
		noto-fonts-emoji
	curl -SL -o "tmp/iosevka.zip" "https://github.com/be5invis/Iosevka/releases/download/v2.3.0/01-iosevka-2.3.0.zip" \
		&& cd tmp \
		&& unzip iosevka.zip \
		&& mkdir -p ~/.fonts \
		&& cp ttf/* ~/.fonts
	curl -SL -o "tmp/material.zip" "https://github.com/Templarian/MaterialDesign-Webfont/archive/v4.5.95.zip" \
		&& cd tmp \
		&& unzip material.zip \
		&& mkdir -p ~/.fonts \
		&& cp MaterialDesign-Webfont-4.5.95/fonts/materialdesignicons-webfont.ttf ~/.fonts

redshift: ~/.config/redshift.conf
	sudo pacman -S redshift

nextcloud:
	curl -o tmp/nextcloud "https://download.nextcloud.com/desktop/releases/Linux/Nextcloud-2.6.1-x86_64.AppImage" \
		&& cd tmp \
		&& chmod +x nextcloud \
		&& mv nextcloud ~/.bin/nextcloud

modern-utils: ~/.config/bat/config
	sudo pacman -S --noconfirm --needed \
		ripgrep \
		bat \
		hyperfine \
		exa

utils:
	sudo pacman -S --noconfirm --needed \
		bash-completion \
		ctags \
		git \
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
	yay -S --noconfirm --needed \
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

security: /etc/resolv.conf
	sudo pacman -S --noconfirm \
		dnscrypt-proxy
	sudo systemctl enable dnscrypt-proxy.service
	sudo systemctl start dnscrypt-proxy.service
	sudo chattr +i /etc/resolv.conf

x200: /etc/thinkfan.conf
	yay -S --noconfirm --needed \
		acpi_call \
		libva-intel-driver-g45-h264 \
		tp_smapi

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

.PHONY: dwm slstatus slock dmenu st
