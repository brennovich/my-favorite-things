.PHONY = \
	applications/2bwm \
	applications/dropbox \
	applications/locker \
	applications/mpd \
	applications/mpv \
	applications/ncmpcpp \
	applications/neovim \
	applications/ranger \
	applications/redshift \
	applications/scrot \
	applications/selecta \
	applications/taskwarrior \
	applications/weechat \
	applications/zathura

applications/2bwm: ~/.bin/launcher ~/.bin/random-gradient-wallpaper
	- cd $(PWD)/2bwm-pkgbuild && makepkg -cf
	- pacaur -U --noconfirm $(PWD)/2bwm-pkgbuild/2bwm-git*.tar.xz

applications/redshift: ~/.config/redshift.conf
	- pacaur -S --noconfirm --needed \
		redshift

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

applications/mpv:
	- sudo pacman -S --noconfirm --needed mpv

applications/ncmpcpp: ~/.ncmpcpp/bindings ~/.ncmpcpp/config

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
