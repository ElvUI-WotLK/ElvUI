local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local GetTotalAchievementPoints = GetTotalAchievementPoints
local ToggleAchievementFrame = ToggleAchievementFrame
local ACHIEVEMENTS = ACHIEVEMENTS

local displayNumberString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self
	self.text:SetFormattedText(displayNumberString, GetTotalAchievementPoints())
end

local function OnClick()
	ToggleAchievementFrame()
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", ACHIEVEMENTS, ": ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Achievement", {"ACHIEVEMENT_EARNED"}, OnEvent, nil, OnClick, nil, nil, ACHIEVEMENTS)