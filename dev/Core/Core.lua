---@type string, TherapyWeeklyRewards
local Name, T = ...

local C, E, L = T.Console, T.EventHandler, T.Locale

T.CurrentSeason = 0

---@param event string
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

        LibStub("AceConfig-3.0"):RegisterOptionsTable(Name, T.Options)
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions(Name, Name)
    end
end

E:RegisterEvent("ADDON_LOADED", OnLoad)
E:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE", GetSeason)
E:RegisterEvent("PLAYER_LOGIN", OnLogin)