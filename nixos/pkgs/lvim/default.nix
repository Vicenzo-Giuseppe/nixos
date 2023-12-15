{
  neovim-unwrapped,
  wrapNeovim,
  fetchFromGitHub,
  stdenv,
  makeWrapper,
  lib,
  ripgrep,
  git,
  fzf,
}: let
  nvim-customized = wrapNeovim neovim-unwrapped {};
in
  stdenv.mkDerivation {
    pname = "lvim";
    version = "0.0.2";
    src = fetchFromGitHub {
      owner = "LunarVim";
      repo = "LunarVim";
      rev = "023fb27b322ca8d0e3c02b4bbe88118b8d131c4e";
      sha256 = "sha256-ouat7ke7uLtXngE2UUV6O+L3o4xjaDrsRTIXMrAPIM8=";
    };
    nativeBuildInputs = [makeWrapper nvim-customized];
    buildInputs = [nvim-customized];

    buildPhase = ''
      echo "hello"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin

      cp -r $(pwd) $out/lvim
      mv $out/lvim/utils/bin/lvim.template $out/lvim/utils/bin/lvim
      export shim="$out/lvim/utils/bin/lvim"
      substituteInPlace "$shim" \
        --replace 'exec -a "$NVIM_APPNAME" nvim -u' "exec ${nvim-customized}/bin/nvim -u"

      chmod +x "$shim"

      makeWrapper "$shim" "$out/bin/lvim" \
        --set LUNARVIM_RUNTIME_DIR "$out" \
        --set LUNARVIM_CONFIG_DIR /home/vicenzo/.config/lvim \
        --set LUNARVIM_BASE_DIR /home/vicenzo/.local/share/lunarvim/lvim \
        --set LUNARVIM_CACHE_DIR /home/vicenzo/.cache/lvim \
        --prefix PATH : ${lib.makeBinPath [fzf git ripgrep]}
      runHook postInstall
    '';
  }
