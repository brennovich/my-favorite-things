include config.mk

.PHONY = \
	applications/dropbox \
	applications/mpd \
	applications/ncmpcpp \
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

clean/dotfiles:
	rm -rf $(dotfiles)
