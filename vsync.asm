; Vertical Syncronization Routines

; Long Sync
.macro long_sync
    ldi R17, @0
    loop:

        ; 30us Long VSync (480 cycles)
        cbi PORTD, PORTD5 ; Sync Level
        delay 477
        delay_1

        ; 2us Wait (32 cycles)
        sbi PORTD, PORTD5 ; Black Level
        delay 27
        dec R17
    brne loop
.endmacro

; Short Sync
.macro short_sync
    ldi R17, @0
    loop:

        ; 2us Short VSync (32 cycles)
        cbi PORTD, PORTD5 ; Sync Level
        delay 30

        ; 30us Wait (480 cycles)
        sbi PORTD, PORTD5 ; Black Level
        delay 474
        delay_1
        dec R17
    brne loop
.endmacro

; Overscan
.macro overscan
    ldi R17, @0
    loop:

        ; 4.6875us HSync (75 cycles)
        cbi PORTD, PORTD5 ; Sync Level
        delay 72
        delay_1

        ; 59.3us Draw blank line (949 cycles)
        sbi PORTD, PORTD5 ; Black Level
        delay 765
        delay 177
        delay_2
        dec R17
    brne loop
.endmacro
