.dseg ; Data Segment (SRAM)

.org 0x260
videoram: .byte 0x5A0 ; 1440 bytes (45 x 32)

.cseg
