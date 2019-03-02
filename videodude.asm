; VideoDude Main Routine

.include "m168def.inc"
.include "delay.asm"
.include "vsync.asm"

.org 0

setup:
    cli
    clr R0

    ; PD0 - Serial RX
    ; PD1 - Video Draw
    ; PD4 - Reserved
    ; PD5 - Video Sync
    ldi R16, (1 << PORTD1) | (1 << PORTD4) | (1 << PORTD5)
    out DDRD, R16

.include "frame.asm"
