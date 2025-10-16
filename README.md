# Our NixOS Config

KDE Plasma, with customizations for appearance, applications, fonts, and user services.

## Notes

- With thanks to [Rikumi](https://github.com/rikumi/silent-audio) for the Yoga 14IRP8 audio fix, and [SudoMason](https://www.reddit.com/r/NixOS/comments/1hzgxns/fully_declarative_flatpak_management_on_nixos/) for the Flatpak configuration.
- `nixos/globals.nix` configures a number of variables, including your desired username. Before building the config, take a look and edit it as needed.
- `flake/assets/profile-picture.nix` configures user profile pictures by creating a system service. If you wish to use a profile picture, it must be avaliable in a relative path.

e.g.

```
services.userProfilePicture = {
    enable = true;
    users.${globals.username}.picture = ../misc/pfp.jpg; # Required if service is enabled
};
```

- `pfp.jpg` comes from a still of Laura Les' set at [A2B2 Night of Fire](https://www.youtube.com/watch?v=mxa55SJ8KC8).