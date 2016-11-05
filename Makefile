include config.mk

macrocmd = m4 \
	   -Duser_name="$(user-name)" \
	   -Duser="$(user-nick)" \
	   -Duser_email="$(user-email)" \
	   macros.m4

include core.mk
include user.mk

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

# Sound infrastructure powered by pulseaudio plus mpd and ncmpcpp for music
user:  user/media

clean: clean/dotfiles clean/tmp
