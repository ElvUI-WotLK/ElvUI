local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join

local lastPanel;
local displayNumberString = '';

local function OnEvent(self, event, unit)
	local baseMR, castingMR = GetManaRegen();
	
	if ( InCombatLockdown() ) then
		self.text:SetFormattedText(displayNumberString, MANA_REGEN, castingMR * 5);
	else
		self.text:SetFormattedText(displayNumberString, MANA_REGEN, baseMR * 5);
	end
	
	lastPanel = self;
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join('', '%s: ', hex, '%d|r');
	
	if ( lastPanel ~= nil ) then
		OnEvent(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

DT:RegisterDatatext(MANA_REGEN, { 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE' }, OnEvent);