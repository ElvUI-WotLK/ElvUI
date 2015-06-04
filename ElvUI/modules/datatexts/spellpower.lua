local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join;

local lastPanel;
local displayNumberString = '';

local function OnEvent(self, event, unit)
	local spellDamage = GetSpellBonusDamage(7);
	local spellHealing = GetSpellBonusHealing();
	
	if ( spellHealing > spellDamage ) then
		self.text:SetFormattedText(displayNumberString, L['HP'], spellHealing);
	else
		self.text:SetFormattedText(displayNumberString, L['SP'], spellDamage);
	end

	lastPanel = self;
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join('', '%s: ', hex, '%d|r');
	
	if ( lastPanel ~= nil ) then
		OnEvent(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext(L['Spell/Heal Power'], { 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE' }, OnEvent);