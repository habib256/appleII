#include <conio.h>
#include <apple2enh.h>

void main(void) {
    videomode(VIDEOMODE_40COL);
    clrscr();
    cprintf("Hello, Apple II!\r\n");
    cprintf("\r\nAppuyez sur une touche...\r\n");
    cgetc();
}


