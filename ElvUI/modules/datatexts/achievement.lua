local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local join = string.join;

local GetTotalAchievementPoints = GetTotalAchievementPoints;
local ToggleAchievementFrame = ToggleAchievementFrame;
local ACHIEVEMENT_TITLE = ACHIEVEMENT_TITLE;

local lastPanel;
local displayNumberString = "";

local function OnEvent(self)
	self.text:SetFormattedText(displayNumberString, ACHIEVEMENT_TITLE, GetTotalAchievementPoints());
	lastPanel = self;
end

local function Click()
	ToggleAchievementFrame();
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%d|r");

	if(lastPanel ~= nil) then
		OnEvent(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Achievement", {"ACHIEVEMENT_EARNED"}, OnEvent, nil, Click);