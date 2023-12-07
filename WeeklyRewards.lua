--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.2 (December 7, 2023)

----------------------------------------------------------------------]]

local WeeklyRewards = LibStub("AceEvent-3.0"):Embed(CreateFrame("Frame"))

local Noop = function() end

-- cache
local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local C_AddOns_LoadAddOn = C_AddOns.LoadAddOn
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_Timer_After = C_Timer.After
local C_WeeklyRewards_GetActivities = C_WeeklyRewards.GetActivities
local C_WeeklyRewards_HasAvailableRewards = C_WeeklyRewards.HasAvailableRewards
local C_WeeklyRewards_IsWeeklyChestRetired = C_WeeklyRewards.IsWeeklyChestRetired
local GetMaxLevelForLatestExpansion = GetMaxLevelForLatestExpansion
local InCombatLockdown = InCombatLockdown
local UnitLevel = UnitLevel
local WrapTextInColorCode = WrapTextInColorCode

-- locals
local Earned = 0

local CATALYST_CHARGES = "You have %s Catalyst |4charge:charges; available."
local REWARDS_AVAILABLE = "Rewards Available!"
local WEEKLY_REWARDS = "Weekly Rewards"

local CatalystCharges = 0
local CatalystCurrencyId = 2796
local ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

local function GetCatalystCharges() return C_CurrencyInfo_GetCurrencyInfo(CatalystCurrencyId).quantity end
local function HasAvailableRewards() return C_WeeklyRewards_HasAvailableRewards() end
local function IsEligible() return (UnitLevel("player") >= GetMaxLevelForLatestExpansion()) or C_WeeklyRewards_IsWeeklyChestRetired() end


local function Click()
    if InCombatLockdown() then return end

    if C_AddOns_IsAddOnLoaded("Blizzard_WeeklyRewards") then
        if WeeklyRewardsFrame:IsShown() then
            WeeklyRewardsFrame:Hide()
        else
            WeeklyRewardsFrame:Show()
        end
    else
        C_AddOns_LoadAddOn("Blizzard_WeeklyRewards")
        WeeklyRewardsFrame:Show()
    end
end

local function OnEnter(tooltip)
    if InCombatLockdown() or HasAvailableRewards() then return end

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
    if currencyType == CatalystCurrencyId then
        CatalystCharges = GetCatalystCharges()
    end
end

local function UpdateRewards()
    C_Timer_After(1, function()
        if IsEligible() then
            if C_WeeklyRewards_HasAvailableRewards() then
                Broker.label = nil
                Broker.text = HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(REWARDS_AVAILABLE)
                return
            else
                Broker.label = WEEKLY_REWARDS
            end

            local ActivityInfo = C_WeeklyRewards_GetActivities()
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
                        elseif activity.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
                            Row.textRight = format(WEEKLY_REWARDS_MYTHIC, activity.level)
                        elseif activity.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
                            Row.textRight = PVPUtil.GetTierName(activity.level)
                        end

                        Row.color = { r = 0.09, g = 1, b = 0.09 }

                        Earned = Earned + 1
                    end
                end
            end

            Broker.text = WrapTextInColorCode(format(GENERIC_FRACTION_STRING, Earned, 9), ValueColor)
        end
    end)
end

local LDB = LibStub("LibDataBroker-1.1")
if LDB then
    ---@diagnostic disable-next-line: missing-fields
    Broker = LDB:NewDataObject(WEEKLY_REWARDS, {
        type = "data source",
        label = WEEKLY_REWARDS,
        text = WrapTextInColorCode("N/A", ValueColor),
        icon = [[Interface\AddOns\TherapyWeeklyRewards\Icons\Vault]],
        OnClick = IsEligible() and Click or Noop,
        OnTooltipShow = IsEligible() and OnEnter or Noop
    })
end

if IsEligible() then
    for i = 1, 3 do
        WeeklyRewards[i] = CreateFrame("Frame")
        WeeklyRewards[i].Header = (i == 1 and MYTHIC_DUNGEONS) or (i == 2 and PVP) or (i == 3 and RAIDS)
        WeeklyRewards[i].ThresholdString = (i == 1 and WEEKLY_REWARDS_THRESHOLD_MYTHIC) or (i == 2 and WEEKLY_REWARDS_THRESHOLD_PVP)
        WeeklyRewards[i][1] = CreateFrame("Frame")
        WeeklyRewards[i][2] = CreateFrame("Frame")
        WeeklyRewards[i][3] = CreateFrame("Frame")
    end

    WeeklyRewards:RegisterEvent("CURRENCY_DISPLAY_UPDATE", UpdateCatalyst)
    WeeklyRewards:RegisterEvent("WEEKLY_REWARDS_UPDATE", UpdateRewards)

    UpdateCatalyst()
    UpdateRewards()
end