BangDB = BangDB or {}

local function Print(msg)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffBang:|r " .. tostring(msg))
  end
end

local function EnsureDefaults()
  if BangDB.enabled == nil then BangDB.enabled = true end
end

local function IsEnabled()
  EnsureDefaults()
  return BangDB.enabled
end

local function SetEnabled(v)
  EnsureDefaults()
  BangDB.enabled = not not v
  Print("Enabled: " .. (BangDB.enabled and "ON" or "OFF"))
end

local function StartsWith(str, prefix)
  return type(str) == "string" and str:sub(1, #prefix) == prefix
end

-- Map Blizzard event names to SendChatMessage chat types
local function ChatTypeFromEvent(event)
  local t = event:match("^CHAT_MSG_(.+)")
  if not t then return nil end
  -- Strip leader variants (e.g., PARTY_LEADER -> PARTY)
  t = t:gsub("_LEADER$", "")
  -- Instance groups use INSTANCE_CHAT, not PARTY
  return t
end

-- Remove any non-ASCII bytes to avoid malformed UTF-8 crashes.
local function SanitizeMessage(msg)
  -- Lua patterns can choke on ranges with NUL; strip bytes 0x80-0xFF instead.
  return (msg:gsub("[\128-\255]", ""))
end

local function TransformMessage(msg)
  msg = SanitizeMessage(msg:gsub("!", ""))
  if msg == "" then return nil end

  if msg == "penis" then
    return "8" .. string.rep("=", math.random(1, 20)) .. "D"
  elseif msg == "pylon" then
    return "8" .. string.rep("0", math.random(1, 20)) .. "D"
  elseif msg == "toes" then
    return "O" .. string.rep("0", math.random(3, 5)) .. "o"
  else
    local len = #msg
    if len <= 1 then return msg end
    local r = math.random(1, len - 1)
    local ch = msg:sub(r, r)
    return msg:sub(1, r) .. string.rep(ch, math.random(1, 10)) .. msg:sub(r + 1)
  end
end

SLASH_BANG_STANDALONE1 = "/bang"
SLASH_BANG_STANDALONE2 = "/bangaddon"
SlashCmdList["BANG_STANDALONE"] = function(cmd)
  cmd = (cmd or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if cmd == "on" or cmd == "enable" then
    SetEnabled(true)
  elseif cmd == "off" or cmd == "disable" then
    SetEnabled(false)
  elseif cmd == "toggle" or cmd == "" then
    SetEnabled(not IsEnabled())
  elseif cmd == "status" then
    Print("Currently: " .. (IsEnabled() and "ON" or "OFF"))
  else
    Print("Commands: /bang [toggle|on|off|status]")
  end
end

-- Event handler
local EVENTS = {
  "CHAT_MSG_PARTY",
  "CHAT_MSG_PARTY_LEADER",
  "CHAT_MSG_RAID",
  "CHAT_MSG_RAID_LEADER",
  "CHAT_MSG_INSTANCE_CHAT",
  "CHAT_MSG_INSTANCE_CHAT_LEADER",
  "CHAT_MSG_GUILD",
  "CHAT_MSG_OFFICER"
}

local f = CreateFrame("Frame")
for _, e in ipairs(EVENTS) do f:RegisterEvent(e) end
f:SetScript("OnEvent", function(_, event, msg)
  if not IsEnabled() then return end
  if not msg or not StartsWith(msg, "!") then return end
  local chatType = ChatTypeFromEvent(event)
  if not chatType then return end
  local out = TransformMessage(msg)
  if not out or out == "" then return end
  SendChatMessage(out, chatType)
end)

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
  EnsureDefaults()
  Print("Loaded. /bang to toggle. Currently: " .. (IsEnabled() and "ON" or "OFF"))
end)
