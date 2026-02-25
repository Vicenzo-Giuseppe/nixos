{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
}:
buildGoModule {
  pname = "stormy";
  version = "v0.3.3";

  src = fetchFromGitHub {
    owner = "ashish0kumar";
    repo = "stormy";
    rev = "v0.3.3";
    sha256 = "sha256-9QEjr4EFHmAsBx0z0/Zj7uyX12rZYekCXXGLBW1s91Q=";
  };

  vendorHash = "sha256-iwgGAJRygi+xS5eorZ8wyR6pMDZvmGFXBbCiFazyaHw=";
  nativeBuildInputs = [go];
  postInstall = ''
        mkdir -p $out/etc/stormy
        cat > $out/etc/stormy/stormy.toml <<EOF
    provider = "OpenMeteo"
    api_key = ""
    city = "Cosmopolis"
    units = "metric"
    showcityname = true
    use_colors = true
    live_mode = false
    compact = false
    EOF
  '';

  meta = with lib; {
    mainProgram = "stormy";
    description = "CLI weather tool with ASCII art";
    homepage = "https://github.com/ashish0kumar/stormy";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
