===============================================================================
                        SPACE EXPLORER TRIP
                   An Interactive Galactic Odyssey
                  Data-Driven Game Engine for Apple II
===============================================================================

DESCRIPTION
-----------
Space Explorer Trip is a data-driven adventure game engine for Apple IIe
Enhanced. It demonstrates a modern architecture where a small game engine
(~13 KB) dynamically loads content from ProDOS files, enabling virtually
unlimited game content on modern storage devices (32 MB ProDOS volumes).

This approach leverages modern Apple II hardware (hard drives, CFFA cards)
while maintaining the classic Apple II experience. The result: massive games
in minimal memory footprint.

CORE PHILOSOPHY: DATA-DRIVEN ARCHITECTURE
------------------------------------------
Traditional Apple II games (1980-1990):
  - All content hardcoded in program or loaded in RAM
  - Limited by 64 KB RAM constraint
  - Adding content requires recompilation
  - Typical size: 10-20 scenes maximum

Space Explorer Trip (2025):
  - Tiny engine (~13 KB) + unlimited content on disk
  - Dynamic loading: only current scene in RAM
  - Adding content: just add files (no recompilation)
  - Potential: 1000+ scenes with HD storage
  - Ratio: 1000:1 (content vs. memory footprint)

This is the same approach modern games use (assets on disk, small engine
in memory), adapted for Apple II with ProDOS and 32 MB volumes.

KEY FEATURES
------------
Game Engine:
- Compact 13 KB footprint in memory
- Scene management with dynamic file loading
- Bilingual support (French/English) - easily extensible
- Text mode (80 columns) and HGR graphics mode (280x192)
- Choice-based navigation system

Content (Unlimited on Disk):
- Scene descriptions (text files)
- HGR graphics (8 KB images)
- Expandable without recompiling engine
- Moddable: users can create their own content

ARCHITECTURE: ENGINE + DATA
---------------------------
The game separates ENGINE (code) from DATA (content):

ENGINE (in RAM, ~13 KB):
  - SPACETRIP.BIN     Game engine executable
  - spacetrip.c       Main source code
  - paths.c           Path management module
  - paths.h           Path API header
  - Makefile          Build configuration

DATA (on disk, unlimited):
  - IMG/              HGR graphics (8 KB per scene)
  - TXTFR/            French text files
  - TXTEN/            English text files

Current Content: 13 scenes × 2 languages × (text + image)
Potential: 1000+ scenes limited only by disk space (32 MB max)

Data Structure (Flat and Simple):
  /
  ├── SPACETRIP.BIN       [Engine: 13 KB in RAM]
  ├── IMG/                [Graphics on disk]
  │   ├── N001.HGR        8 KB
  │   ├── N002.HGR        8 KB
  │   └── N003.HGR        8 KB
  ├── TXTFR/              [French scenes on disk]
  │   ├── N001            ~1 KB
  │   ├── N002            ~1 KB
  │   └── N003            ~1 KB
  └── TXTEN/              [English scenes on disk]
      ├── N001            ~1 KB
      ├── N002            ~1 KB
      └── N003            ~1 KB

WHY THIS IS REVOLUTIONARY
--------------------------
Memory Efficiency:
  - Engine: 13 KB (always in RAM)
  - Current scene: ~9 KB (image + text, loaded dynamically)
  - Total RAM usage: ~22 KB
  - Remaining: ~16 KB for stack, buffers, future features (combat, inventory)

Content Scalability:
  - 1000 scenes = 1000 text files (~1 MB) + 1000 images (~8 MB) = ~9 MB
  - Still fits on 32 MB ProDOS volume with room for saves, music, etc.
  - Engine size unchanged: still 13 KB!

Extensibility:
  - Add new scenes: Copy files to IMG/, TXTFR/, TXTEN/
  - No recompilation needed
  - Players can create custom content ("mods")
  - Updates = new data files only

Compare to traditional approach:
  - Traditional: 30 KB program with 20 hardcoded scenes
  - Data-driven: 13 KB engine + unlimited scenes on disk
  - 1000 scenes would require 1500 KB in traditional approach
  - Data-driven: still 13 KB engine + disk storage only

===============================================================================
HOW THE ENGINE WORKS
===============================================================================

DATA-DRIVEN GAME LOOP
---------------------
1. Engine starts (13 KB loaded in RAM at $4000)
2. Language selection: FR or EN
3. For each scene:
   a. Build file paths based on scene ID and language
      Example: Scene 5, FR → "IMG/N005.HGR" + "TXTFR/N005"
   b. Load HGR image (8 KB) into $2000-$3FFF
   c. Load text file into buffer (1 KB max)
   d. Parse text: extract description + choices
   e. Display content (text or graphics mode)
   f. Wait for player input
4. On choice: Repeat step 3 with new scene ID
5. On quit: Return to ProDOS

DYNAMIC LOADING IN ACTION
--------------------------
When player chooses scene 5:
  1. fopen("IMG/N005.HGR", "rb")        → 8 KB loaded to $2000
  2. fopen("TXTFR/N005", "r")           → ~1 KB loaded to buffer
  3. Parse buffer → extract choices
  4. Display → player sees content
  5. Previous scene data is OVERWRITTEN (no longer needed)

This is why memory footprint stays constant regardless of total content!

MEMORY MAP
----------
$0000-$1FFF : System (ProDOS, zero page, stack)
$2000-$3FFF : HGR buffer (current scene image, 8 KB)
$4000-$4FFF : Engine code (~13 KB)
$5000-$9FFF : Available for future features
$A000-$BFFF : C stack and heap
$C000-$FFFF : I/O and ROM

Total engine footprint: ~22 KB (13 KB code + 9 KB current scene)
Available for expansion: ~16 KB (for combat, inventory, saves, etc.)

===============================================================================
CONTENT FILE FORMATS (DATA)
===============================================================================

TEXT FILES (.TXT removed, ProDOS style)
---------------------------------------
Location: TXTFR/N<id> (French) or TXTEN/N<id> (English)
Format: Plain text, 80 columns max per line
Naming: N001, N002, N003... (3 digits, no extension)

Structure:
  Line 1-N: Scene description (narrative text)
  Blank lines: Spacing for readability
  Choice lines: C <scene_id> <choice_title>
  
Example (TXTEN/N001):
  ────────────────────────────────────────────────────────────
  Home, Sweet home
  ------------------
  
  Here you stand at the threshold of an extraordinary cosmic adventure!
  Your brand new spaceship awaits on the launch pad.
  
  C 002 Heading to the planet of eternal forests
  C 003 Racing towards the supermassive black hole
  ────────────────────────────────────────────────────────────

Choice Format: C <scene_id> <title>
  - C = literal character flag
  - scene_id = 3-digit number (001-999)
  - title = short description (< 60 chars)

HGR IMAGE FILES
---------------
Location: IMG/N<id>.HGR
Format: Raw HGR page (8192 bytes exactly)
Resolution: 280×192 pixels, 6 colors
Naming: N001.HGR, N002.HGR, N003.HGR... (3 digits + .HGR)

Creating images:
  - Use bmp2dhr converter
  - Extract from Apple II disk images
  - Draw with Apple II graphics software

FILE NAMING CONVENTION
----------------------
Scenes are numbered 001-999:
  IMG/N001.HGR, IMG/N002.HGR, IMG/N999.HGR
  TXTFR/N001, TXTFR/N002, TXTFR/N999
  TXTEN/N001, TXTEN/N002, TXTEN/N999

Note: Text files have NO extension (ProDOS style)
      Images have .HGR extension for identification

===============================================================================
COMPILING THE ENGINE
===============================================================================

USING MAKEFILE (RECOMMENDED)
-----------------------------
make              # Compile engine if source changed
make clean        # Remove compiled files
make rebuild      # Clean + compile
make info         # Show build configuration
make structure    # Create IMG/, TXTFR/, TXTEN/ directories

MANUAL COMPILATION
------------------
cl65 -t apple2enh -O -Oirs -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
     -o SPACETRIP.BIN spacetrip.c paths.c

Key flags:
  -t apple2enh         Target Apple IIe Enhanced (65C02)
  -O -Oirs             Optimizations enabled
  -Wl -S,0x4000        Start at $4000 (reserves $2000-$3FFF for HGR)
  -Wl -D,__EXEHDR__=0  Raw binary (no AppleSingle header)

Result: SPACETRIP.BIN (~13 KB, starts at $4000)

WHY START AT $4000?
-------------------
HGR Page 1 is at $2000-$3FFF (8 KB reserved for images).
Starting at $4000 prevents program from overwriting graphics.

===============================================================================
RUNNING THE GAME
===============================================================================

ON VIRTUAL ][ (MACOS)
---------------------
1. Mount SPACETRIP folder as ProDOS disk:
   Media → "Mount Folder as ProDOS Disk" → Select SPACETRIP folder
2. Boot ProDOS system disk
3. Run: ]BRUN SPACETRIP

Virtual ][ handles file type conversion automatically for most files.
Maximum folder size: 32 MB (plenty for 1000+ scenes!)

Optional: Set extended attributes for proper file types
# Text files
find TXTFR -type f -exec xattr -wx prodos.FileType 04 00 {} \;
find TXTEN -type f -exec xattr -wx prodos.FileType 04 00 {} \;
# HGR images  
find IMG -name "*.HGR" -exec xattr -wx prodos.FileType 06 00 {} \;
find IMG -name "*.HGR" -exec xattr -wx prodos.AuxType 00 20 {} \;

ON REAL APPLE II HARDWARE
--------------------------
Use AppleCommander or similar tool to:
1. Create ProDOS disk image (32 MB recommended)
2. Copy SPACETRIP.BIN, IMG/, TXTFR/, TXTEN/ to image
3. Transfer to Apple II via:
   - CFFA card (CompactFlash)
   - Hard drive
   - Floppy disk (limited to ~140 KB, ~1-2 scenes only)
4. Boot ProDOS
5. Run: ]BRUN SPACETRIP

GAME COMMANDS
-------------
Language Selection:
  [F] - Français
  [E] - English

In-Game:
  [SPACE] - Toggle text/graphics mode
  [A-Z]   - Select choice (A=first, B=second, etc.)
  [Q]     - Quit to ProDOS

===============================================================================
CREATING CONTENT (EXTENDING THE GAME)
===============================================================================

ADDING NEW SCENES
-----------------
The beauty of the data-driven approach: No recompilation needed!

Steps:
1. Create text files:
   TXTFR/N014 (French description + choices)
   TXTEN/N014 (English translation)

2. Create HGR image:
   IMG/N014.HGR (8192 bytes, 280×192 pixels)
   Use bmp2dhr converter or extract from disk images

3. Link from existing scenes:
   Add choice line in another scene: C 014 Explore the nebula

4. Done! New scene is playable immediately.

CREATING HGR IMAGES
-------------------
Tools:
  - bmp2dhr: Command-line converter (PNG/BMP → HGR)
  - Apple II graphics software (Paintworks, etc.)
  - Extract from existing disk images (AppleCommander)

Format: 8192 bytes, 280×192 pixels, 6 colors
Naming: N001.HGR, N002.HGR, N999.HGR (3-digit + .HGR)

MODDING AND COMMUNITY CONTENT
------------------------------
The data-driven architecture makes modding easy:
- Players can create custom scenes
- Share scene packs (IMG/TXTFR/TXTEN files only)
- No programming knowledge required
- Engine remains unchanged

Example: Community expansion pack
  - EXPANSION1/IMG/N100-N150.HGR (50 scenes)
  - EXPANSION1/TXTFR/N100-N150 (French)
  - EXPANSION1/TXTEN/N100-N150 (English)
  - Just copy to main directories and play!

===============================================================================
FUTURE EXPANSION: RPG FEATURES
===============================================================================

The data-driven architecture provides ~16 KB of free RAM for new features.
Planned additions (see IMPROVEMENTS.TXT for details):

COMBAT SYSTEM
-------------
- Dynamic encounters with space creatures
- Turn-based combat (Attack, Defend, Item, Flee)
- Monster data loaded from files (like scenes)
- HGR images for monsters (IMG/MONSTERS/)
- Experience points and leveling system

INVENTORY & ITEMS
-----------------
- Collect items during exploration
- Keys to unlock new areas
- Weapons and armor (boost stats)
- Healing items (restore HP)
- Items stored in data files (moddable)

STATS & PROGRESSION
-------------------
- Player stats: HP, Attack, Defense, Level
- Save/Load system (multiple save slots)
- Progress tracking (scenes discovered)
- Score system

DATA FILE EXTENSIONS
--------------------
New data files would include:
  - MONSTERS.DAT: Monster definitions
  - ITEMS.DAT: Item catalog
  - DOORS.DAT: Locked area requirements
  - IMG/MONSTERS/*.HGR: Combat images

All following the same data-driven philosophy:
  → Engine stays small (~15-18 KB with RPG features)
  → Content grows on disk (unlimited)
  → No recompilation for new monsters/items

===============================================================================
TECHNICAL DETAILS
===============================================================================

PATH MANAGEMENT
---------------
Dynamic path generation (paths.c):
  build_paths(scene_id, language, imgPath, txtPath);
  
Example:
  build_paths(5, "FR", ...) → "IMG/N005.HGR", "TXTFR/N005"
  build_paths(5, "EN", ...) → "IMG/N005.HGR", "TXTEN/N005"

PRODOS DIRECTORY LIMITS
------------------------
Root directory: 51 entries max (fixed)
Subdirectories: No fixed limit (grow dynamically)

This game uses only 3 root entries (IMG/, TXTFR/, TXTEN/),
each subdirectory can hold hundreds of files.

BUFFER SIZES
------------
- file_buffer: 1024 bytes (max scene text size)
- g_imgPath/g_txtPath: 64 bytes each (path strings)
- Global buffers avoid cc65 "Too many local variables" error

KEY SOFT SWITCHES
-----------------
$C050 (TXTCLR) - Graphics on
$C057 (HIRES)  - Hi-res mode
$C054 (LOWSCR) - Page 1
$C052 (MIXCLR) - Full screen

===============================================================================
TROUBLESHOOTING
===============================================================================

FILE NOT FOUND
--------------
Check:
  - Files in correct directories (TXTFR/, TXTEN/, IMG/)
  - 3-digit format (N001, not N1)
  - No .TXT extension on text files
  - Virtual ][ folder properly mounted
  - Use ]CAT to verify ProDOS structure

CHOICES NOT DISPLAYING
-----------------------
Check:
  - Choice lines start with "C " (C + space)
  - Format: C <scene_id> <title>
  - Lines under 80 characters

CORRUPTED GRAPHICS
-------------------
Check:
  - HGR files exactly 8192 bytes
  - Compilation with -Wl -S,0x4000

PROGRAM CRASHES
---------------
Check:
  - Compiled with -Wl -S,0x4000
  - Run with: ]BRUN SPACETRIP

===============================================================================
SPECIFICATIONS
===============================================================================

REQUIREMENTS
------------
- Apple IIe Enhanced or later (65C02)
- 64 KB RAM
- ProDOS operating system
- 80-column card
- Hard drive or CFFA recommended (32 MB for full content)

ENGINE SIZE
-----------
- Binary: ~13 KB
- Memory footprint: $4000-$9FFF (~22 KB with scene loaded)
- Free RAM: ~16 KB (for future RPG features)

CONTENT CAPACITY
----------------
- Scene IDs: 001-999 supported
- Current: 13 scenes (2 languages)
- Potential: 1000+ scenes with 32 MB storage
- Root directory: 3 entries used (IMG/, TXTFR/, TXTEN/)
- Subdirectories: No practical limit

===============================================================================
TOOLS & RESOURCES
===============================================================================

DEVELOPMENT
-----------
- cc65: C compiler for 6502 (https://cc65.github.io/)
- make: Build automation
- Virtual ][: Apple II emulator for macOS (https://www.virtualii.com/)
- bmp2dhr: Image converter for HGR

DOCUMENTATION
-------------
- cc65 Apple II docs: https://cc65.github.io/doc/apple2enh.html
- HGR format: https://www.kreativekorp.com/miscpages/a2info/hgr.shtml
- ProDOS 8: https://prodos8.com/

===============================================================================
CREDITS
===============================================================================

Space Explorer Trip - Data-Driven Adventure Engine
Created by VERHILLE Arnaud (gist974@gmail.com)

PHILOSOPHY
----------
This project demonstrates a modern approach to Apple II game development:
leveraging 32 MB ProDOS storage with a compact game engine for virtually
unlimited content. The same approach modern games use, adapted for Apple II.

WHAT THIS ENGINE SHOWS
-----------------------
- Data-driven architecture (13 KB engine + unlimited disk content)
- Dynamic file loading from ProDOS
- Bilingual support (easily extensible)
- Clean C code with cc65
- Moddable content without recompilation

Feel free to use this as a template for your own Apple II adventures!
See IMPROVEMENTS.TXT for planned RPG features.

===============================================================================
VERSION HISTORY
===============================================================================

Version 2.2 (2024) - "DATA-DRIVEN ARCHITECTURE"
  - MAJOR DOCUMENTATION UPDATE: Emphasizes data-driven philosophy
  - README rewritten to highlight engine vs. content separation
  - Architecture comparison: traditional vs. data-driven
  - Memory efficiency explained (13 KB engine, 1000:1 ratio)
  - Modding and extensibility documentation
  - Future RPG features outlined
  - Simplified and modernized all documentation

Version 2.1 (2024) - "FLAT STRUCTURE"
  - Simplified directory structure (IMG/, TXTFR/, TXTEN/)
  - ProDOS limits correctly documented
  - 13 complete scenes (FR + EN)
  - Enhanced atmospheric descriptions

Version 2.0 (2024) - "PATH MANAGEMENT"
  - Path management module (paths.c/paths.h)
  - Language-specific directories
  - Optimized compilation
  - Global buffers

Version 1.0 (2024) - "INITIAL RELEASE"
  - Bilingual engine
  - 3 scenes with HGR graphics
  - Text/Graphics toggle

===============================================================================
                                   END
===============================================================================
