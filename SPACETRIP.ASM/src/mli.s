; mli.s - Wrappers ProDOS Machine Language Interface
;
; file_open  : ouvre le fichier dont le pathname (Pascal, préfixé
;              par la longueur) est à l'adresse zp_ptr1.
;              Retourne C=0 (OK) et ref_num en A, ou C=1 + A=erreur.
; file_read  : lit request_count octets dans data_buffer.
;              data_buffer     -> zp_ptr1
;              request_count   -> zp_len (lo), zp_tmp1 (hi)
;              ref_num         -> zp_idx
;              Retourne C=0 OK, C=1 + A=erreur.
; file_close : ferme le fichier dont le ref_num est en A.
;
; La zone io_buffer doit être alignée sur une page et faire 1024
; octets. Elle est allouée dans main.s via .align 256.

.include "apple2.inc"
.include "zp.inc"

.export file_open
.export file_read
.export file_close

.import io_buffer               ; 1 Ko aligné 256 (défini dans main.s)

.segment "CODE"

;-------------------------------------------------------------------
; file_open
;-------------------------------------------------------------------
.proc file_open
        ; Installer le pathname
        lda     zp_ptr1
        sta     open_path
        lda     zp_ptr1+1
        sta     open_path+1
        ; Installer l'io_buffer (page-aligné)
        lda     #<io_buffer
        sta     open_iobuf
        lda     #>io_buffer
        sta     open_iobuf+1

        jsr     MLI
        .byte   MLI_OPEN
        .word   open_pb
        bcs     err
        lda     open_refnum
        clc
        rts
err:
        sec
        rts
.endproc

;-------------------------------------------------------------------
; file_read
;-------------------------------------------------------------------
.proc file_read
        lda     zp_idx
        sta     read_refnum
        lda     zp_ptr1
        sta     read_buf
        lda     zp_ptr1+1
        sta     read_buf+1
        lda     zp_len
        sta     read_count
        lda     zp_tmp1
        sta     read_count+1

        jsr     MLI
        .byte   MLI_READ
        .word   read_pb
        bcs     err
        clc
        rts
err:
        sec
        rts
.endproc

;-------------------------------------------------------------------
; file_close : ferme le ref_num en A.
;-------------------------------------------------------------------
.proc file_close
        sta     close_refnum
        jsr     MLI
        .byte   MLI_CLOSE
        .word   close_pb
        rts
.endproc

;-------------------------------------------------------------------
; Paramètres MLI (en DATA car modifiés à l'exécution)
;-------------------------------------------------------------------
.segment "DATA"

open_pb:
        .byte   3               ; param_count
open_path:
        .word   0               ; pointeur pathname
open_iobuf:
        .word   0               ; pointeur io_buffer (1 Ko aligné)
open_refnum:
        .byte   0               ; ref_num (retour)

read_pb:
        .byte   4               ; param_count
read_refnum:
        .byte   0
read_buf:
        .word   0
read_count:
        .word   0
read_trans:
        .word   0               ; octets effectivement lus

close_pb:
        .byte   1
close_refnum:
        .byte   0
