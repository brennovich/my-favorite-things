include config.mk

.PHONY = \
	applications/dropbox \
	applications/locker \
	applications/mpd \
	applications/ncmpcpp \
	applications/scrot \
	user/dotfiles \
	user/media

dotfiles = \
	~/.gitconfig \
	~/.gitignore \
	~/.ctags \
	~/.bashrc \
	~/.bash_profile \
	~/.xinitrc \
	~/.Xresources \
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

user/media: applications/mpd applications/ncmpcpp applications/mplayer

applications/bspwm: ~/.config/bspwm/bspwmrc ~/.config/sxhkd/sxhkdrc ~/.compton.conf
	- sudo pacman -S --noconfirm --needed \
		bspwm \
		compton \
		dmenu \
		feh \
		sxhkd
	- chmod +x ~/.config/bspwm/bspwmrc
	- killall compton
	- ~/.config/bspwm/bspwmrc
	- pkill -USR1 -x sxhkd

applications/dropbox:
	- pacaur -S dropbox dropbox-cli --noconfirm --needed
	- systemctl --user enable dropbox.service
	- systemctl --user start dropbox.service
	- dropbox-cli exclude add ~/Dropbox/Backup ~/Dropbox/love-mondays ~/Dropbox/books_da_broderage


applications/mpd: ~/.config/mpd/mpd.conf ~/.config/systemd/user/mpd.service
	- mkdir -p ~/.mpd/playlists
	- systemctl --user daemon-reload
	- systemctl --user enable mpd.service
	- systemctl --user start mpd.service

applications/ncmpcpp: ~/.ncmpcpp/bindings ~/.ncmpcpp/config

applications/mplayer:
	- sudo pacman -S --noconfirm mplayer

applications/scrot:
	- sudo pacman -S --noconfirm --needed scrot
	- mkdir -p ~/Pictures/screenshots

applications/locker: ~/.bin/my-favorite-things-locker /etc/systemd/system/my-favorite-things-locker.service
	- sudo systemctl enable my-favorite-things-locker.service
	- cp templates/dotfiles/my-favorite-things/lock-icon.png ~/.my-favorite-things/lock-icon.png
	- chmod +x ~/.bin/my-favorite-things-locker
	- pacaur -S --noconfirm --needed \
		i3lock \
		imagemagick

clean/dotfiles:
	rm -rf $(dotfiles)
