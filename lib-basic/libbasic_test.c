/*               _
 **  ___ ___ _ _|_|___ ___
 ** |  _| .'|_'_| |_ -|_ -|
 ** |_| |__,|_,_|_|___|___|
 **         raxiss (c) 2021
 **
 ** GNU General Public License v3.0
 ** See https://github.com/iss000/oricOpenLibrary/blob/main/LICENSE
 **
 */

/* ================================================================== *
 * libsedoric code                                                    *
 * ================================================================== */


#ifdef __CC65__
#include <stdio.h>
#else
#include <lib.h>
#endif

/* macros as free bonus ;) */
#define poke(addr, val) do *((unsigned char*)(addr)) = val; while(0)
#define peek(addr)      (*((unsigned char*)(addr)))
#define call(addr)      ((void (*)())(addr))()

#include "libbasic.h"

static char* fname = "TEST.TXT";

static void waitkey(void)
{
  printf("\nPress any key...");
  while(!peek(0x2df));
  poke(0x2df,0);
}

void main(void)
{
  basic("CLS");
  printf("Content of disk A:\n");
  printf("------------------\n\n");
  basic("!DIR");
  printf("\n\n\n");
  waitkey();

  basic("CLS:PRINT\"Hello world\"");
  basic("!SAVEO\"SAMPLE.SCR\",A#BB80,E#BFDF:!DIR");
  printf("\n\n\nFile SAMPLE.SCR saved!\n");
  waitkey();

  basic("CLS");
  basic("!LOAD\"SAMPLE.SCR\",N");
  printf("\n\n\nFile SAMPLE.SCR loaded!\n");
  waitkey();

  printf("\n\n\nDone.");
}

