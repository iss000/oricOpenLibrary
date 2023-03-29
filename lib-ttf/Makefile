#)              _
#)  ___ ___ _ _|_|___ ___
#) |  _| .'|_'_| |_ -|_ -|
#) |_| |__,|_,_|_|___|___|
#)         raxiss (c) 2021

# More free fonts here:
# https://www.fontsquirrel.com/fonts/list/popular

# Uncomment one line:
FONT = OpenSans
# FONT = Walkway
# FONT = Pacifico

.PHONY: all clean res-fonts res-tabs

all: res-fonts res-tabs

clean:
	@rm -f ttf-fontname.h ttf-tabs.s font-10.s font-12.s font-16.s font-20.s

res-tabs:
	@./tools/gen-tabs.lua ttf-tabs.s

res-fonts:
	@echo '#define FONT_NAME "$(FONT)"' > ttf-fontname.h
	@./tools/ttf2asm.lua res/$(FONT).ttf font-10.s  10   _ttf_10
	@./tools/ttf2asm.lua res/$(FONT).ttf font-12.s  12   _ttf_12
	@./tools/ttf2asm.lua res/$(FONT).ttf font-16.s  16   _ttf_16
	@./tools/ttf2asm.lua res/$(FONT).ttf font-20.s  20   _ttf_20  outline
