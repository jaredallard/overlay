# overlay

@jaredallard's overlay for Gentoo Linux.

## Usage

I recommend using `app-eselect/eselect-repository`: `emerge --ask app-eselect/eselect-repository`

```bash
# Git instance I use:
eselect repository add jaredallard-overlay git https://git.rgst.io/jaredallard/overlay.git

# Or, Github if you prefer!
eselect repository add jaredallard-overlay git https://github.com/jaredallard/overlay.git
```

## Development

### Regenerating All Manifests

If, for some reason, you need to regenerate the following `fd` (`find`
replacement) command may be useful:

```bash
fd -e ebuild -x dirname | sort | uniq | xargs -o -n1 ./rebuild-manifest.sh
```

## License

GPL-2.0
