local _, WeeklyRewards = ...

WeeklyRewards.CatalystCharges = 0
WeeklyRewards.CatalystCurrencyId = 2796

local function UpdateCatalyst(_, currencyType)
    C_Timer.After(1, function()
        if currencyType == WeeklyRewards.CatalystCurrencyId then
            WeeklyRewards.CatalystCharges = C_CurrencyInfo.GetCurrencyInfo(currencyType).quantity
            print(WeeklyRewards.CatalystCharges)
        end
    end)
end

EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", UpdateCatalyst)