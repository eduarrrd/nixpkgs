{ stdenv, fetchurl, libgcrypt, libnl, pkgconfig, pythonPackages, wireless-regdb }:

let version = "3.18"; in
stdenv.mkDerivation {
  name = "crda-${version}";

  src = fetchurl {
    sha256 = "1gydiqgb08d9gbx4l6gv98zg3pljc984m50hmn3ysxcbkxkvkz23";
    url = "http://kernel.org/pub/software/network/crda/crda-${version}.tar.xz";
  };

  buildInputs = [ libgcrypt libnl ];
  nativeBuildInputs = [
    pkgconfig pythonPackages.m2crypto pythonPackages.python
  ];

  postPatch = ''
    patchShebangs utils/
    substituteInPlace Makefile --replace ldconfig true
    sed -i crda.c \
      -e "/\/usr\/.*\/regulatory.bin/d" \
      -e "s|/lib/crda|${wireless-regdb}/lib/crda|g"
  '';

  makeFlags = [
    "PREFIX=$(out)"
    "SBINDIR=$(out)/bin/"
    "UDEV_RULE_DIR=$(out)/lib/udev/rules.d/"
    "REG_BIN=${wireless-regdb}/lib/crda/regulatory.bin"
  ];

  buildFlags = [ "all_noverify" ];
  enableParallelBuilding = true;

  doCheck = true;
  checkTarget = "verify";

  meta = with stdenv.lib; {
    inherit version;
    description = "Linux wireless Central Regulatory Domain Agent";
    longDescription = ''
      CRDA acts as the udev helper for communication between the kernel and
      userspace for regulatory compliance. It relies on nl80211 for communication.
      CRDA is intended to be run only through udev communication from the kernel.
    '';
    homepage = http://drvbp1.linux-foundation.org/~mcgrof/rel-html/crda/;
    license = licenses.free; # "copyleft-next 0.3.0", as yet without a web site
    platforms = platforms.linux;
    maintainers = with maintainers; [ nckx ];
  };
}
