{ lib, stdenv, fetchFromGitHub, python3 }:

stdenv.mkDerivation {
  pname = "cupp";
  version = "master";

  src = fetchFromGitHub {
    owner = "Mebus";
    repo = "cupp";
    rev = "master";
    hash = "sha256-eNE8DUFtFFEfBsm3TrL3GcnBXPQ7x0kfzZHH49Jqy5w=";
  };

  nativeBuildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

  mkdir -p $out/bin
    cp cupp.py $out/bin/cupp
    cp cupp.cfg $out/bin/cupp.cfg
    chmod +x $out/bin/cupp
    patchShebangs $out/bin/cupp

    runHook postInstall
  '';

  meta = {
    description = "Common User Passwords Profiler";
    homepage = "https://github.com/Mebus/cupp";
    license = lib.licenses.gpl3Only;
    mainProgram = "cupp";
    platforms = lib.platforms.unix;
  };
}
