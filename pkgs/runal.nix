{pkgs, ...}:
pkgs.buildGoModule {
  pname = "runal";
  version = "0.3.3";
  src = pkgs.fetchFromGitHub {
    owner = "emprcl";
    repo = "runal";
    rev = "v0.3.3";
    sha256 = "sha256-+/aIRvlR/vIT4MwGP/uY0DEars/h0RdyDWw5TK/MVbA=";
  };

  subPackages = ["."];
  sourceRoot = "source/cli";
  vendorHash = "sha256-7KtLP6rZlPy3d9G84EH8f84wj4Pscz94UPa2r4yPpds=";

  meta = with pkgs.lib; {
    description = "Runal CLI";
    license = licenses.mit;
  };
}
