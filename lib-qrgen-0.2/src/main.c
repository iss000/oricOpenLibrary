// #include <stdio.h>
// #include <conio.h>
// #include <ctype.h>

#include <compat.h>
#include <isr.h>

#include "qr_encode.h"

#define kDisplayWidth 8

static unsigned char qr_m_data[MAX_BITDATA];
static char res[MAX_BITDATA*8];

static char* textIn = "http://Defence-Force.org";

char* pBinFill(long int x,char* so)
{
  // fill in array from right to left
  char s[kDisplayWidth+1];
  int i=kDisplayWidth;
  s[i--]=0x00;   // terminate string
  do
  {
    // fill in array from right to left
    s[i--]=(x & 1) ? 0xa0:0x20;
    x>>=1;  // shift right 1 bit
  }
  while(x > 0);

  while(i>=0) s[i--]=0x20;
  sprintf(so,"%s",s);
  return so;
}

void DBG0(void) __asm__("_DBG0");
void DBG1(void) __asm__("_DBG1");

static char* scr = (char*)0xbb80;
static int qr_width;
static int size;

int main(void)
{
  int i;

  // sei();

  compat();
  memset(scr, 0x20, 40*28);
  memcpy(scr+36,TOOLCHAIN,4);

  isr_open();

  isr_timer_set();
  DBG0();
  qr_width=EncodeData(0,0,textIn,0,qr_m_data);
  DBG1();
  isr_timer_get();
  isr_timer_get_str();

  size=((qr_width*qr_width)/8)+(((qr_width*qr_width)%8)?1:0);

  for(i=0; i<size; i++)
    pBinFill(qr_m_data[i], &res[i*8]);

  for(i=0; i<qr_width*qr_width; i++)
  {
    if(i%qr_width == 0)
      scr += 40;
    scr[i%qr_width] = res[i];
  }

  sprintf((char*)(0xbb80+27*40),"qr:%dx%d, %d bytes      ",
          qr_width,qr_width,size);

  memcpy((char*)(0xbb80+27*40+20),isr_timer_str,14);
  memcpy((char*)(0xbb80+27*40+34)," msec",5);

  isr_close();

  while(1);

  return 0;
}
