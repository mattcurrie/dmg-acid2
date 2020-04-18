SECTION "mgblib", ROMX
INCLUDE "mgblib/src/hardware.inc"
INCLUDE "mgblib/src/macros.asm"
INCLUDE "mgblib/src/old_skool_outline_thick.asm"
INCLUDE "mgblib/src/display.asm"


SECTION "stat_int", ROM0[$48]
    jp hl


SECTION "boot", ROM0[$100]
    nop                                       
    jp Main         


SECTION "main", ROM0[$150]
Main::
    di
    ld sp, $cfff

    call ResetDisplay
    call LoadFont8000

    ld hl, OAMData
    ld de, _OAMRAM
    ld bc, OAMData.end - OAMData
    call MemCopy

    ; set the footer tile map
    ld hl, $9e80
    ld a, $10
    ld c, 20
.loop:
    ld [hl+], a
    inc a
    dec c
    jr nz, .loop
    ld l, $a0

    ld c, 20
.loop2:
    ld [hl+], a
    inc a
    dec c
    jr nz, .loop2

    ld hl, BackgroundMap
    ld de, $9880
    ld bc, BackgroundMap.end - BackgroundMap
    call MemCopy

    ld hl, WindowMap
    ld de, $9c00
    ld bc, WindowMap.end - WindowMap
    call MemCopy

    ld hl, WindowMap9840
    ld de, $9840
    ld bc, WindowMap9840.end - WindowMap9840
    call MemCopy

    ld hl, TileData
    ld de, $8000
    ld bc, TileData.end - TileData
    call MemCopy

    ld hl, TileDataA0
    ld de, $8a00
    ld bc, TileDataA0.end - TileDataA0
    call MemCopy

    ld hl, TileData
    ld de, $9000
    ld bc, 16 * 3       ; just copy 3 tiles worth of data to mirror between $8000 and $9000
    call MemCopy

    ld hl, TileData + (2 * 16)  ; copying the light grey tile
    ld de, $9090        ; equivalent location as the mole tile
    ld bc, 16           
    call MemCopy

    ld hl, FooterTiles
    ld de, $9100
    ld bc, FooterTiles.end - FooterTiles
    call MemCopy


    ; enable interrupt for ly=lyc
    ld a, $40
    ldh [rSTAT], a
    ld a, $57
    ldh [rLYC], a
    ld a, 2
    ldh [rIE], a

    ld a, $e4
    ldh [rOBP0], a
    ld a, $2c
    ldh [rOBP1], a
    ld a, $20
    ldh [rSCY], a
    ld a, $28
    ldh [rWY], a
    ld a, $58 + 7
    ldh [rWX], a

    win_map_9c00
    enable_sprites
    bg_tile_data_8000
    lcd_on

    xor a
    ldh [rIF], a

    ; schedule first job
    ld a, $08
    ldh [rLYC], a
    ld hl, LY_08

    ; initialise the frame counter
    ; a source code breakpoint will be triggered after 10 frames
    ld b, 10

    ei

.forever
    halt
    jr .forever

LY_08:
    ld hl, rLCDC
    res 0, [hl]     ; disable background. hides the hair

    ld a, $10
    ldh [rLYC], a
    ld hl, LY_10
    reti

LY_10:
    ld hl, rLCDC
    set 0, [hl]     ; enable background
    set 5, [hl]     ; enable window

    ld a, $30
    ldh [rLYC], a
    ld hl, LY_30
    reti

LY_30:
    ld hl, rLCDC
    res 4, [hl]     ; bg/win tile data $8800-$97ff

    ld a, $38
    ldh [rLYC], a
    ld hl, LY_38
    reti

LY_38:    
    ld a, 240       ; disable window by setting WX off-screen
    ld [rWX], a

    ld hl, rLCDC
    set 4, [hl]     ; bg/win tile data $8000-$8fff

    ld a, $3F
    ldh [rLYC], a
    ld hl, LY_3F
    reti

LY_3F:
    ld a, 240       ; disable window by setting WX off-screen
    ld [rWX], a

    ld a, $58
    ldh [rLYC], a
    ld hl, LY_58
    reti

LY_58:
    ld hl, rLCDC
    set 2, [hl]     ; object size 8x16

    ld a, $68
    ldh [rLYC], a
    ld hl, LY_68
    reti

LY_68:
    ld hl, rLCDC
    res 2, [hl]     ; object size 8x8
    res 1, [hl]     ; objects disabled - hides the tongue

    ld a, $70
    ldh [rLYC], a
    ld hl, LY_70
    reti


LY_70:
    ld a, $58 + 7   ; enable window by positioning WX on-screen
    ld [rWX], a

    ld hl, rLCDC
    res 6, [hl]     ; window map $9800

    ld a, $80
    ldh [rLYC], a
    ld hl, LY_80
    reti


LY_80:
    ld hl, rLCDC
    set 3, [hl]     ; bg map $9c00
    res 4, [hl]     ; bg/win tile data $8800-97ff

    ld a, $81
    ldh [rLYC], a
    ld hl, LY_81
    reti


LY_81:
    ld hl, rLCDC
    res 5, [hl]     ; disable window
    set 6, [hl]     ; window map $9c00

    ld a, $82
    ldh [rLYC], a
    ld hl, LY_82
    reti


LY_82:
    ld a, $f3
    ldh [rSCX], a   ; position footer correctly

    ld a, $8f
    ldh [rLYC], a
    ld hl, LY_8F
    reti


LY_8F:
    ld hl, rLCDC
    res 3, [hl]     ; bg map $9800
    set 4, [hl]     ; bg/win tile data $8000-8fff

    ld a, $90
    ldh [rLYC], a
    ld hl, LY_90
    reti

LY_90:
    ld hl, rLCDC
    set 1, [hl]     ; enable objects

    xor a
    ldh [rSCX], a   ; restore SCX

    ; decrease the frame counter
    dec b
    jr nz, .skip

    ; source code breakpoint - good time to take a 
    ; screenshot to compare to reference image
    ld b, b

.skip:
    ld a, $08
    ldh [rLYC], a
    ld hl, LY_08
    reti

INCLUDE "inc/background.asm"
INCLUDE "inc/window.asm"
INCLUDE "inc/tiles.asm"
INCLUDE "inc/oam.asm"
FooterTiles::
    INCBIN "img/footer.2bpp"
.end: