
local filepath = require "util/filepath"

local ChallengeDef = class("ChallengeFightClass.ChallengeDef", BasicLocalizedDef)

function ChallengeDef:init(id, data)
    ChallengeDef._base.init(self, id, data)
    self:SetModID( CURRENT_MOD_ID )
end
function ChallengeDef:GetLocPrefix()
    return "CHALLENGE_DEF." .. string.upper(self.id)
end

local result = {}

for k, filepath in ipairs( filepath.list_files( "ChallengeFight:fight_data", "*.lua", true )) do
    local name = filepath:match( "(.+)[.]lua$" )
    
    if name then
        local temp = require(name)
        local id = temp.id or filepath:match("([^/]+)[.]lua$")
        table.insert(result, ChallengeDef(id, temp)) 
    end
end

Content.internal.CHALLENGE_DEF = result
return result