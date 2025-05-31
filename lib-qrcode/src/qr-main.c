/*   _
**  |_|___ ___(tm)
**  | |_ -|_ -|
**  |_|___|___|
** (c) 2016-2025
*/

// #include <stdio.h>
// #include <conio.h>
// #include <ctype.h>

#include <compat.h>
#include <isr.h>
#include <xprintf.h>

#include "qr.h"

static const char* textIn = "https://raxiss.com";

void DBG0(void) __asm__("_DBG0");
void DBG1(void) __asm__("_DBG1");

static char* scr = (char*)0xbb80;
static const char* p = 0;
static int qr_width = 0;

int main(void)
{
  sei();
  compat();
  memset(scr, 0x20, 40*28);
  memcpy(scr+36,TOOLCHAIN,4);

  isr_open();
  isr_timer_set();
  DBG0();
  qr_width = qr(scr,textIn);
  DBG1();
  isr_timer_get();
  isr_timer_get_str();
  isr_close();

  sei();
  p = isr_timer_str;
  while(*p && *p==0x20) ++p;
  xsprintfxy(0,27,"qr:%dx%d, %s millisec",
             qr_width,qr_width,p);

  while(1);

  return 0;
}

void xprintf_outbyte(int c)
{
  _putchar(c);
}
