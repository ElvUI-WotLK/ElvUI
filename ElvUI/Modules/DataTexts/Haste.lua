local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local format, join = string.format, string.join
--WoW API / Variables
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local UnitAttackSpeed = UnitAttackSpeed
local UnitRangedDamage = UnitRangedDamage
local ATTACK_SPEED = ATTACK_SPEED
local CR_HASTE_MELEE = CR_HASTE_MELEE
local CR_HASTE_RANGED = CR_HASTE_RANGED
local CR_HASTE_RATING_TOOLTIP = CR_HASTE_RATING_TOOLTIP
local CR_HASTE_SPELL = CR_HASTE_SPELL
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local SPELL_HASTE = SPELL_HASTE
local SPELL_HASTE_ABBR = SPELL_HASTE_ABBR
local SPELL_HASTE_TOOLTIP = SPELL_HASTE_TOOLTIP

local hasteRating
local displayNumberString = ""
local lastPanel

local function OnEvent(self, event)
	lastPanel = self

	if event == "SPELL_UPDATE_USABLE" then
		self:UnregisterEvent(event)
	end

	if E.Role == "Caster" then
		hasteRating = GetCombatRating(CR_HASTE_SPELL)
	elseif E.myclass == "HUNTER" then
		hasteRating = GetCombatRating(CR_HASTE_RANGED)
	else
		hasteRating = GetCombatRating(CR_HASTE_MELEE)
	end

	self.text:SetFormattedText(displayNumberString, hasteRating)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local text, tooltip
	if E.Role == "Caster" then
		text = format("%s %d", SPELL_HASTE, hasteRating)
		tooltip = format(SPELL_HASTE_TOOLTIP, GetCombatRatingBonus(CR_HASTE_SPELL))
	elseif E.myclass == "HUNTER" then
		text = format("%s %.2f", format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED), UnitRangedDamage("player"))
		tooltip = format(CR_HASTE_RATING_TOOLTIP, hasteRating, GetCombatRatingBonus(CR_HASTE_RANGED))
	else
		local speed, offhandSpeed = UnitAttackSpeed("player")

		if offhandSpeed then
			text = format("%s %.2f / %.2f", format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED), speed, offhandSpeed)
		else
			text = format("%s %.2f", format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED), speed)
		end

		tooltip = format(CR_HASTE_RATING_TOOLTIP, hasteRating, GetCombatRatingBonus(CR_HASTE_MELEE))
	end

	DT.tooltip:AddLine(text, 1, 1, 1)
	DT.tooltip:AddLine(tooltip, nil, nil, nil, 1)

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", SPELL_HASTE_ABBR, ": ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Haste", {"SPELL_UPDATE_USABLE", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "UNIT_ATTACK_SPEED", "UNIT_SPELL_HASTE"}, OnEvent, nil, nil, OnEnter, nil, SPELL_HASTE)