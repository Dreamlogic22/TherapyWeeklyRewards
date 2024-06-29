---@meta

---@class TherapyWeeklyRewards
---@field Events AceEvent-3.0
---@field Icon LibDBIcon-1.0
---@field Locale Locale
---@field Options Options
---@field Title string
---@field Version string
---@field db Settings
---@field Console AceConsole-3.0

---@alias AppMessage
---| "APP_SEASON_UPDATE"

---@class AceConsole-3.0
local AceConsole = {}

---@generic T
---@param target T target object to embed AceConsole in
---@return T|AceEvent-3.0 augmentedTarget
function AceConsole:Embed(target) end