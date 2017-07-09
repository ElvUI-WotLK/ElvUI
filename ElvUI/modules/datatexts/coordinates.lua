local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts")

local join = string.join;

local GetPlayerMapPosition = GetPlayerMapPosition;
local ToggleFrame = ToggleFrame;

local displayString = ""
local x, y = 0, 0

local function OnUpdate(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed;

	if(self.timeSinceUpdate > 0.1) then
		x, y = GetPlayerMapPosition("player");
		x = E:Round(100 * x, 1);
		y = E:Round(100 * y, 1);

		self.text:SetFormattedText(displayString, x, y);
		self.timeSinceUpdate = 0;
	end
end

local function OnClick()
	ToggleFrame(WorldMapFrame);
end

local function ValueColorUpdate(hex)
	displayString = join("", hex, "%.1f|r", " , ", hex, "%.1f|r");
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Coords", nil, nil, OnUpdate, OnClick, nil, nil, L["Coords"])