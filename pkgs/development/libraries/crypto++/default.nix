{ fetchFromGitHub, stdenv }:

stdenv.mkDerivation rec {
  name = "crypto++-${version}";
  majorVersion = "5.6";
  version = "${majorVersion}.5";

  src = fetchFromGitHub {
    owner = "weidai11";
    repo = "cryptopp";
    rev = "CRYPTOPP_5_6_5";
    sha256 = "1yk7jyf4va9425cg05llskpls2jm7n3jwy2hj5jm74zkr4mwpvl7";
  };

  patches = stdenv.lib.concatLists [
    (stdenv.lib.optional (stdenv.hostPlatform.system != "i686-cygwin") ./dll.patch)
    (stdenv.lib.optional stdenv.hostPlatform.isDarwin ./GNUmakefile-darwin.patch)
  ];

  configurePhase = ''
    sed -i GNUmakefile \
      -e 's|-march=native|-fPIC|g' \
      -e '/^CXXFLAGS =/s|-g ||'
  '';

  enableParallelBuilding = true;

  makeFlags = [ "PREFIX=$(out)" ];
  buildFlags = [ "libcryptopp.so" ];
  installFlags = [ "LDCONF=true" ];

  doCheck = true;
  checkPhase = "LD_LIBRARY_PATH=`pwd` make test";

  # cryptotest.exe seems superfluous
  # some programs can look for headers in include/crypto++ instead of include/cryptopp
  # add pkg-config file (taken from Archlinux)
  postInstall = ''
    rm -r "$out/bin"
    ln -sf "$out"/lib/libcryptopp.so.${version} "$out"/lib/libcryptopp.so.${majorVersion}

    ln -s cryptopp $out/include/crypto++

    mkdir -p $out/lib/pkgconfig
    cp ${./libcrypto++.pc} $out/lib/pkgconfig/libcrypto++.pc
    substituteInPlace $out/lib/pkgconfig/libcrypto++.pc \
      --subst-var-by out $out \
      --subst-var-by version "${version}"
  '';

  meta = with stdenv.lib; {
    description = "Crypto++, a free C++ class library of cryptographic schemes";
    homepage = http://cryptopp.com/;
    license = licenses.boost;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
