.include "../inc/mmc5.inc"

.segment "CODE"
.proc test_player_movement
    ; Test player movement
    lda #0
    sta player_x
    sta player_y
    lda #1
    sta player_vel_x
    sta player_vel_y

    ; Call UpdatePlayer
    jsr UpdatePlayer

    ; Check results
    lda player_x
    cmp #1
    bne test_failed
    lda player_y
    cmp #1
    bne test_failed

    ; Test passed
    lda #$00
    rts

test_failed:
    lda #$FF
    rts
.endproc

.proc test_scroll_movement
    ; Test scroll movement
    lda #0
    sta frame_counter
    sta scroll_x

    ; Call UpdateScroll
    jsr UpdateScroll

    ; Check results (should not increment on even frame)
    lda scroll_x
    cmp #0
    bne test_failed

    ; Test with odd frame
    lda #1
    sta frame_counter
    jsr UpdateScroll

    ; Check results (should increment on odd frame)
    lda scroll_x
    cmp #1
    bne test_failed

    ; Test passed
    lda #$00
    rts

test_failed:
    lda #$FF
    rts
.endproc

.segment "VECTORS"
    .addr 0, 0, 0 