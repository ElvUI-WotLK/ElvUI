local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join;

local lastPanel;
local displayModifierString = '';

local function OnEvent(self, event, ...)
	local critRating;
	
	if ( E.Role == 'Caster' )then
		critRating = GetSpellCritChance(2);
	else
		if ( E.myclass == 'HUNTER' )then
			critRating = GetRangedCritChance();
		else
			critRating = GetCritChance();
		end
	end
	
	self.text:SetFormattedText(displayModifierString, CRIT_ABBR, critRating);

	lastPanel = self;
end

local function ValueColorUpdate(hex, r, g, b)
	displayModifierString = join('', '%s: ', hex, '%.2f%%|r');
	
	if ( lastPanel ~= nil ) then
		OnEvent(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

DT:RegisterDatatext(CRIT_ABBR, { 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'PLAYER_DAMAGE_DONE_MODS' }, OnEvent);