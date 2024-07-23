---@type string, TherapyWeeklyRewards
local Name, T = ...

local C, E, L = T.Console, T.Events, T.Locale

T.CatalystCharges = 0
T.CurrentSeason = 0
T.ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

---@param event WowEvent
local function GetSeason(event)
    E:UnregisterEvent(event)

    T.CurrentSeason = C_MythicPlus.GetCurrentSeason()

    if T.CurrentSeason == -1 then
        C:Print(L.ERR_SEASON_LOAD)
        return
    else
        C:Printf("Current season is %s", T.CurrentSeason)

        E:SendMessage("APP_SEASON_UPDATE")
    end
end

local function ConstructBroker()
    T.Icon = LibStub("LibDBIcon-1.0")

    local LDB = LibStub("LibDataBroker-1.1")
    if LDB then
        LDB:NewDataObject(Name, {
            type = "data source",
            label = L.WEEKLY_REWARDS,
            text = WrapTextInColorCode(NOT_APPLICABLE, T.ValueColor),
            icon = [[Interface\AddOns\TherapyWeeklyRewards\Media\Vault]]
        })

        T.LDB = LDB
    end
end

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

---@param event WowEvent
local function OnLogin(event)
    if IsLoggedIn() then
        E:UnregisterEvent(event)

        C_MythicPlus.RequestMapInfo()
    end
end

---@param event WowEvent
---@param addOnName string
local function OnLoad(event, addOnName)
    if addOnName == Name then
        E:UnregisterEvent(event)

        LoadDatabase()
        ConstructBroker()

        LibStub("AceConfig-3.0"):RegisterOptionsTable(Name, T.Options)
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions(Name, Name)
    end
end

E:RegisterEvent("ADDON_LOADED", OnLoad)
E:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE", GetSeason)
E:RegisterEvent("PLAYER_LOGIN", OnLogin)