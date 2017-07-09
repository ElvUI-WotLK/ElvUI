local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local floor = math.floor;
local format, join = string.format, string.join;

local GetTime = GetTime;

local timer = 0;
local startTime = 0;
local displayNumberString = "";
local lastPanel;

local function OnUpdate(self)
	timer = GetTime() - startTime;
	self.text:SetFormattedText(displayNumberString, L["Combat"], format("%02d:%02d:%02d", floor(timer / 60), timer % 60, (timer - floor(timer)) * 100));
end

local function OnEvent(self, event)
	if(event == "PLAYER_REGEN_DISABLED") then
		timer = 0;
		startTime = GetTime();
		self:SetScript("OnUpdate", OnUpdate);
	elseif(event == "PLAYER_REGEN_ENABLED") then
		self:SetScript("OnUpdate", nil);
	else
		self.text:SetFormattedText(displayNumberString, L["Combat"], "00:00:00");
	end

	lastPanel = self;
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%s|r");

	if(lastPanel ~= nil) then
		OnEvent(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Combat Time", {"PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED"}, OnEvent, nil, nil, nil, nil, L["Combat Time"])