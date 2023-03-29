// =====================================================================
#include "ttf.h"
#include "ttf-fontname.h"

// =====================================================================
// usefull macros
#define call(addr)      ((void (*)())(addr))()
#define peek(addr)      (*((unsigned char*)(addr)))
#define poke(addr, val) {*((unsigned char*)(addr)) = val;}
#define mkptr(x)        ((void*)(x))

// ATMOS only compatible
#define atmos_cls       0xccce
#define atmos_text      0xec21
#define atmos_hires     0xec33

#define CLS()           call(atmos_cls)
#define TEXT()          call(atmos_text)
#define HIRES()         call(atmos_hires)

// =====================================================================
extern ttf_t ttf_10;
extern ttf_t ttf_12;
extern ttf_t ttf_16;
extern ttf_t ttf_20;

// =====================================================================
void main(void)
{
  unsigned char X,Y;

  HIRES();
  CLS();

  ttf_open(&ttf_10);
  ttf_space(2);
  X = 10;
  Y = 10;
  ttf_print(X,Y,FONT_NAME " size 10");

  ttf_open(&ttf_12);
  ttf_space(4);
  Y = 40;
  ttf_printleft(Y,FONT_NAME " size 12");

  ttf_open(&ttf_16);
  ttf_space(8);
  Y = 80;
  ttf_printcenter(Y,FONT_NAME " size 16");

  ttf_open(&ttf_20);
  ttf_space(10);
  Y = 120;
  ttf_printright(Y,FONT_NAME " size 20 outline");

  while(1);
}
