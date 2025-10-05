/* paths.c - Path management implementation */
#include <stdio.h>
#include "paths.h"

int build_paths(unsigned int scene_id, const char* lang,
                char* imgPath, char* txtPath) {
    /* Validate scene_id range */
    if (scene_id > 999) {
        return -1;
    }
    
    /* Build image path: IMG/N<id>.HGR (relative path for ProDOS) */
    sprintf(imgPath, "IMG/N%03u.HGR", scene_id);
    
    /* Build text path: TXT<lang>/N<id> (relative path for ProDOS) */
    sprintf(txtPath, "TXT%s/N%03u", lang, scene_id);
    
    return 0;
}

