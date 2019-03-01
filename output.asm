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

; Send Empty Char Sequency (16 cycles)
.macro send_black
    ldi R17, @0
    empty_bytes:
        sts UDR0, R0
        wait 9
        wait_2
        dec R17
    brne empty_bytes
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

    ; NOTE: Test
    clr R1
    ldi R16, 255
    mov R2, R16

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
            ; 4.6875us HSync (75 cycles)
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
        ; 4.6875us HSync (75 cycles)
        cbi PORTD, PORTD5 ; Sync Level
        wait 72
        wait_1

        ; 5,7us back porch + 3,1125us overscan (141 cycles)
        sbi PORTD, PORTD5 ; Black Level
        wait 78
        wait_2

        ; Setup USART SPI Mode
        sts UBRR0H, R0
        sts UBRR0L, R0
        sts UCSR0A, R0
        ldi R16, (1 << UMSEL01) | (1 << UMSEL00)
        sts UCSR0C, R16
        ldi R16, (1 << TXEN0)
        sts UDR0, R0
        sts UCSR0B, R16
        sts UBRR0H, R0
        sts UBRR0L, R0
        wait 9
        send_black 2

        ; 45us Active Area (720 cycles)
        ldi R17, 45
        send_stripes:
            sts UDR0, R1
            eor R1, R2
            wait 9
            wait_1
            dec R17
        brne send_stripes

        ; 3.85us overscan + 1.65us front porch (88 cycles)
        sts UCSR0B, R0
        wait 81
        wait_1
        sbiw R24, 1
    brne active_area

    overscan 16

    short_sync 6

rjmp frame
