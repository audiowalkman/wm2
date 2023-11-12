# Csound which also build Lua API and exports path

{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs {}, lua ? pkgs.lua5_4}:

let
  remote-csound = pkgs.csound;
in
  remote-csound.overrideAttrs (
    finalAttrs: previousAttrs: {
      # See https://github.com/csound/csound/blob/a1580f9cdf331c35dceb486f4231871ce0b00266/interfaces/CMakeLists.txt#L5C8-L7
      cmakeFlags = [ "-DBUILD_CSOUND_AC=0" "-DBUILD_LUA_INTERFACE=1" "-DBUILD_CXX_INTERFACE=1" "-DLUA_LIBRARY=${lua}/lib/liblua.a" ];
      propagatedBuildInputs = [ lua ];
      # Swig is automacially found by cmake, but somehow cmake can't find lua, neither lua5_2 nor lua5_1...
      buildInputs = [ lua pkgs.swig ] ++ previousAttrs.buildInputs;
      nativeBuildInputs = [ lua pkgs.swig ] ++ previousAttrs.nativeBuildInputs;
      # XXX: This doesn't work yet unfortunately :(
      postInstall = ''
        # Patch LUA_CPATH so that lua can find 'luaCsnd6.so'
        export LUA_CPATH=$LUA_CPATH";${placeholder "out"}/lib/?.so"
      '';
    }
  )
