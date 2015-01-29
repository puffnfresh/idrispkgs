{ nixpkgs ? import <nixpkgs> {} 
, idris_plain ? nixpkgs.haskellPackages.callPackage ./idris_plain {}
}:

with nixpkgs;

let
  libraryDirectory = "${idris_plain.system}-ghc-${idris_plain.ghc.version}/${idris_plain.fname}";
in
rec {
  mkDerivation = { pname, version, buildDepends, src, buildInputs ? [] }:
    let wrappedIdris = idrisWithPackages buildDepends;
    in stdenv.mkDerivation {
      name = "${pname}-${version}";
      inherit src buildInputs;
      dontUseCmakeConfigure = true;
      LANG = "en_US.UTF-8";
      LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
      buildPhase = ''
        export TARGET="$out"
        ${wrappedIdris}/bin/idris --build ${pname}.ipkg
      '';
      installPhase = ''
        ${wrappedIdris}/bin/idris --install ${pname}.ipkg
      '';
    };

  idrisWithPackages = pkgs: callPackage ./idris_plain/wrapper.nix {
    idris_plain = idris_plain;
    idrisLibraryPath = symlinkJoin "idris-env" ([
      "${idris_plain}/share/${libraryDirectory}"
    ] ++ pkgs);
  };

  lightyear = mkDerivation rec {
    pname = "lightyear";
    version = "e0b3e883f833c1114effc837a086b0ab9c6c44eb";
    src = fetchFromGitHub {
      owner = "jfdm";
      repo = "lightyear";
      rev = version;
      sha256 = "1636xzzvd84p7s9b6ikd6pl122v8sb7z8ivn42546px8763l0rkw";
    };
    buildDepends = [];
  };
  idris-commonmark = mkDerivation rec {
    pname = "commonmark";
    version = "e9c27048765bbe56ebeb37df0df18ad2ab42ecaf";
    src = fetchgit {
      url = "https://github.com/puffnfresh/idris-commonmark.git";
      sha256 = "0mqg8idaqp2xpnjkz81vxkmqq7vrvpqla86gdanpr6i7n11xnm41";
    };
    buildInputs = [ re2c ];
    buildDepends = [ ];
  };
  idris-config = mkDerivation rec {
    pname = "config";
    version = "763567ad095f720fb905ff2aa4598470ef2b741b";
    src = fetchFromGitHub {
      owner = "jfdm";
      repo = "idris-config";
      rev = version;
      sha256 = "1sa0wrkm769sw25vqq7b3xnrq6irzr9387hhh4dlfjn1kg03nah5";
    };
    buildDepends = [ lightyear ];
  };
  quantities = mkDerivation rec {
    pname = "quantities";
    version = "f0e3cbb010843c7c46768953328579c7e62330be";
    src = fetchFromGitHub {
      owner = "timjb";
      repo = "quantities";
      rev = version;
      sha256 = "1rz259mln5387akcbv5fgss69fiaiihgk9ja4k6s1w8dhsfza6bl";
    };
    buildDepends = [ ];
  };
}
