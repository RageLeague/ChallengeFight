require "quest_def"

-- MountModData( "ChallengeFight" )

local filepath = require "util/filepath"

local function LoadConvoLua( filename )
    package.loaded[ filename ] = nil
    local ok, result = xpcall( require, generic_error, filename )
    if not ok then
        error( result )
    end
    return ok, result
end

local function OnLoad()
    print("TheGame:GetDebug():CreatePanel( DebugTable( t ))")
    local self_dir = "ChallengeFight:script/"
    -- Load conversations

    require(self_dir .. "additional_battle_defs")


    local CONVO_DIR = self_dir..'conversations'
    for k, filepath in ipairs( filepath.list_files( CONVO_DIR, "*.lua", true )) do
        local name = filepath:match( "(.+)[.]lua$" )
        if name then
            LoadConvoLua( name )
        end
    end

    -- Load quests

    for k, filepath in ipairs( filepath.list_files( self_dir.."quests", "*.lua", true )) do
        local name = filepath:match( "(.+)[.]lua$" )

        if filepath:find( "/deprecated/" ) then
        else
            if name then
                package.loaded[ name ] = nil
                require( name )
                assert( rawget( _G, "QDEF" ) == nil or error( string.format( "Stop declaring global QDEFS %s", name )))
            end
        end
    end
    for k, filepath in ipairs( filepath.list_files( self_dir .. "location", "*.lua", true )) do
        local name = filepath:match( "(.+)[.]lua$" )
        if name then
            require(name)
        end
    end

end

return {
    OnLoad = OnLoad,
    alias = "ChallengeFight",
}