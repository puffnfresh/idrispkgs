{ stdenv, gmp, makeWrapper, runCommand, idris_plain, boehmgc, idrisLibraryPath }:

runCommand "idris-wrapper" {} ''
  source ${makeWrapper}/nix-support/setup-hook
  mkdir -p $out/bin
  ln -s ${idris_plain}/bin/idris $out/bin
      wrapProgram $out/bin/idris \
        --set    IDRIS_LIBRARY_PATH ${idrisLibraryPath} \
        --suffix NIX_CFLAGS_COMPILE : '"-I${gmp}/include -L${gmp}/lib -L${boehmgc}/lib"' \
        --suffix PATH : ${stdenv.cc}/bin \
        --suffix PATH : ${idris_plain}/bin
''
