--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.42 (March 2, 2024)

----------------------------------------------------------------------]]

local Name, T = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

T.Name = Name
T.Title = GetAddOnMetadata(Name, "Title")
T.Version = GetAddOnMetadata(Name, "Version")

-- localization
T.L = {}

local Defaults = {
    minimap = {
        hide = false
    }
}

local function LoadDatabase()
    -- uncomment to wipe: wipe(TherapyWeeklyRewardsDB)

    TherapyWeeklyRewardsDB = TherapyWeeklyRewardsDB or {}
    local DB = TherapyWeeklyRewardsDB

    for key, value in pairs(Defaults) do
        if DB[key] == nil then
            DB[key] = value
        end
    end

    if not DB.version or type(DB.version) ~= "number" then
        DB.version = T.Version
    end

    Defaults = nil
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, addOnName)
    if addOnName == Name then
        EventRegistry:UnregisterFrameEventAndCallback("ADDON_LOADED", owner)

        LoadDatabase()
    end
end, T)