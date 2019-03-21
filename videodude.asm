; VideoDude Main Routine

.include "m328pdef.inc"
.include "delay.asm"
.include "vsync.asm"
.include "charmap.asm"
.include "memory.asm"

.org 0

setup:
    cli
    clr R0
    ldi R16, 255
    mov R1, R16

    ; PD0 - Serial RX
    ; PD1 - Video Draw
    ; PD4 - Reserved
    ; PD5 - Video Sync
    ldi R16, (1 << PORTD1) | (1 << PORTD4) | (1 << PORTD5)
    out DDRD, R16

    ; Clear screen
    ldi XH, 0x02
    ldi XL, 0x5F
    clear_loop:
        st X+, R0
        cpi XH, 9
    brne clear_loop

    ; Welcome Message
    ldi XH, 0x02
    ldi XL, 0x5F
    ldi ZH, high(info*2)
    ldi ZL, low(info*2)
    welcome:
        lpm R1, Z+
        st X+, R1
        cp R1, R0
    brne welcome

.include "frame.asm"

info: .db "VideoDude v0.1 Alpha", 0, 0
