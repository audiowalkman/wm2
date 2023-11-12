{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs {}}:

with pkgs;
with pkgs.lua54Packages;

let

    lua = pkgs.lua5_4;
    luaPackages = pkgs.lua54Packages;
    csound-with-lua = import ./nix/csound.nix {sources=sources; pkgs=pkgs; lua=lua;};

in

  buildLuarocksPackage {
    pname = "wm2";
    version = "0.1,0";
    knownRockspec = ./wm2-dev-1.rockspec;
    src = ./.;
    propagatedBuildInputs = [
      lua
      csound-with-lua
      luaPackages.lyaml
    ];
  }
