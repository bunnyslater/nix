{ username, hostname, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    users.${username} = import ./home/common.nix {
      inherit username hostname;
    };
  };
}
