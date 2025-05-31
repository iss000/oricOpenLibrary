/*   _
**  |_|___ ___(tm)
**  | |_ -|_ -|
**  |_|___|___|
** (c) 2016-2025
*/

/*
** qr
*/

#ifndef __QR_H__
#define __QR_H__

extern char* _qr_str __asm__("__qr_str");
extern char* _qr_ptr __asm__("__qr_ptr");
extern void _qr(void) __asm__("__qr");
#define qr(o,s) (_qr_ptr=(char*)(o),_qr_str=(char*)(s),_qr(),(int)_qr_str)

#endif
