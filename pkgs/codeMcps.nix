{
  lib,
  stdenvNoCC,
  fetchurl,
  buildNpmPackage,
  makeWrapper,
  nodejs_22,
  python3Packages,
}: let
  nodejs = nodejs_22;

  mkBundledNodeCli = {
    pname,
    version,
    url,
    hash,
    bin,
    script,
    description,
  }:
    stdenvNoCC.mkDerivation {
      inherit pname version;
      src = fetchurl {
        inherit url hash;
      };
      sourceRoot = "package";
      nativeBuildInputs = [makeWrapper];

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/lib/node_modules/${pname}" "$out/bin"
        cp -r . "$out/lib/node_modules/${pname}"

        makeWrapper ${nodejs}/bin/node "$out/bin/${bin}" \
          --add-flags "$out/lib/node_modules/${pname}/${script}"

        runHook postInstall
      '';

      meta = {
        inherit description;
        homepage = "https://www.npmjs.com/package/${pname}";
        license = lib.licenses.mit;
        mainProgram = bin;
        platforms = lib.platforms.linux;
      };
    };

  mkNodeCli = {
    pname,
    version,
    url,
    hash,
    lockfile,
    npmDepsHash,
    bin,
    script,
    description,
  }:
    buildNpmPackage {
      inherit pname version npmDepsHash;
      src = fetchurl {
        inherit url hash;
      };
      sourceRoot = "package";
      nodejs = nodejs;
      nativeBuildInputs = [makeWrapper];
      dontNpmBuild = true;
      postPatch = ''
        cp ${lockfile} package-lock.json
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/lib/node_modules/${pname}" "$out/bin"
        cp -r . "$out/lib/node_modules/${pname}"

        makeWrapper ${nodejs}/bin/node "$out/bin/${bin}" \
          --add-flags "$out/lib/node_modules/${pname}/${script}"

        runHook postInstall
      '';

      meta = {
        inherit description;
        homepage = "https://www.npmjs.com/package/${pname}";
        license = lib.licenses.mit;
        mainProgram = bin;
        platforms = lib.platforms.linux;
      };
    };
in {
  exa = mkBundledNodeCli {
    pname = "exa-mcp-server";
    version = "3.2.1";
    url = "https://registry.npmjs.org/exa-mcp-server/-/exa-mcp-server-3.2.1.tgz";
    hash = "sha256-Z1aI3/zXRri7asfwd7ZLc4LEowX5SNRLpSbme+UDlt8=";
    bin = "exa-mcp-server";
    script = "smithery/stdio/index.cjs";
    description = "Exa MCP server";
  };

  firecrawl = mkNodeCli {
    pname = "firecrawl-mcp";
    version = "3.11.0";
    url = "https://registry.npmjs.org/firecrawl-mcp/-/firecrawl-mcp-3.11.0.tgz";
    hash = "sha256-To3/EALTZwpbKAQ/wz+K2sDTby+GM2TtOuDrjkvDylI=";
    lockfile = ./codeMcps-locks/firecrawl-mcp-package-lock.json;
    npmDepsHash = "sha256-bWsTyPFlxPpVz0SImiV2Cb9HFaZ7bSHb2M7J86Lj4oE=";
    bin = "firecrawl-mcp";
    script = "dist/index.js";
    description = "Firecrawl MCP server";
  };

  # blender = python3Packages.buildPythonApplication rec {
  #   pname = "blender-mcp";
  #   version = "1.5.6";
  #   pyproject = true;
  #
  #   src = fetchurl {
  #     url = "https://files.pythonhosted.org/packages/ac/4a/08510fc5f0487cba6f7a994193e995675d8f92ef1882057b4d87441b9470/blender_mcp-1.5.6.tar.gz";
  #     hash = "sha256-9aBGQcMC1ustj3H1WgRFCha6fk+XSASIzcZr6Rrgif4=";
  #   };
  #
  #   build-system = with python3Packages; [ setuptools ];
  #   dependencies = with python3Packages; [
  #     mcp
  #     supabase
  #     tomli
  #   ];
  #
  #   pythonImportsCheck = [ "blender_mcp" ];
  #
  #   meta = {
  #     description = "Blender MCP server";
  #     homepage = "https://pypi.org/project/blender-mcp/";
  #     license = lib.licenses.mit;
  #     mainProgram = "blender-mcp";
  #     platforms = lib.platforms.linux;
  #   };
  # };
}
