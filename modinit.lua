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
    version = "0.2.0",
    title = "Challenge Fights",
    description = [[This mod adds a couple challenge optional battles. These battles are extremely difficult, and should only be attempted by experienced players.
These challenges can be attempted at any time you can talk to a working bartender at a tavern. That includes Fssh, Hebbel, Sweet Moreef, and the bartender at the Gutted Yote.
Any characters spawned during these challenges are isolated. They will not affect any existing characters in the main campaign, and will not appear in the main campaign.
Once you defeat a challenge, you will be awarded with decent amount of shills, and an item card from the base game. In the future, this might be changed so that custom cards are awarded to the player.
For more information, talk to one of the bartenders and ask about them.]],
    previewImagePath = "preview.png",
}