# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/-bin/}"
MY_PV="${PV/-r*/}"

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop linux-info optfeature unpacker xdg

DESCRIPTION="ArmCord is a custom client designed to enhance your Discord experience while keeping everything lightweight"
HOMEPAGE="https://github.com/ArmCord/ArmCord"
SRC_URI="
  amd64? ( https://github.com/ArmCord/ArmCord/releases/download/v${PV}/ArmCord-${PV}.tar.gz )
  arm64? ( https://github.com/ArmCord/ArmCord/releases/download/v${PV}/ArmCord-${PV}-arm64.tar.gz )
"

IUSE="appindicator +seccomp wayland"
LICENSE="OSL-3.0"
SLOT="0"
KEYWORDS="amd64 arm64"

RESTRICT="bindist mirror strip test"

QA_PREBUILT="*"
DESTDIR="/opt/${MY_PN}"
CONFIG_CHECK="~USER_NS"

src_unpack() {
  unpacker_src_unpack
  ls -alg "${WORKDIR}"

  # Use the first directory found in the unpacked tarball.
  S=$(find "${WORKDIR}" -maxdepth 1 -mindepth 1 -type d -print)
}

src_configure() {
  default
  chromium_suid_sandbox_check_kernel_config
}

src_install() {
  doicon -s 256 "${FILESDIR}/icon.png"

  exeinto "${DESTDIR}"
  doexe "${MY_PN}" chrome-sandbox libEGL.so libffmpeg.so libGLESv2.so libvk_swiftshader.so

  insinto "${DESTDIR}"
  doins chrome_100_percent.pak chrome_200_percent.pak icudtl.dat resources.pak snapshot_blob.bin v8_context_snapshot.bin
  insopts -m0755
  doins -r locales resources

  # Chrome-sandbox requires the setuid bit to be specifically set.
  # see https://github.com/electron/electron/issues/17972
  fowners root "${DESTDIR}/chrome-sandbox"
  fperms 4711 "${DESTDIR}/chrome-sandbox"
  [[ -x chrome_crashpad_handler ]] && doins chrome_crashpad_handler

  dosym "${DESTDIR}/${MY_PN}" "/usr/bin/${MY_PN}"

  executable="${PN}"
  if use wayland; then
    executable="${PN} --ozone-platform-hint=auto"
  fi
  make_desktop_entry "$executable" "ArmCord" "${PN}" "Network;InstantMessaging;"
}

pkg_postinst() {
  xdg_pkg_postinst

  optfeature_header "Install the following packages for additional support:"
  optfeature "sound support" \
    media-sound/pulseaudio media-sound/apulse[sdk] media-video/pipewire
  optfeature "emoji support" media-fonts/noto-emoji
}
