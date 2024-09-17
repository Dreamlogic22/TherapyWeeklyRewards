--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.48 (September 10, 2024)

----------------------------------------------------------------------]]

---@type string, TherapyWeeklyRewards
local Name, T = ...
local L = T.Locale

local GRAY_FONT_COLOR = GRAY_FONT_COLOR
local GREEN_FONT_COLOR = GREEN_FONT_COLOR

local Activities = {}
local Broker
local CatalystCharges = 0
local CatalystCurrencyId = 2813
local Earned = 0
local HasRewards = C_WeeklyRewards.HasAvailableRewards
local ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

local function AddCatalystInfo(tooltip)
    tooltip:AddLine(format(L.CATALYST_CHARGES, CatalystCharges))
    tooltip:AddLine(" ")
end

local function OnClick()
    if InCombatLockdown() or HasRewards() then return end

    WeeklyRewards_ShowUI()
end

---@param tooltip GameTooltip
local function OnEnter(tooltip)
    if InCombatLockdown() then return end

    if HasRewards() then
        if not T.db.minimap.hide then
            tooltip:AddLine(HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(L.REWARDS_AVAILABLE))
            tooltip:AddLine(" ")
        end

        AddCatalystInfo(tooltip)

        return
    end

    tooltip:AddLine(L.WEEKLY_REWARDS)
    tooltip:AddLine(" ")

    for _, Activity in next, Activities do
        tooltip:AddLine(Activity.Header)

        for _, v in ipairs(Activity) do
            tooltip:AddDoubleLine(v.textLeft, v.textRight, v.color.r, v.color.g, v.color.b, v.color.r, v.color.g, v.color.b)
        end

        tooltip:AddLine(" ")
    end

    AddCatalystInfo(tooltip)

    tooltip:AddLine(WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS, 1, 1, 1)
end

---@param _ any
---@param currencyType number
---@param quantity number
local function UpdateCatalyst(_, currencyType, quantity)
    if currencyType == CatalystCurrencyId then CatalystCharges = quantity end
end

local function UpdateRewards()
    C_Timer.After(1, function()
        if HasRewards() then
            Broker.label = nil
            Broker.text = HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(L.REWARDS_AVAILABLE)

            return
        else
            Broker.label = L.WEEKLY_REWARDS
        end

        local ActivityInfo = C_WeeklyRewards.GetActivities()
        if ActivityInfo and #ActivityInfo > 0 then
            Earned = 0

            if not Activities[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString then
                Activities[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString = ActivityInfo[Enum.WeeklyRewardChestThresholdType.Raid].raidString or UNKNOWN
            end

            for _, activity in ipairs(ActivityInfo) do
                local Row = Activities[activity.type][activity.index]

                Row.color = GRAY_FONT_COLOR
                Row.level = activity.level
                Row.progress = activity.progress
                Row.textLeft = format(Activities[activity.type].ThresholdString or UNKNOWN, activity.threshold)
                Row.textRight = format(GENERIC_FRACTION_STRING, activity.progress, activity.threshold)
                Row.threshold = activity.threshold
                Row.unlocked = activity.progress >= activity.threshold

                if Row.unlocked then
                    if activity.type == Enum.WeeklyRewardChestThresholdType.Raid then
                        Row.textRight = DifficultyUtil.GetDifficultyName(activity.level)
                    elseif activity.type == Enum.WeeklyRewardChestThresholdType.Activities then
                        Row.textRight = C_WeeklyRewards.GetDifficultyIDForActivityTier(activity.activityTierID) == DifficultyUtil.ID.DungeonHeroic and WEEKLY_REWARDS_HEROIC or format(WEEKLY_REWARDS_MYTHIC, activity.level)
                    elseif activity.type == Enum.WeeklyRewardChestThresholdType.World then
                        Row.textRight = GREAT_VAULT_WORLD_TIER:format(activity.level)
                    end

                    Row.color = GREEN_FONT_COLOR

                    Earned = Earned + 1
                end

                if not Broker.OnClick then
                    Broker.OnClick = OnClick
                end

                Broker.text = WrapTextInColorCode(format(GENERIC_FRACTION_STRING, Earned, 9), ValueColor)
            end
        end
    end)
end

---@param activity Enum.WeeklyRewardChestThresholdType
local function SetupActivity(activity)
    Activities[activity] = CreateFrame("Frame")
    Activities[activity].Header = (activity == Enum.WeeklyRewardChestThresholdType.Activities and DUNGEONS) or (activity == Enum.WeeklyRewardChestThresholdType.Raid and RAIDS) or (activity == Enum.WeeklyRewardChestThresholdType.World and WORLD)
    Activities[activity].ThresholdString = (activity == Enum.WeeklyRewardChestThresholdType.Activities and WEEKLY_REWARDS_THRESHOLD_DUNGEONS) or (activity == Enum.WeeklyRewardChestThresholdType.World and WEEKLY_REWARDS_THRESHOLD_WORLD)
    Activities[activity][1] = CreateFrame("Frame")
    Activities[activity][2] = CreateFrame("Frame")
    Activities[activity][3] = CreateFrame("Frame")
end

---@param ownerId number
local function Enable(ownerId)
    EventRegistry:UnregisterFrameEventAndCallback("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE", ownerId)

    local CurrentSeason = C_MythicPlus.GetCurrentSeason()
    if CurrentSeason == -1 then
        print("|cff33ff99Therapy|r:", L.ERR_SEASON_LOAD)
        return
    else
        if CurrentSeason > 0 and not C_WeeklyRewards.IsWeeklyChestRetired() then
            T.Icon:Register(Name, Broker, T.db.minimap)

            SetupActivity(Enum.WeeklyRewardChestThresholdType.Raid)
            SetupActivity(Enum.WeeklyRewardChestThresholdType.Activities)
            SetupActivity(Enum.WeeklyRewardChestThresholdType.World)

            CatalystCharges = C_CurrencyInfo.GetCurrencyInfo(CatalystCurrencyId).quantity

            EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", UpdateCatalyst)
            EventRegistry:RegisterFrameEventAndCallback("WEEKLY_REWARDS_UPDATE", UpdateRewards)

            UpdateRewards()
        end
    end
end

local function LoadDatabase()
    local Version = C_AddOns.GetAddOnMetadata(Name, "Version")

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

    if not TherapyWeeklyRewardsDB.version or TherapyWeeklyRewardsDB.version ~= Version then
        TherapyWeeklyRewardsDB.version = Version
    end

    T.db = TherapyWeeklyRewardsDB

    T.Defaults = nil
end

---@param ownerId number
---@param addOnName string
local function OnLoad(ownerId, addOnName)
    if addOnName == Name then
        EventRegistry:UnregisterFrameEventAndCallback("ADDON_LOADED", ownerId)

        LoadDatabase()

        LibStub("AceConfig-3.0"):RegisterOptionsTable(Name, T.Options)
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions(Name, Name)
    end
end

---@param ownerId number
local function OnLogin(ownerId)
    if IsLoggedIn() then
        EventRegistry:UnregisterFrameEventAndCallback("PLAYER_LOGIN", ownerId)

        C_MythicPlus.RequestMapInfo()

        T.Icon = LibStub("LibDBIcon-1.0")

        local LDB = LibStub("LibDataBroker-1.1")
        if LDB then
            Broker = LDB:NewDataObject(Name, {
                type = "data source",
                label = L.WEEKLY_REWARDS,
                text = WrapTextInColorCode(NOT_APPLICABLE, ValueColor),
                icon = [[Interface\AddOns\TherapyWeeklyRewards\Media\Vault]],
                OnTooltipShow = OnEnter
            })
        end
    end
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", OnLoad)
EventRegistry:RegisterFrameEventAndCallback("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE", Enable)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", OnLogin)