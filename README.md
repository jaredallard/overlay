# overlay

@jaredallard's overlay for Gentoo Linux.

## Usage

I recommend using `app-eselect/eselect-repository`: `emerge --ask app-eselect/eselect-repository`

```bash
# Git instance I use:
eselect repository add jaredallard git https://git.rgst.io/jaredallard/overlay.git

# Or, Github if you prefer!
eselect repository add jaredallard git https://github.com/jaredallard/overlay.git
```

### Optional (but recommended): Un/mask individual packages

This is recommended as per Gentoo's [ebuild repository best practices].

First, mask all of the packages in this overlay:

```bash
mkdir -p /etc/portage/package.mask
echo "*/*::jaredallard" >/etc/portage/package.mask/jaredallard
```

Then, unmask packages as needed by either;

* Automatic (via `dispatch-conf`): `emerge -av --autounmask <package>::jaredallard`
* Manual: Create a file in `/etc/portage/package.unmask`

## Development

### Regenerating All Manifests

If, for some reason, you need to regenerate the following `fd` (`find`
replacement) command may be useful:

```bash
fd -e ebuild -x dirname | sort | uniq | xargs -o -n1 ./rebuild-manifest.sh
```

## License

GPL-2.0

[ebuild repository best practices]: https://wiki.gentoo.org/wiki/Ebuild_repository#Masking_enabled_ebuild_repositories
