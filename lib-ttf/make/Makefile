#)              _
#)  ___ ___ _ _|_|___ ___
#) |  _| .'|_'_| |_ -|_ -|
#) |_| |__,|_,_|_|___|___|
#)         raxiss (c) 2022

# This Makefile is part of my Linux oolchain
# It's here for reference only.

PROJECT                 := ttf_test
PROJECT_DIR             := $(shell pwd)
PROJECT_LABEL           := ttf_test
PROJECT_VERSION         := 1.00

# # # Only for FlopyBuilder
# PROJECT_DSK           := $(PROJECT).dsk

# # # extra TAPs to include/exclude in/from DSK
PROJECT_DSK_INCLUDE     :=
PROJECT_DSK_EXCLUDE     :=

# # # Autorun main project file
PROJECT_AUTORUN         := 1

# # # Leave DOS
PROJECT_QUITDOS         := 1

# # # 6502, 65816
CPU                     := 6502

# # # Toolchain CC65 or OSDK
TOOLCHAIN               := CC65

# # # -ma -m1 -mt -mp
MACH                    := -ma

# # #
include                 make/Makefile.local
#
OSDK                    := $(OSDK_DIR)
OSDK_OPT                := 0
CC65                    := $(CC65_DIR)
CC65_ALIGNED            := 0

# # #
START_ADDRESS           := $(shell echo $$((0x0600)))

#
CPROJECT                ?= $(PROJECT)

# # #
ATAPS                   :=
BTAPS                   :=
CTAPS                   := $(PROJECT)
OTAPS                   :=

TAPS                    := $(addsuffix .tap,$(ATAPS) $(BTAPS) $(CTAPS) $(OTAPS))

# # #
PROJECT_DSK_INCLUDE     +=
PROJECT_DSK_EXCLUDE     +=

common_SRC              :=

# #
ttf_test_SRC            := ttf_test.c ttf.s font-10.s font-12.s font-16.s font-20.s
ttf_test_AUTORUN        := 1
ttf_test_ADDRESS        := $(START_ADDRESS)
ttf_test_ACPP           := 1

EMU                     := ./oricutron-sdl2
EMUDIR                  := $(EMUL_DIR)
EMUARG                  := $(MACH)
EMUARG                  += --serial none
EMUARG                  += --vsynchack off
EMUARG                  += --turbotape off
EMUARG                  += -s $(PROJECT_DIR)/$(PROJECT).sym
EMUARG                  += -r :$(PROJECT_DIR)/$(PROJECT).brk
EMUARG                  += #-r $(START_ADDRESS)

#
# COMMON                  := $(COMMON_DIR)
# SRC                     := .
#
VPATH                   := $(VPATH) ./ res/

PREPARE                 := prepare
FINALIZE                := finalize

#
include                 $($(TOOLCHAIN)_DIR)/atmos.make

#
AFLAGS                  += $(addprefix -I,$(VPATH))
AFLAGS                  += -DASSEMBLER

AFLAGS                  += -DUSE_ROMCALLS

# AFLAGS                  += -DUSE_VSYNC
# AFLAGS                  += -DUSE_VSYNC_50HZ
# AFLAGS                  += -DUSE_VSYNC_60HZ
# AFLAGS                  += -DUSE_VSYNC_SOFT
# AFLAGS                  += -DUSE_VSYNC_HARD
# AFLAGS                  += -DUSE_VSYNC_NEGEDGE
# AFLAGS                  += -DUSE_VSYNC_AUTO_TEXT
# AFLAGS                  += -DUSE_JOYSTICK
# AFLAGS                  += -DUSE_JOYSTICK2
# AFLAGS                  += -DUSE_JOYSTICK_IJK
# AFLAGS                  += -DUSE_JOYSTICK_IJK_EGOIST
# AFLAGS                  += -DUSE_JOYSTICK_ALTAI

#
CFLAGS                  += $(addprefix -I,$(VPATH))

# CFLAGS                  += -DUSE_ROMCALLS
# CFLAGS                  += -DUSE_VSYNC
# CFLAGS                  += -DUSE_VSYNC_50HZ
# CFLAGS                  += -DUSE_VSYNC_60HZ
# CFLAGS                  += -DUSE_VSYNC_SOFT
# CFLAGS                  += -DUSE_VSYNC_HARD
# CFLAGS                  += -DUSE_VSYNC_NEGEDGE
# CFLAGS                  += -DUSE_VSYNC_AUTO_TEXT
# CFLAGS                  += -DUSE_JOYSTICK
# CFLAGS                  += -DUSE_JOYSTICK2
# CFLAGS                  += -DUSE_JOYSTICK_IJK
# CFLAGS                  += -DUSE_JOYSTICK_IJK_EGOIST
# CFLAGS                  += -DUSE_JOYSTICK_ALTAI

# ttf_test_AFLAGS             +=
# ttf_test_CFLAGS             +=
# ttf_test_LFLAGS             += -D__GRAB__=1
#
ttf_test_AFLAGS              := -DSTART_ADDRESS=$(START_ADDRESS)
ttf_test_CFLAGS              := -DSTART_ADDRESS=$(START_ADDRESS)

# # # additional file to delete
TEMP_FILES              +=

prepare: nfo res

finalize: #hxc
	@([ -e $(PROJECT).brk ] || touch $(PROJECT).brk) || echo -n
	@echo   "[NFO]   ------------------------------"
	@printf "[MEM]   ttf_test   : #%.4X .. #%.4X\\n" $$(($(ttf_test_ADDRESS))) $$(expr `cat ttf_test  | wc -c` + $$(($(ttf_test_ADDRESS))))
	@echo   "[CRC]   $$(crc32 ttf_test)"

.PHONY: nfo res check

nfo:
	@echo "Building with $(TOOLCHAIN):"

res:
	@true

check: all
	@oric2 -ma -s $(PROJECT_DIR)/ttf_test.sym -r :$(PROJECT_DIR)/$(PROJECT).brk ttf_test.dsk
