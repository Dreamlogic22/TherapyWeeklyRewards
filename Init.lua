--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.3 (December 14, 2023)

----------------------------------------------------------------------]]

local Name, Engine = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

Engine[1] = LibStub("AceEvent-3.0"):Embed(CreateFrame("Frame"))
Engine[2] = {}

Engine[1].Name = Name
Engine[1].Title = GetAddOnMetadata(Name, "Title")
Engine[1].Version = GetAddOnMetadata(Name, "Version")

-- dev
_G[Name] = Engine