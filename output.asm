; PAL signal
; Reference: http://blog.retroleum.co.uk/electronics-articles/pal-tv-timing-and-voltages/

.include "m168def.inc"

; Waiting macros
.macro wait
    ldi R16, @0 / 3
    wait_loop:
        dec R16
        brne wait_loop
.endmacro

.macro wait_2
    nop
    nop
.endmacro

.macro wait_1
    nop
.endmacro

setup:
    cli
    clr R0

    ; Port Setup
    ; PD0 - Serial RX
    ; PD1 - Video Draw
    ; PD4 - Reserved
    ; PD5 - Video Sync
    ldi R16, (1 << PORTD1) | (1 << PORTD4) | (1 << PORTD5)
    out DDRD, R16

frame:
    ; Long Sync
    ldi R17, 5
    long_sync:

        ; 30us Long VSync (480 cycles)
        cbi PORTD, PORTD5 ; Sync Level
        wait 477
        wait_1

        ; 2us Wait (32 cycles)
        sbi PORTD, PORTD5 ; Black Level
        wait 27
        dec R17
    brne long_sync


    ; Short Sync
    .macro short_sync
        ldi R17, @0
        short_sync_loop:

            ; 2us Short VSync (32 cycles)
            cbi PORTD, PORTD5 ; Sync Level
            wait 30

            ; 30us Wait (480 cycles)
            sbi PORTD, PORTD5 ; Black Level
            wait 474
            wait_1
            dec R17
        brne short_sync_loop
    .endmacro

    short_sync 5

    ; Overscan
    .macro overscan
        ldi R17, @0
        overscan_loop:
            ; 4.7us HSync (75 cycles)
            cbi PORTD, PORTD5 ; Sync Level
            wait 72
            wait_1

            ; 59.3us Draw blank line (949 cycles)
            sbi PORTD, PORTD5 ; Black Level
            wait 765
            wait 177
            wait_2
            dec R17
        brne overscan_loop
    .endmacro

    ; VSync + Top Overscan (16 + 16 lines)
    overscan 32

    ; Active Area (256 lines)
    ldi R24, 0
    ldi R25, 1
    active_area:
        ; 4,7us HSync (75 cycles)
        cbi PORTD, PORTD5 ; Sync Level
        wait 72
        wait_1

        ; 5,7us back porch + 3us overscan (139 cycles)
        sbi PORTD, PORTD5 ; Black Level
        wait 135
        wait_2

        ; 45.95us Active Area (735 cycles)
        sbi PORTD, PORTD1 ; White
        wait 732
        wait_1

        ; 3us overscan + 1.65us front porch (75 cycles)
        cbi PORTD, PORTD1 ; Black Level
        wait 69
        sbiw R24, 1
    brne active_area

    overscan 16

    short_sync 6

rjmp frame
