# Our Nix Config

Nix flake which provides configurations for NixOS and nix-darwin. Includes customizations for appearance, applications, fonts, user services and desktop environment (GNOME on NixOS). This repository also contains hardware-specific workarounds and configurations for specific use cases (e.g., VFIO). It is recommended that you do not copy this configuration wholesale.

## Directory Structure

| Path | Description |
|------|-------------|
| `/darwin` | macOS-specific configurations (nix-darwin, Homebrew, Home Manager). |
| `/hardware` | Device-specific configurations and modules for NixOS hosts. |
| `/home` | Home Manager configurations: baseline (`common.nix`), DE customisations, shell, programs, etc. |
| `/modules` | System-wide packages/services (e.g., DE configs, custom services like `profile-picture.nix`). `baseline.nix` provides a common set of configurations for every NixOS system to use. |
| `/misc` | Arbitrary files like profile pictures, KDE keybind exports, SVGs for custom XDG entries, etc. |
