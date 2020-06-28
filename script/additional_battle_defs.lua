local battle_defs = require "battle/battle_defs"
local EVENT = battle_defs.EVENT
local CARD_FLAGS = battle_defs.CARD_FLAGS

local conditions =
{
    CHALLENGE_INSURANCE = 
    {
        name = "Challenge Insurance",
        desc = "Prevents this fighter from being killed.\n"
            .. "If this fighter takes lethal damage, prevent that damage and force them to flee.",
        icon = "ChallengeFight:textures/condition_icons/insurance.png",
        max_stacks = 1,
        ctype = CTYPE.INNATE,

        OnPreDamage = function( self, damage, attacker, battle, source, piercing )
            if damage >= self.owner:GetHealth() then
                --self.activated = true
                -- local applicant = self:GetRecentApplicant()
                -- if is_instance( applicant, Battle.Card ) then
                --     self:RemoveApplicant( applicant )
                --     applicant:TransferCard( battle.trash_deck )
                --     applicant:Consume( battle )
                -- end
                if is_instance( source, Battle.Hit ) then 
                    source:SetHitResult( "defended" )
                end
                self.owner:Flee()
                return 0
            end
            return damage
        end,
    },
    DISRUPTOR_SUMMONER = {
        name = "Disruptor Summoner",
        desc = "At the end of this fighter's turn, summon an Autodog with {disruptor_pylon} if able.",
        
        icon = "ChallengeFight:textures/condition_icons/commander.png",

        ctype = CTYPE.INNATE,

        summon_def = "AUTODOG",
        summon_scaling = { 1, 2, 3 },
        
        event_handlers = {
            [ EVENT.END_TURN ] = function( self, fighter )
                local battle = self.owner.engine
                if fighter == self.owner then
                    local open_slots = self.owner:GetTeam():GetMaxFighters() - self.owner:GetTeam():NumActiveFighters()
                    if open_slots > 0 then
                        self.owner:AddCondition("disruptor_field", 1, self)
                        local agent = Agent( self.summon_def )
                        local new_fighter = Fighter.CreateFromAgent( agent, self.summon_scaling[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1] )
                        new_fighter.no_death_loot = true
                        self.owner:GetTeam():AddFighter( new_fighter )
                        new_fighter:AddCondition("disruptor_pylon", 1, self)
                        self.owner:GetTeam():ActivateNewFighters( battle )
                    end
                    
                end
            end,
        }
    },
}

for condition_id, t in pairs( conditions ) do
    Content.AddBattleCondition( condition_id, t )
end