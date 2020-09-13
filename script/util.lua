return {
    CHALLENGE_REWARD_MONEY = 150,
    -- fight_data = require("ChallengeFight:script/collect_fight_data"),
    AddChallengeFightEntry = function (id, entry)
        table.insert(ChallengeUtil.fight_data, ChallengeDef(entry))
    end
}