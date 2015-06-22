; Define minimal syscall library
define void @exit(i32 %code) alwaysinline noreturn {
    call void asm sideeffect "
        pushl $0
        movl $$0x1, %eax
        subl $$4, %esp
        int $$0x80
    ", "
        rmi
    "  (i32 %code)
    ret void
}

define void @write(i32 %fd, i8* nocapture %buf, i32 %len) alwaysinline {
    call void asm sideeffect "
        pushl $2
        pushl $1
        pushl $0
        movl $$0x4, %eax
        subl $$4, %esp
        int $$0x80
        addl $$16, %esp
    ", "
        rmi,     r,        rmi     ~{dirflag},~{fpsr},~{flags}
    "  (i32 %fd, i8* %buf, i32 %len)
    ret void
}

