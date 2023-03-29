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

-- -- ----------------------------------------------------------------------
-- -- return absolute path and name
-- -- local function get_dirname_filename()
-- --   local fullpath = debug.getinfo(1,"S").source:sub(2)
-- --   fullpath = io.popen("realpath '"..fullpath.."'", 'r'):read('a')
-- --   fullpath = fullpath:gsub('[\n\r]*$','')
-- --   local dirname, filename = fullpath:match('^(.*/)([^/]-)$')
-- --   dirname = dirname or ''
-- --   filename = filename or fullpath
-- --   --print(dirname, filename)
-- --   return dirname, filename
-- -- end

-- ======================================================================
-- Usage: gen-tabs.lua <output.s>

-- ======================================================================
local base_path = string.match(arg[0], '^(.-)[^/\\]*$')
package.path = string.format('%s;%sluamod/?.lua', package.path, base_path)
-- ----------------------------------------------------------------------
local bmp24 = require('bmp24')
local bmptoasm = require('bmptoasm')

-- ----------------------------------------------------------------------
-- constants
local debug = 1

-- vars

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
local f = io.open(assert(arg[1]),fmode('w','t'))
if not f then
  os.exit(-1)
end
--
f:write('; --- table X to byte')
f:write('\ntabXtoByte')
for i = 1,240,8 do
  f:write('\n\t.byte\t')
  for j=1,8 do
    local sep = j==8 and '' or ','
    local n = (i-1)+(j-1)
    n = math.floor(n/6)
    f:write(string.format('$%.2x%s',n,sep))
  end
end
--
f:write('\n\n')
--
f:write('; --- table X to shift')
f:write('\ntabXtoShift')
for i = 1,240,8 do
  f:write('\n\t.byte\t')
  for j=1,8 do
    local sep = j==8 and '' or ','
    local n = (i-1)+(j-1)
    n = math.floor(n%6)
    f:write(string.format('$%.2x%s',n,sep))
  end
end
--
f:flush()
f:close()
