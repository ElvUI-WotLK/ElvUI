local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local next, unpack = next, unpack
local format, join = string.format, string.join
local tinsert = table.insert
local time, utf8sub = time, string.utf8sub

local GetGameTime = GetGameTime;
local GetNumSavedInstances = GetNumSavedInstances;
local GetSavedInstanceInfo = GetSavedInstanceInfo;
local GetWintergraspWaitTime = GetWintergraspWaitTime;
local IsInInstance = IsInInstance;
local SecondsToTime = SecondsToTime;
local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE;
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME;
local WINTERGRASP_IN_PROGRESS = WINTERGRASP_IN_PROGRESS;

local timeDisplayFormat = "";
local dateDisplayFormat = "";
local europeDisplayFormat_nocolor = join("", "%02d", ":|r%02d");
local lockoutInfoFormat = "%s%s %s |cffaaaaaa(%s)"
local lockoutColorExtended, lockoutColorNormal = {r = 0.3, g = 1, b = 0.3}, {r = .8, g = .8, b = .8};

local function OnClick(_, btn)
	if(btn == "RightButton") then
		if(not IsAddOnLoaded("Blizzard_TimeManager")) then LoadAddOn("Blizzard_TimeManager"); end
		TimeManagerClockButton_OnClick(TimeManagerClockButton);
	else
		GameTimeFrame:Click();
	end
end

local function OnLeave()
	DT.tooltip:Hide();
end

local instanceIconByName = {}
local function GetInstanceImages(...)
	local numTextures = select("#", ...) / 4

	local param, title, texture = 1
	for textureIndex = 1, numTextures do
		title = select(param, ...)
		param = param + 1
		texture = select(param, ...)
		param = param + 1
		instanceIconByName[title] = texture
		param = param + 2
	end
end

local locale = GetLocale()
local krcntw = locale == "koKR" or locale == "zhCN" or locale == "zhTW"
local difficultyTag = { -- Normal, Heroic, Normal, Heroic
	(krcntw and PLAYER_DIFFICULTY1) or utf8sub(PLAYER_DIFFICULTY1, 1, 1), -- N
	(krcntw and PLAYER_DIFFICULTY2) or utf8sub(PLAYER_DIFFICULTY2, 1, 1), -- H
	(krcntw and PLAYER_DIFFICULTY1) or utf8sub(PLAYER_DIFFICULTY1, 1, 1), -- N
	(krcntw and PLAYER_DIFFICULTY2) or utf8sub(PLAYER_DIFFICULTY2, 1, 1), -- H
}

local collectedInstanceImages = false
local function OnEnter(self)
	DT:SetupTooltip(self)

	RequestRaidInfo()

	if not collectedInstanceImages then
		GetInstanceImages(CalendarEventGetTextures(1))
		GetInstanceImages(CalendarEventGetTextures(2))
		collectedInstanceImages = true
	end

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

	local lockedInstances = {raids = {}, dungeons = {}}
	local name, reset, difficulty, locked, extended, isRaid, maxPlayers
	local difficultyLetter, buttonImg
	
	for i = 1, GetNumSavedInstances() do
		name, _, reset, difficulty, locked, extended, _, isRaid, maxPlayers = GetSavedInstanceInfo(i)
		if (locked or extended) and name then
			difficultyLetter = difficultyTag[(isRaid and difficulty == 2 and 3 or 4) or difficulty]
			buttonImg = instanceIconByName[name] and format("|T%s:22:22:0:0:96:96:0:64:0:64|t ", "Interface\\LFGFrame\\LFGIcon-"..instanceIconByName[name]) or ""

			if isRaid then
				tinsert(lockedInstances["raids"], {name, buttonImg, reset, difficultyLetter, extended, maxPlayers})
			elseif difficulty == 2 then
				tinsert(lockedInstances["dungeons"], {name, buttonImg, reset, difficultyLetter, extended, maxPlayers})
			end
		end
	end

	if next(lockedInstances["raids"]) then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddLine(L["Saved Raid(s)"])

		for i = 1, #lockedInstances["raids"] do
			name, buttonImg, reset, difficultyLetter, extended, maxPlayers = unpack(lockedInstances["raids"][i])

			lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
			DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, buttonImg, maxPlayers, difficultyLetter, name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
		end

		DT.tooltip:Show()
	end

	if next(lockedInstances["dungeons"]) then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddLine(L["Saved Dungeon(s)"])

		for i = 1, #lockedInstances["dungeons"] do
			name, buttonImg, reset, difficultyLetter, extended, maxPlayers = unpack(lockedInstances["dungeons"][i])

			lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
			DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, buttonImg, maxPlayers, difficultyLetter, name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
		end

		DT.tooltip:Show()
	end

	DT.tooltip:AddLine(" ");

	DT.tooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, format(europeDisplayFormat_nocolor, GetGameTime()), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b);

	DT.tooltip:Show();
end

local lastPanel;
local int = 5;
local function OnUpdate(self, t)
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

local function ValueColorUpdate(hex)
	timeDisplayFormat = join("", hex, ":|r");
	dateDisplayFormat = join("", hex, " ");

	if(lastPanel ~= nil) then
		OnUpdate(lastPanel, 20000);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Time", nil, nil, OnUpdate, OnClick, OnEnter, OnLeave);