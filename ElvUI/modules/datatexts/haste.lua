local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join;

local lastPanel;
local displayNumberString = '';

local function OnEvent(self, event, unit)
	local hasteRating;
	
	if ( E.Role == 'Caster' ) then
		hasteRating = GetCombatRating(CR_HASTE_SPELL);
	elseif ( E.myclass == 'HUNTER' ) then
		hasteRating = GetCombatRating(CR_HASTE_RANGED);
	else
		hasteRating = GetCombatRating(CR_HASTE_MELEE);
	end
	
	self.text:SetFormattedText(displayNumberString, SPEED, hasteRating);
	
	lastPanel = self;
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join('', '%s: ', hex, '%d|r');
	
	if ( lastPanel ~= nil )then
		OnEvent(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

DT:RegisterDatatext(SPEED, { 'UNIT_ATTACK_SPEED', 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'UNIT_SPELL_HASTE', 'PLAYER_DAMAGE_DONE_MODS' }, OnEvent);