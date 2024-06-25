---@type string, TherapyWeeklyRewards
local Name, T = ...

local E, L = T.EventHandler, T.Locale

local Activities = {}
local Broker

local CatalystCharges = 0
local CatalystCurrencyId = 2912
local Earned = 0
local ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

local function HasRewards() return C_WeeklyRewards.HasAvailableRewards() end

local function Click()
    if InCombatLockdown() or HasRewards() then return end

    WeeklyRewards_ShowUI()
end

local function OnEnter(tooltip)
    if InCombatLockdown() or HasRewards() then return end

    tooltip:AddLine(L["Weekly Rewards"])
    tooltip:AddLine(" ")

    for i = 1, #Activities do
        tooltip:AddLine(Activities[i].Header)

        for _, v in ipairs(Activities[i]) do
            tooltip:AddDoubleLine(v.textLeft, v.textRight, v.color.r, v.color.g, v.color.b, v.color.r, v.color.g, v.color.b)
        end

        tooltip:AddLine(" ")
    end

    tooltip:AddLine(format(L["Catalyst Charges"], CatalystCharges))
    tooltip:AddLine(" ")

    tooltip:AddLine(WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS, 1, 1, 1)
end

local function UpdateCatalyst(_, currencyType, quantity)
    if currencyType == CatalystCurrencyId then CatalystCharges = quantity end
end

local function UpdateRewards()
    C_Timer.After(1, function()
        if HasRewards() then
            Broker.label = nil
            Broker.text = HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(L["Rewards Available"])
            return
        else
            Broker.label = L["Weekly Rewards"]
        end

        local ActivityInfo = C_WeeklyRewards.GetActivities()
        if ActivityInfo and #ActivityInfo > 0 then
            Earned = 0

            if not Activities[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString then
                Activities[Enum.WeeklyRewardChestThresholdType.Raid].ThresholdString = ActivityInfo[Enum.WeeklyRewardChestThresholdType.Raid].raidString or UNKNOWN
            end

            for _, activity in pairs(ActivityInfo) do
                local Row = Activities[activity.type][activity.index]

                Row.color = { r = 0.5, g = 0.5, b = 0.5 }
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

local function Enable()
    if IsLoggedIn() then
        E:UnregisterEvent("PLAYER_LOGIN")

        T.Icon = LibStub("LibDBIcon-1.0")

        local LDB = LibStub("LibDataBroker-1.1")
        if LDB then
            Broker = LDB:NewDataObject(Name, {
                type = "data source",
                label = L["Weekly Rewards"],
                text = WrapTextInColorCode(NOT_APPLICABLE, ValueColor),
                icon = [[Interface\AddOns\TherapyWeeklyRewards\Media\Vault]]
            })

            T.Icon:Register(Name, Broker, T.db.minimap)
        end

        if (UnitLevel("player") >= GetMaxLevelForLatestExpansion()) and not C_WeeklyRewards.IsWeeklyChestRetired() then
            for i = 1, 3 do
                Activities[i] = CreateFrame("Frame")
                Activities[i].Header = (i == 1 and DUNGEONS) or (i == 2 and PVP) or (i == 3 and RAIDS)
                Activities[i].ThresholdString = (i == 1 and WEEKLY_REWARDS_THRESHOLD_DUNGEONS) or (i == 2 and WEEKLY_REWARDS_THRESHOLD_PVP)
                Activities[i][1] = CreateFrame("Frame")
                Activities[i][2] = CreateFrame("Frame")
                Activities[i][3] = CreateFrame("Frame")
            end

            Broker.OnClick = Click
            Broker.OnTooltipShow = OnEnter

            CatalystCharges = C_CurrencyInfo.GetCurrencyInfo(CatalystCurrencyId).quantity

            E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", UpdateCatalyst)
            E:RegisterEvent("WEEKLY_REWARDS_UPDATE", UpdateRewards)

            UpdateRewards()
        end
    end
end

E:RegisterEvent("PLAYER_LOGIN", Enable)