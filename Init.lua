--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.42 (March 10, 2024)

----------------------------------------------------------------------]]

local name, ns = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

ns.Name = name
ns.Title = GetAddOnMetadata(name, "Title")
ns.Version = GetAddOnMetadata(name, "Version")

ns.Locale = {}

ns.ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

local function LoadDatabase()
    local db = TherapyWeeklyRewardsDB

    if #db == 0 then
        for key, value in pairs(ns.defaults) do
            if db[key] == nil then
                db[key] = value
            end
        end
    end

    if not db.version or db.version ~= ns.Version then
        db.version = ns.Version
    end

    ns.defaults = nil

    ns.db = db
end

local function Initialize()
    local LDB = LibStub("LibDataBroker-1.1")

    if LDB then
        ns.Broker = LDB:NewDataObject(name, {
            type = "data source",
            label = ns.Locale["Weekly Rewards"],
            text = WrapTextInColorCode(NOT_APPLICABLE, ns.ValueColor),
            icon = [[Interface\AddOns\TherapyWeeklyRewards\Media\Vault]]
        })
    end

    ns.Button = LibStub("LibDBIcon-1.0")

    if ns.Button then
        ---@diagnostic disable-next-line: param-type-mismatch
        ns.Button:Register(name, ns.Broker, ns.db.minimap)
    end
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, addOnName)
    if addOnName == name then
        EventRegistry:UnregisterFrameEventAndCallback("ADDON_LOADED", owner)

        LoadDatabase()

        Initialize()
    end
end, ns)