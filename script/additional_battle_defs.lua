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
        max_stacks = 1,
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
}

for condition_id, t in pairs( conditions ) do
    Content.AddBattleCondition( condition_id, t )
end