local Name, T = ...

local function UpdateMinimapButton(shouldShow)
    if shouldShow then
        T.Button:Show(Name)
    else
        T.Button:Hide(Name)
    end
end

-- T.Options = {
--     name = T.Title,
--     type = "group",
--     args = {
--         get = function(info) return T.db.minimap[info[#info]] end,
--         set = function(info, value) T.db.minimap[info[#info]] = value UpdateMinimapButton() end,
--         inline = true,
--         name = "Show Minimap Icon",
--         order = 1,
--         type = "toggle"
--     }
-- }

local function printTable(tbl)
    for k,v in pairs(tbl) do
        print(k, v)
    end
end

T.Options = {
    name = T.Title,
    type = "group",
    get = function(info) return T.db.minimap[info[#info]] end,
    set = function(info, value) T.db.minimap[info[#info]] = value end,
    args = {
        minimap = {
            name = "Show Minimap Icon",
            order = 0,
            type = "toggle"
        }
    }
}
