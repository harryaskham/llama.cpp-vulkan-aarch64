{ pkgs ? import <nixpkgs> {}}:

# Set up to compile on nix-on-droid with Vulkan backend via Turnip driver
# Tested on a Samsung Galaxy S24 Ultra w/ adreno 750
#
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
      curl
    ];
    shellHook = ''
      export LIBCLANG_PATH="${pkgs.llvmPackages_latest.libclang}/lib";
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:~/.nix-profile/lib:${pkgs.vulkan-validation-layers}/lib:${pkgs.vulkan-tools-lunarg}/lib:${pkgs.mesa.drivers}/lib:${pkgs.xorg.libxcb}/lib"

      export MESA_NO_ERROR=1
      export MESA_GL_VERSION_OVERRIDE=4.5COMPAT
      export MESA_GLSL_VERSION_OVERRIDE=450
      export MESA_GLES_VERSION_OVERRIDE=3.2

      export VULKAN_SDK="${pkgs.vulkan-headers}";
      export VK_ICD_FILENAMES="${pkgs.mesa.drivers}/share/vulkan/icd.d/freedreno_icd.aarch64.json"
      export VK_LAYER_PATH="${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d:${pkgs.vulkan-tools-lunarg}/share/vulkan/explicit_layer.d";
      export Vulkan_LIBRARY="${pkgs.mesa.drivers}/lib/libvulkan_freedreno.so"
      export Vulkan_INCLUDE_DIR="${pkgs.vulkan-headers}/include/vulkan"

      export GALLIUM_DRIVER=zink
      export ZINK_DESCRIPTORS=lazy
      export MESA_LOADER_DRIVER_OVERRIDE=zink
      export MESA_VK_WSI_DEBUG=sw
      export TU_DEBUG=noconform
      export vblank_mode=0

      alias configure-llama-cpp="cmake -B build -DGGML_VULKAN=ON -DGGML_CCACHE=OFF -DGGML_BLAS_VENDOR=OpenBLAS"
      alias build-llama-cpp="configure-llama-cpp; cmake --build build --config Release"
    '';
  })
