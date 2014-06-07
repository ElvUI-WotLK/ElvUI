local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join;

local lastPanel;
local displayString = '';

local function OnEvent(self, event, unit)
	local hitRating, hitRatingBonus;
	
	if ( E.Role == 'Caster' ) then
		local expertise = GetExpertise();
		hitRating = GetCombatRating(CR_HIT_SPELL);
		hitRatingBonus = GetCombatRatingBonus(CR_HIT_SPELL);
	else
		if ( E.myclass == 'HUNTER' ) then
			hitRating = GetCombatRating(CR_HIT_RANGED);
			hitRatingBonus = GetCombatRatingBonus(CR_HIT_RANGED);
		else
			hitRating = GetCombatRating(CR_HIT_MELEE);
			hitRatingBonus = GetCombatRatingBonus(CR_HIT_MELEE);
		end
	end

	self.text:SetFormattedText(displayString, L['Hit'], hitRatingBonus);
	
	lastPanel = self;
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join('', '%s: ', hex, '%.2f%%|r');

	if ( lastPanel ~= nil ) then
		OnEvent(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

DT:RegisterDatatext(L['Hit'], { 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE' }, OnEvent);