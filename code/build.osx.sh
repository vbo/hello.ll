#!/bin/bash
set -e

exe() { echo "\$ $@" ; "$@" ; }

usage () {
    echo "USAGE: $0 <arch> <mode>"
    echo 
    echo "ARCHITECTURES:"
    echo "  x86"
    echo "  x86_64"
    echo 
    echo "MODES:"
    echo "  clean      Remove all build files"
    echo "  cstd       Build using C stdlib (libSystem.dylib)"
    echo "  minstd     Build using minimal stdlib (minstd.osx.<arch>.asm)"
    echo "  llstd      Build using minimal stdlib defined in LLVM bitcode"
    echo "             providing inlining possibility (minstd.osx.<arch>.ll)"
}

src_file="hello.ll"
out_path="build/hello.out"
opt_flag="-O3"

arch_name="$1"
mode="$2"

case "$arch_name" in
x86_64)
    arch_nasm_mode="macho64"
    arch_ld_mode="x86_64"
    arch_llc_mode="x86-64"
    ;;
x86)
    arch_nasm_mode="macho"
    arch_ld_mode="i386"
    arch_llc_mode="x86"
    ;;
*)
    usage
    exit 1
esac

case "$mode" in
clean)
    echo "Cleaning up..."
    exe rm -f build/hello*
    exe rm -f build/minstd*
    exit 0
    ;;
cstd)
    echo "Building in $mode mode..."
    # Ask ld to link with C stdlib (libSystem on OS X)
    prelinked_src_file=$src_file
    lib_file="-lSystem"
    osx_v_min="10.8.0"
    exe cp code/$src_file build/$src_file
    ;;
minstd)
    echo "Building in $mode mode..."
    # Build minimal stdlib and ask ld to link it
    prelinked_src_file=$src_file
    lib_file="build/minstd.o"
    osx_v_min="10.6.0"
    exe nasm code/minstd.osx.$arch_name.asm \
        -f $arch_nasm_mode \
        -o $lib_file
    exe cp code/$src_file build/$src_file
    ;;
llstd)
    echo "Building in $mode mode..."
    # Merge with minimal stdlib defined in LLVM IR
    # The resulting code is self-contained so no additinal linkage required
    prelinked_src_file=$src_file.prelinked
    lib_file=""
    osx_v_min="10.6.0"
    exe vendor/llvm/bin/llvm-link code/minstd.osx.$arch_name.ll code/$src_file \
        -S -o build/$prelinked_src_file
    ;;
*)
    usage
    exit 1
    ;;
esac

# LLVM pipeline common for all modes: optimize -> compile -> assemble
exe vendor/llvm/bin/opt build/$prelinked_src_file $opt_flag -S -o build/$src_file.opt
exe vendor/llvm/bin/llc build/$src_file.opt $opt_flag -filetype obj -relocation-model pic -march $arch_llc_mode -o build/hello.o

# Link executable
exe ld $lib_file build/hello.o \
    -demangle -dynamic -arch $arch_ld_mode -dead_strip \
    -macosx_version_min $osx_v_min \
    -e _start -o $out_path

echo "Done."
