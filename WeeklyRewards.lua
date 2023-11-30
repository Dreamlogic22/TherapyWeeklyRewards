--[[--------------------------------------------------------------------

    Therapy Weekly Rewards 1.1 (November 24, 2023)

----------------------------------------------------------------------]]

local _, WeeklyRewards = ...

local CATALYST_CHARGES = "You have %s Catalyst |4charge:charges; available."
local REWARDS_AVAILABLE = "Rewards Available!"
local WEEKLY_REWARDS = "Weekly Rewards"

local CatalystCharges = 0
local CatalystCurrencyId = 2796
local ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

WeeklyRewards = CreateFrame("Frame")

for i = 1, 3 do
    WeeklyRewards[i] = CreateFrame("Frame")
    WeeklyRewards[i].Header = (i == 1 and MYTHIC_DUNGEONS) or (i == 2 and PVP) or (i == 3 and RAIDS)
    WeeklyRewards[i].ThresholdString = (i == 1 and WEEKLY_REWARDS_THRESHOLD_MYTHIC) or (i == 2 and WEEKLY_REWARDS_THRESHOLD_PVP)
    WeeklyRewards[i][1] = CreateFrame("Frame")
    WeeklyRewards[i][2] = CreateFrame("Frame")
    WeeklyRewards[i][3] = CreateFrame("Frame")
end

local function GetCatalystCharges() return C_CurrencyInfo.GetCurrencyInfo(CatalystCurrencyId).quantity end
local function HasAvailableRewards() return C_WeeklyRewards.HasAvailableRewards() end
local function IsEligible() return IsPlayerAtEffectiveMaxLevel() or C_WeeklyRewards.IsWeeklyChestRetired() end

---@diagnostic disable-next-line: missing-fields
local Broker = LibStub("LibDataBroker-1.1"):NewDataObject("WeeklyRewards", {
    type = "data source",
    label = WEEKLY_REWARDS,
    text = WrapTextInColorCode("N/A", ValueColor),
    icon = [[Interface\AddOns\TherapyWeeklyRewards\Icons\Vault]],
    OnClick = function() end,
    OnTooltipShow = function() end
})

local function UpdateCatalyst(currencyType)
    if currencyType == CatalystCurrencyId then
        CatalystCharges = GetCatalystCharges()
    end
end

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

local function Update(event)
    if not IsEligible() then return end

    C_Timer.After(1, function()
        if event == "PLAYER_ENTERING_WORLD" then
            CatalystCharges = GetCatalystCharges()
            WeeklyRewards:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end

        if HasAvailableRewards() then
            Broker.label = nil
            Broker.text = HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(REWARDS_AVAILABLE)

            return
        else
            Broker.label = WEEKLY_REWARDS
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
                Row.textLeft = format(WeeklyRewards[activity.type].ThresholdString or UNKNOWN, activity.threshold)
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
    end)
end

-- events
WeeklyRewards:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
WeeklyRewards:RegisterEvent("PLAYER_ENTERING_WORLD")
WeeklyRewards:RegisterEvent("WEEKLY_REWARDS_UPDATE")
WeeklyRewards:SetScript("OnEvent", function(self, event, currencyType)
    if not IsEligible() then
        if C_WeeklyRewards.IsWeeklyChestRetired() then
            self:UnregisterAllEvents()
            self:SetScript("OnEvent", nil)

            return
        end
    end

    if event == "CURRENCY_DISPLAY_UPDATE" then
        UpdateCatalyst(currencyType)
    else
        Update()
    end
end)

-- addon compartment globals
function TherapyWeeklyRewards_OnAddonCompartmentClick() Click() end

function TherapyWeeklyRewards_OnAddonCompartmentEnter(_, button)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(button, "ANCHOR_CURSOR")

    OnEnter(GameTooltip)

    GameTooltip:Show()
end

function TherapyWeeklyRewards_OnAddonCompartmentLeave() GameTooltip:Hide() end