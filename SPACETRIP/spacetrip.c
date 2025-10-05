#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <conio.h>
#include <apple2enh.h>
#include "paths.h"

/* Adresse de la page HGR 1 */
#define HGR_PAGE1 ((unsigned char*)0x2000)
#define HGR_SIZE  8192
#define MAX_LINE  120
#define MAX_CHOICES 10
#define MAX_PATH  64

/* Structure pour les choix */
typedef struct {
    int scene_id;
    char title[80];
} Choice;

/* Variables globales */
int current_scene = 1;
int video_mode = 0;  /* 0=texte 80col, 1=HGR plein */
Choice choices[MAX_CHOICES];
int num_choices = 0;
char file_buffer[1024];  /* Buffer pour lecture fichier */
char language[3] = "FR";  /* Langue par defaut : FR ou EN */
char g_imgPath[MAX_PATH];  /* Buffer pour chemin image */
char g_txtPath[MAX_PATH];  /* Buffer pour chemin texte */

/* Fonction pour charger une image HGR */
int load_hgr_image(int scene_id) {
    FILE* f;
    size_t bytes_read;
    
    /* Build paths */
    if (build_paths(scene_id, language, g_imgPath, g_txtPath) != 0) {
        return 0;  /* Scene ID hors plage */
    }
    
    /* Open HGR file */
    f = fopen(g_imgPath, "rb");
    if (!f) {
        return 0;  /* Pas d'image pour cette scene */
    }
    
    /* Read exactly 8192 bytes into HGR page 1 */
    bytes_read = fread(HGR_PAGE1, 1, HGR_SIZE, f);
    fclose(f);
    
    if (bytes_read != HGR_SIZE) {
        return 0;  /* Taille incorrecte */
    }
    
    return 1;
}

/* Soft switches pour les modes video */
void enable_text_mode(void) {
    __asm__("sta $C051");  /* TXTSET */
}

void enable_hgr_full(void) {
    __asm__("sta $C050");  /* TXTCLR */
    __asm__("sta $C057");  /* HIRES */
    __asm__("sta $C054");  /* LOWSCR */
    __asm__("sta $C052");  /* MIXCLR */
}

/* Parser et afficher le fichier texte */
void display_scene_text(int scene_id) {
    char line[MAX_LINE];
    FILE* f;
    int i, j;
    size_t bytes_read;
    
    /* Build paths */
    if (build_paths(scene_id, language, g_imgPath, g_txtPath) != 0) {
        cprintf("Erreur: scene %d hors plage (0-999).\r\n", scene_id);
        cprintf("Appuyez sur une touche...\r\n");
        cgetc();
        return;
    }
    
    /* Reinitialiser les choix */
    num_choices = 0;
    
    /* Mode texte 80 colonnes */
    enable_text_mode();
    videomode(VIDEOMODE_80COL);
    clrscr();
    
    /* Open text file */
    f = fopen(g_txtPath, "r");
    if (!f) {
        cprintf("Erreur: fichier %s introuvable.\r\n", g_txtPath);
        cprintf("Appuyez sur une touche...\r\n");
        cgetc();
        return;
    }
    
    /* Read file into buffer */
    bytes_read = fread(file_buffer, 1, sizeof(file_buffer) - 1, f);
    fclose(f);
    
    if (bytes_read == 0) {
        cprintf("Erreur: fichier vide.\r\n");
        return;
    }
    file_buffer[bytes_read] = '\0';
    
    /* Parser ligne par ligne */
    j = 0;
    for (i = 0; i <= bytes_read; i++) {
        if (file_buffer[i] == '\r' || file_buffer[i] == '\n' || file_buffer[i] == '\0') {
            /* Fin de ligne */
            line[j] = '\0';
            
            if (line[0] == 'C' && line[1] == ' ') {
                /* Choix : C ID Titre */
                if (num_choices < MAX_CHOICES) {
                    int id;
                    char* title_start = strchr(line + 2, ' ');
                    if (title_start && sscanf(line + 2, "%d", &id) == 1) {
                        choices[num_choices].scene_id = id;
                        strncpy(choices[num_choices].title, title_start + 1, 79);
                        choices[num_choices].title[79] = '\0';
                        num_choices++;
                    }
                }
            } else if (j > 0) {
                /* Texte normal */
                cprintf("%s\r\n", line);
            }
            
            /* Reinitialiser pour la prochaine ligne */
            j = 0;
            /* Sauter les \n qui suivent les \r */
            if (file_buffer[i] == '\r' && file_buffer[i+1] == '\n') {
                i++;
            }
        } else {
            /* Ajouter le caractere a la ligne */
            if (j < MAX_LINE - 1) {
                line[j++] = file_buffer[i];
            }
        }
    }
    
    /* Afficher les choix */
    if (num_choices > 0) {
        if (strcmp(language, "FR") == 0) {
            cprintf("\r\n--- Choix ---\r\n");
        } else {
            cprintf("\r\n--- Choices ---\r\n");
        }
        for (i = 0; i < num_choices; i++) {
            cprintf("%c) %s\r\n", 'A' + i, choices[i].title);
        }
    }
    
    if (strcmp(language, "FR") == 0) {
        cprintf("\r\n[ESPACE]=Basculer vers le Graphique HGR [A-Z]=Choix [Q]=Quitter\r\n");
    } else {
        cprintf("\r\n[SPACE]=Toggle HGR Graphic [A-Z]=Choice [Q]=Quit\r\n");
    }
}

/* Cycle entre les modes video */
void cycle_video_mode(void) {
    video_mode = (video_mode + 1) % 2;  /* 2 modes: texte, plein */
    
    switch (video_mode) {
        case 0:  /* Texte 80 colonnes */
            display_scene_text(current_scene);
            break;
            
        case 1:  /* HGR plein ecran */
            enable_hgr_full();
            break;
    }
}

/* Charger une nouvelle scene */
void load_scene(int scene_id) {
    current_scene = scene_id;
    
    /* Charger l'image HGR */
    load_hgr_image(scene_id);
    
    /* Afficher selon le mode */
    if (video_mode == 0) {
        display_scene_text(scene_id);
    } else {
        enable_hgr_full();
    }
}

void main(void) {
    char key;
    int choice_num;
    
    /* Ecran de selection de langue */
    videomode(VIDEOMODE_80COL);
    clrscr();
    
    cprintf("\r\n\r\n\r\n");
    cprintf("          ====================================================\r\n");
    cprintf("                      SPACE EXPLORER TRIP\r\n");
    cprintf("          ====================================================\r\n");
    cprintf("\r\n\r\n");
    cprintf("                    SELECT YOUR LANGUAGE / LANGUE\r\n");
    cprintf("\r\n\r\n");
    cprintf("                         [F] - Francais\r\n");
    cprintf("\r\n");
    cprintf("                         [E] - English\r\n");
    cprintf("\r\n\r\n\r\n");
    cprintf("          ====================================================\r\n");
    
    /* Attendre le choix de langue */
    while (1) {
        key = cgetc();
        if (key == 'F' || key == 'f') {
            strcpy(language, "FR");
            break;
        } else if (key == 'E' || key == 'e') {
            strcpy(language, "EN");
            break;
        }
    }
    
    /* Ecran de titre selon la langue */
    clrscr();
    cprintf("\r\n");
    cprintf("          ====================================================\r\n");
    cprintf("                      SPACE EXPLORER TRIP\r\n");
    
    if (strcmp(language, "FR") == 0) {
        cprintf("                 Une Odyssee Interactive Galactique\r\n");
        cprintf("          ====================================================\r\n");
        cprintf("\r\n");
        cprintf("  Embarquez pour un voyage extraordinaire a travers les etoiles !\r\n");
        cprintf("\r\n");
        cprintf("  Explorez des mondes fascinants, du coeur incandescent des trous noirs\r\n");
        cprintf("  aux forets cristallines de planetes lointaines. Chaque destination est\r\n");
        cprintf("  une aventure unique ou vos choix determinent votre destinee cosmique.\r\n");
        cprintf("\r\n");
        cprintf("  Collectionnez des selfies spectaculaires pour epater vos amis sur\r\n");
        cprintf("  l'Instagram intergalactique et devenez la star de la Voie Lactee !\r\n");
        cprintf("\r\n");
        cprintf("  COMMANDES:\r\n");
        cprintf("    [ESPACE] - Basculer entre mode texte et mode graphique\r\n");
        cprintf("    [A-Z]    - Choisir une destination\r\n");
        cprintf("    [Q]      - Quitter l'aventure\r\n");
        cprintf("\r\n");
        cprintf("  Un jeu de VERHILLE Arnaud - gist974@gmail.com\r\n");
        cprintf("\r\n");
        cprintf("            >>> Appuyez sur une touche pour decoller ! <<<\r\n");
    } else {
        cprintf("                 An Interactive Galactic Odyssey\r\n");
        cprintf("          ====================================================\r\n");
        cprintf("\r\n");
        cprintf("  Embark on an extraordinary journey through the stars!\r\n");
        cprintf("\r\n");
        cprintf("  Explore fascinating worlds, from the incandescent heart of black holes\r\n");
        cprintf("  to the crystalline forests of distant planets. Each destination is\r\n");
        cprintf("  a unique adventure where your choices determine your cosmic destiny.\r\n");
        cprintf("\r\n");
        cprintf("  Collect spectacular selfies to impress your friends on the\r\n");
        cprintf("  intergalactic Instagram and become the star of the Milky Way!\r\n");
        cprintf("\r\n");
        cprintf("  COMMANDS:\r\n");
        cprintf("    [SPACE]  - Toggle between text and graphic mode\r\n");
        cprintf("    [A-Z]    - Choose a destination\r\n");
        cprintf("    [Q]      - Quit the adventure\r\n");
        cprintf("\r\n");
        cprintf("  A game by VERHILLE Arnaud - gist974@gmail.com\r\n");
        cprintf("\r\n");
        cprintf("              >>> Press any key to launch! <<<\r\n");
    }
    
    cgetc();
    
    /* Charger la scene initiale */
    load_scene(1);
    
    /* Boucle principale */
    while (1) {
        key = cgetc();
        
        if (key == ' ') {
            /* Barre d'espace : cycler les modes */
            cycle_video_mode();
            
        } else if (key == 'Q' || key == 'q') {
            /* Quitter */
            enable_text_mode();
            videomode(VIDEOMODE_40COL);
            clrscr();
            if (strcmp(language, "FR") == 0) {
                cprintf("Au revoir!\r\n");
            } else {
                cprintf("Goodbye!\r\n");
            }
            return;
            
        } else if ((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z')) {
            /* Choix par lettre */
            if (key >= 'a') {
                choice_num = key - 'a';
            } else {
                choice_num = key - 'A';
            }
            if (choice_num < num_choices) {
                load_scene(choices[choice_num].scene_id);
            }
        }
    }
}
