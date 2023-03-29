/*               _
 **  ___ ___ _ _|_|___ ___
 ** |  _| .'|_'_| |_ -|_ -|
 ** |_| |__,|_,_|_|___|___|
 **         raxiss (c) 2021
 */

/* ================================================================== *
 * ; TTF render                                                       *
 * ================================================================== */

// =====================================================================
#ifndef __TTF_H__
#define __TTF_H__
// ---------------------------------------------------------------------
#define TTF_MAXCHARS  (128-32)
// =====================================================================
typedef struct ttf_s
{
  unsigned char w;
  unsigned char h;
  unsigned char* widths;
  unsigned char* width_bytes;
  unsigned char* offsets_lo;
  unsigned char* offsets_hi;
  unsigned char* char_defs;
} ttf_t, *ttf_p;

// =====================================================================
extern ttf_p _ttf_ptr;
extern unsigned char _ttf_x;
extern unsigned char _ttf_y;
extern unsigned char _ttf_space;
extern unsigned char _ttf_len;

// ---------------------------------------------------------------------
void _ttf_open(void);
#define ttf_open(p) do{_ttf_ptr=(ttf_p)(p);_ttf_open();}while(0)

// ---------------------------------------------------------------------
void _ttf_strlen(void);
unsigned char ttf_strlen(char* s)
{
  _ttf_ptr=(ttf_p)(s);
  _ttf_strlen();
  return _ttf_len;
}

// ---------------------------------------------------------------------
void _ttf_print(void);
#define ttf_print(x,y,s) do{_ttf_x=(x);_ttf_y=(y);_ttf_ptr=(ttf_p)(s);_ttf_print();}while(0)
#define ttf_printleft(y,s) do{_ttf_x=0;_ttf_y=(y);_ttf_ptr=(ttf_p)(s);_ttf_print();}while(0)
#define ttf_printcenter(y,s) do{_ttf_x=120-(ttf_strlen(s)>>1);_ttf_y=(y);_ttf_print();}while(0)
#define ttf_printright(y,s) do{_ttf_x=240-(ttf_strlen(s));_ttf_y=(y);_ttf_print();}while(0)
#define ttf_space(x) _ttf_space=(x)

// ---------------------------------------------------------------------
#endif /* __TTF_H__ */
