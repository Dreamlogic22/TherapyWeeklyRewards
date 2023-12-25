--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.4 (December 21, 2023)

----------------------------------------------------------------------]]

local Name, Main = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

Main[1] = LibStub("AceEvent-3.0"):Embed(CreateFrame("Frame"))
Main[2] = {}

Main[1].Name = Name
Main[1].Title = GetAddOnMetadata(Name, "Title")
Main[1].Version = GetAddOnMetadata(Name, "Version")