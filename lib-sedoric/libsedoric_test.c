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
#include "libsedoric.h"

static char* fname = "TEST.TXT";
static void* scrn = (void*)(0xbb80);
static int len = 4*40;

#define cls() (((void(*)(void))0xccce)())

void main(void)
{
    int rc;
    savefile(fname, scrn, len);

    cls();
    printf("\n%d screen bytes saved to '%s'.\npress a key to restore ...",len,fname);
    getchar();

    len = 0;
    rc = loadfile(fname, scrn, &len);
    printf("\n\n\n%d bytes loaded, rc=%d\n",len,rc);
}
