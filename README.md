## My Favorite Things

This project that is named just like [John Coltrane's album](https://en.wikipedia.org/wiki/My_Favorite_Things_(album))
it's an attempt to automate every step of a fresh Arch Linux installation. It assume a custom workflow used by me, and
builds an environment with this workflow in mind.

Everything is automated using `make` and `m4`. There are many utilities and system specific scripts in order to provide
seamless integration.

### Usage

You can take advantage of whole `make` tasks bundle, or specific ones:

```sh
# Install everything necessary for core functions like sound, power, bluetooth, aur-helper, etc
make system

# Install and configure VIm
make applications/vim
```

### Extensibility

Tasks have a small degree of configuration, basically provided by `m4`, for few applications configuration you can
define a coloscheme and your personal info like name and email, please look at `config.mk`.

### Preview

Here are a few photos, I'm using a grayscale colorscheme with a deep focus intent:

![Clean desktop](https://cloud.githubusercontent.com/assets/379894/21473970/c7ebf358-caf7-11e6-895f-4f7322dbbdd1.png)
![Colorscheme](https://cloud.githubusercontent.com/assets/379894/21473971/c7f0c162-caf7-11e6-9ee4-c63e512535e7.png)
![VIm](https://cloud.githubusercontent.com/assets/379894/21473972/c7f1cf6c-caf7-11e6-81ad-f460d0af875a.png)
