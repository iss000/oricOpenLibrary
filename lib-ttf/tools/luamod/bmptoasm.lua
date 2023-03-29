#!/usr/bin/env lua

--               _
--   ___ ___ _ _|_|___ ___
--  |  _| .'|_'_| |_ -|_ -|
--  |_| |__,|_,_|_|___|___|
--          raxiss (c) 2021
--

-- ======================================================================
-- Oric ToolBox {aka. OTB}
-- ======================================================================

-- ======================================================================
-- Usage: call bmptoasm(bmp,label), returns assembler source

-- ======================================================================
-- ----------------------------------------------------------------------
local function bmptoasm(bmp,label,inv)
  assert(bmp)
  local function get_pixel(w,h)
    if inv then
      return bmp:getBWPixelInv(w,h)
    end
    return bmp:getBWPixel(w,h)
  end
  local asm = ''
  local function _(s)
    asm = asm..s
  end
  -- print(bmp.width, bmp.height)
  local w,h,ww,hh,sep = math.floor((bmp.width+5)/6)*6,bmp.height
  _('; ---')
  _('\n'..label)
  _('\n\t.byt '..tostring(math.floor(w/6))..','..tostring(h))
  for hh = 0,h-1 do
    _('\n\t.byt ')
    sep = false
    local byt,mask = 0,0x20
    for ww = 0,w-1 do
      byt = byt + get_pixel(ww,hh)*mask
      mask = math.floor(mask / 2)
      if 0 == mask then
        _((sep and ',' or '')..string.format('$%.2x', byt+0x40))
        sep = true
        byt,mask = 0,0x20
      end
    end
  end
  return asm..'\n\n'
end

return bmptoasm
