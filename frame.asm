; PAL Frame Generation
; Reference: http://blog.retroleum.co.uk/electronics-articles/pal-tv-timing-and-voltages/

; Send Empty Char Sequency (16 cycles)
.macro send_black
    ldi R17, @0
    empty_bytes:
        sts UDR0, R0
        delay 9
        delay_2
        dec R17
    brne empty_bytes
.endmacro

frame:
    ; 5 Long Syncs
    long_sync 5

    ; 5 Top Short Sync
    short_sync 5

    ; VSync + Top Overscan (16 + 16 lines)
    overscan 32

    ; Active Area (256 lines)
    ldi R24, 0
    ldi R25, 0
    active_area:
        ; 4.6875us HSync (75 cycles)
        cbi PORTD, PORTD5 ; Sync Level
        delay 72
        delay_1

        ; 5,7us back porch + 3,1125us overscan (141 cycles)
        sbi PORTD, PORTD5 ; Black Level

        ; Set char line counter
        mov R18, R24
        andi R18, 7

        delay 78

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
        delay 9
        send_black 2

        ; 45us Active Area (720 cycles)
        ldi R17, 45
        send_stripes:
            sts UDR0, R1
            eor R1, R2
            delay 9
            delay_1
            dec R17
        brne send_stripes

        ; 3.85us overscan + 1.65us front porch (88 cycles)
        sts UCSR0B, R0
        delay 81
        adiw R24, 1 ; NOTE: Uses 2 cycles
        cpi R25, 1
    brne active_area

    ; Bottom Overscan (16 Lines)
    overscan 16

    ; 6 Bottom Short Sync
    short_sync 6

rjmp frame
