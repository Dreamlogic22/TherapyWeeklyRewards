--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.1 (November 21, 2023)

----------------------------------------------------------------------]]

local _, WeeklyRewards = ...

local LDB = LibStub("LibDataBroker-1.1")

local ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

WeeklyRewards = LibStub("AceEvent-3.0"):Embed(CreateFrame("Frame"))

for i = 1, 3 do
    WeeklyRewards[i] = CreateFrame("Frame")
    WeeklyRewards[i].Header = (i == 1 and MYTHIC_DUNGEONS) or (i == 2 and PVP) or (i == 3 and RAIDS)
    WeeklyRewards[i].ThresholdString = (i == 1 and WEEKLY_REWARDS_THRESHOLD_MYTHIC) or (i == 2 and WEEKLY_REWARDS_THRESHOLD_PVP)
    WeeklyRewards[i][1] = CreateFrame("Frame")
    WeeklyRewards[i][2] = CreateFrame("Frame")
    WeeklyRewards[i][3] = CreateFrame("Frame")
end

local function HasAvailableRewards() return C_WeeklyRewards.HasAvailableRewards() and C_WeeklyRewards.CanClaimRewards() end

---@diagnostic disable-next-line: missing-fields
local Broker = LDB:NewDataObject("WeeklyRewards", {
    type = "data source",
    label = "Weekly Rewards",
    text = WrapTextInColorCode("N/A", ValueColor),
    icon = [[Interface\AddOns\TherapyWeeklyRewards\Icons\Vault]],
    OnClick = function() end,
    OnTooltipShow = function() end
})

local function Click()
    if InCombatLockdown() then return end

    if C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") then
        if WeeklyRewardsFrame:IsShown() then
            WeeklyRewardsFrame:Hide()
        else
            WeeklyRewardsFrame:Show()
        end
    else
        C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
        WeeklyRewardsFrame:Show()
    end
end

local function OnEnter(tooltip)
    if InCombatLockdown() or HasAvailableRewards() then return end

    tooltip:AddLine("Weekly Rewards")
    tooltip:AddLine(" ")

    for i = 1, #WeeklyRewards do
        tooltip:AddLine(WeeklyRewards[i].Header)

        for _, v in ipairs(WeeklyRewards[i]) do
            tooltip:AddDoubleLine(v.textLeft, v.textRight, v.color.r, v.color.g, v.color.b, v.color.r, v.color.g, v.color.b)
        end

        tooltip:AddLine(" ")
    end

    tooltip:AddLine(WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS, 1, 1, 1)
end

local function Update(event)
    if event == "PLAYER_ENTERING_WORLD" then
        WeeklyRewards:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end

    if not IsLevelAtEffectiveMaxLevel(UnitLevel("player")) or C_WeeklyRewards.IsWeeklyChestRetired() then return end

    if HasAvailableRewards() then
        Broker.label = nil
        Broker.text = "|cff00ccffRewards Available!|r"

        return
    else
        Broker.label = "Weekly Rewards"
    end

    local Earned = 0

    local ActivityInfo = C_WeeklyRewards.GetActivities()
    if ActivityInfo and #ActivityInfo > 0 then
        if not WeeklyRewards[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString then
            WeeklyRewards[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString = ActivityInfo[Enum.WeeklyRewardChestThresholdType.Raid].raidString or WEEKLY_REWARDS_THRESHOLD_RAID
        end

        for _, activity in ipairs(ActivityInfo) do
            local Row = WeeklyRewards[activity.type][activity.index]

            Row.color = { r = 0.5, g = 0.5, b = 0.5 }
            Row.level = activity.level
            Row.progress = activity.progress
            Row.textLeft = format(WeeklyRewards[activity.type].ThresholdString or "Unknown", activity.threshold)
            Row.textRight = format(GENERIC_FRACTION_STRING, activity.progress, activity.threshold)
            Row.threshold = activity.threshold
            Row.unlocked = activity.progress >= activity.threshold

            if Row.unlocked then
                if activity.type == Enum.WeeklyRewardChestThresholdType.Raid then
                    Row.textRight = DifficultyUtil.GetDifficultyName(activity.level)
                elseif activity.type == Enum.WeeklyRewardChestThresholdType.Activities then
                    Row.textRight = format(WEEKLY_REWARDS_MYTHIC, activity.level)
                elseif activity.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
                    Row.textRight = PVPUtil.GetTierName(activity.level)
                end

                Row.color = { r = 0.09, g = 1, b = 0.09 }

                Earned = Earned + 1
            end
        end

        Broker.text = WrapTextInColorCode(format(GENERIC_FRACTION_STRING, Earned, 9), ValueColor)
    end

    Broker.OnClick = Click
    Broker.OnTooltipShow = OnEnter
end

WeeklyRewards:RegisterEvent("PLAYER_ENTERING_WORLD", Update)
WeeklyRewards:RegisterEvent("WEEKLY_REWARDS_UPDATE", Update)