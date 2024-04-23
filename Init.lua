--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.44 (April 23, 2024)

----------------------------------------------------------------------]]

local Name, T = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

T.Title = GetAddOnMetadata(Name, "Title")
T.Version = GetAddOnMetadata(Name, "Version")

T.Locale = {}

local function LoadDatabase()
    if not TherapyWeeklyRewardsDB then
        TherapyWeeklyRewardsDB = {}
    end

    if #TherapyWeeklyRewardsDB == 0 then
        for key, value in pairs(T.Defaults) do
            if TherapyWeeklyRewardsDB[key] == nil then
                TherapyWeeklyRewardsDB[key] = value
            end
        end
    end

    if not TherapyWeeklyRewardsDB.version or TherapyWeeklyRewardsDB.version ~= T.Version then
        TherapyWeeklyRewardsDB.version = T.Version
    end

    T.db = TherapyWeeklyRewardsDB

    T.Defaults = nil
end

T.EventHandler = LibStub("AceEvent-3.0"):Embed(CreateFrame("Frame"))
T.EventHandler:RegisterEvent("ADDON_LOADED", function(event, addOnName)
    if addOnName == Name then
        T.EventHandler:UnregisterEvent(event)

        LoadDatabase()

        LibStub("AceConfig-3.0"):RegisterOptionsTable(Name, T.Options)
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions(Name, Name)
    end
end)