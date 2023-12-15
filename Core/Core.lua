local T, Broker = unpack(select(2, ...))

-- strings
local CATALYST_CHARGES = "You have %s Catalyst |4charge:charges; available."
local REWARDS_AVAILABLE = "Rewards Available!"
local WEEKLY_REWARDS = "Weekly Rewards"

-- constants
local CatalystCharges = 0
local CatalystCurrencyId = 2796
local Earned = 0
local ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

-- functions
local function IsEligible() return (UnitLevel("player") >= GetMaxLevelForLatestExpansion()) or C_WeeklyRewards.IsWeeklyChestRetired() end

----------------------------------------------------------------------
-- Display
----------------------------------------------------------------------

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
    if InCombatLockdown() or C_WeeklyRewards.HasAvailableRewards() then return end

    tooltip:AddLine(WEEKLY_REWARDS)
    tooltip:AddLine(" ")

    for i = 1, #T do
        tooltip:AddLine(T[i].Header)

        for _, v in ipairs(T[i]) do
            tooltip:AddDoubleLine(v.textLeft, v.textRight, v.color.r, v.color.g, v.color.b, v.color.r, v.color.g, v.color.b)
        end

        tooltip:AddLine(" ")
    end

    tooltip:AddLine(format(CATALYST_CHARGES, CatalystCharges))
    tooltip:AddLine(" ")

    tooltip:AddLine(WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS, 1, 1, 1)
end

----------------------------------------------------------------------
-- Data
----------------------------------------------------------------------

local function UpdateCatalyst(_, currencyType)
    if currencyType == CatalystCurrencyId then
        CatalystCharges = C_CurrencyInfo.GetCurrencyInfo(CatalystCurrencyId).quantity
    end
end

local function UpdateRewards()
    C_Timer.After(1, function()
        if IsEligible() then
            if C_WeeklyRewards.HasAvailableRewards() then
                Broker.label = nil
                Broker.text = HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(REWARDS_AVAILABLE)
                return
            else
                Broker.label = WEEKLY_REWARDS
            end

            local ActivityInfo = C_WeeklyRewards.GetActivities()
            if ActivityInfo and #ActivityInfo > 0 then
                Earned = 0

                if not T[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString then
                    T[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString = ActivityInfo[Enum.WeeklyRewardChestThresholdType.Raid].raidString or UNKNOWN
                end

                for _, activity in pairs(ActivityInfo) do
                    local Row = T[activity.type][activity.index]

                    Row.color = { r = 0.5, g = 0.5, b = 0.5 }
                    Row.level = activity.level
                    Row.progress = activity.progress
                    Row.textLeft = format(T[activity.type].ThresholdString or UNKNOWN, activity.threshold)
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
            end

            Broker.text = WrapTextInColorCode(format(GENERIC_FRACTION_STRING, Earned, 9), ValueColor)
        end
    end)
end

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------

local function Enable(event, addOnName)
    if event == "ADDON_LOADED" and addOnName == T.Name then
        T:UnregisterEvent("ADDON_LOADED")

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
    end

    if IsEligible() then
        if T:IsEventRegistered("PLAYER_LEVEL_UP") then
            T:UnregisterEvent("PLAYER_LEVEL_UP")
        end

        for i = 1, 3 do
            T[i] = CreateFrame("Frame")
            T[i].Header = (i == 1 and MYTHIC_DUNGEONS) or (i == 2 and PVP) or (i == 3 and RAIDS)
            T[i].ThresholdString = (i == 1 and WEEKLY_REWARDS_THRESHOLD_MYTHIC) or (i == 2 and WEEKLY_REWARDS_THRESHOLD_PVP)
            T[i][1] = CreateFrame("Frame")
            T[i][2] = CreateFrame("Frame")
            T[i][3] = CreateFrame("Frame")
        end

        Broker.OnClick = Click
        Broker.OnTooltipShow = OnEnter

        UpdateCatalyst(nil, CatalystCurrencyId)
        UpdateRewards()

        T:RegisterEvent("CURRENCY_DISPLAY_UPDATE", UpdateCatalyst)
        T:RegisterEvent("WEEKLY_REWARDS_UPDATE", UpdateRewards)
    else
        T:RegisterEvent("PLAYER_LEVEL_UP", Enable)
    end
end

T:RegisterEvent("ADDON_LOADED", Enable)