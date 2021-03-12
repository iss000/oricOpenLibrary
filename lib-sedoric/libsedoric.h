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

#ifndef __LIBSEDORIC_H__
#define __LIBSEDORIC_H__

#ifndef ASSEMBLER
extern const char* sed_fname;
extern void* sed_begin;
extern void* sed_end;
extern unsigned int sed_size;
extern int sed_err;

extern void sed_savefile(void);
extern void sed_loadfile(void);

int savefile(const char* fname, void* buf, int len)
{
    sed_fname = fname;
    sed_begin = buf;
    sed_end = (char*)sed_begin+len;
    sed_size = len;
    sed_savefile();
    return sed_err;
}

int loadfile(const char* fname, void* buf, int* len)
{
    sed_fname = fname;
    sed_begin = buf;
    sed_loadfile();
    *len = sed_size;
    return sed_err;
}
#endif

#endif /* __LIBSEDORIC_H__ */
