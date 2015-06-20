; Linked from libc/minstd.asm/minstd.ll depending on build mode
declare void @exit(i32) nounwind noreturn
declare void @write(i32, i8*, i32) nounwind

; Global stuff
@hello_world.str = constant [14 x i8] c"Hello World!\0A\00"

; Entry point (skipping libc main)
define void @start() {
    %t1 = getelementptr [14 x i8]*  @hello_world.str, i64 0, i64 0
    call void @write(i32 1, i8* %t1, i32 14)
    %t2 = call i32 @some_math(i32 100, i32 70)
    call void @exit(i32 %t2)
    ret void
}

; Some helper function to check out optimizer awesomeness
define internal i32 @some_math(i32 %x, i32 %y) {
    %t1 = mul i32 %x, %y
    %t11 = add i32 42, %t1
    %t2 = urem i32 %t11, %y
    ret i32 %t2
}

