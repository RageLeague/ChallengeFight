
return {
    id = "enhanced_automech_boss",
    title = "Enhanced Automech Boss",
    desc = "Defeat the Automech Boss. Except this time, he summons an Autodog every turn that protects him.",
    enemies = {"AUTOMECH_BOSS"},
    on_start_battle = function(battle)
        local main = battle:GetEnemyTeam():Primary()
        main:AddCondition("DISRUPTOR_SUMMONER")
    end,
    reward = {
        {card = "screamer"},
        {money = true}
    }
}