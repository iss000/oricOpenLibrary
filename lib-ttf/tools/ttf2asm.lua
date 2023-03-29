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
-- Usage ttf2asm <font.ttf> <output.s> <ptsize> <label> [outline]

-- ======================================================================
local base_path = string.match(arg[0], '^(.-)[^/\\]*$')
package.path = string.format('%s;%sluamod/?.lua', package.path, base_path)
-- ----------------------------------------------------------------------
local bmp24 = require('bmp24')

-- ----------------------------------------------------------------------
local font = assert(arg[1])
local output = assert(arg[2]):gsub(' ','-'):gsub(':','')
local pointsize = tonumber(assert(arg[3]))
local fontlabel = assert(arg[4])
local gravity = 'west'

-- ----------------------------------------------------------------------
-- append 'b' or 't' if os require binary mode files
local function fmode(rw,b)
    b = b or 'b'
    local t = os.getenv('SystemDrive')
    if t and t:match('^.:$') then rw = rw..b end
    return rw
end

-- ----------------------------------------------------------------------
-- return max value
local function max(a,b)
  return (a < b and b) or a
end

-- ----------------------------------------------------------------------
local function dump_bmp(bmp,i)
  local f = io.open(string.format('temp/%.2x.bmp',i),fmode('w'))
  if f then
    f:write(bmp.data)
    f:flush()
    f:close()
  end
end

local function convert_ascii(ascii, outline, size)
  ---density 72
  ascii = string.char(assert(ascii))
  local trim = (size and '') or '-trim'
  size = size or '240x200'
  local fill = '-fill black -stroke white -strokewidth 0'
  fill = (outline and fill) or '-fill white'
  --
  local cmd='convert'
  local function _(...)
    for i,v in ipairs{...} do
      cmd = cmd..' '..v
    end
  end
  --
  _('-size',size)
  _('-gravity',gravity)
  _('xc:black')
  _('-font',font,'-pointsize',pointsize)
  _(fill)
  _('-antialias')
  _('-annotate 0','\''..ascii..'\'')
  _('-flatten',trim,'+repage')
  _('-type truecolor -depth 8 bmp3:-')
  --   print(cmd)
  return bmp24(assert(io.popen(cmd, fmode('r','b'))))
end

local outline = (arg[5] and true) or false
local ascii = '_!?:[]%'
ascii = ascii..'0123456789'
ascii = ascii..'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
ascii = ascii..'abcdefghijklmnopqrstuvwxyz'

local function render_ttf()
  local f = io.open(output, fmode('w','t'))
  local k
  local maxw,maxh = 0,0
  local sizes = {}
  if f then
    f:write(fontlabel..'\n.(')
    -- calculate sizes
    for k = 1,#ascii do
      local i = ascii:sub(k,k):byte()
      local n = tostring(i)
      local bmp = convert_ascii(i,outline)
      local w,h = bmp.width,bmp.height
      w = w + 1 -- spacing
      h = h + 5 -- fix for 'p'
      maxw = max(maxw,w)
      maxh = max(maxh,h)
      sizes[n] = { w=w, h=h }
      --
      -- dump_bmp(bmp,i)
      --
    end
    --print(maxw,maxh)
    --
    f:write('\n; max width + 1 for buffer\n\t.byte '..string.format('%d',math.floor((maxw+5)/6)+1))
    f:write('\n; max height\n\t.byte '..string.format('%d',maxh))
    f:write('\n\t.word ttf_widths')
    f:write('\n\t.word ttf_width_bytes')
    f:write('\n\t.word ttf_lo')
    f:write('\n\t.word ttf_hi')
    f:write('\n')
    --
    f:write('\nttf_widths')
    for i=32,127 do
      local n = tostring(i)
      if sizes[n] then
        n = sizes[n].w
      else
        n = sizes[tostring(ascii:sub(1,1):byte())].w
      end
      f:write('\n\t.byte '..string.format('%d',n))
    end
    f:write('\nttf_width_bytes')
    for i=32,127 do
      local n = tostring(i)
      if sizes[n] then
        n = sizes[n].w
      else
        n = sizes[tostring(ascii:sub(1,1):byte())].w
      end
      f:write('\n\t.byte '..string.format('%d',math.floor((n+5)/6)))
    end
    --
    f:write('\nttf_lo')
    for i=32,127 do
      local n = tostring(i)
      if sizes[n] then
        n = i
      else
        n = ascii:sub(1,1):byte()
      end
      f:write('\n\t.byte <chr_'..string.format('%.2x',n))
    end
    f:write('\nttf_hi')
    for i=32,127 do
      local n = tostring(i)
      if sizes[n] then
        n = i
      else
        n = ascii:sub(1,1):byte()
      end
      f:write('\n\t.byte >chr_'..string.format('%.2x',n))
    end
    -- render chars
    for k = 1,#ascii do
      local i = ascii:sub(k,k):byte()
      local n = tostring(i)
      local bmp = convert_ascii(i,outline,string.format('%sx%d',sizes[n].w,maxh))
      --
      -- dump_bmp(bmp,i)
      --
      local w,h,ww,hh,sep = math.floor((bmp.width+5)/6)*6,bmp.height
      f:write('\nchr_'..string.format('%.2x',i))
      for hh = 0,h-1 do
        f:write('\n\t.byte ')
        sep = false
        local byt,mask = 0,0x20
        for ww = 0,w-1 do
          byt = byt + bmp:getBWPixel(ww,hh)*mask
          mask = math.floor(mask / 2)
          if 0 == mask then
            f:write((sep and ',' or '')..string.format('$%.2x', byt)) -- +0x40
            sep = true
            byt,mask = 0,0x20
          end
        end
      end
    end
    --
    f:write('\n.)\n')
    --
    f:flush()
    f:close()
  end
end

render_ttf()
