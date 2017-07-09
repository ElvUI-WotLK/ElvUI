local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local join = string.join;

local InCombatLockdown = InCombatLockdown;
local GetManaRegen = GetManaRegen;
local MANA_REGEN = MANA_REGEN;

local lastPanel;
local displayNumberString = "";

local function OnEvent(self)
	local baseMR, castingMR = GetManaRegen();
	if(InCombatLockdown()) then
		self.text:SetFormattedText(displayNumberString, MANA_REGEN, castingMR * 5);
	else
		self.text:SetFormattedText(displayNumberString, MANA_REGEN, baseMR * 5);
	end
	lastPanel = self;
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%d|r");

	if(lastPanel ~= nil) then
		OnEvent(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Mana Regen", {"PLAYER_DAMAGE_DONE_MODS", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"}, OnEvent, nil, nil, nil, nil, MANA_REGEN)