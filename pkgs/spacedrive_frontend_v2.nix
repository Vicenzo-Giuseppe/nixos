{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "spacedrive-frontend-v2";
  version = "v2.0.0-alpha.2";

  src = fetchurl {
    url = "https://github.com/spacedriveapp/spacedrive/releases/download/${finalAttrs.version}/Spacedrive-frontend-linux-x86_64.tar.xz";
    hash = "sha256-C+SXAvDLNlKUSZhXNoEmMJmSLc2etZzrmnd/rLZN+lE=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/spacedrive-frontend
    cp -r index.html assets $out/share/spacedrive-frontend/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Spacedrive v2 frontend static bundle";
    homepage = "https://github.com/spacedriveapp/spacedrive";
    changelog = "https://github.com/spacedriveapp/spacedrive/releases/tag/${finalAttrs.version}";
    license = licenses.agpl3Plus;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux"];
  };
})
