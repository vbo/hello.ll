#!/bin/bash
set -e

exe() { echo "\$ $@" ; "$@" ; }

src_file="hello.ll"
out_path="build/hello.out"
opt_flag="-O3"

mode="$1"

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
    exe nasm code/minstd.osx.x86_64.asm \
        -f macho64 \
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
    exe vendor/llvm/bin/llvm-link code/minstd.osx.x86_64.ll code/$src_file \
        -S -o build/$prelinked_src_file
    ;;
*)
    echo "USAGE: $0 <mode>"
    echo 
    echo "MODES:"
    echo "  clean      Remove all build files"
    echo "  cstd       Build using C stdlib (libSystem.dylib)"
    echo "  minstd     Build using minimal stdlib (minstd.osx.x86_64.asm)"
    echo "  llstd      Build using minimal stdlib defined in LLVM bitcode"
    echo "             providing inlining possibility (minstd.osx.x86_64.ll)"
    exit 1
    ;;
esac

# LLVM pipeline common for all modes: optimize -> compile -> assemble
exe vendor/llvm/bin/opt build/$prelinked_src_file $opt_flag -S -o build/$src_file.opt
exe vendor/llvm/bin/llc build/$src_file.opt $opt_flag -filetype obj -o build/hello.o

# Link executable
exe ld $lib_file build/hello.o \
    -demangle -dynamic -arch x86_64 -dead_strip \
    -macosx_version_min $osx_v_min \
    -e _start -o $out_path

echo "Done."
