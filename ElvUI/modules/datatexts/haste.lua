local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local UnitAttackSpeed = UnitAttackSpeed
local UnitRangedDamage = UnitRangedDamage
local ATTACK_SPEED = ATTACK_SPEED;
local CR_HASTE_MELEE = CR_HASTE_MELEE;
local CR_HASTE_RANGED = CR_HASTE_RANGED;
local CR_HASTE_RATING_TOOLTIP = CR_HASTE_RATING_TOOLTIP;
local CR_HASTE_SPELL = CR_HASTE_SPELL;
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT;
local SPELL_HASTE = SPELL_HASTE;
local SPELL_HASTE_ABBR = SPELL_HASTE_ABBR;
local SPELL_HASTE_TOOLTIP = SPELL_HASTE_TOOLTIP;
local STAT_HASTE = STAT_HASTE

local displayNumberString = "";
local format = string.format;
local join = string.join;
local lastPanel;

local function OnEvent(self)
	local hasteRating;
	if(E.Role == "Caster") then
		hasteRating = GetCombatRating(CR_HASTE_SPELL);
	elseif(E.myclass == "HUNTER") then
		hasteRating = GetCombatRating(CR_HASTE_RANGED);
	else
		hasteRating = GetCombatRating(CR_HASTE_MELEE);
	end
	self.text:SetFormattedText(displayNumberString, SPELL_HASTE_ABBR, hasteRating);
	lastPanel = self;
end

local function OnEnter(self)
	DT:SetupTooltip(self);

	local text, tooltip;
	if(E.Role == "Caster") then
		text = SPELL_HASTE;
		tooltip = format(SPELL_HASTE_TOOLTIP, GetCombatRatingBonus(CR_HASTE_SPELL));
	elseif(E.myclass == "HUNTER") then
		text = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..format("%.2F", UnitRangedDamage("player"));
		tooltip = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_RANGED), GetCombatRatingBonus(CR_HASTE_RANGED));
	else
		local speed, offhandSpeed = UnitAttackSpeed("player");
		speed = format("%.2F", speed);
		if(offhandSpeed) then
			offhandSpeed = format("%.2F", offhandSpeed);
		end
		local string;
		if(offhandSpeed) then
			string = speed.." / "..offhandSpeed;
		else
			string = speed;
		end
		text = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..string;
		tooltip = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE));
	end

	DT.tooltip:AddLine(text, 1, 1, 1);
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true);
	DT.tooltip:Show();
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%d|r");

	if(lastPanel ~= nil)then
		OnEvent(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Haste", {"UNIT_ATTACK_SPEED", "UNIT_SPELL_HASTE"}, OnEvent, nil, nil, OnEnter, nil, STAT_HASTE)