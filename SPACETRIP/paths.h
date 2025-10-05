/* paths.h - Path management API for ProDOS directory structure */
#ifndef PATHS_H
#define PATHS_H

/* Build paths for a scene number (0-999)
 * Returns 0 on success, -1 if scene_id out of range
 * Paths use ProDOS relative path format (no leading slash):
 *   imgPath: IMG/N<id>.HGR
 *   txtPath: TXTFR/N<id> or TXTEN/N<id>
 */
int build_paths(unsigned int scene_id, const char* lang, 
                char* imgPath, char* txtPath);

#endif /* PATHS_H */

