{ stdenv, fetchFromGitHub, fetchpatch }:

stdenv.mkDerivation rec {
  name = "hiredis-${version}";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "redis";
    repo = "hiredis";
    rev = "v${version}";
    sha256 = "0ik38lwpmm780jqrry95ckf6flmvd172444p3q8d1k9n99jwij9c";
  };

  patches = [ (fetchpatch {
    url = https://github.com/redis/hiredis/commit/2fa34e37af0881ff3700fea64fe211bbb8b028a2.patch;
    sha256 = "1qiy5k9i1j90y4lx4ya2kf7bk6f0nq684qsp002kp6hfzc5aj9g2";
  }) ];

  PREFIX = "\${out}";

  meta = with stdenv.lib; {
    homepage = https://github.com/redis/hiredis;
    description = "Minimalistic C client for Redis >= 1.2";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
