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
-- Usage: call bmp24(file), returns bitmap info structure

-- ======================================================================
-- ----------------------------------------------------------------------
-- Make color an object to ease code
local Color = {}
local DefThreshold = 0.5
function Color:new(r,g,b)
  local o = {};
  o.r = type(r)=='number' and r or r and r.r or 0;
  o.g = type(g)=='number' and g or r and r.g or 0;
  o.b = type(b)=='number' and b or r and r.b or 0;
  setmetatable(o, self)
  self.__index = self
  return o
end
Color.black = Color:new()
function Color:tostring()
  return "(r="..self.r.." g="..self.g.." b="..self.b..")"
end
function Color:map(func, c)
  self._lab = nil
  self.r = func(self.r, c and c.r)
  self.g = func(self.g, c and c.g)
  self.b = func(self.b, c and c.b)
  return self
end
function Color:clamp(x,y)
  return self:map(function(z) return z<x and x or z>y and y or z end)
end
function Color:mul(val)
  return self:map(function(x) return val*x end)
end
function Color:div(val)
  return self:mul(1/val)
end
function Color:add(other, coef)
  self._lab = nil
  if coef then
    self.r = self.r + other.r*coef;
    self.g = self.g + other.g*coef;
    self.b = self.b + other.b*coef;
  else
    self.r = self.r + other.r;
    self.g = self.g + other.g;
    self.b = self.b + other.b;
  end
  return self
end
function Color:sub(other, coef)
  return self:add(other, coef and -coef or -1)
end
function Color:toLinear()
  return self:map(function(val)
                  val = val/255
                 -- if val<=0.081 then val = val/4.5; else val = ((val+0.099)/1.099)^2.2; end

                 -- works much metter: https://fr.wikipedia.org/wiki/SRGB#Transformation_inverse
                 if val<=0.04045 then val = val/12.92 else val = ((val+0.055)/1.055)^2.4 end
                 return val
                 end)
end

-- support for bmp (https://www.gamedev.net/forums/topic/572784-lua-read-bitmap/)
local function getLinearPixel(self,x,y)
  if x<0 or y<0 or x>=self.width or y>=self.height then
    return Color.black
  else
    local i = self.offset + (self.height-1-y)*self.bytesPerRow + 3*x
    local b = self.data
    local c = Color:new(b:byte(i+3), b:byte(i+2), b:byte(i+1)):toLinear()
    if self.norm then c:map(function(x) x=x*self.norm; return x<1 and x or 1 end) end
    return c
  end
end
local function getBWPixel(self,x,y)
  if x<0 or y<0 or x>=self.width or y>=self.height then return 0 end
  local i = self.offset + (self.height-1-y)*self.bytesPerRow + 3*x
  local b = self.data
  local c = (b:byte(i+3) + b:byte(i+2) + b:byte(i+1))/3
  if self.threshold < c then return 1 end
  return 0
end
local function getBWPixelInv(self,x,y)
  if x<0 or y<0 or x>=self.width or y>=self.height then return 0 end
  local i = self.offset + (self.height-1-y)*self.bytesPerRow + 3*x
  local b = self.data
  local c = (b:byte(i+3) + b:byte(i+2) + b:byte(i+1))/3
  if self.threshold < c then return 0 end
  return 1
end

local function readbmp24(file,threshold)
  if not file then return nil end
  local data = file:read('*all')
  file:close()
  if data:len()<32 then return nil end

  -- Helper function: Parse a 16-bit WORD from the binary string
  local function ReadWORD(str, offset)
    local loByte = str:byte(offset);
    local hiByte = str:byte(offset+1);
    return hiByte*256 + loByte;
  end

  -- Helper function: Parse a 32-bit DWORD from the binary string
  local function ReadDWORD(str, offset)
    local loWord = ReadWORD(str, offset);
    local hiWord = ReadWORD(str, offset+2);
    return hiWord*65536 + loWord;
  end

  -------------------------
  -- Parse BITMAPFILEHEADER
  -------------------------
  local offset = 1;
  local bfType = ReadWORD(data, offset);
  if(bfType ~= 0x4D42) then
    -- error("Not a bitmap file (Invalid BMP magic value)");
    return nil
  end
  local bfOffBits = ReadWORD(data, offset+10);

  -------------------------
  -- Parse BITMAPINFOHEADER
  -------------------------
  offset = 15; -- BITMAPFILEHEADER is 14 bytes long
  local biWidth = ReadDWORD(data, offset+4);
  local biHeight = ReadDWORD(data, offset+8);
  local biBitCount = ReadWORD(data, offset+14);
  local biCompression = ReadDWORD(data, offset+16);
  if(biBitCount ~= 24) then
    -- error("Only 24-bit bitmaps supported (Is "..biBitCount.."bpp)");
    return nil;
  end
  if(biCompression ~= 0) then
    -- error("Only uncompressed bitmaps supported (Compression type is "..biCompression..")");
    return nil;
  end

  return {
    data = data,  -- raw file data
    width = biWidth,
    height = biHeight,
    bytesPerRow = 4*math.floor((biWidth*biBitCount/8 + 3)/4),
    offset = bfOffBits,
    getLinearPixel = getLinearPixel,
    getBWPixel = getBWPixel,
    getBWPixelInv = getBWPixelInv,
    threshold = threshold or DefThreshold
  }
end

return readbmp24
