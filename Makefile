include config.mk

macrocmd = m4 \
	   -Duser_name="$(user-name)" \
	   -Duser_nick="$(user-nick)" \
	   -Duser_email="$(user-email)" \
	   macros.m4 \
	   $(colorscheme).m4

include core.mk
include user.mk
include applications.mk

.PHONY = system user

# Every system configuration such as core packages, tty config, kernel module configs, etc
system: \
	packages/aur-helper \
	packages/bluetooth \
	packages/core \
	packages/power \
	packages/sound \
	packages/web \
	packages/utils \
	packages/xorg \
	/etc/vconsole.conf \
	/etc/modprobe.d/i915.conf

user:  user/media user/fonts user/desktop user/dotfiles

clean: clean/dotfiles clean/tmp
