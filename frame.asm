; PAL Frame Generation
; Reference: http://blog.retroleum.co.uk/electronics-articles/pal-tv-timing-and-voltages/

frame:
    ; 5 Long Syncs
    long_sync 5

    ; 5 Top Short Sync
    short_sync 5

    ; VSync + Top Overscan (16 + 16 lines)
    overscan 32

    ; Set Video Memory Map Location
    ldi XH, 0x02
    ldi XL, 0x8C

    ; Active Area (256 lines)
    active_area:
        ; 4.6875us HSync (75 cycles)
        cbi PORTD, PORTD5 ; Sync Level
        delay 72
        delay_1

        ; 5,7us back porch + 3,1125us overscan (141 cycles)
        sbi PORTD, PORTD5 ; Black Level

        delay 66
        delay_1

        ; Set char line counter
        dec ZH
        andi ZH, 7
        breq continue ; FIXME: Two or Three Cycles
            sbiw XL, 45
        continue:
        ori ZH, 8

        ; Setup USART SPI Mode
        sts UBRR0H, R0
        sts UBRR0L, R0
        sts UCSR0A, R0
        ldi R16, (1 << UMSEL01) | (1 << UMSEL00) | (1 << UDORD0)
        sts UCSR0C, R16
        ldi R16, (1 << TXEN0)
        sts UDR0, R0
        sts UCSR0B, R16
        sts UBRR0H, R0
        sts UBRR0L, R0

        ; Send black
        ldi R17, 3
        send_blank:
            sts UDR0, R0
            delay 9
            delay_2
            dec R17
        brne send_blank

        ; 45us Active Area (720 cycles)
        ldi R17, 45
        send_char:
            ld ZL, X+
            lpm R1, Z
            sts UDR0, R1
            delay 6
            dec R17
        brne send_char

        ; 3.85us overscan + 1.65us front porch (88 cycles)
        sts UCSR0B, R0
        delay 81
        delay_2
        cpi XH, 8
    brlt active_area

    ; Bottom Overscan (16 Lines)
    overscan 16

    ; 6 Bottom Short Sync
    short_sync 6

rjmp frame
