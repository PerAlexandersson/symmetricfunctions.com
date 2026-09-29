local file_reading = dofile("file_reading.lua")

local function fail(message)
  io.stderr:write("[ERROR] json-determinism: " .. message .. "\n")
  os.exit(1)
end

local left = {}
left.zeta = { second = 2, first = 1 }
left.alpha = { "x", "y" }
left.middle = { nested_z = true, nested_a = false }

local right = {}
right.middle = { nested_a = false, nested_z = true }
right.alpha = { "x", "y" }
right.zeta = { first = 1, second = 2 }

local encoded_left = file_reading.json_encode(left)
local encoded_right = file_reading.json_encode(right)
if encoded_left ~= encoded_right then
  fail("equal nested tables encoded to different bytes")
end

local alpha_at = encoded_left:find('"alpha"', 1, true)
local middle_at = encoded_left:find('"middle"', 1, true)
local zeta_at = encoded_left:find('"zeta"', 1, true)
if not alpha_at or not middle_at or not zeta_at or
   not (alpha_at < middle_at and middle_at < zeta_at) then
  fail("object keys were not sorted")
end
