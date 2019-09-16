local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local GetPlayerMapPosition = GetPlayerMapPosition
local ToggleFrame = ToggleFrame

local displayString = ""
local x, y = 0, 0

local timeSinceUpdate = 0

local function OnUpdate(self, elapsed)
	timeSinceUpdate = timeSinceUpdate + elapsed

	if timeSinceUpdate > 0.03333 then
		timeSinceUpdate = 0

		x, y = GetPlayerMapPosition("player")

		self.text:SetFormattedText(displayString, x * 100, y * 100)
	end
end

local function OnClick()
	ToggleFrame(WorldMapFrame)
end

local function ValueColorUpdate(hex)
	displayString = join("", hex, "%.2f|r", " , ", hex, "%.2f|r")
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Coords", nil, nil, OnUpdate, OnClick, nil, nil, L["Coords"])