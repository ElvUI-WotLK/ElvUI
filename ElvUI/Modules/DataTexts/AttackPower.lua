local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local max = math.max
local format, join = string.format, string.join
--WoW API / Variables
local ComputePetBonus = ComputePetBonus
local UnitAttackPower = UnitAttackPower
local UnitRangedAttackPower = UnitRangedAttackPower
local ATTACK_POWER = ATTACK_POWER
local ATTACK_POWER_MAGIC_NUMBER = ATTACK_POWER_MAGIC_NUMBER
local ATTACK_POWER_TOOLTIP = ATTACK_POWER_TOOLTIP
local MELEE_ATTACK_POWER = MELEE_ATTACK_POWER
local MELEE_ATTACK_POWER_TOOLTIP = MELEE_ATTACK_POWER_TOOLTIP
local PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER = PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER
local PET_BONUS_TOOLTIP_SPELLDAMAGE = PET_BONUS_TOOLTIP_SPELLDAMAGE
local RANGED_ATTACK_POWER = RANGED_ATTACK_POWER
local RANGED_ATTACK_POWER_TOOLTIP = RANGED_ATTACK_POWER_TOOLTIP

local apower, base, posBuff, negBuff
local displayNumberString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	if E.myclass == "HUNTER" then
		base, posBuff, negBuff = UnitRangedAttackPower("player")
		apower = base + posBuff + negBuff
	else
		base, posBuff, negBuff = UnitAttackPower("player")
		apower = base + posBuff + negBuff
	end

	self.text:SetFormattedText(displayNumberString, apower)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	if E.myclass == "HUNTER" then
		local petAPBonus = ComputePetBonus("PET_BONUS_RAP_TO_AP", apower)
		local petSpellDmgBonus = ComputePetBonus("PET_BONUS_RAP_TO_SPELLDMG", apower)

		DT.tooltip:AddDoubleLine(RANGED_ATTACK_POWER, apower, 1, 1, 1, 1, 1, 1)
		DT.tooltip:AddLine(format(RANGED_ATTACK_POWER_TOOLTIP, max(0, apower) / ATTACK_POWER_MAGIC_NUMBER), nil, nil, nil, 1)

		if petAPBonus > 0 then
			DT.tooltip:AddLine(format(PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER, petAPBonus), nil, nil, nil)
		end

		if petSpellDmgBonus > 0 then
			DT.tooltip:AddLine(format(PET_BONUS_TOOLTIP_SPELLDAMAGE, petSpellDmgBonus), nil, nil, nil)
		end
	else
		DT.tooltip:AddDoubleLine(MELEE_ATTACK_POWER, apower, 1, 1, 1, 1, 1, 1)
		DT.tooltip:AddLine(format(MELEE_ATTACK_POWER_TOOLTIP, max(0, apower) / ATTACK_POWER_MAGIC_NUMBER), nil, nil, nil, 1)
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", ATTACK_POWER, ": ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Attack Power", {"UNIT_ATTACK_POWER", "UNIT_RANGED_ATTACK_POWER"}, OnEvent, nil, nil, OnEnter, nil, ATTACK_POWER_TOOLTIP)