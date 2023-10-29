# overlay

@jaredallard's overlay for Gentoo Linux.

## Usage

I recommend using `app-eselect/eselect-repository`: `emerge --ask app-eselect/eselect-repository`

```bash
eselect repository add jaredallard-overlay git https://github.com/jaredallard/overlay.git
```

Otherwise, if using `layman`:

```bash
layman -o https://raw.githubusercontent.com/jaredallard/overlay/main/repositories.xml -f -a jaredallard-overlay
```

## License

GPL-2.0
