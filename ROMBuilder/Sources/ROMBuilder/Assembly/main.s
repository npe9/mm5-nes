.include "../inc/mmc5.inc"

.segment "HEADER"
    .byte "NES", $1A   ; iNES header identifier
    .byte 2            ; Number of 16KB PRG-ROM banks
    .byte 1            ; Number of 8KB CHR-ROM banks
    .byte $05          ; Mapper 5 (MMC5)
    .byte $00          ; Mirroring: vertical
    .byte $00          ; No battery RAM
    .byte $00          ; No trainer
    .byte $00          ; No four-screen
    .byte $00          ; No VS system
    .byte $00          ; No PlayChoice-10
    .byte $00          ; No NES 2.0
    .byte $00          ; No PRG RAM
    .byte $00          ; No CHR RAM
    .byte $00          ; No expansion audio
    .byte $00          ; No expansion audio
    .byte $00          ; No expansion audio

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
reset_handler:
    sei                 ; Disable interrupts
    cld                 ; Clear decimal mode
    ldx #$FF
    txs                 ; Set up stack
    inx                 ; X = 0
    stx $2000          ; Disable NMI
    stx $2001          ; Disable rendering
    stx $4015          ; Disable APU sound

    ; Initialize MMC5
    lda #PRG_MODE_0
    sta MMC5_PRG_MODE  ; Set PRG mode to 32KB fixed, 32KB switchable
    lda #CHR_MODE_0
    sta MMC5_CHR_MODE  ; Set CHR mode to 8KB switchable
    lda #NT_MIRROR_V
    sta MMC5_NT_MIRROR ; Set vertical mirroring

    ; Set up initial banks
    lda #0
    sta MMC5_PRG_BANK0 ; Bank 0 at $8000
    lda #1
    sta MMC5_PRG_BANK1 ; Bank 1 at $A000
    lda #2
    sta MMC5_PRG_BANK2 ; Bank 2 at $C000
    lda #3
    sta MMC5_PRG_BANK3 ; Bank 3 at $E000

    ; Enable rendering
    lda #%10000000     ; Enable NMI, sprites from Pattern Table 1
    sta $2000
    lda #%00011110     ; Enable sprites, enable background
    sta $2001

    jmp main_loop

nmi_handler:
    rti

irq_handler:
    rti

main_loop:
    jmp main_loop

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
    .addr nmi_handler, reset_handler, irq_handler

.segment "CHARS"
    .incbin "../res/player.chr" 