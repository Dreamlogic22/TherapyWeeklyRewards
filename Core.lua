local name, ns = ...

local L = ns.Locale

local Activities
local CatalystCharges = 0
local CatalystCurrencyId = 2796
local Earned = 0

local function HasRewards() return C_WeeklyRewards.HasAvailableRewards() end

local Headers = {
    DUNGEONS,
    PVP,
    RAID
}

local ThresholdStrings = {
    WEEKLY_REWARDS_THRESHOLD_DUNGEONS,
    WEEKLY_REWARDS_THRESHOLD_PVP
}

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

local function UpdateRewards()
    C_Timer.After(1, function()
        if HasRewards() then
            ns.Broker.label = nil
            ns.Broker.text = HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(L["Rewards Available"])
            return
        else
            ns.Broker.label = L["Weekly Rewards"]
        end
    end)

    local ActivityInfo = C_WeeklyRewards.GetActivities()
    if ActivityInfo and #ActivityInfo > 0 then
        Earned = 0

        if #ThresholdStrings < 3 then
            table.insert(ThresholdStrings, ActivityInfo[Enum.WeeklyRewardChestThresholdType.Raid].raidString or UNKNOWN)
        end


    end
end

local function Enable()
    if (UnitLevel("player") >= GetMaxLevelForLatestExpansion()) and not C_WeeklyRewards.IsWeeklyChestRetired() then
        ns.Broker.OnClick = Click
        -- ns.Broker.OnTooltipShow = OnEnter

        -- EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", UpdateCatalyst)
        EventRegistry:RegisterFrameEventAndCallback("WEEKLY_REWARDS_UPDATE", UpdateRewards)

        CatalystCharges = C_CurrencyInfo.GetCurrencyInfo(CatalystCurrencyId).quantity

        UpdateRewards()
    end
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", function(owner)
    if IsLoggedIn() then
        EventRegistry:UnregisterFrameEventAndCallback("PLAYER_LOGIN", owner)

        Enable()
    end
end, ns)