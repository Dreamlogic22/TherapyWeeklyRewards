local Name, T = ...

local LDI = LibStub("LibDBIcon-1.0")

function T:RegisterButton()
    if LDI then
        LDI:Register(Name, T.Broker, T.db.minimap)
    end
end

function T:UpdateButton()
    if LDI:IsRegistered(Name) then
        LDI:Refresh(Name, T.db.minimap)
    end
end