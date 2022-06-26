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
 * libbasic code                                                      *
 * ================================================================== */

#ifndef __LIBBASIC_H__
#define __LIBBASIC_H__

#ifndef ASSEMBLER

/* Link to BASIC exec */
extern char* _basic_s;
extern void _basic(void);
#define basic(str)  {_basic_s=((char*)(str)),_basic();}

#endif

#endif /* __LIBBASIC_H__ */
