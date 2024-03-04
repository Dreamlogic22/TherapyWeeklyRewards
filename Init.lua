--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.42 (March 4, 2024)

----------------------------------------------------------------------]]

local Name, WeeklyRewards = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

WeeklyRewards.Name = Name
WeeklyRewards.Title = GetAddOnMetadata(Name, "Title")
WeeklyRewards.Version = GetAddOnMetadata(Name, "Version")

WeeklyRewards.Locale = {}

WeeklyRewards.ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

local function LoadDatabase()
    local Defaults = {
        minimap = {
            hide = false
        }
    }

    -- uncomment to wipe: wipe(TherapyWeeklyRewardsDB)

    TherapyWeeklyRewardsDB = TherapyWeeklyRewardsDB or {}

    local DB = TherapyWeeklyRewardsDB

    for key, value in pairs(Defaults) do
        if DB[key] == nil then
            DB[key] = value
        end
    end

    if not DB.version or type(DB.version) ~= "number" then
        DB.version = WeeklyRewards.Version
    end

    Defaults = nil
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, addOnName)
    if addOnName == Name then
        EventRegistry:UnregisterFrameEventAndCallback("ADDON_LOADED", owner)
    end

    LoadDatabase()

    local L = WeeklyRewards.Locale

    local LDB = LibStub("LibDataBroker-1.1")
    local LDI = LibStub("LibDBIcon-1.0")

    if LDB then
        WeeklyRewards.Broker = LDB:NewDataObject(L["Weekly Rewards"], {
            type = "data source",
            label = L["Weekly Rewards"],
            text = WrapTextInColorCode(NOT_APPLICABLE, WeeklyRewards.ValueColor),
            icon = [[Interface\AddOns\TherapyWeeklyRewards\Media\Vault]]
        })
    end

    if LDI then
        ---@diagnostic disable-next-line: param-type-mismatch
        LDI:Register(Name, WeeklyRewards.Broker, TherapyWeeklyRewardsDB.minimap)
        WeeklyRewards.Button = LDI
    end

end, WeeklyRewards)