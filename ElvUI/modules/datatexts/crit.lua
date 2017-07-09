local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local format, join = string.format, string.join;

local GetCombatRating = GetCombatRating;
local GetCombatRatingBonus = GetCombatRatingBonus;
local GetCritChance = GetCritChance;
local GetRangedCritChance = GetRangedCritChance;
local GetSpellCritChance = GetSpellCritChance;
local COMBAT_RATING_NAME11 = COMBAT_RATING_NAME11;
local CRIT_ABBR = CRIT_ABBR;
local CR_CRIT_MELEE = CR_CRIT_MELEE;
local CR_CRIT_MELEE_TOOLTIP = CR_CRIT_MELEE_TOOLTIP;
local CR_CRIT_RANGED = CR_CRIT_RANGED;
local CR_CRIT_RANGED_TOOLTIP = CR_CRIT_RANGED_TOOLTIP;
local MELEE_CRIT_CHANCE = MELEE_CRIT_CHANCE;
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT;
local RANGED_CRIT_CHANCE = RANGED_CRIT_CHANCE;
local SPELL_CRIT_CHANCE = SPELL_CRIT_CHANCE;
local STAT_CRITICAL_STRIKE = STAT_CRITICAL_STRIKE

local critRating;
local displayModifierString = "";
local lastPanel;

local function OnEvent(self)
	if(E.Role == "Caster")then
		critRating = GetSpellCritChance(2);
	else
		if(E.myclass == "HUNTER")then
			critRating = GetRangedCritChance();
		else
			critRating = GetCritChance();
		end
	end
	self.text:SetFormattedText(displayModifierString, CRIT_ABBR, critRating);
	lastPanel = self;
end

local function OnEnter(self)
	DT:SetupTooltip(self);

	local text, tooltip;
	if(E.Role == "Caster") then
		text = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, SPELL_CRIT_CHANCE) .. " " .. format("%.2F%%", GetSpellCritChance(2));
		tooltip = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, COMBAT_RATING_NAME11) .. " " .. GetCombatRating(11);
	else
		if(E.myclass == "HUNTER") then
			text = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, RANGED_CRIT_CHANCE) .. " " .. format("%.2F%%", GetRangedCritChance());
			tooltip = format(CR_CRIT_RANGED_TOOLTIP, GetCombatRating(CR_CRIT_RANGED), GetCombatRatingBonus(CR_CRIT_RANGED));
		else
			text = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MELEE_CRIT_CHANCE) .. " " .. format("%.2F%%", GetCritChance());
			tooltip = format(CR_CRIT_MELEE_TOOLTIP, GetCombatRating(CR_CRIT_MELEE), GetCombatRatingBonus(CR_CRIT_MELEE));
		end
	end

	DT.tooltip:AddLine(text, 1, 1, 1);
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true);
	DT.tooltip:Show();
end

local function ValueColorUpdate(hex)
	displayModifierString = join("", "%s: ", hex, "%.2f%%|r");

	if(lastPanel ~= nil) then
		OnEvent(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Crit Chance", {"PLAYER_DAMAGE_DONE_MODS"}, OnEvent, nil, nil, OnEnter, nil, STAT_CRITICAL_STRIKE)