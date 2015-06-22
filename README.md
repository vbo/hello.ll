# hello.ll
Here I am demonstrating several ways to implement Hello World program for OS X in LLVM Language.

1. Link with C standard library to get at least `write()` and `exit()` functions. That's the simplest way but adds unnecessary
libc dependency. It's just boring =)
2. Implement your own minimal standard library (e.g. in assembly) and ask `ld` to link with it. Here
we can fully bypass libc but system calls can't be inlined or otherwise optimized by LLVM.
3. Implement your own minimal standard library in LLVM Language and link with it using `llvm-link`.
This is the most interesting way resulting in the tightest machine code. System calls could become
a target to full-blown LLVM optimization and `ld` invocation becomes trivial.

How to play on your own
-----------------------
 - Build LLVM and put everything to `vendor/llvm` directory (`llc` should be accessible via `vendor/llvm/bin/llc`)
 - For the second option you also need `nasm` (could be installed via homebrew)
 - Run `code/build.osx.sh`
 ~~~~~~
  USAGE: ./code/build.osx.sh <arch> <mode>
  
  ARCHITECTURES:
    x86
    x86_64
  
  MODES:
    clean      Remove all build files
    cstd       Build using C stdlib (libSystem.dylib)
    minstd     Build using minimal stdlib (minstd.osx.<arch>.asm)
    llstd      Build using minimal stdlib defined in LLVM bitcode
               providing inlining possibility (minstd.osx.<arch>.ll)
 ~~~~~~
 
 - Run `build/hello.out`
 ~~~~~~
  Hello World!
 ~~~~~~
 
 - Examine `build/hello.out`. E.g.
 ~~~~~~
  $ otool -tv build/hello.out
  build/hello.out:
  (__TEXT,__text) section
  _start:
  0000000100000f80	leaq	0x1d(%rip), %rsi
  0000000100000f87	movl	$0x1, %edi
  0000000100000f8c	movl	$0xe, %edx
  0000000100000f91	movl	$0x2000004, %eax        ## imm = 0x2000004
  0000000100000f96	syscall
  0000000100000f98	movl	$0x2a, %edi
  0000000100000f9d	movl	$0x2000001, %eax        ## imm = 0x2000001
  0000000100000fa2	syscall
 ~~~~~~
