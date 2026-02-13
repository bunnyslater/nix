# Our NixOS Config

GNOME, with customizations for appearance, applications, fonts, and user services. KDE Plasma is also configured. This repository includes configurations for specific use cases (e.g., VFIO) and hardware-specific workarounds. It is recommended that you do not copy this configuration wholesale.

## Directory Structure

- `/hardware`: Device-specific configurations and modules.
- `/home`: Home Manager configurations: baseline (`common.nix`), DE customisations, shell, programs, etc.  
- `/modules`: System-wide packages/services (e.g., DE configs, custom services like `profile-picture.nix`). `baseline.nix` provides a common set of configurations for every system to use.
- `/misc`: Abitrary files like profile pictures, KDE keybind exports, SVGs for custom XDG entries, etc.
