local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join;

local lastPanel;
local displayNumberString = '';

local function OnEvent(self, event, unit)
	local melee = GetCombatRating(CR_CRIT_TAKEN_MELEE);
	local ranged = GetCombatRating(CR_CRIT_TAKEN_RANGED);
	local spell = GetCombatRating(CR_CRIT_TAKEN_SPELL);

	local minResilience = min(melee, ranged);
	
	minResilience = min(minResilience, spell);

	self.text:SetFormattedText(displayNumberString, STAT_RESILIENCE, minResilience);
	
	lastPanel = self;
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join('', '%s: ', hex, '%d|r');
	
	if ( lastPanel ~= nil ) then
		OnEvent(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

DT:RegisterDatatext(STAT_RESILIENCE, { 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE' }, OnEvent);