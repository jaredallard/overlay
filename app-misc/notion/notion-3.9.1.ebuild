# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/-bin/}"
MY_PV="${PV/-r*/}"

# Matches the versions used by Notion.
ELECTRON_VERSION="v29.3.0"
BETTER_SQLITE3_VERSION="9.4.5"

inherit chromium-2 desktop linux-info optfeature unpacker xdg

DESCRIPTION="Your connected workspace for wiki, docs & projects"
HOMEPAGE="https://github.com/ArmCord/ArmCord"
SRC_URI="
  https://desktop-release.notion-static.com/Notion-${MY_PV}.dmg
  amd64? (
    https://gentoo.rgst.io/updater_artifacts/app-misc/notion/${MY_PV}/better_sqlite3-${BETTER_SQLITE3_VERSION}/amd64/better_sqlite3.node -> better_sqlite3_amd64.node
    https://github.com/electron/electron/releases/download/$ELECTRON_VERSION/electron-$ELECTRON_VERSION-linux-x64.zip 
  )
  arm64? ( 
    https://gentoo.rgst.io/updater_artifacts/app-misc/notion/${MY_PV}/better_sqlite3-${BETTER_SQLITE3_VERSION}/arm64/better_sqlite3.node -> better_sqlite3_arm64.node
    https://github.com/electron/electron/releases/download/$ELECTRON_VERSION/electron-$ELECTRON_VERSION-linux-arm64.zip 
  )
"

IUSE="appindicator +seccomp wayland"
BDEPEND="app-arch/7zip"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="amd64 arm64"

RESTRICT="bindist mirror strip test"

QA_PREBUILT="*"
DESTDIR="/opt/${MY_PN}"
CONFIG_CHECK="~USER_NS"

src_unpack() {
  ls -alh
  7zz x "${DISTDIR}/Notion-${MY_PV}.dmg" || true
  7zz x "${DISTDIR}/electron-$ELECTRON_VERSION-linux-"**".zip" -o"$WORKDIR/electron" || die "Failed to extract Electron"
  cp "$DISTDIR/better_sqlite3_"**".node" "$WORKDIR/better_sqlite3.node" || die "Failed to copy better_sqlite3.node"

  S="${WORKDIR}"
}

src_configure() {
  default
  chromium_suid_sandbox_check_kernel_config
}

src_compile() {
  # We "build" Notion by combining the downloaded artifacts.

  BUILDDIR="${S}/${MY_PN}-${MY_PV}"
  mkdir -p "${BUILDDIR}"

  # Copy the Electron files.
  cp -r "${WORKDIR}/electron"/* "${BUILDDIR}"

  # Copy the Notion files.
  cp -rp Notion/Notion.app/Contents/Resources/{app.asar.unpacked,app.asar} "$BUILDDIR/resources/"

  # Remove the Electron files we don't need.
  rm -rf "${BUILDDIR}/resources/default_app.asar"

  # Rename "electron" to "notion" to avoid confusion.
  mv "${BUILDDIR}/electron" "${BUILDDIR}/${MY_PN}"

  # Replace better_sqlite 3 with one for our architecture so that Notion
  # is able to open.
  cp better_sqlite3.node "$BUILDDIR/resources/app.asar.unpacked/node_modules/better-sqlite3/build/Release/better_sqlite3.node" ||
    die "Failed to copy better_sqlite3.node"
  S="${BUILDDIR}"
}

src_install() {
  doicon -s 256 "${FILESDIR}/notion.png"

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
  make_desktop_entry "$executable" "Notion" "${PN}" "Office;TextEditor;"
}

pkg_postinst() {
  xdg_pkg_postinst

  optfeature_header "Install the following packages for additional support:"
  optfeature "sound support" \
    media-sound/pulseaudio media-sound/apulse[sdk] media-video/pipewire
  optfeature "emoji support" media-fonts/noto-emoji
}
