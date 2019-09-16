local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local select = select
local abs = math.abs
local format, join = string.format, string.join
--WoW API / Variables
local GetBlockChance = GetBlockChance
local GetBonusBarOffset = GetBonusBarOffset
local GetDodgeChance = GetDodgeChance
local GetInventoryItemID = GetInventoryItemID
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemInfo = GetItemInfo
local GetParryChance = GetParryChance
local UnitLevel = UnitLevel
local BLOCK_CHANCE = BLOCK_CHANCE
local BOSS = BOSS
local DEFENSE = DEFENSE
local DODGE_CHANCE = DODGE_CHANCE
local PARRY_CHANCE = PARRY_CHANCE

local displayString = ""
local chanceString = "%.2f%%"
local chanceString2 = "+%.2f%%"
local AVD_DECAY_RATE = 0.2
local targetlvl, playerlvl
local baseMissChance, levelDifference, dodge, parry, block, avoidance, unhittable
local lastPanel

local function IsWearingShield()
	local slotID = GetInventorySlotInfo("SecondaryHandSlot")
	local itemID = GetInventoryItemID("player", slotID)

	if itemID then
		return select(9, GetItemInfo(itemID))
	end
end

local function OnEvent(self)
	targetlvl, playerlvl = UnitLevel("target"), E.mylevel

	baseMissChance = E.myrace == "NightElf" and 7 or 5
	if targetlvl == -1 then
		levelDifference = 3
	elseif targetlvl > playerlvl then
		levelDifference = (targetlvl - playerlvl)
	elseif targetlvl < playerlvl and targetlvl > 0 then
		levelDifference = (targetlvl - playerlvl)
	else
		levelDifference = 0
	end

	if levelDifference >= 0 then
		dodge = (GetDodgeChance() - levelDifference * AVD_DECAY_RATE)
		parry = (GetParryChance() - levelDifference * AVD_DECAY_RATE)
		block = (GetBlockChance() - levelDifference * AVD_DECAY_RATE)
		baseMissChance = (baseMissChance - levelDifference * AVD_DECAY_RATE)
	else
		dodge = (GetDodgeChance() + abs(levelDifference * AVD_DECAY_RATE))
		parry = (GetParryChance() + abs(levelDifference * AVD_DECAY_RATE))
		block = (GetBlockChance() + abs(levelDifference * AVD_DECAY_RATE))
		baseMissChance = (baseMissChance+ abs(levelDifference * AVD_DECAY_RATE))
	end

	if dodge <= 0 then dodge = 0 end
	if parry <= 0 then parry = 0 end
	if block <= 0 then block = 0 end

	if E.myclass == "DRUID" and GetBonusBarOffset() == 3 then
		parry = 0
	end

	if IsWearingShield() ~= "INVTYPE_SHIELD" then
		block = 0
	end

	avoidance = (dodge + parry + block + baseMissChance)
	unhittable = avoidance - 102.4

	self.text:SetFormattedText(displayString, avoidance)

	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	if targetlvl > 1 then
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], join("", " (", L["lvl"], " ", targetlvl, ")"))
	elseif targetlvl == -1 then
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], join("", " (", BOSS, ")"))
	else
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], join("", " (", L["lvl"], " ", playerlvl, ")"))
	end

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(DODGE_CHANCE, format(chanceString, dodge), 1, 1, 1)
	DT.tooltip:AddDoubleLine(PARRY_CHANCE, format(chanceString, parry), 1, 1, 1)
	DT.tooltip:AddDoubleLine(BLOCK_CHANCE, format(chanceString, block), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Miss Chance"], format(chanceString, baseMissChance), 1, 1, 1)
	DT.tooltip:AddLine(" ")

	if unhittable > 0 then
		DT.tooltip:AddDoubleLine(L["Unhittable:"], format(chanceString2, unhittable), 1, 1, 1, 0, 1, 0)
	else
		DT.tooltip:AddDoubleLine(L["Unhittable:"], format(chanceString, unhittable), 1, 1, 1, 1, 0, 0)
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", DEFENSE, ": ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Avoidance", {"COMBAT_RATING_UPDATE", "PLAYER_TARGET_CHANGED"}, OnEvent, nil, nil, OnEnter, nil, L["Avoidance Breakdown"])