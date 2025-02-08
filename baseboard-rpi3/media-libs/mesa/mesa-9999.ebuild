# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_PROJECT="chromiumos/third_party/mesa"
CROS_WORKON_LOCALNAME="mesa"
CROS_WORKON_EGIT_BRANCH="mesa-24.3.3"

KEYWORDS="~*"

inherit meson flag-o-matic cros-workon

DESCRIPTION="The Mesa 3D Graphics Library"
HOMEPAGE="http://mesa3d.org/"

# Most of the code is MIT/X11.
# GLES[2]/gl[2]{,ext,platform}.h are SGI-B-2.0
LICENSE="MIT SGI-B-2.0"

IUSE="debug vulkan libglvnd zstd egl gles2 perfetto"

COMMON_DEPEND="
	dev-libs/expat:=
	>=x11-libs/libdrm-2.4.94:=
"

RDEPEND="${COMMON_DEPEND}
	libglvnd? ( media-libs/libglvnd )
	!libglvnd? ( !media-libs/libglvnd )
	zstd? ( app-arch/zstd )
	dev-libs/libxml2
  app-arch/libarchive:=
  dev-libs/libconfig:=
  sys-libs/ncurses:=
  >=sys-libs/zlib-1.2.13
  virtual/libudev:=
  dev-util/spirv-tools
  media-libs/minigbm
"

DEPEND="${COMMON_DEPEND}
	perfetto? ( >=chromeos-base/perfetto-29.0 )
"

BDEPEND="
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"

src_configure() {
	cros_optimize_package_for_speed
	emesonargs+=(
		-Dexecmem=false
		-Dglvnd=$(usex libglvnd true false)
		-Dllvm=disabled
		-Dshader-cache=disabled
		-Dglx=disabled
		-Degl=enabled
		-Dgbm=disabled
		-Dgles1=disabled
		-Dgles2=enabled
		-Dshared-glapi=enabled
		-Dgallium-drivers=v3d
		-Dgallium-vdpau=disabled
		-Dgallium-xa=disabled
		-Dperfetto=$(usex perfetto true false)
		$(meson_feature zstd)
		-Dplatforms=
		-Dtools=
		--buildtype $(usex debug debug release)
		-Dvulkan-drivers=$(usex vulkan broadcom '')
		-Dvulkan-beta=true
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	find "${ED}" -name '*kgsl*' -exec rm -f {} +
	rm -v -rf "${ED}/usr/include"
}
