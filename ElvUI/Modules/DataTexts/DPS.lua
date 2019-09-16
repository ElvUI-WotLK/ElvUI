local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local select = select
local time = time
local join = string.join
--WoW API / Variables
local UnitGUID = UnitGUID

local events = {SWING_DAMAGE = true, RANGE_DAMAGE = true, SPELL_DAMAGE = true, SPELL_PERIODIC_DAMAGE = true, DAMAGE_SHIELD = true, DAMAGE_SPLIT = true, SPELL_EXTRA_ATTACKS = true}
local playerID, petID
local dmgTotal, lastDmgAmount = 0, 0
local combatTime = 0
local timeStamp = 0
local lastSegment = 0
local lastPanel
local displayString = ""

local function Reset()
	timeStamp = 0
	combatTime = 0
	dmgTotal = 0
	lastDmgAmount = 0
end

local function GetDPS(self)
	local dps
	if dmgTotal == 0 or combatTime == 0 then
		dps = 0
	else
		dps = dmgTotal / combatTime
	end
	self.text:SetFormattedText(displayString, E:ShortValue(dps))
end

local function OnEvent(self, event, ...)
	lastPanel = self

	if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_LEAVE_COMBAT" then
		local now = time()
		if now - lastSegment > 20 then
			Reset()
		end
		lastSegment = now
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if not events[select(2, ...)] then return end

		local id = select(3, ...)
		if id == playerID or id == petID then
			if timeStamp == 0 then
				timeStamp = ...
			end

			lastSegment = timeStamp
			combatTime = (...) - timeStamp

			if select(2, ...) == "SWING_DAMAGE" then
				lastDmgAmount = select(9, ...)
			else
				lastDmgAmount = select(12, ...)
			end

			dmgTotal = dmgTotal + lastDmgAmount
		end
	elseif event == "UNIT_PET" then
		petID = UnitGUID("pet")
	elseif event == "PLAYER_ENTERING_WORLD" then
		playerID = E.myguid
		self:UnregisterEvent(event)
	end

	GetDPS(self)
end

local function OnClick(self)
	Reset()
	GetDPS(self)
end

local function ValueColorUpdate(hex)
	displayString = join("", L["DPS"], ": ", hex, "%s")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("DPS", {"PLAYER_ENTERING_WORLD", "COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_LEAVE_COMBAT", "PLAYER_REGEN_DISABLED", "UNIT_PET"}, OnEvent, nil, OnClick, nil, nil, L["DPS"])