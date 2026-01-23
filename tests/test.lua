-- Minimal offline test for Bang's TransformMessage logic (ASCII-only handling).
-- Run with: lua tests/test.lua

local function SanitizeMessage(msg)
  -- Strip non-ASCII bytes to avoid malformed UTF-8 crashes.
  return (msg:gsub("[\128-\255]", ""))
end

local function TransformMessage(msg)
  msg = SanitizeMessage(msg:gsub("!", ""))
  if msg == "" then return nil end

  local len = #msg
  if len <= 1 then return msg end
  local r = math.random(1, len - 1)
  local ch = msg:sub(r, r)
  return msg:sub(1, r) .. string.rep(ch, math.random(1, 10)) .. msg:sub(r + 1)
end

local function assert_equals(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s: expected %q, got %q", label, tostring(expected), tostring(actual)))
  end
end

-- Make results deterministic for testing.
math.randomseed(1)

-- Test: ASCII input mutates but remains ASCII.
local out1 = TransformMessage("!bang")
assert(out1 ~= nil and out1:match("^[\0-\127]+$"), "ASCII stays ASCII")
assert(out1:sub(1,1) ~= "!", "Output should never start with !")

-- Test: Non-ASCII input is stripped and returns nil.
local out2 = TransformMessage("!シ")
assert_equals(out2, nil, "Non-ASCII stripped returns nil")

-- Test: Multiple leading bangs collapse and still produce output.
local out3 = TransformMessage("!!bang")
assert(out3 ~= nil and out3:match("^[\0-\127]+$"), "Double bang produces ASCII output")
assert(out3:sub(1,1) ~= "!", "Double bang output should not start with !")

-- Test: All bangs with no letters yields nil.
local out4 = TransformMessage("!!!")
assert_equals(out4, nil, "Only bangs yields nil")

print("All tests passed.")
