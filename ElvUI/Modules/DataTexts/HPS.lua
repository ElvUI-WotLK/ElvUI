local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local select = select
local time = time
local max = math.max
local join = string.join
--WoW API / Variables
local UnitGUID = UnitGUID

local events = {SPELL_HEAL = true, SPELL_PERIODIC_HEAL = true}
local playerID, petID
local healTotal, lastHealAmount = 0, 0
local combatTime = 0
local timeStamp = 0
local lastSegment = 0
local lastPanel
local displayString = ""

local function Reset()
	timeStamp = 0
	combatTime = 0
	healTotal = 0
	lastHealAmount = 0
end

local function GetHPS(self)
	local hps
	if healTotal == 0 or combatTime == 0 then
		hps = 0
	else
		hps = healTotal / combatTime
	end
	self.text:SetFormattedText(displayString, E:ShortValue(hps))
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

			local overHeal = select(13, ...)
			lastHealAmount = select(12, ...)
			healTotal = healTotal + max(0, lastHealAmount - overHeal)
		end
	elseif event == "UNIT_PET" then
		petID = UnitGUID("pet")
	elseif event == "PLAYER_ENTERING_WORLD" then
		playerID = E.myguid
		self:UnregisterEvent(event)
	end

	GetHPS(self)
end

local function OnClick(self)
	Reset()
	GetHPS(self)
end

local function ValueColorUpdate(hex)
	displayString = join("", L["HPS"], ": ", hex, "%s")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("HPS", {"PLAYER_ENTERING_WORLD", "COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_LEAVE_COMBAT", "PLAYER_REGEN_DISABLED", "UNIT_PET"}, OnEvent, nil, OnClick, nil, nil, L["HPS"])