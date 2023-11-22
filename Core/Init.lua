--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.1 (November 21, 2023)

----------------------------------------------------------------------]]

local _, T = ...

local LDB = LibStub("LibDataBroker-1.1")
local Registry = LibStub("AceEvent-3.0"):Embed(CreateFrame("Frame"))

local ActiveSeason = false
local Eligible = false
local ValueColor = "ffffffff"

local Color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
if Color then
    ValueColor = Color.colorStr
end

---@diagnostic disable-next-line: missing-fields
local Broker = LDB:NewDataObject("WeeklyRewards", {
    type = "data source",
    label = "Weekly Rewards",
    text = WrapTextInColorCode("N/A", ValueColor),
    icon = [[Interface\AddOns\TherapyWeeklyRewards\Icons\Vault]],
    OnClick = function() end,
    OnTooltipShow = function() end
})

local Headers = {
    [Enum.WeeklyRewardChestThresholdType.Activities] = MYTHIC_DUNGEONS,
    [Enum.WeeklyRewardChestThresholdType.RankedPvP] = PVP,
    [Enum.WeeklyRewardChestThresholdType.Raid] = RAIDS
}

local ThresholdStrings = {
    [Enum.WeeklyRewardChestThresholdType.Activities] = WEEKLY_REWARDS_THRESHOLD_MYTHIC,
    [Enum.WeeklyRewardChestThresholdType.RankedPvP] = WEEKLY_REWARDS_THRESHOLD_PVP
}

-- api cache
C_WeeklyRewards_HasAvailableRewards = C_WeeklyRewards.HasAvailableRewards
C_WeeklyRewards_IsWeeklyChestRetired = C_WeeklyRewards.IsWeeklyChestRetired
IsLevelAtEffectiveMaxLevel = IsLevelAtEffectiveMaxLevel
C_WeeklyRewards_GetActivities = C_WeeklyRewards.GetActivities

local function Update(event)
    if event == "PLAYER_ENTERING_WORLD" then
        Registry:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end

    ActiveSeason = not C_WeeklyRewards_IsWeeklyChestRetired()
    Eligible = IsLevelAtEffectiveMaxLevel(UnitLevel("player"))

    if not Eligible or not ActiveSeason then return end

    if C_WeeklyRewards_HasAvailableRewards() then
        Broker.label = nil
        Broker.text = "|cff00ccffRewards Available!|r"

        return
    else
        Broker.label = "Weekly Rewards"
    end

    local Earned = 0

    local ActivityInfo = C_WeeklyRewards_GetActivities()
    if ActivityInfo and #ActivityInfo > 0 then
        if not ThresholdStrings[Enum.WeeklyRewardChestThresholdType.Raid] then
            ThresholdStrings[Enum.WeeklyRewardChestThresholdType.Raid] = ActivityInfo[Enum.WeeklyRewardChestThresholdType.Raid].raidString or WEEKLY_REWARDS_THRESHOLD_RAID
        end

        for _, activity in pairs(ActivityInfo) do
            if activity.progress >= activity.threshold then
                Earned = Earned + 1
            end
        end

        Broker.text = WrapTextInColorCode(format(GENERIC_FRACTION_STRING, Earned, 9), ValueColor)
    end
end

Registry:RegisterEvent("PLAYER_ENTERING_WORLD", Update)
Registry:RegisterEvent("WEEKLY_REWARDS_UPDATE", Update)

---

-- for i = 1, 3 do
--     WeeklyRewards[i] = {}
--     WeeklyRewards[i].Header = (i == 1 and MYTHIC_DUNGEONS) or (i == 2 and PVP) or (i == 3 and RAIDS)
--     WeeklyRewards[i].ThresholdString = (i == 1 and WEEKLY_REWARDS_THRESHOLD_MYTHIC) or (i == 2 and WEEKLY_REWARDS_THRESHOLD_PVP)
--     WeeklyRewards[i][1] = {}
--     WeeklyRewards[i][2] = {}
--     WeeklyRewards[i][3] = {}
-- end