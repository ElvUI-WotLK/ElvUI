local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local InCombatLockdown = InCombatLockdown
local GetManaRegen = GetManaRegen
local MANA_REGEN = MANA_REGEN

local displayNumberString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	local baseMR, castingMR = GetManaRegen()

	if InCombatLockdown() then
		self.text:SetFormattedText(displayNumberString, castingMR * 5)
	else
		self.text:SetFormattedText(displayNumberString, baseMR * 5)
	end
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", MANA_REGEN, ": ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Mana Regen", {"PLAYER_DAMAGE_DONE_MODS", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"}, OnEvent, nil, nil, nil, nil, MANA_REGEN)