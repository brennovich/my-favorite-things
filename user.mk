include config.mk

.PHONY = \
	user/desktop \
	user/dotfiles \
	user/fonts \
	user/media

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

# Generalistic task to copy dotifles' templates
~/.%: templates/dotfiles/*
	- mkdir -p $(@D)
	- $(macrocmd) \
		templates/dotfiles/$* \
		> $@

# User's System services
/etc/systemd/system/%: templates/etc/systemd/system/*
	- sudo mkdir -p $(@D)
	- $(macrocmd) \
		templates/etc/systemd/system/$* \
		| sudo dd of=$@

# User scripts
~/.bin/%: templates/dotfiles/bin/*
	- mkdir -p $(@D)
	- $(macrocmd) \
		templates/dotfiles/bin/$* \
		> $@
	- chmod +x $@

user/dotfiles: $(dotfiles)

user/media: applications/mpd applications/ncmpcpp applications/mpv
	- pacaur -S --noconfirm --needed \
		sxiv

user/desktop: applications/redshift applications/2bwm applications/locker ~/.bin/panel
	- pacaur -S --noconfirm --needed \
		compton \
		dmenu \
		hsetroot \
		lemonbar-xft-git \
		wmutils-git \
		xorg-xprop \
		xorg-xfd \
		xorg-xsetroot

user/fonts:
	- pacaur -S --noconfirm --needed \
		siji-git \
		tamzen-font-git \
		ttf-fira-mono \
		ttf-fira-sans \
		ttf-fira-code

environments/scala: ~/.sbt/0.13/sbt-ctags.sbt ~/.sbt/0.13/plugins/plugins.sbt

clean/dotfiles:
	rm -rf $(dotfiles)
