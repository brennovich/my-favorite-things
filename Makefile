# Configuration
#
# Variables used in m4 templates
user-email = brennolncosta@gmail.com
user-name = Brenno Costa
user-nick = $(USER)
colorscheme = base16-dark

# Template parsing command
macrocmd = m4 \
	   -Duser_name="$(user-name)" \
	   -Duser_nick="$(user-nick)" \
	   -Duser_email="$(user-email)" \
	   macros.m4 \
	   $(colorscheme).m4

# Userspace
#

dotfiles = \
	~/.gitconfig \
	~/.gitignore \
	~/.ctags \
	~/.bashrc \
	~/.bash_profile \
	~/.xinitrc \
	~/.Xresources \
	~/.Xresources.d/2bwm \
	~/.Xresources.d/colorscheme \
	~/.Xresources.d/urxvt \
	~/.Xresources.d/xterm

user/dotfiles: $(dotfiles)

user/desktop: applications/i3wm \
		applications/urxvt \
		applications/dunst \
		~/.compton.conf \
		~/.bin/launcher
	- pacaur -S --noconfirm --needed \
		compton \
		dmenu \
		hsetroot \
		xorg-xsetroot

user/environments/scala:
	- sudo pacman -S --noconfirm --needed \
		sbt

user/environments/golang: ~/.env-golang
	- sudo pacman -S --noconfirm --needed \
		go \
		go-tools
	- go get -u github.com/rogpeppe/godef
	- go get -u github.com/nsf/gocode
	- curl https://glide.sh/get | sh

user/environments/js:
	- sudo pacman -S --noconfirm --needed \
		nodejs-lts-boron \
		npm

user/environments/rust: ~/.env-rust
	- curl https://sh.rustup.rs -sSf \
		| sh -s -- --no-modify-path
	- rustup install nightly
	- rustup default nightly
	- rustup run nightly cargo install rustfmt-nightly

# Applications
#

applications/i3wm: ~/.xinitrc \
	~/.config/i3/config \
	~/.config/i3status/config \
	applications/redshift \
	applications/zathura \
	applications/ranger \
	applications/locker
	- sudo pacman -S --noconfirm --needed \
		compton \
		gnome-keyring \
		gnome-power-manager \
		i3-wm \
		i3lock \
		i3status \
		maim \
		sxiv \
		xorg-xrandr

applications/dunst:
	- pacaur -S --noconfirm --needed \
		dunst-git \
		dunst-service
	- systemctl --user enable dunst.service
	- systemctl --user start dunst.service

applications/redshift: ~/.config/redshift.conf
	- pacaur -S --noconfirm --needed \
		redshift

applications/nextcloud: ~/.config/systemd/user/nextcloud-client.service
	- pacaur -S --noconfirm --needed \
		gnome-keyring \
		nextcloud-client
	- systemctl --user enable nextcloud-client.service

config_path = ~/.vim
applications/vim: ~/.vimrc
	- sudo pacman -S --noconfirm --needed \
		ctags \
		gvim \
		vim-spell-en
	- rm -rf $(config_path)/pack
	- mkdir -p $(config_path)/backups $(config_path)/pack/plugins/start
	- cd $(config_path)/pack/plugins/start \
		&& git clone https://github.com/chriskempson/base16-vim.git \
		&& git clone https://github.com/derekwyatt/vim-scala.git \
		&& git clone https://github.com/fatih/vim-go.git \
		&& git clone https://github.com/tpope/vim-fugitive.git \
		&& git clone https://github.com/tpope/vim-markdown.git \
		&& git clone https://github.com/tpope/vim-repeat.git \
		&& git clone https://github.com/tpope/vim-rsi.git \
		&& git clone https://github.com/tpope/vim-sensible.git \
		&& git clone https://github.com/tpope/vim-sleuth.git \
		&& git clone https://github.com/tpope/vim-surround.git \
		&& git clone https://github.com/tpope/vim-vinegar.git

applications/mpd: ~/.config/mpd/mpd.conf ~/.config/systemd/user/mpd.service
	- sudo pacman -S --noconfirm --needed mpd mpc
	- mkdir -p ~/.mpd/playlists
	- systemctl --user daemon-reload
	- systemctl --user enable mpd.service
	- systemctl --user start mpd.service

applications/mpv:
	- sudo pacman -S --noconfirm --needed mpv

applications/ncmpcpp: ~/.ncmpcpp/bindings ~/.ncmpcpp/config
	- sudo pacman -S --noconfirm --needed ncmpcpp

applications/ranger: ~/.config/ranger/rc.conf ~/.bin/previewer ~/.bin/imgt
	- sudo pacman -S --noconfirm --needed \
		highlight \
		ranger \
		w3m

applications/zathura:
	- sudo pacman -S --noconfirm --needed \
		zathura \
		zathura-pdf-mupdf

applications/taskwarrior: ~/.taskrc
	- sudo pacman -S --noconfirm --needed \
		task

applications/urxvt: ~/.Xresources.d/urxvt
	- sudo pacman -S --noconfirm --needed \
		rxvt-unicode \
		urxvt-perls

applications/xterm: ~/.Xresources.d/xterm
	- sudo pacman -S --noconfirm --needed \
		xterm \

applications/locker: ~/.bin/my-favorite-things-locker /etc/systemd/system/my-favorite-things-locker.service
	- sudo systemctl enable my-favorite-things-locker.service
	- cp templates/dotfiles/my-favorite-things/lock-icon.png ~/.my-favorite-things/lock-icon.png
	- chmod +x ~/.bin/my-favorite-things-locker
	- sudo pacman -S --noconfirm --needed \
		maim \
		i3lock \
		imagemagick

applications/firefox:
	- pacaur -S --noconfirm --needed \
		firefox-nightly

applications/docker:
	- sudo pacman -S --noconfirm --needed \
		docker \
		lxc
	- sudo gpasswd -a $(USER) docker

# Core
#

core/utils:
	sudo pacman -S --noconfirm \
		bash-completion \
		ctags \
		git-core \
		openssh  \
		unzip \
		xsel

core/fonts:
	- pacaur -S --noconfirm --needed \
		siji-git \
		tamzen-font-git \
		ttf-bitstream-vera \
		ttf-opensans \
		ttf-xorg-fonts-misc \
		ttf-xorg-fonts-alias \
		ttf-dejavu \
		ttf-fira-mono \
		ttf-fira-sans \
		ttf-roboto \
		ttf-droid \
		ttf-ubuntu-font-family

core/aur-helper: core/aur-helper/cower
	cd tmp \
		&& curl -L -O "https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz" \
		&& tar -xvf pacaur.tar.gz \
		&& cd pacaur \
		&& makepkg -sri --noconfirm
core/aur-helper/cower: clean/tmp
	- gpg --recv-keys 487EACC08557AD082088DABA1EB2638FF56C0C53 # Dave Reisner, cower maintainer
	- mkdir -p tmp \
		&& cd tmp \
		&& curl -L -O "https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz" \
		&& tar -xvf cower.tar.gz \
		&& cd cower \
		&& makepkg -sri --noconfirm

# Setup Xorg and its basic drivers and tools.
#
# NOTICE: Isn't possible to eliminate DDX intel drivers yet as modesetting generic driver has
# heavy tearing under Thinkpad 460s Skylake Intel GPU.
#
# TODO: Do not forget to re-check this after Xorg updates, modesetting has better performance
# and less bugs than Intel's SNA AccellMethod.
#
# UPDATE: Well, actually using intel DDX drivers is problematic as the system simply freezes
# when RC6 powersaving is being used which makes it impracticable.
#
core/xorg: /etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/00-keyboard.conf ~/.drirc
	- sudo pacman -S --noconfirm --needed \
		libva-intel-driver \
		libvdpau-va-gl \
		xf86-input-libinput \
		xf86-video-intel \
		xorg-server \
		xorg-xinit \
		xorg-xrandr \
		xorg-xrdb \
		xterm

# System
#

system/power: /etc/modprobe.d/i915.conf
	- sudo pacman -S --noconfirm \
		acpi \
		ethtool \
		powertop \
		rfkill \
		tlp \
		x86_energy_perf_policy
	- sudo systemctl enable tlp.service tlp-sleep.service
	- sudo systemctl start tlp.service tlp-sleep.service

system/sound: /etc/modprobe.d/blacklist.conf /etc/modprobe.d/snd_hda_intel.conf
	- pacaur -S --noconfirm --needed \
		pamixer \
		pulsemixer \
		pulseaudio \
		pulseaudio-bluetooth
	- pulseaudio -D

system/bluetooth:
	- sudo pacman -S --noconfirm --needed \
		bluez \
		bluez-utils
	- sudo systemctl enable bluetooth.service
	- sudo systemctl start bluetooth.service

# Device specific
#

device/x200: /etc/thinkfan.conf
	- sudo pacaur -S --noconfirm --needed \
		acpi_call \
		libva-intel-driver-g45-h264 \
		thinkfan \
		tp_smapi
	- sudo rmmod thinkpad_acpi
	- sudo modprobe thinkpad_acpi
	- sudo systemctl enable thinkfan
	- sudo systemctl start thinkfan

device/thinkpad460s:
	- pacaur -S --noconfirm \
		aic94xx-firmware \
		wd719x-firmware

# Task utils
#

/etc/vconsole.conf: templates/etc/vconsole.conf
	- sudo pacman -S --noconfirm terminus-font
	- sudo cp ./templates/vconsole.conf /etc/vconsole.conf

/etc/modprobe.d/%: templates/etc/modprobe.d/*
	- sudo cp templates/etc/modprobe.d/$* $@

/etc/%: templates/etc/*
	- sudo cp templates/etc/$* $@

/etc/X11/xorg.conf.d/%.conf: templates/etc/X11/xorg.conf.d/*
	- sudo cp templates/etc/X11/xorg.conf.d/$*.conf $@

~/.%: templates/dotfiles/*
	- mkdir -p $(@D)
	- $(macrocmd) \
		templates/dotfiles/$* \
		> $@

/etc/systemd/system/%: templates/etc/systemd/system/*
	- sudo mkdir -p $(@D)
	- $(macrocmd) \
		templates/etc/systemd/system/$* \
		| sudo dd of=$@

~/.bin/%: templates/dotfiles/bin/*
	- mkdir -p $(@D)
	- $(macrocmd) \
		templates/dotfiles/bin/$* \
		> $@
	- chmod +x $@

clean/tmp:
	- mkdir -p tmp
	- rm -rf tmp/*
