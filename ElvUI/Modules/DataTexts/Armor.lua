local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local format, join = string.format, string.join
--WoW API / Variables
local UnitArmor = UnitArmor
local UnitLevel = UnitLevel
local PaperDollFrame_GetArmorReduction = PaperDollFrame_GetArmorReduction
local ARMOR = ARMOR

local chanceString = "%.2f%%"
local displayString = ""
local _, effectiveArmor
local lastPanel

local function OnEvent(self)
	_, effectiveArmor = UnitArmor("player")

	self.text:SetFormattedText(displayString, effectiveArmor)

	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddLine(L["Mitigation By Level: "])
	DT.tooltip:AddLine(" ")

	local playerLevel = E.mylevel + 3
	local targetLevel = UnitLevel("target")
	local armorReduction

	for i = 1, 4 do
		armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, playerLevel)
		DT.tooltip:AddDoubleLine(playerLevel, format(chanceString, armorReduction), 1, 1, 1)
		playerLevel = playerLevel - 1
	end

	if targetLevel and targetLevel > 0 and (targetLevel > playerLevel + 3 or targetLevel < playerLevel) then
		armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, targetLevel)
		DT.tooltip:AddDoubleLine(targetLevel, format(chanceString, armorReduction), 1, 1, 1)
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", ARMOR, ": ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Armor", {"UNIT_RESISTANCES"}, OnEvent, nil, nil, OnEnter, nil, ARMOR)