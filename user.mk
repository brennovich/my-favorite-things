include config.mk

.PHONY = user/dotfiles user/media applications/mpd applications/ncmpcpp

dotfiles = \
	~/.gitconfig \
	~/.gitignore \
	~/.ctags \
	~/.bashrc \
	~/.bash_profile \
	~/.xinitrc \
	~/.Xresources \
	~/.Xresources.d/urxvt

user/dotfiles: $(dotfiles)

user/media: applications/mpd applications/ncmpcpp

applications/mpd: ~/.config/mpd/mpd.conf ~/.config/systemd/user/mpd.service
	- mkdir -p ~/.mpd
	- systemctl --user daemon-reload
	- systemctl --user enable mpd.service
	- systemctl --user start mpd.service

applications/ncmpcpp: ~/.ncmpcpp/bindings ~/.ncmpcpp/config

# Generalistic task to copy dotifles' templates
~/.%: templates/dotfiles/*
	- mkdir -p $(@D)
	- $(macrocmd) \
		templates/dotfiles/$* \
		> $@

clean/dotfiles:
	rm -rf $(dotfiles)
