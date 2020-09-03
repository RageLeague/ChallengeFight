local ENEMY_IDS = {}
for id, data in pairs(Content.GetAllCharacterDefs()) do
    --print(id)
    if data and (not data.is_template) and (not data.unique) 
        and not data.boss and data.fight_data and data.fight_data.behaviour
        and data.faction_id ~= PLAYER_FACTION 
        and data.species ~= SPECIES.BEAST and data.species ~= SPECIES.MECH and data.species ~= SPECIES.SNAIL --[[   and data.fight_data.behavior.OnActivate]] 
        and not id:match( "(.*)_PROMOTED$" ) then
        table.insert(ENEMY_IDS,id)
        print(id)
    end
end
print(ENEMY_IDS)
return {
    id = "everyones_here",
    title = "Everyone's Here",
    desc = "Defeat each of every generic, non-promoted npc class. And Kalandra, because reasons. The max team size of the opponent is reduced to 3.",
    enemies = ENEMY_IDS,
    on_start_battle = function(battle)
        battle:GetEnemyTeam():SetMaxFighters( 3 )
    end,
    reward = {
        {card = "battle_plan"},
        {money = true}
    }
}