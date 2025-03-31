.include "mmc5.inc"

.segment "HEADER"
    .byte $4E, $45, $53, $1A   ; NES header identifier
    .byte $02                   ; Number of 16KB PRG-ROM banks
    .byte $01                   ; Number of 8KB CHR-ROM banks
    .byte $05                   ; MMC5 mapper, vertical mirroring
    .byte $00                   ; Mapper, battery RAM, trainer (unused)
    .byte $00                   ; No battery RAM
    .byte $00                   ; NTSC timing
    .byte $00                   ; No battery RAM
    .byte $00, $00, $00, $00   ; Padding bytes

.segment "ZEROPAGE"
; Game state variables
player_x:       .res 2
player_y:       .res 2
player_vel_x:   .res 1
player_vel_y:   .res 1
player_state:   .res 1
frame_counter:  .res 1
scroll_x:       .res 2
scroll_y:       .res 2

.segment "CODE"
.proc Reset
    sei                     ; Disable interrupts
    cld                     ; Clear decimal mode
    ldx #$FF
    txs                     ; Set up stack pointer

    ; Initialize MMC5
    lda #$00
    sta $5015              ; Disable sound
    sta $5204              ; Disable split screen
    lda #$03
    sta $5100              ; Set PRG mode 3 (32KB fixed, 32KB switchable)
    lda #$00
    sta $5101              ; Set CHR mode 0 (8KB switchable)
    lda #$00
    sta $5102              ; Set vertical mirroring
    lda #$00
    sta $5103              ; Set vertical mirroring
    lda #$00
    sta $5104              ; Disable extended RAM mode
    lda #$00
    sta $5105              ; Set nametable mapping

    ; Initialize PPU
    lda #$00
    sta $2000              ; Disable NMI
    sta $2001              ; Disable rendering
    sta $4015              ; Disable APU sound

    ; Wait for first vblank
    bit $2002
    :
        bit $2002
        bpl :-

    ; Initialize game state
    lda #$80
    sta player_x
    sta player_y
    lda #$00
    sta player_vel_x
    sta player_vel_y
    sta player_state
    sta frame_counter
    sta scroll_x
    sta scroll_y

    ; Enable rendering
    lda #%10000000         ; Enable NMI, sprites from Pattern Table 1
    sta $2000
    lda #%00011110         ; Enable sprites, enable background, no clipping on left side
    sta $2001

    jmp MainLoop
.endproc

.proc NMI
    pha
    txa
    pha
    tya
    pha

    ; Update sprites
    lda #$00
    sta $2003              ; Set the low byte of the RAM address
    lda #$02
    sta $4014              ; Set the high byte of the RAM address, start the transfer

    ; Update scroll position
    lda scroll_x
    sta $2005
    lda scroll_y
    sta $2005

    pla
    tay
    pla
    tax
    pla
    rti
.endproc

.proc MainLoop
    :
        inc frame_counter
        jsr UpdatePlayer
        jsr UpdateScroll
        jmp :-
.endproc

.proc UpdatePlayer
    ; Basic player movement
    lda player_vel_x
    clc
    adc player_x
    sta player_x
    lda player_vel_y
    clc
    adc player_y
    sta player_y
    rts
.endproc

.proc UpdateScroll
    ; Basic scroll movement
    lda frame_counter
    and #$01
    beq :+
    inc scroll_x
    :
    rts
.endproc

.segment "VECTORS"
    .word NMI
    .word Reset
    .word 0                ; IRQ vector (unused) 