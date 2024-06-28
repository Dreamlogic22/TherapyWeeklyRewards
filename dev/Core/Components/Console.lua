---@type string, TherapyWeeklyRewards
local Name, T = ...

setmetatable(T.Console, { __tostring = function() return Name end})
LibStub("AceConsole-3.0"):Embed(T.Console)