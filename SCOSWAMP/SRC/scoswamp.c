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
#define MAX_PATH  64  /* FILENAME_MAX pour ProDOS sur Apple II */

/* Structure pour les choix */
typedef struct {
    int scene_id;
    char title[80];
} Choice;

/* Structure pour l'état global de l'application */
typedef struct {
    int current_scene;
    int video_mode;  /* 0=texte 80col, 1=HGR plein */
    Choice choices[MAX_CHOICES];
    int num_choices;
    char language[3];  /* FR ou EN */
    char imgPath[MAX_PATH];
    char txtPath[MAX_PATH];
    int text_loaded;  /* flag pour savoir si le texte est en buffer */
} AppState;

/* Variables globales optimisées */
AppState app;
char file_buffer[1536];  /* Buffer pour lecture fichier */

/* Fonction pour charger une image HGR */
int load_hgr_image(int scene_id) {
    FILE* f;
    size_t bytes_read;
    
    /* Build paths (conforme ProDOS MLI) */
    if (build_paths(scene_id, app.language, app.imgPath, app.txtPath) != 0) {
        return 0;  /* Scene ID hors plage */
    }
    
    /* Open HGR file (mode binaire "rb" pour 8192 octets bruts) */
    f = fopen(app.imgPath, "rb");
    if (!f) {
        return 0;  /* Pas d'image pour cette scene */
    }
    
    /* Read exactly 8192 bytes into HGR page 1 ($2000-$3FFF) */
    bytes_read = fread(HGR_PAGE1, 1, HGR_SIZE, f);
    fclose(f);
    
    if (bytes_read == HGR_SIZE) {
        return 1;
    }
    
    return 0;
}

/* Soft switches pour les modes video - version optimisée */
void set_video_mode(int mode) {
    if (mode == 0) {
        /* Mode texte 80 colonnes */
        __asm__("sta $C051");  /* TXTSET */
    } else {
        /* Mode HGR plein écran - séquence Apple II correcte */
        __asm__("sta $C050");  /* TXTCLR - désactiver le mode texte */
        __asm__("sta $C057");  /* HIRES - activer le mode haute résolution */
        __asm__("sta $C054");  /* LOWSCR - sélectionner la page basse (HGR page 1) */
        __asm__("sta $C052");  /* MIXCLR - désactiver le mode mixte */
    }
}

/* Fonction commune pour parser un fichier texte */
int parse_text_file(int scene_id, int display_mode) {
    FILE* f;
    size_t bytes_read;
    char line[MAX_LINE];
    int i, j;
    
    /* Note: L'optimisation du cache texte n'est pas possible car le buffer texte Apple II */
    /* est écrasé lors du basculement vers HGR. On doit toujours recharger pour l'affichage. */
    
    /* Build paths */
    if (build_paths(scene_id, app.language, app.imgPath, app.txtPath) != 0) {
        if (display_mode) {
            cprintf("Erreur: scene %d hors plage (0-999).\r\n", scene_id);
            cprintf("Appuyez sur une touche...\r\n");
            cgetc();
        }
        return 0;
    }
    
    /* Réinitialiser les choix */
    app.num_choices = 0;
    
    /* Mode texte si on doit afficher */
    if (display_mode) {
        set_video_mode(0);
        videomode(VIDEOMODE_80COL);
        clrscr();
    }
    
    /* Open text file */
    f = fopen(app.txtPath, "r");
    if (!f) {
        if (display_mode) {
            cprintf("Erreur: fichier %s introuvable.\r\n", app.txtPath);
            cprintf("Appuyez sur une touche...\r\n");
            cgetc();
        }
        return 0;
    }
    
    /* Read file into buffer */
    bytes_read = fread(file_buffer, 1, sizeof(file_buffer) - 1, f);
    fclose(f);
    
    if (bytes_read == 0) {
        if (display_mode) {
            cprintf("Erreur: fichier vide.\r\n");
        }
        return 0;
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
                if (app.num_choices < MAX_CHOICES) {
                    int id;
                    char* title_start = strchr(line + 2, ' ');
                    if (title_start && sscanf(line + 2, "%d", &id) == 1) {
                        app.choices[app.num_choices].scene_id = id;
                        strncpy(app.choices[app.num_choices].title, title_start + 1, 79);
                        app.choices[app.num_choices].title[79] = '\0';
                        app.num_choices++;
                    }
                }
            } else if (display_mode && j > 0) {
                /* Texte normal - afficher seulement en mode display */
                cprintf("%s\r\n", line);
            }
            
            /* Réinitialiser pour la prochaine ligne */
            j = 0;
            /* Sauter les \n qui suivent les \r */
            if (file_buffer[i] == '\r' && file_buffer[i+1] == '\n') {
                i++;
            }
        } else {
            /* Ajouter le caractère à la ligne */
            if (j < MAX_LINE - 1) {
                line[j++] = file_buffer[i];
            }
        }
    }
    
    /* Afficher les choix si en mode display */
    if (display_mode && app.num_choices > 0) {
        if (strcmp(app.language, "FR") == 0) {
            cprintf("\r\n--- Choix ---\r\n");
        } else {
            cprintf("\r\n--- Choices ---\r\n");
        }
        for (i = 0; i < app.num_choices; i++) {
            cprintf("%c) %s\r\n", 'A' + i, app.choices[i].title);
        }
        
        if (strcmp(app.language, "FR") == 0) {
            cprintf("\r\n[ESPACE/RETURN/ESC]=Basculer Graphique HGR [A-Z]=Choix [Q]=Quitter\r\n");
        } else {
            cprintf("\r\n[SPACE/RETURN/ESC]=Toggle HGR Graphic [A-Z]=Choice [Q]=Quit\r\n");
        }
    }
    
    return 1;
}

/* Charger le texte et les choix sans affichage (pour mode HGR) */
void load_scene_text_choices(int scene_id) {
    parse_text_file(scene_id, 0);  /* Mode non-display */
    app.text_loaded = 1;
}

/* Parser et afficher le fichier texte */
void display_scene_text(int scene_id) {
    parse_text_file(scene_id, 1);  /* Mode display */
}

/* Cycle entre les modes video */
void cycle_video_mode(void) {
    app.video_mode = (app.video_mode + 1) % 2;  /* 2 modes: texte, plein */
    
    if (app.video_mode == 0) {
        /* Texte 80 colonnes - réafficher depuis le buffer texte Apple II */
        display_scene_text(app.current_scene);
    } else {
        /* HGR plein écran */
        set_video_mode(1);
        /* L'image est déjà en mémoire HGR */
    }
}

/* Charger une nouvelle scene */
void load_scene(int scene_id) {
    int has_image;
    app.current_scene = scene_id;
    app.text_loaded = 0;  /* Réinitialiser le flag au changement de scène */
    
    /* Charger l'image HGR si elle existe */
    has_image = load_hgr_image(scene_id);
    
    if (has_image) {
        /* Image disponible : afficher en mode HGR plein écran */
        app.video_mode = 1;
        set_video_mode(1);
        /* L'image est maintenant affichée sur l'écran HGR */
        
        /* Charger aussi le texte en arrière-plan pour permettre le basculement */
        load_scene_text_choices(scene_id);
        
    } else {
        /* Pas d'image : afficher le texte en mode 80 colonnes */
        app.video_mode = 0;
        display_scene_text(scene_id);
    }
}

/* Fonction pour afficher l'écran de sélection de langue */
void display_language_selection(void) {
    videomode(VIDEOMODE_80COL);
    clrscr();
    
    cprintf("\r\n");
    cprintf("          ====================================================\r\n");
    cprintf("                     SCORPIONS SWAMP\r\n");
    cprintf("                          LE MARAIS AUX SCORPIONS\r\n");
    cprintf("          ====================================================\r\n");
    cprintf("\r\n");
    cprintf("           Un livre dont vous etes le heros\r\n");
    cprintf("                               A Fighting Fantasy Gamebook\r\n");
    cprintf("\r\n");
    cprintf("               (1985) by Steve JACKSON & Ian LIVINGSTONE \r\n");
    cprintf("\r\n");
    cprintf("                    SELECT YOUR LANGUAGE / LANGUE\r\n");
    cprintf("\r\n");
    cprintf("                         [F] - Francais\r\n");
    cprintf("\r\n");
    cprintf("                         [E] - English\r\n");
    cprintf("\r\n");
    cprintf("\r\n");
    cprintf("               2025 Apple II Port by : Arnaud VERHILLE\r\n");
    cprintf("                                  (gist974@gmail.com)\r\n");
    cprintf("\r\n\r\n");
    cprintf("          ====================================================\r\n");
}

/* Fonction pour sélectionner la langue */
void select_language(void) {
    char key;
    
    display_language_selection();
    
    /* Attendre le choix de langue */
    while (1) {
        key = cgetc();
        if (key == 'F' || key == 'f') {
            strcpy(app.language, "FR");
            break;
        } else if (key == 'E' || key == 'e') {
            strcpy(app.language, "EN");
            break;
        }
    }
}

/* Fonction pour gérer les choix de l'utilisateur */
void handle_user_input(char key) {
    int choice_num;
    
    if (key == ' ' || key == '\r' || key == 27) {
        /* Barre d'espace, RETURN ou ESC : cycler les modes */
        cycle_video_mode();
        
    } else if (key == 'Q' || key == 'q') {
        /* Quitter */
        set_video_mode(0);
        videomode(VIDEOMODE_40COL);
        clrscr();
        if (strcmp(app.language, "FR") == 0) {
            cprintf("Au revoir!\r\n");
        } else {
            cprintf("Goodbye!\r\n");
        }
        exit(0);
        
    } else if ((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z')) {
        /* Choix par lettre */
        choice_num = (key >= 'a') ? (key - 'a') : (key - 'A');
        if (choice_num < app.num_choices) {
            load_scene(app.choices[choice_num].scene_id);
        }
    }
}

void main(void) {
    char key;
    
    /* Initialiser l'état de l'application */
    app.current_scene = 0;
    app.video_mode = 1;  /* Démarrer en mode HGR */
    app.num_choices = 0;
    app.text_loaded = 0;  /* Initialiser le flag */
    strcpy(app.language, "FR");  /* Valeur par défaut */
    
    /* Note: Le prefix ProDOS est défini par l'environnement de lancement
     * (typiquement via BASIC.SYSTEM ou le répertoire du fichier .SYSTEM)
     * Les chemins relatifs dans ce programme sont résolus à partir de ce prefix
     * Voir PRODOS-MLI.md pour plus de détails sur chdir() et getcwd()
     */
    
    /* Sélection de langue */
    select_language();
    
    /* Charger directement la scene initiale (scene 0 = titre) en mode HGR */
    load_scene(0);
    set_video_mode(1);
    app.video_mode = 1;
    
    /* Boucle principale */
    while (1) {
        key = cgetc();
        handle_user_input(key);
    }
}
