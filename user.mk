include config.mk

.PHONY = \
	applications/dropbox \
	applications/locker \
	applications/mpd \
	applications/ncmpcpp \
	applications/scrot \
	user/desktop \
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
		xorg-xsetroot

applications/2bwm: ~/.bin/launcher
	- cd $(PWD)/2bwm-pkgbuild && makepkg -cf
	- pacaur -U --noconfirm $(PWD)/2bwm-pkgbuild/2bwm-git*.tar.xz

applications/redshift: ~/.config/redshift.conf
	- pacaur -S --noconfirm --needed \
		redshift

user/fonts:
	- sudo pacman -S --noconfirm --needed \
		ttf-fira-mono \
		ttf-fira-sans

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

applications/mpv:
	- sudo pacman -S --noconfirm --needed mpv

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

config_path = ~/.config/nvim
applications/neovim: $(config_path)/init.vim
	- sudo pacman -S --noconfirm --needed neovim
	- rm -rf $(config_path)/bundle
	- mkdir -p $(config_path)/autoload $(config_path)/backups $(config_path)/bundle
	- curl -LSso $(config_path)/autoload/pathogen.vim https://tpo.pe/pathogen.vim
	- cd $(config_path)/bundle \
		&& git clone https://github.com/chriskempson/base16-vim.git \
		&& git clone https://github.com/derekwyatt/vim-scala.git \
		&& git clone https://github.com/neomake/neomake.git \
		&& git clone https://github.com/tpope/vim-fugitive.git \
		&& git clone https://github.com/tpope/vim-sensible.git \
		&& git clone https://github.com/tpope/vim-sleuth.git \
		&& git clone https://github.com/tpope/vim-vinegar.git

applications/ranger: ~/.config/ranger/rc.conf ~/.bin/previewer ~/.bin/imgt
	- sudo pacman -S --noconfirm --needed \
		highlight \
		ranger \
		w3m

applications/zathura:
	- sudo pacman -S --noconfirm --needed \
		zathura \
		zathura-pdf-mupdf

applications/selecta:
	- sudo pacman -S --noconfirm --needed \
		ruby
	- curl -o ~/.bin/selecta "https://raw.githubusercontent.com/garybernhardt/selecta/master/selecta"
	- chmod +x ~/.bin/selecta

environments/scala: ~/.sbt/0.13/sbt-ctags.sbt ~/.sbt/0.13/plugins/plugins.sbt

clean/dotfiles:
	rm -rf $(dotfiles)
