{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs {}}:

with pkgs;
with pkgs.lua54Packages;

let

    lua = pkgs.lua5_4;
    luaPackages = pkgs.lua54Packages;
    csound-with-lua = import ./nix/csound.nix {sources=sources; pkgs=pkgs; lua=lua;};
    # wm2 = import ./default.nix  {sources=sources; pkgs=pkgs;};
    # wm2

in
    mkShell {
        buildInputs = [
            lua
            # To parse yml patches
            luaPackages.lyaml
            # To support DSP
            csound-with-lua
        ];
        shellHook = ''
            export LUA_CPATH=$LUA_CPATH";${csound-with-lua}/lib/?.so"

            # When using 'luaPackages' we can't use local paths anymore, so
            # explicitly specify them...
            export LUA_PATH=$LUA_PATH";/home/levinericzimmermann/Programming/wm2/wm2/?.lua"
            export LUA_PATH=$LUA_PATH";/home/levinericzimmermann/Programming/wm2/wm2/?/init.lua"
        '';
    }
