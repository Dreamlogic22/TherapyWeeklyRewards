--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.42 (February 26, 2024)

----------------------------------------------------------------------]]

local Name, WeeklyRewards = ...

WeeklyRewards = LibStub("AceEvent-3.0"):Embed(CreateFrame("Frame"))

local Broker, Button, Data

local CATALYST_CHARGES = "You have %s Catalyst |4charge:charges; available."
local REWARDS_AVAILABLE = "Rewards Available!"
local WEEKLY_REWARDS = "Weekly Rewards"

local CatalystCharges = 0
local CatalystCurrencyId = 2796
local Earned = 0
local ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

local function HasRewards() return C_WeeklyRewards.HasAvailableRewards() end

local function Click()
    if InCombatLockdown() or HasRewards() then return end

    WeeklyRewards_ShowUI()
end

local function OnEnter(tooltip)
    if InCombatLockdown() or HasRewards() then return end

    tooltip:AddLine(WEEKLY_REWARDS)
    tooltip:AddLine(" ")

    for i = 1, #WeeklyRewards do
        tooltip:AddLine(WeeklyRewards[i].Header)

        for _, v in ipairs(WeeklyRewards[i]) do
            tooltip:AddDoubleLine(v.textLeft, v.textRight, v.color.r, v.color.g, v.color.b, v.color.r, v.color.g, v.color.b)
        end

        tooltip:AddLine(" ")
    end

    tooltip:AddLine(format(CATALYST_CHARGES, CatalystCharges))
    tooltip:AddLine(" ")

    tooltip:AddLine(WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS, 1, 1, 1)
end

local function UpdateCatalyst(_, currencyType)
    C_Timer.After(1, function()
        if currencyType == CatalystCurrencyId then
            CatalystCharges = C_CurrencyInfo.GetCurrencyInfo(CatalystCurrencyId).quantity
        end
    end)
end

local function UpdateRewards()
    C_Timer.After(1, function()
        if HasRewards() then
            Broker.label = nil
            Broker.text = HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(REWARDS_AVAILABLE)
            return
        else
            Broker.label = WEEKLY_REWARDS
        end

        local ActivityInfo = C_WeeklyRewards.GetActivities()
        if ActivityInfo and #ActivityInfo > 0 then
            Earned = 0

            if not WeeklyRewards[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString then
                WeeklyRewards[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString = ActivityInfo[Enum.WeeklyRewardChestThresholdType.Raid].raidString or UNKNOWN
            end

            for _, activity in pairs(ActivityInfo) do
                local Row = WeeklyRewards[activity.type][activity.index]

                Row.color = { r = 0.5, g = 0.5, b = 0.5 }
                Row.level = activity.level
                Row.progress = activity.progress
                Row.textLeft = format(WeeklyRewards[activity.type].ThresholdString or UNKNOWN, activity.threshold)
                Row.textRight = format(GENERIC_FRACTION_STRING, activity.progress, activity.threshold)
                Row.threshold = activity.threshold
                Row.unlocked = activity.progress >= activity.threshold

                if Row.unlocked then
                    if activity.type == Enum.WeeklyRewardChestThresholdType.Raid then
                        Row.textRight = DifficultyUtil.GetDifficultyName(activity.level)
                    elseif activity.type == Enum.WeeklyRewardChestThresholdType.Activities then
                        Row.textRight = C_WeeklyRewards.GetDifficultyIDForActivityTier(activity.activityTierID) == DifficultyUtil.ID.DungeonHeroic and WEEKLY_REWARDS_HEROIC or format(WEEKLY_REWARDS_MYTHIC, activity.level)
                    elseif activity.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
                        Row.textRight = PVPUtil.GetTierName(activity.level)
                    end

                    Row.color = { r = 0.09, g = 1, b = 0.09 }

                    Earned = Earned + 1
                end
            end
        end

        Broker.text = WrapTextInColorCode(format(GENERIC_FRACTION_STRING, Earned, 9), ValueColor)
    end)
end

local function UpdateButton()
    if Data.global.minimap.hide then
        Button:Hide(Name)
    else
        Button:Show(Name)
    end
end

local function Enable(event, addOnName)
    local Defaults = {
        global = {
            minimap = {
                hide = false
            }
        }
    }

    if event == "ADDON_LOADED" and addOnName == Name then
        WeeklyRewards:UnregisterEvent("ADDON_LOADED")

        Button = LibStub("LibDBIcon-1.0")
        Data = LibStub("AceDB-3.0"):New("TherapyWeeklyRewardsDB", Defaults, true)

        local LDB = LibStub("LibDataBroker-1.1")
        if LDB then
            ---@diagnostic disable-next-line: missing-fields
            Broker = LDB:NewDataObject(WEEKLY_REWARDS, {
                type = "data source",
                label = WEEKLY_REWARDS,
                text = WrapTextInColorCode(NOT_APPLICABLE, ValueColor),
                icon = [[Interface\AddOns\TherapyWeeklyRewards\Media\Vault]]
            })
        end

        if Button then
            ---@diagnostic disable-next-line: param-type-mismatch
            Button:Register(Name, Broker, Data.global.minimap)
        end
    end

    if (UnitLevel("player") >= GetMaxLevelForLatestExpansion()) and not C_WeeklyRewards.IsWeeklyChestRetired() then
        for i = 1, 3 do
            WeeklyRewards[i] = CreateFrame("Frame")
            WeeklyRewards[i].Header = (i == 1 and DUNGEONS) or (i == 2 and PVP) or (i == 3 and RAIDS)
            WeeklyRewards[i].ThresholdString = (i == 1 and WEEKLY_REWARDS_THRESHOLD_DUNGEONS) or (i == 2 and WEEKLY_REWARDS_THRESHOLD_PVP)
            WeeklyRewards[i][1] = CreateFrame("Frame")
            WeeklyRewards[i][2] = CreateFrame("Frame")
            WeeklyRewards[i][3] = CreateFrame("Frame")
        end

        Broker.OnClick = Click
        Broker.OnTooltipShow = OnEnter

        WeeklyRewards:RegisterEvent("CURRENCY_DISPLAY_UPDATE", UpdateCatalyst)
        WeeklyRewards:RegisterEvent("WEEKLY_REWARDS_UPDATE", UpdateRewards)

        UpdateButton()
        UpdateCatalyst(nil, CatalystCurrencyId)
        UpdateRewards()
    end

    SLASH_THERAPYWEEKLYREWARDS1 = "/tww"
    SlashCmdList["THERAPYWEEKLYREWARDS"] = function(message)
        if strlen(message) > 0 and message == "minimap" then
            Data.global.minimap.hide = not Data.global.minimap.hide
            UpdateButton()
        else
            print([[|cff33937fTherapy|r Weekly Rewards: Type "/tww minimap" to toggle the minimap button.]])
        end
    end
end

WeeklyRewards:RegisterEvent("ADDON_LOADED", Enable)