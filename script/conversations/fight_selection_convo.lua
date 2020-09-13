local CHALLENGE_FIGHTS = nil
local ENTRY_PER_PAGE = 4

Convo("CHALLENGE_FIGHT_SELECTION")
    :Questions("CHALLENGE_INFO", {
        "Ask about the challenges",
        [[
            player:
                What are these challenges?
            agent:
                These are difficult and/or interesting fights added as an optional challenge.
                They are designed for experienced players who can easily clear prestige 16.
                You must have a strong deck with a strong synergy to defeat those challenges.
        ]],
        "Ask about the rewards",
        [[
            player:
                What's in it for me?
            agent:
                Once you complete a challenge, you will be rewarded with shills, cards, and/or grafts to empower your deck.
                Plus, it's a bragging right.
                However, you will not be rewarded with normal post-fight rewards.
        ]],
        "Ask about what you can bring to the challenge",
        [[
            player:
                What can I bring with me to complete these challenges?
            agent:
                You can bring your entire battle deck, including items, as well as your grafts, boons and banes.
                However, all battles are no bystander battles, so you can't hire mercenaries or bring your friends to help you fight.
                Pets are fine, though.
        ]],
        "Ask about the repercussions",
        [[
            player:
                What are the repercussions to these challenges?
            agent:
                You are unable to die from these battles, since they are optional.
                If you are about to die, the last hit will be negated, and you will be forced to flee.
                You can also flee the battle after turn 3, like normal.
                Fleeing might cause your allies to dislike you, but it shouldn't matter that much, since they will retire anyway.
                Any enemy or ally who appear in this fight that does not die will retire.
                Since the battles are isolated, you can kill if you want without consequences.
                Every enemy and ally are spawned during the battle, even unique ones such as Oolo or Nadan.
                Killing them will have no consequences on the real ones. Probably.
                There's no reward for killing, though.
                However, you will sustain any health loss(or gain, if you healed during battle) from the fight.
        ]],
        "Ask about the opportunities you can attempt these challenges",
        [[
            player:
                When can I attempt these challenges?
            agent:
                You can attempt these challenges any time you can talk to a working bartender.
                Don't ever think about attempting these challenges when you have all the broken grafts you get from the final encounter.
                You can attempt each challenge once each day/night, to prevent cheesing experience.
                Once you complete a challenge, you cannot attempt it again.
        ]],
    })
    :Loc{
        OPT_DO_FIGHT = "Attempt a challenge...",
        TT_DO_FIGHT = "Attempting difficult, yet rewarding challenges.",
        DIALOG_DO_FIGHT = [[
            player:
                What should we do today?
        ]],

        OPT_ASK = "Ask about...",
        DIALOG_ASK = [[
            player:
                I want to know what I'm getting into...
        ]],

        OPT_SELECT_FIGHT = "Challenge Battle: {1}",
        TT_SELECT_FIGHT = "Battle Description: {1}",
        TT_REWARD = "You will be rewarded with:",
        TT_REWARD_CARD = "{1#card}",
        TT_REWARD_SHILLS = "{1#money}",
        DIALOG_SELECT_FIGHT = [[
            agent:
                Get ready!
        ]],
        
        OPT_PREV_PAGE = "Previous page...",
        REQ_PREV_PAGE = "This is the first page.",
        OPT_NEXT_PAGE = "Next page...",
        REQ_NEXT_PAGE = "This is the last page.",

        OPT_FIGHT = "Fight!",
        REQ_COMPLETE_CHALLENGE = "You have already completed this challenge",
        REQ_ATTEMPTED_CHALLENGE = "You recently attempted this challenge and cannot attempt this again",
        DIALOG_WIN_CHALLENGE = [[
            agent:
                Well done! Here are your rewards for completing this challenge.
        ]],
        DIALOG_LOSE_CHALLENGE = [[
            player:
                !left
            agent:
                !right
                Too bad. Better luck next time!
                To prevent cheesing experience, you can only attempt this challenge once per day/night.
                Try again later.
        ]],

        OPT_BACK_OFF = "Never mind",
        DIALOG_BACK_OFF = [[
            agent:
                Understandable. You should be extremely prepared to even attempt this challenge.
        ]],
    }
    :RequireFlags( CONVERSATION_FLAGS.ROOT )
    :Hub( function(cxt, who)
        if who and who:GetRoleAtLocation() == CHARACTER_ROLES.PROPRIETOR and cxt.location:HasTag("tavern") then
            local page_number = 0
            cxt:Opt("OPT_DO_FIGHT")
                :PostText("TT_DO_FIGHT")
                :PreIcon( global_images.warning )
                :IsHubOption( true )
                :LoopingFn(function() 
                    if cxt:FirstLoop() then
                        cxt:Dialog("DIALOG_DO_FIGHT")
                        page_number = 0
                    end
                    cxt:Opt("OPT_ASK")
                        :LoopingFn(function()
                            if cxt:FirstLoop() then
                                cxt:Dialog("DIALOG_ASK")
                            end
                            cxt:InsertQuestions("CHALLENGE_INFO")
                            StateGraphUtil.AddBackButton(cxt)
                        end)

                    if CHALLENGE_FIGHTS == nil then
                        CHALLENGE_FIGHTS = ChallengeUtil.fight_data
                    end
                    local result = CHALLENGE_FIGHTS

                    for i = ENTRY_PER_PAGE * page_number + 1, math.min(ENTRY_PER_PAGE * (page_number + 1), #result) do
                        local data = result[i]
                        local option = cxt:Opt("OPT_SELECT_FIGHT", data.title)
                            :PreIcon( global_images.combat )
                        
                        if data.desc then
                            option:PostText( "TT_SELECT_FIGHT", data.desc )
                        end
                        if data.reward and #data.reward > 0 then
                            option:PostText( "TT_REWARD" )
                            for j, reward in ipairs(data.reward) do
                                if reward.card then
                                    option:PostText("TT_REWARD_CARD", reward.card)
                                        :PostCard(reward.card,true)
                                end
                                if reward.money then
                                    if reward.money == true then reward.money = ChallengeUtil.CHALLENGE_REWARD_MONEY end
                                    option:PostText("TT_REWARD_SHILLS", reward.money)
                                end
                            end
                        end
                        option:ReqCondition(not TheGame:GetGameState():GetPlayerAgent()
                            :HasMemory("COMPLETE_CHALLENGE:"..data.id), "REQ_COMPLETE_CHALLENGE")
                        option:ReqCondition(not TheGame:GetGameState():GetPlayerAgent()
                            :HasMemory("ATTEMPTED_CHALLENGE:"..data.id, 1), "REQ_ATTEMPTED_CHALLENGE")
                        option:Fn(function(cxt)
                            local enemyAgents = {}
                            local allyAgents = {}
                            if data.enemies then
                                for j, agent_id in ipairs(data.enemies) do
                                    table.insert(enemyAgents, Agent(agent_id))
                                end
                            end
                            if data.allies then
                                for j, agent_id in ipairs(data.allies) do
                                    table.insert(allyAgents, Agent(agent_id))
                                end
                            end

                            local function RetireAllAgents()
                                for _, agent in ipairs(enemyAgents) do
                                    if not agent:IsRetired() then
                                        agent:Retire()
                                    end
                                end
                                for _, agent in ipairs(allyAgents) do
                                    if not agent:IsRetired() then
                                        agent:Retire()
                                    end
                                end
                            end
                            
                            cxt:Dialog("DIALOG_SELECT_FIGHT")
                            
                            cxt:Opt("OPT_FIGHT")
                                
                                :Battle{
                                    
                                    flags = BATTLE_FLAGS.SELF_DEFENCE | BATTLE_FLAGS.ISOLATED | BATTLE_FLAGS.NO_BYSTANDERS
                                        | BATTLE_FLAGS.NO_REWARDS | BATTLE_FLAGS.BOSS_FIGHT | (data.battle_flags or 0),
                                    no_oppo_limit = true,

                                    enemies = enemyAgents,

                                    on_start_battle = function(battle) 
                                        local fighter = battle:GetFighterForAgent(TheGame:GetGameState():GetPlayerAgent())
                                        if fighter then
                                            fighter:AddCondition("CHALLENGE_INSURANCE")
                                        end
                                        if data.on_start_battle then
                                            data.on_start_battle(battle)
                                        end
                                    end,

                                    on_win = function(cxt)
                                        local player = TheGame:GetGameState():GetPlayerAgent()
                                        player:Remember("COMPLETE_CHALLENGE:"..data.id)
                                        RetireAllAgents()
                                        cxt:Dialog("DIALOG_WIN_CHALLENGE")
                                        if data.reward and #data.reward > 0 then
                                            
                                            for j, reward in ipairs(data.reward) do
                                                if reward.card then
                                                    cxt:GainCards{reward.card}
                                                end
                                                if reward.money then
                                                    cxt.enc:GainMoney(reward.money)
                                                end
                                            end
                                        end
                                    end,
                                    on_runaway = function(cxt)
                                        local player = TheGame:GetGameState():GetPlayerAgent()
                                        player:Remember("ATTEMPTED_CHALLENGE:"..data.id)
                                        RetireAllAgents()
                                        cxt:Dialog("DIALOG_LOSE_CHALLENGE")
                                    end,
                                }
                            cxt:Opt("OPT_BACK_OFF")
                                :PreIcon( global_images.cancel )
                                :Dialog("DIALOG_BACK_OFF")
                                :Fn(function(cxt)
                                    RetireAllAgents()
                                end)
                        end)
                    end
                    cxt:Opt("OPT_PREV_PAGE")
                        :PreIcon( global_images.close )
                        :ReqCondition(page_number > 0, "REQ_PREV_PAGE")
                        :Fn(function(cxt)
                            page_number = page_number - 1
                        end)
                    cxt:Opt("OPT_NEXT_PAGE")
                        :PreIcon( engine.asset.Texture ("UI/ic_menu_play.tex") )
                        :ReqCondition((page_number + 1) * ENTRY_PER_PAGE < #result, "REQ_NEXT_PAGE")
                        :Fn(function(cxt)
                            page_number = page_number + 1
                        end)
                    -- local t = result
                    -- TheGame:GetDebug():CreatePanel( DebugTable( t ))
                    StateGraphUtil.AddBackButton(cxt)
                end)
                
        end
    end)
