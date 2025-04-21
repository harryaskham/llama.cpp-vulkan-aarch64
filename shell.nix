{ pkgs ? import <nixpkgs> {}}:

# Set up to compile on nix-on-droid with Vulkan backend
# Run:
#   > nix-shell
#   $ build-llama-cpp
#   > ./build/bin/llama-cli -m ...

with pkgs.lib;

pkgs.mkShell ({
  nativeBuildInputs = with pkgs; [
      openblas
      pkg-config
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
    ];
    shellHook = ''
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:~/.nix-profile/lib"
      export LIBCLANG_PATH="${pkgs.llvmPackages_latest.libclang}/lib";
      alias configure-llama-cpp="cmake -B build -DGGML_VULKAN=ON -DGGML_CCACHE=OFF -DGGML_BLAS_VENDOR=OpenBLAS"
      alias build-llama-cpp="configure-llama-cpp; cmake --build build --config Release"
    '';
  })
