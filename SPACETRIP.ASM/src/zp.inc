; zp.inc - Variables zero-page partagées
;
; La zone $80-$99 (26 octets) n'est pas utilisée par ProDOS ni le Monitor.

.globalzp zp_ptr1, zp_ptr2, zp_tmp1, zp_tmp2, zp_len, zp_idx
