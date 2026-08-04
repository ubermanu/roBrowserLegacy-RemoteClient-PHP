{
  description = "roBrowserLegacy RemoteClient (PHP 8.3)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forEachSystem (pkgs:
        let
          php = pkgs.php83.withExtensions ({ enabled, all }: enabled ++ [ all.gd ]);
        in
        {
          default = pkgs.mkShell {
            packages = [ php php.packages.composer ];
          };
        });
    };
}
