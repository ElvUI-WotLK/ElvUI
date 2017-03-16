local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts")

local time = time
local select = select
local max = math.max
local join = string.join

local UnitGUID = UnitGUID

local events = {SPELL_HEAL = true, SPELL_PERIODIC_HEAL = true}
local playerID, petID
local healTotal, lastHealAmount = 0, 0
local combatTime = 0
local timeStamp = 0
local lastSegment = 0
local lastPanel
local displayString = "";

local function Reset()
	timeStamp = 0
	combatTime = 0
	healTotal = 0
	lastHealAmount = 0
end

local function GetHPS(self)
	local hps
	if healTotal == 0 or combatTime == 0 then
		hps = "0.0"
	else
		hps = healTotal / combatTime
	end
	self.text:SetFormattedText(displayString, L["HPS"], hps)
end

local function OnEvent(self, event, ...)
	lastPanel = self

	if event == "PLAYER_ENTERING_WORLD" then
		playerID = UnitGUID("player")
	elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_LEAVE_COMBAT" then
		local now = time()
		if now - lastSegment > 20 then
			Reset()
		end
		lastSegment = now
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if not events[select(2, ...)] then return end

		local id = select(3, ...)
		if id == playerID or id == petID then
			if timeStamp == 0 then timeStamp = select(1, ...) end
			local overHeal = select(13, ...)
			lastSegment = timeStamp
			combatTime = select(1, ...) - timeStamp
			lastHealAmount = select(12, ...)
			healTotal = healTotal + max(0, lastHealAmount - overHeal)
		end
	elseif event == "UNIT_PET" then
		petID = UnitGUID("pet")
	end

	GetHPS(self)
end

local function OnClick(self)
	Reset()
	GetHPS(self)
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%.1f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("HPS", {"PLAYER_ENTERING_WORLD", "COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_LEAVE_COMBAT", "PLAYER_REGEN_DISABLED", "UNIT_PET"}, OnEvent, nil, OnClick)
