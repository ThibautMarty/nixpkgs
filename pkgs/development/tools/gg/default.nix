{ lib, stdenv
, autoconf
, automake
, boost
, cryptopp
, fetchFromGitHub
, fetchpatch
, gettext
, glibc, symlinkJoin, buildPackages
, help2man
, hiredis
, keyutils
, libcap
, libtool
, ncurses5
, openssl
, pkgconfig
, protobuf
, python3
, texinfo
, zlib
}:

let
  # Fix use of "private" keyword in header when included in c++ file
  keyutils' = keyutils.overrideAttrs (old: {
    patchPhase = ''
      find . -type f -exec sed -i 's/private/dh_private/g' {} \;
    '';
  });

in stdenv.mkDerivation rec {
  name = "gg-${version}";
  version = "nsdi-19-submission";

  src = fetchFromGitHub {
    owner  = "StanfordSNR";
    repo   = "gg";
    rev    = version;
    sha256 = "1iasgnpflyvnrj7vzc7481nyni6lpga50zhhdv5anncjr4h7ascd";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      url = https://github.com/StanfordSNR/gg/commit/8d392e2ba73b85f6f1cea26bd743504dae6d9ec5.patch;
      sha256 = "0lq4c96l7b1jl1wa49h628294gkgh0y2zk1bb3aanmvffrsz1kjb";
    })
    (fetchpatch {
      url = https://github.com/StanfordSNR/gg/commit/a58614d2e26d336b46b1037376f0c2858961f738.patch;
      sha256 = "0k3wga1k0xh6p9fgs343vds2q4k4qrf0l7f3ghlmyqpffxdynqfv";
    })
  ];

  # change gcc-7/g++-7 references
  postPatch = ''
    find src tests -type f -exec sed -i 's/gcc-7/gcc/g;s/g++-7/g++/g' {} \;
  '';

  buildInputs = [
    boost
    cryptopp
    gettext
    hiredis
    keyutils'
    libcap
    libtool.lib
    ncurses5
    openssl
    (openssl.override { static = true; })
    protobuf
    python3
    zlib.static # missing dependency from README
  ];

  nativeBuildInputs = [
    autoconf
    automake
    help2man
    pkgconfig
    protobuf
    texinfo
    # Fix ld: cannot find -lm (static link)
    (buildPackages.symlinkJoin {
      name = "glibc";
      paths = [ glibc glibc.static glibc.dev ];
    })
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  outputs = [ "out" "wrappers" ];

  postInstall = ''
    cp -r $src/src/models/wrappers $wrappers
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "The Stanford Builder";
    homepage = https://github.com/StanfordSNR/gg;
    downloadPage = https://ccache.samba.org/download.html;
    license = licenses.unfree; # no license found
    platforms = platforms.linux;
  };
}
