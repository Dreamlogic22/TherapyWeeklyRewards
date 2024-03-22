local Name, T = ...
local L = T.Locale

T.Options = {
    name = T.Title,
    type = "group",
    args = {
        minimap = {
            inline = true,
            name = HUD_EDIT_MODE_MINIMAP_LABEL,
            type = "group",
            order = 0,
            get = function(info) return T.db.minimap[info[#info]] end,
            set = function(info, value) T.db.minimap[info[#info]] = value; T.Button:Refresh(Name, T.db.minimap) end,
            args = {
                hide = {
                    name = L["Hide Minimap Button"],
                    order = 0,
                    type = "toggle"
                },
                lock = {
                    name = L["Lock Minimap Button"],
                    order = 1,
                    type = "toggle",
                    disabled = function() return T.db.minimap.hide end
                }
            }
        }
    }
}