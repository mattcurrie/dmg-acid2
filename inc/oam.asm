OAMData::
    ; nose - use OBP1 palette
    db $50, $50, $4, $10
    db $50, $58, $4, $30
    db $58, $50, $4, $50
    db $58, $58, $4, $70

    ; left eye - overlapping background color 0 only, so fills in the whites of the eyes
    db $38, $40, $a3, $90
    db $40, $40, $a3, $d0

    ; right eye - overlapping window color 0 only, so fills in the whites of the eyes
    db $38, $60, $a3, $90
    db $40, $60, $a3, $d0

    ; hello world
    db $10, $28, "H", 0
    db $10, $30, "e", 0
    db $10, $38, "l", 0
    db $10, $40, "l", 0
    db $10, $48, "o", 0

    db $10, $58, "W", 0
    db $10, $60, "o", 0
    db $10, $68, "r", 0
    db $10, $70, "l", 0
    db $10, $78, "d", 0
    db $10, $80, 1, $10       ; this solid white box shouldn't display - 10 sprite limit per line

    ; mouth
    db $68, $38, 12, $00     ; sprite size is 8x16 when these sprites are rendered
    db $68, $40, 12, $40     ; y-flipped 8x16 sprite
    db $68, $48, 12, $40
    db $68, $50, 12, $40
    db $68, $58, 13, $40     ; specify tile 13, but bit 0 of tile index is ignored in 8x16 tile mode
    db $68, $60, 13, $40
    db $68, $68, 13, $40
    db $68, $70, 13, $00


    db $52, $3d, 9, $00     ; mole
    db $52, $3c, 10, $00    ; light grey square - lower x-coordinate so has priority over the mole
                            ; even though the mole has a lower index in OAM

    db $52, $6c, 10, $00    ; light grey square - same x-coordinate so tile with lower index in OAM
                            ; has priority
    db $52, $6c, 9, $00     ; mole

    
    db $38, $3a, 5, $00     ; left eyelash top
    db $40, $3a, 6, $00     ; left eyelash bottom
    
    db $38, $6e, 5, $20     ; right eyelash top
    db $40, $6e, 6, $20     ; right eyelash bottom

    db $78, $54, 15, $00    ; tongue
.end:
