; Delay routines

; Delay an number of times
; Must be multiple of 3
.macro delay
    ldi R16, @0 / 3
    loop:
        dec R16
    brne loop
.endmacro

; Delay 2 cycles
.macro delay_2
    nop
    nop
.endmacro

; Delay 1 cycle
; Just for consistency
.macro delay_1
    nop
.endmacro
