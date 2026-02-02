{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.userProfilePicture;
in
{
  options.services.userProfilePicture = {
    enable = mkEnableOption "user profile picture setup for AccountsService";

    users = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          picture = mkOption {
            type = types.path;
            description = "Path to the profile picture file";
            example = literalExpression "./assets/profile.jpg";
          };
        };
      });
      default = {};
      description = "User profile pictures configuration";
      example = literalExpression ''
        {
          billie.picture = ./assets/billie.jpg;
          john.picture = ./assets/john.jpg;
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts.userProfilePictures = stringAfter [ "users" ] ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      
      ${concatStringsSep "\n" (mapAttrsToList (username: userCfg: ''
        # Copy profile picture for ${username}
        cp ${userCfg.picture} /var/lib/AccountsService/icons/${username}
        
        # Create AccountsService user file
        cat > /var/lib/AccountsService/users/${username} << 'EOF'
[User]
Icon=/var/lib/AccountsService/icons/${username}
EOF
        
        # Also create .face symlink in user's home directory
        if [ -d /home/${username} ]; then
          ln -sf /var/lib/AccountsService/icons/${username} /home/${username}/.face
          ln -sf /var/lib/AccountsService/icons/${username} /home/${username}/.face.icon
          chown ${username} /home/${username}/.face /home/${username}/.face.icon 2>/dev/null || true
        fi
      '') cfg.users)}
    '';
  };
}
