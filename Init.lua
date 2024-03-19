--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.42 (March 18, 2024)

----------------------------------------------------------------------]]

local Name, T = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

T.Title = GetAddOnMetadata(Name, "Title")
T.Version = GetAddOnMetadata(Name, "Version")

T.Locale = {}

T.ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

local function LoadDatabase()
    local db = TherapyWeeklyRewardsDB

    if #db == 0 then
        for key, value in pairs(T.Defaults) do
            if db[key] == nil then
                db[key] = value
            end
        end
    end

    if not db.version or db.version ~= T.Version then
        db.version = T.Version
    end

    T.Defaults = nil

    T.db = db
end

local function Initialize()
    LoadDatabase()

    T.LDB = LibStub("LibDataBroker-1.1")
    T.LDI = LibStub("LibDBIcon-1.0")

    T.LDB:NewDataObject(Name, {
        type = "data source",
        label = T.Locale["Weekly Rewards"],
        text = WrapTextInColorCode(NOT_APPLICABLE, T.ValueColor),
        icon = [[Interface\AddOns\TherapyWeeklyRewards\Media\Vault]]
    })

    T.LDI:Register(Name, T.LDB:GetDataObjectByName(Name), T.db.minimap)

    LibStub("AceConfig-3.0"):RegisterOptionsTable(Name, T.Options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(Name, Name)
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, addOnName)
    if addOnName == Name then
        EventRegistry:UnregisterFrameEventAndCallback("ADDON_LOADED", owner)
        Initialize()
    end
end, T)