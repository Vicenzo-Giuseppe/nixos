package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/charmbracelet/huh"
	"github.com/pelletier/go-toml/v2"
)

type Config struct {
	User     string          `toml:"user"`
	System   string          `toml:"system"`
	Host     string          `toml:"host"`
	Programs map[string]bool `toml:"programs"`
}

var allPrograms = []string{
	"aria2",
	"bat",
	"cosmic",
	"xdg",
	"opencode",
	"direnv",
	"firefox",
	"home",
	"pkgs",
	"starship",
	"zen-browser",
	"zsh",
	"mnw",
	"sops",
	"openssh",
	"btop",
	"spicetify",
	"steam",
	"localsend",
}

var programDescriptions = map[string]string{
	"aria2":       "System Downloader",
	"bat":         "CLI",
	"cosmic":      "Cosmic Desktop with Wayland",
	"xdg":         "XDG User Dirs",
	"opencode":    "AI Agents",
	"direnv":      "Auto-Shell Dev Environment with Nix",
	"firefox":     "Browser",
	"home":        "Home-Manager Misc Configs",
	"pkgs":        "General Packages",
	"starship":    "Customize ZSH prompt",
	"zen-browser": "Browser",
	"zsh":         "Default Shell",
	"mnw":         "Neovim Configured",
	"sops":        "Secrets Encrypted and Managed",
	"openssh":     "Cryptograph SHA256 Key",
	"btop":        "System Usage Monitor",
	"spicetify":   "Spotify",
	"steam":       "Games",
	"localsend":   "Send files fast through local WIFI",
}

func isGitRepo() bool {
	// Check for .git or .gitt (some systems use .gitt)
	if _, err := os.Stat(".git"); err == nil {
		return true
	}
	if _, err := os.Stat(".gitt"); err == nil {
		return true
	}
	return false
}

func hasFlakeNix() bool {
	_, err := os.Stat("flake.nix")
	return err == nil
}

func hasConfigToml() bool {
	_, err := os.Stat("config.toml")
	return err == nil
}

func runVM() {
	// Read config to get host
	config, err := readConfig()
	if err != nil {
		fmt.Printf("Error reading config: %v\n", err)
		os.Exit(1)
	}

	host := config.Host
	if host == "" {
		host = "notebook"
	}

	fmt.Printf(`
╔═══════════════════════════════════════════════════════════╗
║              NixOS Configuration Ready!                  ║
╚═══════════════════════════════════════════════════════════╝

Your system is configured as:
  User: %s
  Host: %s
  System: %s

To apply your NixOS configuration, run:

  sudo nixos-rebuild switch --flake .#%s

Or test in VM:
  nix run .#vm

`, config.User, host, config.System, host)
}

func runFlakeInit() error {
	fmt.Println("Initializing NixOS flake from template...")
	fmt.Println("This will clone the repository and set up the flake structure.\n")

	// Use nix flake init -t to initialize from template
	cmd := exec.Command("nix", "flake", "init", "-t", "github:vicenzo-giuseppe/nixos#nixos")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		// Fallback: do a full git clone
		fmt.Println("\nFalling back to git clone (full repository)...")
		return cloneFullRepo()
	}

	fmt.Println("\n✓ Flake initialized successfully!")
	return nil
}

func cloneFullRepo() error {
	fmt.Println("Cloning full vicenzo-giuseppe/nixos repository...")
	fmt.Println("This will clone all configurations, programs, and systems.\n")

	// Clone the full repo
	cmd := exec.Command("git", "clone", "https://github.com/vicenzo-giuseppe/nixos", ".")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		return fmt.Errorf("git clone failed: %w", err)
	}

	fmt.Println("\n✓ Full repository cloned successfully!")
	return nil
}

func isValidHostname(s string) error {
	if len(s) == 0 || len(s) > 64 {
		return fmt.Errorf("hostname must be 1-64 characters")
	}
	for _, c := range s {
		if !((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-' || c == '_') {
			return fmt.Errorf("hostname can only contain lowercase letters, numbers, - and _")
		}
	}
	return nil
}

func readConfig() (*Config, error) {
	data, err := os.ReadFile("config.toml")
	if err != nil {
		return nil, err
	}

	var config Config
	if err := toml.Unmarshal(data, &config); err != nil {
		return nil, err
	}

	if config.Programs == nil {
		config.Programs = make(map[string]bool)
	}

	return &config, nil
}

func getCurrentUsername() string {
	username := os.Getenv("USER")
	if username == "" {
		username = os.Getenv("USERNAME")
	}
	return username
}

func getCurrentHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		return ""
	}
	// Extract just the hostname without domain
	if idx := strings.Index(hostname, "."); idx != -1 {
		hostname = hostname[:idx]
	}
	return hostname
}

func generateConfigTOML(user, system, host string, selectedPrograms []string) string {
	programMap := make(map[string]bool)
	for _, p := range selectedPrograms {
		programMap[p] = true
	}

	var sb strings.Builder
	sb.WriteString(fmt.Sprintf(`# Basic Settings
user = "%s"        # Default User
system = "%s" # Default System
host = "%s"       # Default Host
# NixOS - Programs Configs Enabled
[programs]
`, user, system, host))

	for _, p := range allPrograms {
		desc := programDescriptions[p]
		if programMap[p] {
			sb.WriteString(fmt.Sprintf("%s = true       # %s\n", p, desc))
		} else {
			sb.WriteString(fmt.Sprintf("%s = false      # %s\n", p, desc))
		}
	}

	return sb.String()
}

func main() {
	fmt.Println(`
╔═══════════════════════════════════════════════════════════╗
║              Welcome to NixOS Setup!                      ║
║                                                           ║
║  This will help you configure your NixOS system.          ║
╚═══════════════════════════════════════════════════════════╝
`)

	// Check if config.toml exists and load defaults
	defaultUser := getCurrentUsername()
	defaultHost := getCurrentHostname()
	if defaultHost == "" {
		defaultHost = "notebook"
	}

	if hasConfigToml() {
		fmt.Println("\nconfig.toml found. Loading current configuration...")
		if cfg, err := readConfig(); err == nil {
			if cfg.User != "" {
				defaultUser = cfg.User
			}
			if cfg.Host != "" {
				defaultHost = cfg.Host
			}
		}
	}

	fmt.Println("\nRunning setup wizard...")

	// 4. Run huh form
	var user, host, system string
	var selectedPrograms []string

	form := huh.NewForm(
		huh.NewGroup(
			huh.NewNote().
				Title("NixOS Setup").
				Description("Let's configure your NixOS system!\n\nPress Enter or Tab to navigate, Space to select."),
		),
		huh.NewGroup(
			huh.NewInput().
				Title("Username").
				Description("Your username on this machine").
				Placeholder(defaultUser).
				Prompt(">").
				Value(&user).
				Validate(func(s string) error {
					if len(s) == 0 {
						return fmt.Errorf("username is required")
					}
					return nil
				}),
			huh.NewInput().
				Title("Hostname").
				Description("Machine name (e.g., notebook, framework-16, desktop)").
				Placeholder(defaultHost).
				Prompt(">").
				Value(&host).
				Validate(isValidHostname),
			huh.NewSelect[string]().
				Title("System").
				Description("Your system architecture").
				Options(
					huh.NewOption("x86_64-linux", "x86_64-linux"),
					huh.NewOption("aarch64-linux", "aarch64-linux"),
					huh.NewOption("x86_64-darwin", "x86_64-darwin"),
					huh.NewOption("aarch64-darwin", "aarch64-darwin"),
				).
				Value(&system),
		),
		huh.NewGroup(
			huh.NewMultiSelect[string]().
				Title("Programs").
				Description("Select programs to enable (Space to toggle)").
				Options(
					huh.NewOption("aria2 - System Downloader", "aria2").Selected(true),
					huh.NewOption("bat - CLI", "bat").Selected(true),
					huh.NewOption("cosmic - Cosmic Desktop with Wayland", "cosmic").Selected(true),
					huh.NewOption("xdg - XDG User Dirs", "xdg").Selected(true),
					huh.NewOption("opencode - AI Agents", "opencode").Selected(true),
					huh.NewOption("direnv - Auto Dev Environment with Nix", "direnv").Selected(true),
					huh.NewOption("firefox - Browser", "firefox").Selected(true),
					huh.NewOption("home - Home-Manager Misc Configs", "home").Selected(true),
					huh.NewOption("pkgs - General Packages", "pkgs").Selected(true),
					huh.NewOption("starship - Customize ZSH prompt", "starship").Selected(true),
					huh.NewOption("zen-browser - Browser", "zen-browser").Selected(true),
					huh.NewOption("zsh - Default Shell", "zsh").Selected(true),
					huh.NewOption("mnw - Neovim Configured", "mnw").Selected(true),
					huh.NewOption("sops - Secrets Encrypted and Managed", "sops").Selected(true),
					huh.NewOption("openssh - Cryptograph SHA256 Key", "openssh").Selected(true),
					huh.NewOption("btop - System Usage Monitor", "btop").Selected(true),
					huh.NewOption("spicetify - Spotify", "spicetify").Selected(true),
					huh.NewOption("steam - Games", "steam").Selected(false),
					huh.NewOption("localsend - Send files fast through local WIFI", "localsend").Selected(true),
				).
				Value(&selectedPrograms),
		),
	)

	err := form.Run()
	if err != nil {
		fmt.Printf("Error running form: %v\n", err)
		os.Exit(1)
	}

	// Set defaults if empty
	if user == "" {
		user = defaultUser
		if user == "" {
			user = "user"
		}
	}
	if host == "" {
		host = "notebook"
	}
	if system == "" {
		system = "x86_64-linux"
	}

	// 5. Generate config.toml
	content := generateConfigTOML(user, system, host, selectedPrograms)

	err = os.WriteFile("config.toml", []byte(content), 0644)
	if err != nil {
		fmt.Printf("Error writing config.toml: %v\n", err)
		os.Exit(1)
	}

	// 6. Print final message
	absPath, _ := filepath.Abs(".")
	fmt.Printf(`

╔═══════════════════════════════════════════════════════════╗
║                   Setup Complete!                         ║
╚═══════════════════════════════════════════════════════════╝

✓ config.toml created at: %s

Next steps:
  1. Review your config.toml if needed
  2. Apply your NixOS configuration:

     cd %s
     sudo nixos-rebuild switch --flake .#%s

  Or run individual programs:
     nix run .#opencode
     nix run .#zv
     nix run .#firefox

`, absPath, absPath, host)
}
