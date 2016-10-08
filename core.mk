.PHONY = packages/core \
	packages/power \
	packages/aur-helper \
	packages/aur-helper/cower \
	packages/sound \
	packages/utils

packages/aur-helper/cower: clean/tmp
	- gpg --recv-keys 487EACC08557AD082088DABA1EB2638FF56C0C53 # Dave Reisner, cower maintainer
	- mkdir -p tmp \
		&& cd tmp \
		&& curl -L -O "https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz" \
		&& tar -xvf cower.tar.gz \
		&& cd cower \
		&& makepkg -sri --noconfirm

packages/aur-helper: packages/aur-helper/cower
	cd tmp \
		&& curl -L -O "https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz" \
		&& tar -xvf pacaur.tar.gz \
		&& cd pacaur \
		&& makepkg -sri --noconfirm

packages/core:
	sudo pacman -S --noconfirm \
		bash-completion \
		git-core \
		openssh

packages/power:
	- sudo pacman -S --noconfirm \
		acpi \
		ethtool \
		powertop \
		rfkill \
		tlp \
		x86_energy_perf_policy
	- sudo systemctl enable tlp.service tlp-sleep.service
	- sudo systemctl start tlp.service tlp-sleep.service

packages/sound:
	- sudo pacman -S --noconfirm \
		mpc \
		mpd \
		ncmpcpp \
		pavucontrol \
		pulseaudio \
		pulseaudio-bluetooth

packages/thinkpad460s:
	- pacaur -S --noconfirm \
		aic94xx-firmware \
		wd719x-firmware

packages/utils:
	- sudo pacman -S --noconfirm \
		ctags \
		xsel

packages/web:
	- sudo pacman -S --noconfirm \
		firefox

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
packages/xorg: /etc/X11/xorg.conf.d/20-intel.conf
	- sudo pacman -S --noconfirm \
		rxvt-unicode \
		mesa-vdpau \
		xf86-input-libinput \
		xf86-video-intel \
		xorg-xinit \
		xorg-xrandr \
		xorg-xrdb \
		xorg-server

/etc/vconsole.conf: templates/etc/vconsole.conf
	- sudo pacman -S --noconfirm terminus-font
	- sudo cp ./templates/vconsole.conf /etc/vconsole.conf

/etc/modprobe.d/%.conf: templates/etc/modprobe.d/*
	- sudo cp $< $@

/etc/X11/xorg.conf.d/%.conf: templates/etc/X11/xorg.conf.d/*
	- sudo cp $< $@

clean/tmp: tmp*
	rm -rf tmp/*
