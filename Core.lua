local _, T = ...

local L = T.L

T.CatalystCurrencyId = 2796
T.ValueColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

do
    local function HasRewards()
        return C_WeeklyRewards.HasAvailableRewards()
    end

    local function UpdateCatalyst(currencyType)
        C_Timer.After(1, function()
            if currencyType == T.CatalystCurrencyId then
                CatalystCharges = C_CurrencyInfo.GetCurrencyInfo(T.CatalystCurrencyId).quantity
            end
        end)
    end

    T.HasRewards = HasRewards
    T.UpdateCatalyst = UpdateCatalyst
end

local function Enable(owner)
    EventRegistry:UnregisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", owner)

    local Broker = LibStub("LibDataBroker-1.1")
    local Button = LibStub("LibDBIcon-1.0")

    if Broker then
        ---@diagnostic disable-next-line: missing-fields
        T.Broker = Broker:NewDataObject(L["Weekly Rewards"], {
            type = "data source",
            label = L["Weekly Rewards"],
            text = WrapTextInColorCode(NOT_APPLICABLE, T.ValueColor),
            icon = [[Interface\AddOns\TherapyWeeklyRewards\Media\Vault]]
        })
    end

    if Button then
        ---@diagnostic disable-next-line: param-type-mismatch
        Button:Register(T.Name, T.Broker, TherapyWeeklyRewardsDB.minimap)
    end

    T.Button = Button

    local WeeklyRewards = {}
    if (UnitLevel("player") >= GetMaxLevelForLatestExpansion()) and not C_WeeklyRewards.IsWeeklyChestRetired() then
        for i = 1, 3 do
            -- WeeklyRewards[i] = CreateFrame("Frame")
            -- WeeklyRewards[i].Header = (i == 1 and DUNGEONS) or (i == 2 and PVP) or (i == 3 and RAIDS)
            -- WeeklyRewards[i].ThresholdString = (i == 1 and WEEKLY_REWARDS_THRESHOLD_DUNGEONS) or (i == 2 and WEEKLY_REWARDS_THRESHOLD_PVP)
            -- WeeklyRewards[i][1] = CreateFrame("Frame")
            -- WeeklyRewards[i][2] = CreateFrame("Frame")
            -- WeeklyRewards[i][3] = CreateFrame("Frame")

            WeeklyRewards[i] = {}
            WeeklyRewards[i].Header = (i == 1 and DUNGEONS) or (i == 2 and PVP) or (i == 3 and RAIDS)
            WeeklyRewards[i].ThresholdString = (i == 1 and WEEKLY_REWARDS_THRESHOLD_DUNGEONS) or (i == 2 and WEEKLY_REWARDS_THRESHOLD_PVP)
            WeeklyRewards[i][1] = {}
            WeeklyRewards[i][2] = {}
            WeeklyRewards[i][3] = {}
        end
    end

    T.WeeklyRewards = WeeklyRewards
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", Enable, T)