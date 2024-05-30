# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Interact with the Google Cloud Platform"
HOMEPAGE="https://cloud.google.com/cli"
SITE="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads"
SRC_URI="
amd64? ( ${SITE}/google-cloud-cli-${PV}-linux-x86_64.tar.gz )
arm64? ( ${SITE}/google-cloud-cli-${PV}-linux-arm.tar.gz )
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm64 arm"

QA_PREBUILT="
google-cloud-sdk/bin/anothoscli
google-cloud-sdk/bin/gcloud-crc32c
"
RESTRICT="bindist mirror"
S="${WORKDIR}"

src_install() {
  mkdir -p "${D}/opt/google-cloud-sdk"
  cp -r "${S}/google-cloud-sdk/"* "${D}/opt/google-cloud-sdk" || die "Install failed!"
  dosym /opt/google-cloud-sdk/bin/gcloud /usr/bin/gcloud
  dosym /opt/google-cloud-sdk/bin/gsutil /usr/bin/gsutil

  chmod 4755 /opt/google-cloud-sdk/bin/gsutil
  chmod 4755 /opt/google-cloud-sdk/bin/gcloud
}
