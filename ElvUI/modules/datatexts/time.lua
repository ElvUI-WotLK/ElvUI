local E, L, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local time = time;
local format, join = string.format, string.join;

local GetGameTime = GetGameTime;
local GetNumSavedInstances = GetNumSavedInstances;
local GetSavedInstanceInfo = GetSavedInstanceInfo;
local GetWintergraspWaitTime = GetWintergraspWaitTime;
local SecondsToTime = SecondsToTime;
local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE;
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME;
local WINTERGRASP_IN_PROGRESS = WINTERGRASP_IN_PROGRESS;

local timeDisplayFormat = "";
local dateDisplayFormat = "";
local europeDisplayFormat_nocolor = join("", "%02d", ":|r%02d");
local lockoutInfoFormatNoEnc = "%s%s |cffaaaaaa(%s)";
local difficultyInfo = {"N", "N", "H", "H"};
local lockoutColorExtended, lockoutColorNormal = {r = 0.3, g = 1, b = 0.3}, {r = .8, g = .8, b = .8};

local Update, lastPanel; -- UpValue
local name, _, reset, difficultyId, locked, extended, isRaid, maxPlayers;

local function ValueColorUpdate(hex)
	timeDisplayFormat = join("", hex, ":|r");
	dateDisplayFormat = join("", hex, " ");

	if(lastPanel ~= nil) then
		Update(lastPanel, 20000);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

local function Click(_, btn)
	if(btn == "RightButton") then
		if(not IsAddonLoaded("Blizzard_TimeManager")) then LoadAddon("Blizzard_TimeManager"); end
		TimeManagerClockButton_OnClick(TimeManagerClockButton);
	else
		GameTimeFrame:Click();
	end
end

local function OnLeave()
	DT.tooltip:Hide();
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local wgtime = GetWintergraspWaitTime() or nil;
	local _, instanceType = IsInInstance();
	if not(instanceType == "none") then
		wgtime = QUEUE_TIME_UNAVAILABLE;
	elseif(wgtime == nil) then
		wgtime = WINTERGRASP_IN_PROGRESS;
	else
		wgtime = SecondsToTime(wgtime, false, nil, 3);
	end
	DT.tooltip:AddDoubleLine(L["Wintergrasp"], wgtime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b);

	local oneraid, lockoutColor
	for i = 1, GetNumSavedInstances() do
		name, _, reset, difficultyId, locked, extended, _, isRaid, maxPlayers = GetSavedInstanceInfo(i);
		if(isRaid and (locked or extended) and name) then
			if(not oneraid) then
				DT.tooltip:AddLine(" ");
				DT.tooltip:AddLine(L["Saved Raid(s)"]);
				oneraid = true;
			end
			if(extended) then
				lockoutColor = lockoutColorExtended;
			else
				lockoutColor = lockoutColorNormal;
			end

			DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, maxPlayers, difficultyInfo[difficultyId], name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b);
		end
	end

	DT.tooltip:AddLine(" ");

	DT.tooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, format(europeDisplayFormat_nocolor, GetGameTime()), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b);

	DT.tooltip:Show();
end

local int = 5;
function Update(self, t)
	int = int - t;

	if(int > 0) then return; end

	if(GameTimeFrame.flashInvite) then
		E:Flash(self, 0.53);
	else
		E:StopFlash(self);
	end

	self.text:SetText(BetterDate(E.db.datatexts.timeFormat .. " " .. E.db.datatexts.dateFormat, time()):gsub(":", timeDisplayFormat):gsub("%s", dateDisplayFormat));

	lastPanel = self;
	int = 1;
end

DT:RegisterDatatext("Time", nil, nil, Update, Click, OnEnter, OnLeave);