{ lib, ... }:

{
  fileSystems."/".options = lib.mkAfter [ "compress=zstd:3" ];
  fileSystems."/home".options = lib.mkAfter [ "compress=zstd:3" ];
  fileSystems."/nix".options = lib.mkAfter [ "compress=zstd:3" ];
}
