{
  python3Packages,
  fetchFromGitHub,
  lib,
}:
python3Packages.buildPythonPackage rec {
  pname = "dotenvhub";
  version = "dev";
  src = fetchFromGitHub {
    owner = "zaloog";
    repo = "dotenvhub";
    rev = "ec389870d8382c8104f8cfbe6032493f29b5219e";
    sha256 = "sha256-oawKzuylAbmKXmkuHMTdOdMlGTy3keD0Ai/JSpDZpNY=";
  };
  pyproject = true;
  nativeBuildInputs = with python3Packages; [
    hatchling
    hatch-vcs
  ];
  propagatedBuildInputs = with python3Packages; [
    pyperclip
    platformdirs

    textual
  ];

  meta = with lib; {
    mainProgram = "dot";
    description = "";
    homepage = "";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
