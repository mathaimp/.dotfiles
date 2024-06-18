{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, wrapGAppsNoGuiHook
, gobject-introspection , glib, systemd, udev, libevdev, gitMinimal, check
, valgrind, swig, python3, json-glib, libunistring }:

stdenv.mkDerivation rec {
  pname = "libratbag-git";
  version = "1c9662043f4a11af26537e394bbd90e38994066a";

  src = fetchFromGitHub {
    owner  = "libratbag";
    repo   = "libratbag";
    rev    = "1c9662043f4a11af26537e394bbd90e38994066a";
    sha256 = lib.fakeSha256;
  };

  nativeBuildInputs = [
    meson ninja pkg-config gitMinimal swig check valgrind wrapGAppsNoGuiHook gobject-introspection
  ];

  buildInputs = [
    glib systemd udev libevdev json-glib libunistring
    (python3.withPackages (ps: with ps; [ evdev pygobject3 ]))
  ];

  mesonFlags = [
    "-Dsystemd-unit-dir=./lib/systemd/system/"
  ];

  meta = with lib; {
    description = "Configuration library for gaming mice";
    homepage    = "https://github.com/libratbag/libratbag";
    license     = licenses.mit;
    maintainers = with maintainers; [ mvnetbiz ];
    platforms   = platforms.linux;
  };
}

