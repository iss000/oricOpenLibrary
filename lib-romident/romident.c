/*               _
 **  ___ ___ _ _|_|___ ___
 ** |  _| .'|_'_| |_ -|_ -|
 ** |_| |__,|_,_|_|___|___|
 **     iss@raxiss (c) 2024
 */

#include "romident.h"

typedef struct s_romident
{
  unsigned char crc[4];
  char* id;
} t_romident, *p_romident;

const t_romident rominfo[] =
{
  // 256 b
  { { 0x0C,0x82,0xF6,0x36 }, "8D FDC" },
  { { 0x15,0xE9,0x7B,0x60 }, "8D FDC Boot" },
  { { 0x8D,0xA2,0xCC,0xD7 }, "8D FDC Driver" },

  { { 0x38,0xEB,0x94,0xED }, "8D Savena Boot" },
  { { 0x8F,0xDD,0x40,0xA7 }, "8D Savena Driver" },

  // 2 K
  { { 0x37,0x22,0x0E,0x89 }, "Jasmin" },
  { { 0xAC,0xB2,0xDD,0x34 }, "Cumana 1" },

  // Roms 8 Ko:
  { { 0x94,0x35,0x8D,0xC6 }, "Telematic" },
  { { 0xA9,0x66,0x4A,0x9C }, "Microdisc" },
  { { 0x22,0x75,0x29,0xC2 }, "Microdisc mod" },   // (8 Ko): load Basic if diskette fails
  { { 0x19,0xD5,0xBB,0x01 }, "Microdisc mod" },   // (8 Ko): load from IDE if diskette fails (prototype)

  // Roms 16 Ko:
  { { 0xF1,0x87,0x10,0xB4 }, "Basic 1.0" },
  { { 0xA6,0x5D,0x6C,0xED }, "Basic 1.1" },       // first version, aka Basic 1.1a
  { { 0xC3,0xA9,0x2B,0xEF }, "Basic 1.1b" },      // second version, aka Basic 1.1b, no K7 errors count
  { { 0x08,0xE0,0x69,0x53 }, "Basic 1.1b mod" },  // upplied with Sedoric 1.0: at reset, only allow interrupts after installing vectorss
  { { 0x9F,0xD6,0x87,0xC7 }, "Basic 1.1b mod" },  // use of the vector $ 0238 for display
  { { 0x69,0x95,0xDD,0x24 }, "Basic 1.1b mod" },  // PB5 preserved, loading a Basic program since the 2nd rom (Andre PB5Lib)
  { { 0x72,0xB1,0x4D,0x15 }, "Basic 1.1b mod" },  // with Telestrat bank indicator and copyright display
  { { 0x60,0x3B,0x1F,0xBF }, "Basic 1.1b mod" },  // French keyboard (AltGr management, and digits with SHIFT in CAPS mode)
  { { 0x17,0x52,0xDF,0x63 }, "Basic 1.1b mod" },  // French keyboard FR2 (AltGr management, and digits without SHIFT in CAPS mode)
  { { 0x28,0xB2,0x6D,0x35 }, "Basic 1.1b mod" },  // 65816 interrupt vectors, compressed characters, FR2 keyboard routine

  { { 0x30,0x33,0x70,0xD1 }, "Basic 1.1b UK" },  // UK keyboard (AltGr management)
  { { 0xA7,0x15,0x23,0xAC }, "Basic 1.1b SW" },  // Swedish keyboard (AltGr management)
  { { 0x47,0xBF,0x26,0xC7 }, "Basic 1.1b ES" },  // Spain keyboard (AltGr management)
  { { 0x65,0x23,0x3B,0x2D }, "Basic 1.1b GE" },  // German keyboard (AltGr management)

  { { 0xDC,0x4F,0x22,0xDC }, "Basic 1.2" },       // P. Leclerc: 1.1b corrections, RESTORE n
  { { 0x47,0xA4,0x37,0xFC }, "Basic 1.2 FR" },    // French keyboard (digits with SHIFT in CAPS mode)
  { { 0x00,0xFC,0xE8,0xA6 }, "Basic 1.2 UK" },
  { { 0x10,0x0A,0xBE,0x68 }, "Basic 1.2 SW" },
  { { 0x70,0xDE,0x4A,0xEB }, "Basic 1.2 ES" },
  { { 0xF5,0xF0,0xDD,0x52 }, "Basic 1.2 GE" },

  { { 0x0A,0x28,0x60,0xB1 }, "Basic 1.21" },      // P. Leclerc: 1.2 + DRAW command enhancement
  { { 0xE6,0x83,0xDE,0xC2 }, "Basic 1.21 FR" },   // French keyboard (digits with SHIFT in CAPS mode)
  { { 0x75,0xAA,0x1A,0xA9 }, "Basic 1.21 UK" },
  { { 0xE6,0xAD,0x11,0xC7 }, "Basic 1.21 SW" },
  { { 0x87,0xEC,0x67,0x9B }, "Basic 1.21 ES" },
  { { 0x94,0xFE,0x32,0xBF }, "Basic 1.21 GE" },

  { { 0x5E,0xF2,0xA8,0x61 }, "Basic 1.22" },      // P. Leclerc: 1.21 + Euro instead Sterling
  { { 0x37,0x0C,0xFD,0xA4 }, "Basic 1.22 FR" },   // French keyboard (digits with SHIFT in CAPS mode)
  { { 0x98,0x65,0xBC,0xD7 }, "Basic 1.22 UK" },
  { { 0xE7,0xFD,0x57,0xA4 }, "Basic 1.22 SW" },
  { { 0x91,0x44,0xF9,0xE0 }, "Basic 1.22 ES" },
  { { 0x9A,0x42,0xBD,0x62 }, "Basic 1.22 GE" },

  { { 0x7F,0x10,0xF0,0x7F }, "Basic Evolution v1.0" },
  { { 0xFF,0x87,0xA3,0x8C }, "Basic Evolution v1.0 FR" },
  { { 0xEC,0x11,0xA8,0xCE }, "Basic Evolution v1.0 FR beta" }, // version beta

  { { 0x58,0x07,0x95,0x02 }, "Pravetz 8D" },
  { { 0xF8,0xD2,0x38,0x21 }, "Pravetz 8D auto boot" },

  { { 0x5B,0xA2,0x7A,0x7D }, "Telemon 2.3" },
  { { 0xAA,0x72,0x7C,0x5D }, "Telemon 2.4" },
  { { 0x6F,0x1E,0x78,0x57 }, "Telemon 2.4" },       // with suppression of the deactivation delay of the RS232
  { { 0xCD,0xA9,0x24,0x97 }, "Telemon 2.4" },       // French keyboard (AltGr management)
  { { 0x95,0x2D,0xDD,0xE3 }, "Monitor PB5" },       // (Telemon mod) for Oric PB5, without ACIA
  { { 0xB9,0x83,0x0B,0xED }, "Monitor PB5 Acia" },       // (Telemon mod) for Oric PB5, with ACIA
  { { 0xB0,0x7B,0x44,0x2B }, "Monitor PB5 Strobe" },       // (Telemon mod) for Oric PB5-Strobe

  { { 0x1D,0x96,0xAB,0x50 }, "Hyperbasic 2.0B" },   // original for cartridge with TeleAss
  { { 0x31,0xB1,0x04,0x76 }, "Hyperbasic 2.0B" },   // original for cartridge with TeleAss
  { { 0x83,0xE9,0xB9,0xC9 }, "HyperBasic PB5 mod" },

  { { 0xD8,0xC6,0x35,0xB2 }, "Teleforth v1.1" },
  { { 0xBC,0x72,0x95,0x30 }, "Teleforth v1.2" },    // bugs corrected by Thierry Bestel

  { { 0x68,0xB0,0xFD,0xE6 }, "TeleAss" },
  { { 0x84,0xF0,0xA4,0xED }, "TeleAss PB5 mod" },

  { { 0x49,0x1C,0x38,0x39 }, "Telematic double" },  // (2x 8Ko)
  { { 0xE0,0xFB,0x19,0x9A }, "Telematic PB5 mod" }, // (16 Ko)

  { { 0x21,0xFE,0x20,0xD8 }, "Stratoric 1.0" },
  { { 0x13,0xB6,0x96,0xA4 }, "Stratoric 3.0" },
  { { 0xEF,0x23,0x2D,0xD9 }, "Microdisc mod for Telestrat" }, // boots OricDos/Randos/Sedoric from diskette or hard drive (prototype)

  { { 0x88,0xC3,0xE6,0x56 }, "Bank 1 cartridge Adresstel" },
  { { 0x87,0x83,0x59,0x47 }, "Bank 2 cartridge Adresstel" },
  { { 0xE9,0x33,0xC2,0x88 }, "Bank 3 cartridge Adresstel" },
  { { 0xB4,0x88,0xC8,0x01 }, "Bank 4 cartridge Adresstel" },

  { { 0x17,0x26,0xB1,0x82 }, "Diagnostic v1" },

  { { 0xb8,0xf5,0x40,0x91 }, "TeleBoot 1.0" },

  //
  { { 0xB9,0x9A,0x93,0x4B },  "Atmos ROM 1.1 (LOCI patch)" },
  { { 0xB5,0xD3,0x12,0xB9 },  "Atmos ROM 1.1 (EREBUS patch)" },

  { {0,0,0,0}, 0 }
};

static int i;

char* romident(unsigned char* crc)
{
  for(i=0; 0 != rominfo[i].id; i++)
  {
    if(crc[0]==rominfo[i].crc[3])
      if(crc[1]==rominfo[i].crc[2])
        if(crc[2]==rominfo[i].crc[1])
          if(crc[3]==rominfo[i].crc[0])
            return rominfo[i].id;
  }
  return "Unknown";
}
