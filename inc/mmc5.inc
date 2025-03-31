; MMC5 mapper registers
MMC5_PRG_MODE   = $5100   ; PRG ROM bank mode
MMC5_CHR_MODE   = $5101   ; CHR ROM bank mode
MMC5_PRG_RAM    = $5102   ; PRG RAM protection
MMC5_EXRAM_MODE = $5103   ; Extended RAM mode
MMC5_NT_MIRROR  = $5104   ; Nametable mirroring
MMC5_NT_MAP     = $5105   ; Nametable mapping
MMC5_FILL_TILE  = $5106   ; Fill mode tile number
MMC5_FILL_COLOR = $5107   ; Fill mode color
MMC5_PRG_BANK0  = $5113   ; PRG ROM bank 0
MMC5_PRG_BANK1  = $5114   ; PRG ROM bank 1
MMC5_PRG_BANK2  = $5115   ; PRG ROM bank 2
MMC5_PRG_BANK3  = $5116   ; PRG ROM bank 3
MMC5_CHR_BANK0  = $5120   ; CHR ROM bank 0
MMC5_CHR_BANK1  = $5121   ; CHR ROM bank 1
MMC5_CHR_BANK2  = $5122   ; CHR ROM bank 2
MMC5_CHR_BANK3  = $5123   ; CHR ROM bank 3
MMC5_CHR_BANK4  = $5124   ; CHR ROM bank 4
MMC5_CHR_BANK5  = $5125   ; CHR ROM bank 5
MMC5_CHR_BANK6  = $5126   ; CHR ROM bank 6
MMC5_CHR_BANK7  = $5127   ; CHR ROM bank 7
MMC5_SPLIT_CTRL = $5200   ; Split screen control
MMC5_SPLIT_SCRL = $5201   ; Split screen scroll position
MMC5_SPLIT_BANK = $5202   ; Split screen CHR bank
MMC5_SPLIT_MODE = $5203   ; Split screen mode
MMC5_SPLIT_IRQ  = $5204   ; Split screen IRQ
MMC5_MULT_1     = $5205   ; Multiplier 1
MMC5_MULT_2     = $5206   ; Multiplier 2
MMC5_EXRAM      = $5C00   ; Extended RAM (1KB)

; MMC5 sound registers
MMC5_PCM        = $5010   ; PCM volume
MMC5_SND_CTRL   = $5015   ; Sound control

; MMC5 modes
PRG_MODE_0      = $00     ; 32KB fixed, 32KB switchable
PRG_MODE_1      = $01     ; 16KB fixed, 16KB switchable
PRG_MODE_2      = $02     ; 16KB fixed, 16KB switchable
PRG_MODE_3      = $03     ; 16KB fixed, 16KB switchable

CHR_MODE_0      = $00     ; 8KB switchable
CHR_MODE_1      = $01     ; 4KB switchable
CHR_MODE_2      = $02     ; 2KB switchable
CHR_MODE_3      = $03     ; 1KB switchable

; MMC5 nametable mapping
NT_MIRROR_V     = $00     ; Vertical mirroring
NT_MIRROR_H     = $01     ; Horizontal mirroring
NT_MIRROR_1     = $02     ; Single screen
NT_MIRROR_2     = $03     ; Single screen

; MMC5 split screen modes
SPLIT_MODE_OFF  = $00     ; Split screen disabled
SPLIT_MODE_TOP  = $01     ; Split screen on top
SPLIT_MODE_BOT  = $02     ; Split screen on bottom
SPLIT_MODE_BOTH = $03     ; Split screen on both 