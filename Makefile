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
	~/.Xresources.d/urxvt
user/dotfiles: $(dotfiles)

user/desktop: applications/redshift applications/2bwm applications/locker applications/urxvt ~/.compton.conf ~/.bin/launcher
	- pacaur -S --noconfirm --needed \
		compton \
		dmenu \
		hsetroot \
		xorg-xsetroot

environments/scala: ~/.sbt/0.13/sbt-ctags.sbt ~/.sbt/0.13/plugins/plugins.sbt

# Applications
#

applications/2bwm:
	- sudo pacman -S --noconfirm --needed \
		xcb-util-keysyms \
		xcb-util-wm \
		xcb-util-xrm
	- cd $(PWD)/2bwm-pkgbuild && makepkg -cf
	- sudo pacman -U --noconfirm $(PWD)/2bwm-pkgbuild/2bwm-git*.tar.xz

applications/redshift: ~/.config/redshift.conf
	- pacaur -S --noconfirm --needed \
		redshift

applications/emacs: ~/.emacs.d/init.el
	- pacaur -S --noconfirm --needed \
		emacs

config_path = ~/.config/nvim
applications/neovim: $(config_path)/init.vim
	- sudo pacman -S --noconfirm --needed \
		neovim \
		python2 \
		python2-pip
	- sudo pip2 install websocket-client sexpdata neovim
	- rm -rf $(config_path)/bundle
	- mkdir -p $(config_path)/autoload $(config_path)/backups $(config_path)/bundle
	- curl -LSso $(config_path)/autoload/pathogen.vim https://tpo.pe/pathogen.vim
	- cd $(config_path)/bundle \
		&& git clone https://github.com/chriskempson/base16-vim.git \
		&& git clone https://github.com/derekwyatt/vim-scala.git \
		&& git clone https://github.com/ensime/ensime-vim.git \
		&& git clone https://github.com/neomake/neomake.git \
		&& git clone https://github.com/tpope/vim-fugitive.git \
		&& git clone https://github.com/tpope/vim-sensible.git \
		&& git clone https://github.com/tpope/vim-sleuth.git \
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

applications/weechat:
	- sudo pacman -S --noconfirm --needed \
		python2 \
		python2-pip \
		weechat
	- pip2 install websocket-client
	- mkdir -p ~/.weechat/python/autoload
	- curl -o ~/.weechat/python/autoload/wee_slack.py "https://raw.githubusercontent.com/rawdigits/wee-slack/master/wee_slack.py"

applications/zathura:
	- sudo pacman -S --noconfirm --needed \
		zathura \
		zathura-pdf-mupdf

applications/selecta:
	- sudo pacman -S --noconfirm --needed \
		ruby
	- curl -o ~/.bin/selecta "https://raw.githubusercontent.com/garybernhardt/selecta/master/selecta"
	- chmod +x ~/.bin/selecta

applications/taskwarrior: ~/.taskrc
	- sudo pacman -S --noconfirm --needed \
		task

applications/urxvt: ~/.Xresources.d/urxvt
	- sudo pacman -S --noconfirm --needed \
		rxvt-unicode \
		urxvt-perls

applications/locker: ~/.bin/my-favorite-things-locker /etc/systemd/system/my-favorite-things-locker.service applications/scrot
	- sudo systemctl enable my-favorite-things-locker.service
	- cp templates/dotfiles/my-favorite-things/lock-icon.png ~/.my-favorite-things/lock-icon.png
	- chmod +x ~/.bin/my-favorite-things-locker
	- sudo pacman -S --noconfirm --needed \
		i3lock \
		imagemagick

applications/scrot:
	- sudo pacman -S --noconfirm --needed scrot
	- mkdir -p ~/Pictures/screenshots

applications/firefox:
	- pacaur -S --noconfirm --needed \
		firefox-nightly

applications/docker:
	- sudo pacman -S --noconfirm --needed \
		docker \
		lxc
	- sudo systemctl enable docker.service
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
		ttf-dejavu \
		ttf-fira-mono \
		ttf-fira-sans \
		ttf-ms-fonts \
		ttf-roboto \
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
		xterm \
		xorg-xinit \
		xorg-xrandr \
		xorg-xrdb \
		xorg-server

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
	- sudo pacman -S --noconfirm --needed \
		acpi_call \
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
