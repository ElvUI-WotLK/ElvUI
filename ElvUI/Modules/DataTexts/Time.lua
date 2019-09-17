local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local next = next
local time = time
local format, gsub, join, utf8sub = string.format, string.gsub, string.join, string.utf8sub
local tinsert, wipe = table.insert, table.wipe
--WoW API / Variables
local GetGameTime = GetGameTime
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetWintergraspWaitTime = GetWintergraspWaitTime
local IsInInstance = IsInInstance
local SecondsToTime = SecondsToTime
local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME
local WINTERGRASP_IN_PROGRESS = WINTERGRASP_IN_PROGRESS

local timeDisplayFormat = ""
local dateDisplayFormat = ""
local europeDisplayFormat_nocolor = join("", "%02d", ":|r%02d")
local lockoutInfoFormat = "%s%s %s |cffaaaaaa(%s)"
local lockoutColorExtended, lockoutColorNormal = {r = 0.3, g = 1, b = 0.3}, {r = .8, g = .8, b = .8}
local lockedInstances = {raids = {}, dungeons = {}}
local collectedInstanceImages

local function OnClick(_, btn)
	if btn == "RightButton" then
		if not IsAddOnLoaded("Blizzard_TimeManager") then
			LoadAddOn("Blizzard_TimeManager")
		end
		TimeManagerClockButton_OnClick(TimeManagerClockButton)
	else
		GameTimeFrame:Click()
	end
end

local instanceIconByName = {}
local function GetInstanceImages(...)
	local numTextures = select("#", ...) / 4

	local argn, title, texture = 1
	for i = 1, numTextures do
		title, texture = select(argn, ...)
		if texture ~= "" then
			instanceIconByName[title] = texture
		end
		argn = argn + 4
	end
end

local locale = GetLocale()
local krcntw = locale == "koKR" or locale == "zhCN" or locale == "zhTW"
local difficultyTag = { -- Normal, Normal, Heroic, Heroic
	(krcntw and PLAYER_DIFFICULTY1) or utf8sub(PLAYER_DIFFICULTY1, 1, 1), -- N
	(krcntw and PLAYER_DIFFICULTY1) or utf8sub(PLAYER_DIFFICULTY1, 1, 1), -- N
	(krcntw and PLAYER_DIFFICULTY2) or utf8sub(PLAYER_DIFFICULTY2, 1, 1), -- H
	(krcntw and PLAYER_DIFFICULTY2) or utf8sub(PLAYER_DIFFICULTY2, 1, 1), -- H
}

local function OnEnter(self)
	DT:SetupTooltip(self)

	RequestRaidInfo()

	if not collectedInstanceImages then
		GetInstanceImages(CalendarEventGetTextures(1))
		GetInstanceImages(CalendarEventGetTextures(2))
		collectedInstanceImages = true
	end

	local wgtime = GetWintergraspWaitTime()
	local _, instanceType = IsInInstance()
	if not instanceType == "none" then
		wgtime = QUEUE_TIME_UNAVAILABLE
	elseif wgtime == nil then
		wgtime = WINTERGRASP_IN_PROGRESS
	else
		wgtime = SecondsToTime(wgtime, false, nil, 3)
	end

	DT.tooltip:AddDoubleLine(L["Wintergrasp"], wgtime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)

	wipe(lockedInstances.raids)
	wipe(lockedInstances.dungeons)

	local name, reset, difficulty, locked, extended, isRaid, maxPlayers
	local difficultyLetter, buttonImg, lockoutColor, info

	for i = 1, GetNumSavedInstances() do
		name, _, reset, difficulty, locked, extended, _, isRaid, maxPlayers = GetSavedInstanceInfo(i)

		if name and (locked or extended) then
			difficultyLetter = difficultyTag[not isRaid and (difficulty == 2 and 3 or 1) or difficulty]
			buttonImg = format("|T%s%s:22:22:0:0:96:96:0:64:0:64|t ", "Interface\\LFGFrame\\LFGIcon-", instanceIconByName[name] or "Raid")

			if isRaid then
				tinsert(lockedInstances.raids, {name, reset, extended, maxPlayers, difficultyLetter, buttonImg})
			elseif difficulty == 2 then
				tinsert(lockedInstances.dungeons, {name, reset, extended, maxPlayers, difficultyLetter, buttonImg})
			end
		end
	end

	if next(lockedInstances.raids) then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddLine(L["Saved Raid(s)"])

		for i = 1, #lockedInstances.raids do
			info = lockedInstances.raids[i]

			lockoutColor = info[3] and lockoutColorExtended or lockoutColorNormal

			DT.tooltip:AddDoubleLine(
				format(lockoutInfoFormat, info[6], info[4], info[5], info[1]),
				SecondsToTime(info[2], false, nil, 3),
				1, 1, 1,
				lockoutColor.r, lockoutColor.g, lockoutColor.b
			)
		end
	end

	if next(lockedInstances.dungeons) then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddLine(L["Saved Dungeon(s)"])

		for i = 1, #lockedInstances.dungeons do
			info = lockedInstances.dungeons[i]

			lockoutColor = info[3] and lockoutColorExtended or lockoutColorNormal

			DT.tooltip:AddDoubleLine(
				format(lockoutInfoFormat, info[6], info[4], info[5], info[1]),
				SecondsToTime(info[2], false, nil, 3),
				1, 1, 1,
				lockoutColor.r, lockoutColor.g, lockoutColor.b
			)
		end
	end

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, format(europeDisplayFormat_nocolor, GetGameTime()), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)

	DT.tooltip:Show()
end

local lastPanel
local int = 5
local function OnUpdate(self, elapsed)
	int = int - elapsed

	if int > 0 then return end

	int = 1
	lastPanel = self

	if GameTimeFrame.flashInvite then
		E:Flash(self, 0.53)
	else
		E:StopFlash(self)
	end

	self.text:SetText(gsub(gsub(BetterDate(E.db.datatexts.timeFormat.." "..E.db.datatexts.dateFormat, time()), ":", timeDisplayFormat), "%s", dateDisplayFormat))
end

local function ValueColorUpdate(hex)
	timeDisplayFormat = join("", hex, ":|r")
	dateDisplayFormat = join("", hex, " ")

	if lastPanel ~= nil then
		OnUpdate(lastPanel, 20000)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Time", nil, nil, OnUpdate, OnClick, OnEnter)