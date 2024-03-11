local _, WeeklyRewards = ...

WeeklyRewards.CatalystCharges = 0

local CatalystCurrencyId = 2796

WeeklyRewards.UpdateCatalyst = function(_, currencyType)
    if currencyType == CatalystCurrencyId then
        WeeklyRewards.CatalystCharges = C_CurrencyInfo.GetCurrencyInfo(currencyType).quantity
        print(WeeklyRewards.CatalystCharges)
    end
end

EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", WeeklyRewards.UpdateCatalyst)