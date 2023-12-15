{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchFromRepoOrCz,
  fetchgit,
  boehmgc,
  enableLargeConfig ? false,
  enableMmap ? true,
  freetype,
  glfw,
  makeWrapper,
  openssl,
  tinycc,
  upx,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "vlang";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "vlang";
    repo = "v";
    rev = "858ce4e35dc5680a4dc3b7ab3e867862e5b7ced7";
    sha256 = "sha256-mlosFlGiv11dUbO1ZyL8boPyaOqygAV36tL2CXeDcns=";
  };

  # Required for bootstrap.
  vc = fetchFromGitHub {
    owner = "vlang";
    repo = "vc";
    rev = "b6fe48631661061e7dcd832276ff0abe65c73573";
    sha256 = "sha256-Im0lrfs43ZQanYl5Q9cZXmq+NcRC5e1fOMRVVU5mE7E=";
  };

  # Required for vdoc.
  markdown = fetchFromGitHub {
    owner = "vlang";
    repo = "markdown";
    rev = "014724a2e35c0a7e46ea9cc91f5a303f2581b62c";
    sha256 = "sha256-jsL3m6hzNgQPKrQQhnb9mMELK1vYhvyS62sRBRwQ9CE=";
  };

  vlangtinycc = tinycc.overrideAttrs (finalAttrs: previousAttrs: {
    src = fetchFromRepoOrCz {
      repo = "tinycc";
      rev = "806b3f98";
      hash = "sha256-WQq3WsUlzVg2Nfb3FK6ibbvhsqJGe84zhj64EPH5tT4=";
    };

    configureFlags = [
      "--cc=$CC"
      "--ar=$AR"
      "--crtprefix=${lib.getLib stdenv.cc.libc}/lib"
      "--sysincludepaths=${lib.getDev stdenv.cc.libc}/include:{B}/include"
      "--libpaths=${lib.getLib stdenv.cc.libc}/lib"
      # build cross compilers
      "--enable-cross"

      # vlang tinycc flags
      #"--extra-cflags=-03" # Hopefully this isn't critical
      "--config-bcheck=yes"
      "--config-backtrace=yes"
      "--debug"
    ];
  });

  libgc = boehmgc.overrideAttrs (finalAttrs: previousAttrs: {
    configureFlags =
      [
        # Nixos configure flags
        "--enable-cplusplus"
        "--with-libatomic-ops=none"

        # vlang libgc build flags
        "--enable-threads=pthreads"
        "--enable-static"
        "--enable-thread-local-alloc=no"
        "--enable-parallel-mark"
        "--enable-single-obj-compilation"
        "--enable-gc-debug"
      ]
      ++ lib.optional enableMmap "--enable-mmap"
      ++ lib.optional enableLargeConfig "--enable-large-config";
  });

  # The included vsh scripts with shebangs aren't critical for most development
  dontPatchShebangs = 1;

  propagatedBuildInputs =
    [glfw freetype openssl]
    ++ lib.optional stdenv.hostPlatform.isUnix upx;

  nativeBuildInputs = [makeWrapper];

  buildInputs = [xorg.libX11];

  makeFlags = [
    "local=1"
    "VC=${vc}"
  ];

  preBuild = ''
    export HOME=$(mktemp -d)
    mkdir -p thirdparty/tcc/lib
    ln -s ${vlangtinycc}/bin/tcc thirdparty/tcc/tcc.exe
    ln -s ${vlangtinycc}/lib/tcc/libtcc1.a thirdparty/tcc/lib/libtcc.a
    ln -s ${libgc}/lib/libgc.a thirdparty/tcc/lib/
  '';

  # vcreate_test.v requires git, so we must remove it when building the tools.
  # vtest.v fails on Darwin, so let's just disable it for now.
  preInstall =
    ''
      mv cmd/tools/vcreate/vcreate_test.v $HOME/vcreate_test.v
    ''
    + lib.optionalString stdenv.isDarwin ''
      mv cmd/tools/vcreate/vtest.v $HOME/vtest.v
    '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,lib,share}
    cp -r examples $out/share
    cp -r {cmd,vlib,thirdparty} $out/lib
    cp v $out/lib
    ln -s $out/lib/v $out/bin/v
    wrapProgram $out/bin/v --prefix PATH : ${lib.makeBinPath [stdenv.cc]}
    mkdir -p $HOME/.vmodules;
    ln -sf ${markdown} $HOME/.vmodules/markdown
    $out/lib/v -v build-tools
    $out/lib/v -v $out/lib/cmd/tools/vdoc
    $out/lib/v -v $out/lib/cmd/tools/vast
    $out/lib/v -v $out/lib/cmd/tools/vvet
    runHook postInstall
  '';

  # Return vcreate_test.v and vtest.v, so the user can use it.
  postInstall =
    ''
      cp $HOME/vcreate_test.v $out/lib/cmd/tools/vcreate_test.v
    ''
    + lib.optionalString stdenv.isDarwin ''
      cp $HOME/vtest.v $out/lib/cmd/tools/vtest.v
    '';

  meta = with lib; {
    homepage = "https://vlang.io/";
    description = "Simple, fast, safe, compiled language for developing maintainable software";
    license = licenses.mit;
    maintainers = with maintainers; [Madouura];
    mainProgram = "v";
    platforms = platforms.all;
  };
}
