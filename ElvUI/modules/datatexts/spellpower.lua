local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local join = string.join;

local GetSpellBonusDamage = GetSpellBonusDamage;
local GetSpellBonusHealing = GetSpellBonusHealing;

local displayNumberString = "";
local lastPanel;

local function OnEvent(self)
	local spellDamage = GetSpellBonusDamage(7);
	local spellHealing = GetSpellBonusHealing();

	if(spellHealing > spellDamage) then
		self.text:SetFormattedText(displayNumberString, L["HP"], spellHealing);
	else
		self.text:SetFormattedText(displayNumberString, L["SP"], spellDamage);
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

DT:RegisterDatatext("Spell/Heal Power", {"PLAYER_DAMAGE_DONE_MODS"}, OnEvent);