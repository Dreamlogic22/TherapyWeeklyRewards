local Name, WeeklyRewards = ...

WeeklyRewards.Headers = {
    [1] = DUNGEONS,
    [2] = PVP,
    [3] = RAIDS
}

WeeklyRewards.ThresholdStrings = {
    [1] = WEEKLY_REWARDS_THRESHOLD_DUNGEONS,
    [2] = WEEKLY_REWARDS_THRESHOLD_PVP,
    [3] = UNKNOWN
}

function WeeklyRewards:HasRewards()
    return C_WeeklyRewards.HasAvailableRewards()
end

function WeeklyRewards:IsEligible()
    return (UnitLevel("player") >= GetMaxLevelForLatestExpansion() and not C_WeeklyRewards.IsWeeklyChestRetired())
end

function WeeklyRewards:UpdateButton()
    if TherapyWeeklyRewardsDB.minimap.hide then
        WeeklyRewards.Button:Hide(Name)
    else
        WeeklyRewards.Button:Show(Name)
    end
end