local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local join = string.join;

local GetTotalAchievementPoints = GetTotalAchievementPoints;
local ToggleAchievementFrame = ToggleAchievementFrame;
local ACHIEVEMENTS = ACHIEVEMENTS;

local lastPanel;
local displayNumberString = "";

local function OnEvent(self)
	self.text:SetFormattedText(displayNumberString, ACHIEVEMENTS, GetTotalAchievementPoints());
	lastPanel = self;
end

local function OnClick()
	ToggleAchievementFrame();
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%d|r");

	if(lastPanel ~= nil) then
		OnEvent(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Achievement", {"ACHIEVEMENT_EARNED"}, OnEvent, nil, OnClick, nil, nil, ACHIEVEMENTS)