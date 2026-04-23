; zp.s - Réservation des variables zero-page
;
; ProDOS réserve $00-$7F. La zone $80-$99 (26 octets) est disponible
; pour le programme utilisateur pendant qu'Applesoft/BASIC.SYSTEM ne
; tourne pas.

.segment "ZEROPAGE"

zp_ptr1:        .res    2       ; pointeur générique 1 (16 bits)
zp_ptr2:        .res    2       ; pointeur générique 2 (16 bits)
zp_tmp1:        .res    1
zp_tmp2:        .res    1
zp_len:         .res    1
zp_idx:         .res    1

.export zp_ptr1, zp_ptr2, zp_tmp1, zp_tmp2, zp_len, zp_idx
