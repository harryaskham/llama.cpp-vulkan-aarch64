{ pkgs ? import <nixpkgs> {}}:

# Set up to compile on nix-on-droid with Vulkan backend
# Not everything required; forked from a shell.nix for building mesa turnip freedreno

with pkgs.lib;

let
  pythonPkgs = (ps: with ps; [
    distutils
    mako
  ]);
  pythonEnv = pkgs.python3.withPackages pythonPkgs;
in pkgs.mkShell ({
  nativeBuildInputs = with pkgs; [
      openblas
      pkg-config
      meson
      ninja
      pythonEnv
      clang
      clang-tools
      llvmPackages_latest.llvm
      llvmPackages_latest.libclang
      llvmPackages_latest.stdenv
      libdrm
      zlib
      zlib.dev
      dlib
      vulkan-loader
      vulkan-headers
      vulkan-tools
      vulkan-tools-lunarg
      vulkan-validation-layers
      vulkan-extension-layer
      shaderc
      mesa.drivers
      bintools
      libglvnd
      bison
      byacc
      flex
      cmake
      wayland-scanner
      wayland-protocols
      wayland
      xorg.libX11
      xorg.libxcb
      xorg.libXext
      xorg.libXfixes
      xorg.libxshmfence
      xorg.libXxf86vm
      xorg.libXrandr
    ];
    shellHook = ''
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:~/.nix-profile/lib"
      export LIBCLANG_PATH="${pkgs.llvmPackages_latest.libclang}/lib";
      alias configure-llama-cpp="cmake -B build -DGGML_VULKAN=ON -DGGML_CCACHE=OFF"
      alias build-llama-cpp="configure-llama-cpp; cmake --build build --config Release"
    '';
  })
