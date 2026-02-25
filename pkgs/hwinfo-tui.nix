{
  python3Packages,
  python3,
  lib,
}:
python3Packages.buildPythonPackage rec {
  pname = "hwinfo-tui";
  version = "1.0.1";
  src = python3.pkgs.fetchPypi {
    inherit version;
    pname = "hwinfo_tui";
    sha256 = "sha256-NU+JXOVx0gfkGyFNft/YmZ+dtg96HQy3xAtg3wiZOp0=";
  };

  pyproject = true;
  nativeBuildInputs = with python3Packages; [setuptools wheel];
  propagatedBuildInputs = with python3Packages; [rich psutil pandas typer plotext watchdog toml];

  meta = with lib; {
    mainProgram = "hwinfo-tui";
    description = "System Sensors";
    homepage = "https://github.com/JuanjoFuchs/hwinfo-tui";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
