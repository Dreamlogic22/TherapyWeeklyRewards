--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.46 (July 1, 2024)

----------------------------------------------------------------------]]

---@type string, TherapyWeeklyRewards
local Name, T = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

T.Title = GetAddOnMetadata(Name, "Title")
T.Version = GetAddOnMetadata(Name, "Version")

T.Console = {}
T.Events = {}
T.Locale = {}

-- temp
TherapyWeeklyRewards = T