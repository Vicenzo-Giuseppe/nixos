______________________________________________________________________

## description: NixOS package development command that coordinates Researcher→Coder→Explorer→Writer pipeline for creating custom packages in pkgs/ usage: /nixos-pkg-dev \<package_name> [--research] [--implement] [--test] [--document]

# /nixos-pkg-dev - NixOS Package Development Pipeline

## OVERVIEW

Coordinates the complete NixOS package development workflow using the Researcher→Coder→Explorer→Writer→Architect pipeline for creating custom packages in your pkgs/ directory (stormy, yatto, etc.).

## AGENT PIPELINE INTEGRATION

- **Researcher**: Researches existing packages, patterns, and best practices
- **Coder**: Implements package definition following NixOS conventions
- **Explorer**: Validates package integration and dependencies
- **Writer**: Documents package usage and configuration
- **Architect**: Orchestrates the complete development workflow

## CORE DEVELOPMENT WORKFLOW

### 1. New Package Research Phase

```bash
/nixos-pkg-dev "rust-monitoring-tool" --research
```

**Researcher executes comprehensive analysis:**

```bash
@Researcher "research NixOS package development: rust-monitoring-tool"

# Research existing packages in your pkgs/
nixos_nixos_info("stormy")
nixos_nixos_info("yatto") 
github_get_file_contents("ashish0kumar/stormy")

# Research Rust packaging patterns
github_search_repositories("nixpkgs rust package language:nix")
github_search_code("rustPlatform.buildRustPackage")

# Research best practices
exa_get_code_context_exa("NixOS Rust package development 2025")
exa_web_search_exa("NixOS custom package development guide")
```

### 2. Implementation Phase

```bash
/nixos-pkg-dev "rust-monitoring-tool" --implement
```

**Coder creates package following your patterns:**

```bash
@Coder "implement rust-monitoring-tool package based on research"

# Create package definition in pkgs/
write("/home/vicenzo/notebook.nix/pkgs/rust-monitoring-tool.nix", '''
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "rust-monitoring-tool";
  version = "0.1.0";
  
  src = fetchFromGitHub {
    owner = "username";
    repo = "rust-monitoring-tool";
    rev = "v${version}";
    sha256 = "sha256-PLACEHOLDER";
  };
  
  cargoHash = "sha256-PLACEHOLDER";
  
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  
  meta = with lib; {
    description = "Rust system monitoring tool";
    homepage = "https://github.com/username/rust-monitoring-tool";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
''')
```

### 3. Integration Testing

```bash
/nixos-pkg-dev "rust-monitoring-tool" --test
```

**Explorer validates system integration:**

```bash
@Explorer "test rust-monitoring-tool package integration"

# Test package build
bash("cd /home/vicenzo/notebook.nix && nix build .#pkgs.rust-monitoring-tool")

# Validate flake integration
read("/home/vicenzo/notebook.nix/flake.nix")
read("/home/vicenzo/notebook.nix/pkgs/default.nix")

# Check for dependency conflicts
nixos_nixos_search("rustPlatform")
nixos_nixos_info("openssl")
```

## ADVANCED DEVELOPMENT PATTERNS

### Package from GitHub Repository

```bash
/nixos-pkg-dev "https://github.com/user/cool-rust-tool" --from-github
```

**Complete GitHub-to-package workflow:**

```bash
@Researcher "analyze GitHub repository: cool-rust-tool"

# Analyze GitHub repository
github_get_file_contents("user/cool-rust-tool/README.md")
github_get_file_contents("user/cool-rust-tool/Cargo.toml")
github_search_repositories("cool-rust-tool language:rust")

@Coder "create package from GitHub: cool-rust-tool"

# Generate package with proper hashes
write("/home/vicenzo/notebook.nix/pkgs/cool-rust-tool.nix", '''
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cool-rust-tool";
  version = "0.2.1";
  
  src = fetchFromGitHub {
    owner = "user";
    repo = "cool-rust-tool";
    rev = "v${version}";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAA";
  };
  
  cargoHash = "sha256-BBBBBBBBBBBBBBBBBBBBBB";
  
  meta = with lib; {
    description = "Cool Rust tool for system monitoring";
    homepage = "https://github.com/user/cool-rust-tool";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
''')
```

### Package Security Audit

```bash
/nixos-pkg-dev "rust-monitoring-tool" --security-audit
```

**Security-focused development:**

```bash
@Researcher "security audit: rust-monitoring-tool package"

# Research security implications
github_search_code("rust package security vulnerabilities")
exa_web_search_exa("Rust package security best practices 2025")
nixos_nixos_search("security")

@Coder "implement security-hardened package"

# Add security features to package
edit("/home/vicenzo/notebook.nix/pkgs/rust-monitoring-tool.nix", '''
  # Add security hardening
  hardeningEnable = [ "pie" "relro" "bindnow" ];
  
  # Verify source integrity
  verifyCargoHash = true;
  
  # Sandbox build
  __noChroot = false;
''')
```

## INTEGRATION WITH YOUR PROJECT STRUCTURE

### Auto-Discovery Integration

Your `pkgs/default.nix` auto-discovers new packages:

```nix
{pkgs}:
let
  files = readDir ./.;
  nixFiles = filter (name: match ".*\\.nix" name != null) (attrNames files);
in
  listToAttrs (map (name: {
    name = replaceStrings [".nix"] [""] name;
    value = pkgs.callPackage (./. + "/${name}") {};
  }) nixFiles)
```

### Flake Integration

New packages automatically appear in your flake outputs via the overlay:

```nix
sharedOverlays = [
  utils.overlay
  neovim.overlays.default
  (final: prev: import ./pkgs {pkgs = final;})
];
```

## DOCUMENTATION GENERATION

### Complete Package Documentation

```bash
/nixos-pkg-dev "rust-monitoring-tool" --document
```

**Writer creates comprehensive documentation:**

````bash
@Writer "create package documentation: rust-monitoring-tool"

# Generate usage documentation
write("/home/vicenzo/notebook.nix/docs/rust-monitoring-tool.md", '''
# rust-monitoring-tool Package

## Installation
```bash
nix run .#pkgs.rust-monitoring-tool
````

## Configuration

Add to your system configuration:

```nix
environment.systemPackages = with pkgs; [
  rust-monitoring-tool
];
```

## Usage Examples

```bash
# Monitor system resources
rust-monitoring-tool --cpu --memory

# Export to JSON
rust-monitoring-tool --output json > system-stats.json
```

## Integration with Home Manager

```nix
home.packages = with pkgs; [
  rust-monitoring-tool
];
```

''')

````

## PRACTICAL EXAMPLES

### Example 1: Create Go Package (like stormy)
```bash
/nixos-pkg-dev "go-log-analyzer" --go-package
````

**Researcher→Coder workflow for Go package:**

```bash
@Researcher "research Go package patterns in nixpkgs"

# Study existing Go packages
nixos_nixos_info("stormy")
github_get_file_contents("ashish0kumar/stormy")
github_search_code("buildGoModule nixpkgs")

@Coder "implement go-log-analyzer package"

# Create Go package following stormy pattern
write("/home/vicenzo/notebook.nix/pkgs/go-log-analyzer.nix", '''
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "go-log-analyzer";
  version = "v0.1.0";

  src = fetchFromGitHub {
    owner = "username";
    repo = "go-log-analyzer";
    rev = version;
    sha256 = "sha256-PLACEHOLDER";
  };

  vendorHash = "sha256-PLACEHOLDER";

  meta = with lib; {
    description = "Go-based log analysis tool";
    homepage = "https://github.com/username/go-log-analyzer";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
''')
```

### Example 2: Update Existing Package

```bash
/nixos-pkg-dev "stormy" --update --version v0.4.0
```

**Update workflow:**

```bash
@Researcher "research stormy v0.4.0 changes"

# Check GitHub releases
github_get_file_contents("ashish0kumar/stormy/releases")
exa_web_search_exa("stormy weather CLI v0.4.0 changes")

@Coder "update stormy package to v0.4.0"

# Update package with new hashes
edit("/home/vicenzo/notebook.nix/pkgs/stormy.nix", '''
  version = "v0.4.0";
  
  src = fetchFromGitHub {
    owner = "ashish0kumar";
    repo = "stormy";
    rev = "v0.4.0";
    sha256 = "sha256-NEW-HASH";
  };
  
  vendorHash = "sha256-NEW-VENDOR-HASH";
''')
```

### Example 3: Complex Package with Dependencies

```bash
/nixos-pkg-dev "python-ai-toolkit" --python --complex-deps
```

**Complex dependency research:**

```bash
@Researcher "research Python AI toolkit dependencies"

# Research Python packaging
nixos_nixos_search("python3Packages")
github_search_code("python3Packages machine learning nix")
exa_get_code_context_exa("NixOS Python package dependencies")

@Coder "implement python-ai-toolkit with dependencies"

# Create complex Python package
write("/home/vicenzo/notebook.nix/pkgs/python-ai-toolkit.nix", '''
{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "python-ai-toolkit";
  version = "1.2.0";
  
  src = fetchFromGitHub {
    owner = "ai-developer";
    repo = "python-ai-toolkit";
    rev = "v${version}";
    sha256 = "sha256-PLACEHOLDER";
  };
  
  propagatedBuildInputs = with python3Packages; [
    numpy
    pandas
    scikit-learn
    tensorflow
    pytorch
  ];
  
  meta = with lib; {
    description = "Python AI/ML toolkit";
    homepage = "https://github.com/ai-developer/python-ai-toolkit";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
''')
```

## VALIDATION AND TESTING

### Build Validation

```bash
/nixos-pkg-dev "rust-monitoring-tool" --validate
```

**Comprehensive validation:**

```bash
@Explorer "validate rust-monitoring-tool build and integration"

# Test build
bash("nix build .#pkgs.rust-monitoring-tool --no-link")

# Test execution
bash("result/bin/rust-monitoring-tool --help")

# Validate integration
read("/home/vicenzo/notebook.nix/result")
```

### System Integration Test

```bash
/nixos-pkg-dev "rust-monitoring-tool" --system-test
```

**Full system integration:**

```bash
@Architect "test system-wide integration of rust-monitoring-tool"

# Add to system configuration temporarily
edit("/home/vicenzo/notebook.nix/system/user-config.nix", '''
  environment.systemPackages = with pkgs; [
    rust-monitoring-tool
  ];
''')

# Test system build
bash("nix run .#test")
```

This command provides a complete package development pipeline that integrates with your existing project structure and agent workflow.
