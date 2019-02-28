; PAL signal
; Reference: http://blog.retroleum.co.uk/electronics-articles/pal-tv-timing-and-voltages/

.include "m168def.inc"

; Wait a number of cycles
.macro wait
    ldi R16, @0
    wait_loop:
        dec R16
        brne wait_loop
.endmacro

setup:
    ; Port Setup
    sbi DDRB, 0
    sbi DDRB, 1
    cbi PORTB, 0
    cbi PORTB, 1

frame:
    ; Long Sync
    ldi R17, 5
    long_sync:

        ; 30us Long VSync
        cbi PORTB, 0 ; Sync Level
        wait 199
        nop

        ; 2us Wait
        sbi PORTB, 0 ; Black Level
        wait 11
        nop
        nop
        dec R17
    brne long_sync


    ; Short Sync
    .macro short_sync
        ldi R17, @0
        short_sync_loop:

            ; 2us Short VSync
            cbi PORTB, 0 ; Sync Level
            wait 12
            nop
            nop

            ; 30us Wait
            sbi PORTB, 0 ; Black Level
            wait 198
            nop
            dec R17
        brne short_sync_loop
    .endmacro

    short_sync 5

    ; VSync + Top Overscan (16 + 14 lines)
    .macro overscan
        ldi R17, @0
        overscan_loop:
            ; 4us HSync
            cbi PORTB, 0 ; Sync Level
            wait 30
            nop
            nop

            ; Draw blank line (59,3us)
            sbi PORTB, 0
            wait 255
            wait 138
            nop
            nop
            dec R17
        brne overscan_loop
    .endmacro

    overscan 30


    ; Active Area (260 lines)
    ldi R24, 4
    ldi R25, 1
    active_area:

        ; 4,7us HSync
        cbi PORTB, 0 ; Sync Level
        wait 30
        nop
        nop

        ; 5,7 us back porch + 3 us overscan
        sbi PORTB, 0 ; Black Level
        wait 57
        nop

        ; Active Area (45,95 us)
        sbi PORTB, 1 ; White
        wait 255
        wait 50
        nop
        nop

        ; 3 us overscan + 1,65 front porch
        cbi PORTB, 1 ; Black Level
        wait 29
        sbiw R24, 1
    brne active_area

    overscan 14

    short_sync 6

rjmp frame
