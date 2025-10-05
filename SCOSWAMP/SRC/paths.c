/* paths.c - Path management implementation */
#include <stdio.h>
#include "paths.h"

int build_paths(unsigned int scene_id, const char* lang,
                char* imgPath, char* txtPath) {
    unsigned int subdirectory;
    
    /* Validate scene_id range */
    if (scene_id > 999) {
        return -1;
    }
    
    /* Calculate subdirectory: N000 (0-49), N050 (50-99), N100 (100-149), etc. */
    subdirectory = (scene_id / 50) * 50;
    
    /* Build image path: IMG/N<subdir>/N<id>.HGR (relative path for ProDOS)
     * Example: scene_id=1 -> "IMG/N000/N001.HGR"
     * Path length: max 23 chars for scene 999 -> "IMG/N950/N999.HGR"
     * Component lengths: "IMG"=3, "N950"=4, "N999.HGR"=12 (all <= 15 chars, ProDOS compliant)
     */
    sprintf(imgPath, "IMG/N%03u/N%03u.HGR", subdirectory, scene_id);
    
    /* Build text path: TEXT<lang>/N<subdir>/N<id> (relative path for ProDOS)
     * Example: scene_id=1, lang="FR" -> "TEXTFR/N000/N001"
     * Path length: max 24 chars for scene 999 -> "TEXTFR/N950/N999"
     * Component lengths: "TEXTFR"=6, "N950"=4, "N999"=8 (all <= 15 chars, ProDOS compliant)
     */
    sprintf(txtPath, "TEXT%s/N%03u/N%03u", lang, subdirectory, scene_id);
    
    return 0;
}

