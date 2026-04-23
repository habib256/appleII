; apple2.inc - Symboles communs Apple IIe Enhanced
; Soft switches, routines ROM, entrée ProDOS MLI.

; --- Soft switches vidéo ---
TXTCLR          = $C050         ; Sélectionne graphisme
TXTSET          = $C051         ; Sélectionne texte
MIXCLR          = $C052         ; Plein écran graphique
MIXSET          = $C053         ; Mélange graphique/texte
LOWSCR          = $C054         ; Page 1
HISCR           = $C055         ; Page 2
LORES           = $C056         ; Basse résolution
HIRES           = $C057         ; Haute résolution

; --- Soft switches 80 colonnes (Apple IIe) ---
CLR80COL        = $C000         ; 80COLOFF (write)
SET80COL        = $C001         ; 80COLON  (write)
PRIMARY80CHAR   = $C00E         ; ALTCHAR OFF
ALTCHAR         = $C00F         ; ALTCHAR ON

; --- Clavier ---
KBD             = $C000         ; Lecture clavier (read)
KBDSTRB         = $C010         ; Clear keyboard strobe

; --- Routines Applesoft / Monitor ROM ---
COUT            = $FDED         ; Output char in A via CSWL
RDKEY           = $FD0C         ; Read key, result in A (b7 mis)
HOME            = $FC58         ; Clear text screen + home
CROUT           = $FD8E         ; Output CR
BELL            = $FF3A         ; Beep

; --- ProDOS Machine Language Interface ---
MLI             = $BF00         ; Entrée MLI
MLI_QUIT        = $65
MLI_OPEN        = $C8
MLI_READ        = $CA
MLI_CLOSE       = $CC
