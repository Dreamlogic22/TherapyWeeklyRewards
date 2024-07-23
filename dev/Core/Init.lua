--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.46 (July 13, 2024)

----------------------------------------------------------------------]]

---@type string, TherapyWeeklyRewards
local Name, T = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

T.Title = GetAddOnMetadata(Name, "Title")
T.Version = GetAddOnMetadata(Name, "Version")

T.Events = {}
T.Locale = {}

-- temp
TherapyWeeklyRewards = T