
local filepath = require "util/filepath"

local result = {}

for k, filepath in ipairs( filepath.list_files( "ChallengeFight:fight_data", "*.lua", true )) do
    local name = filepath:match( "(.+)[.]lua$" )
    if name then
        local temp = require(name)
        table.insert(result, temp) 
    end
end

function AddChallengeFightEntry(entry)
    table.insert(result, entry)
end

return result