---@meta

---@class TherapyWeeklyRewards
---@field Console AceConsole-3.0
---@field CurrentSeason number
---@field Events AceEvent-3.0
---@field Icon LibDBIcon-1.0
---@field LDB LibDataBroker-1.1
---@field Locale Locale
---@field Options Options
---@field Title string
---@field ValueColor string
---@field Version string
---@field db Settings

---@alias AppMessage
---| "APP_SEASON_UPDATE"

---@class AceConsole-3.0
local AceConsole = {}

---@generic T
---@param target T target object to embed AceConsole in
---@return T|AceEvent-3.0 augmentedTarget
function AceConsole:Embed(target) end