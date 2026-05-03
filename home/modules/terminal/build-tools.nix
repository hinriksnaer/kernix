# Build tools -- compilers, linkers, and archive utilities.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    gnumake
    cmake
    pkg-config
    openssl
    openssl.dev
    unzip
    gnutar
  ];
}
