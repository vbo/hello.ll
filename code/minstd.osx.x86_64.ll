; Define minimal syscall library
define void @exit(i32 %code) alwaysinline noreturn {
    call void asm sideeffect "
        movl $$0x2000001, %eax
        syscall
    ", "
        {edi}
    "  (i32 %code)
    ret void
}

define void @write(i32 %fd, i8* nocapture %buf, i32 %len) alwaysinline {
    call void asm sideeffect "
        movl $$0x2000004, %eax
        syscall
    ", "
        {edi},   {rsi},    {rdx}     ~{dirflag},~{fpsr},~{flags}
    "  (i32 %fd, i8* %buf, i32 %len)
    ret void
}
