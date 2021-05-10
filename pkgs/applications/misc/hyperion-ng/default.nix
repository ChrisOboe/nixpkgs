{ stdenv, lib, fetchFromGitHub, mkDerivation, cmake, qtbase, qtserialport, qtsvg
, qtx11extras, libusb, python3, python3Packages, libcec, libxcb, libXrandr
, avahi-compat, libjpeg, flatbuffers, protobuf, zlib, mbedtls }:

mkDerivation rec {
  pname = "hyperion.ng";
  version = "2.0.0-alpha.9";

  src = fetchFromGitHub {
    owner = "hyperion-project";
    repo = "hyperion.ng";
    rev = "${version}";
    sha256 = "Yhxv/NCxR7iO/9WcnFLqlLAz4T4JRDOdJwFqoxQfyP8=";
  };

  nativeBuildInputs = [ cmake flatbuffers protobuf ];

  buildInputs = [
    qtbase
    qtserialport
    qtsvg
    qtx11extras
    libusb
    python3
    libcec
    libxcb
    libXrandr
    avahi-compat
    libjpeg
    mbedtls
    zlib
  ] ++ (with python3Packages; [ ]);

  patches = [ ./fix-error-macro-conflict.patch ];

  cmakeFlags = [
    "-DUSE_SHARED_AVAHI_LIBS=ON"
    "-DUSE_SYSTEM_FLATBUFFERS_LIBS=ON"
    "-DUSE_SYSTEM_PROTO_LIBS=ON"
    "-DUSE_SYSTEM_MBEDTLS_LIBS=ON"

    "-DENABLE_AMLOGIC=OFF"
    "-DENABLE_DISPMANX=OFF"
    "-DENABLE_OSX=OFF"
    "-DENABLE_QT=ON"
    "-DENABLE_X11=ON"
    "-DENABLE_XCB=ON"
    "-DENABLE_WS281XPWM=OFF" # doesn't build
    "-DENABLE_AVAHI=ON"

    "-DENABLE_V4L2=ON"
    "-DENABLE_SPIDEV=ON"
    "-DENABLE_TINKERFORGE=ON"
    "-DENABLE_FB=ON"
    "-DENABLE_USB_HID=ON"
    "-DENABLE_CEC=ON"
  ];

  dontWrapQtApps = true;
  dontWrapGApps = true;

  preFixup = ''
    for program in $out/bin/*; do
      wrapProgram $program \
        ''${qtWrapperArgs[@]} \
        ''${gappsWrapperArgs[@]} \
        --prefix PYTHONPATH : $PYTHONPATH
    done
  '';

  meta = with lib; {
    homepage = "https://github.com/hyperion-project/hyperion.ng";
    description = "An opensource Bias or Ambient Lightning implementation";
    platforms = platforms.linux;
    maintainers = [ "chris@oboe.email" ];
  };
}

