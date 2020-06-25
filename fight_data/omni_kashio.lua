return {
    id = "omni_kashio",
    title = "Omni-Kashio",
    desc = "Defeat Kashio, by herself, except she has every artifact. Extremely challenging.",
    enemies = {"KASHIO"},
    on_start_battle = function(battle)
        local AUCTION_DATA = require "content/grafts/kashio_boss_fight_defs"
        local candidates = {}
        for k,v in pairs(AUCTION_DATA.CONDITION_LOOKUPS) do
            table.insert(candidates, v)
        end
        local kashio_agent = battle:GetEnemyTeam():Primary()
        for i, id in ipairs(candidates) do
            kashio_agent:AddCondition(id)
        end
    end,
    reward = {
        {card = "support_beacon"},
        {money = CHALLENGE_REWARD_MONEY * 3}
    }
}