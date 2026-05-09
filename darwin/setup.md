# Initialise nix-darwin

See `/flake.nix` to configure `darwinSystem`, `darwinUsername` & `darwinHostname`.

## Build the derivation

 `nix build .#darwinConfigurations.insertHostnameHere.system \
 	--extra-experimental-features 'nix-command flakes'`

## Switch to the new derivation

 `sudo -E ./result/sw/bin/darwin-rebuild switch --flake .#insertHostnameHere`

---

After the derivation has been applied, the `./result` symlink can be removed.
