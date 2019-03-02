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

    ; Clear ZH for memory manipulation
    clr ZH

    ; Text test


.include "frame.asm"
