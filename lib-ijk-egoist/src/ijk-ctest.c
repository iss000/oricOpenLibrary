/*               _
 **  ___ ___ _ _|_|___ ___
 ** |  _| .'|_'_| |_ -|_ -|
 ** |_| |__,|_,_|_|___|___|
 **         raxiss (c) 2019
 **
 ** LGPL v2.1
 ** See https://github.com/iss000/IJK-egoist/blob/main/LICENSE
 **
 */

/* ================================================================== *
 * IJK-driver test code                                               *
 * ================================================================== */

// =====================================================================
// usefull macros
#define call(addr)      ((void (*)())(addr))()
#define peek(addr)      (*((unsigned char*)(addr)))
#define poke(addr, val) {*((unsigned char*)(addr)) = val;}
#define mkptr(x)        ((void*)(x))

// ATMOS only compatible
#define atmos_cls       0xccce
#define atmos_text      0xec21

#define CLS()           call(atmos_cls)
#define TEXT()          call(atmos_text)

// ---------------------------------------------------------------------
// IJK driver API prototypes
void ijk_detect(void);
void ijk_read(void);
extern unsigned char ijk_present;
extern unsigned char ijk_ljoy;
extern unsigned char ijk_rjoy;

// ---------------------------------------------------------------------
// forward declarations
static void clrtext(void);
static void printxyas(unsigned char x, unsigned char y, unsigned char attr, char* s);

// ---------------------------------------------------------------------
void main(void)
{
  TEXT();
  CLS();

  clrtext();

  ijk_detect();
  if(ijk_present)
  {
    poke(0x26a,10);
    printxyas(2,1,2,"IJK interface detected");
    printxyas(4,3,7,"Press [ESC] to quit");
    while(0x9b != peek(0x2df))
    {
      ijk_read();

      printxyas(10,10,(0x04&ijk_ljoy)? 2:1, "X");
      printxyas(10+4,10,(0x01&ijk_ljoy)? 2:1, "R");
      printxyas(10-4,10,(0x02&ijk_ljoy)? 2:1, "L");
      printxyas(10,10+4,(0x08&ijk_ljoy)? 2:1, "D");
      printxyas(10,10-4,(0x10&ijk_ljoy)? 2:1, "U");

      printxyas(30,10,(0x04&ijk_rjoy)? 2:1, "X");
      printxyas(30+4,10,(0x01&ijk_rjoy)? 2:1, "R");
      printxyas(30-4,10,(0x02&ijk_rjoy)? 2:1, "L");
      printxyas(30,10+4,(0x08&ijk_rjoy)? 2:1, "D");
      printxyas(30,10-4,(0x10&ijk_rjoy)? 2:1, "U");
    }
    poke(0x26a,3);
    CLS();
  }
  else
  {
    printxyas(2,1,1,"No IJK interface detected");
  }
}

// ---------------------------------------------------------------------
static void clrtext(void)
{
  unsigned int i;
  unsigned char* p = mkptr(0xbb80);
  for(i=0; i<40*28; i++)
    *p++ = 0x20;
}

// ---------------------------------------------------------------------
static void printxyas(unsigned char x, unsigned char y, unsigned char attr, char* s)
{
  unsigned char* p = mkptr(0xbb80+y*40+x);
  *p++ = attr;
  while(*s)
    *p++ = *s++;
}
