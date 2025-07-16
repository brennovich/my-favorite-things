## My Favorite Things

This project that is named just like [John Coltrane's album](https://en.wikipedia.org/wiki/My_Favorite_Things_(album)) it's an attempt to automate my computer setup. It assume a custom workflow used by me, and builds an environment with this workflow in mind.

Everything is automated using `make`. There are many utilities and system specific scripts in order to provide seamless integration.

### Features

Make tasks per platform to install and configure:

- **vim**: plain old vim, with classic plugins
- **colors**: a set of colors for minimal/distraction-free colors, for terminal and vim
- **dotfiles**: a set of dotfiles for my workflow
- **languages**: a set of languages and tools I use, like `go`, `ruby`, etc.

### Usage

You can take advantage of `make` tasks:

```sh
make -f Makefile.macos dotfiles colors vim
```

### Related Projects

- https://github.com/brennovich/marques-de-itu
