local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local find, format, join = string.find, string.format, string.join
local sort, wipe = table.sort, table.wipe
--WoW API / Variables
local EasyMenu = EasyMenu
local GetGuildInfo = GetGuildInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GetGuildRosterMOTD = GetGuildRosterMOTD
local GetMouseFocus = GetMouseFocus
local GetNumGuildMembers = GetNumGuildMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealZoneText = GetRealZoneText
local GuildRoster = GuildRoster
local InviteUnit = InviteUnit
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local SetItemRef = SetItemRef
local ToggleFriendsFrame = ToggleFriendsFrame
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local GUILD = GUILD
local GUILD_MOTD = GUILD_MOTD
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=0.3,g=1,b=0.3}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}

local levelNameFormat = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s"
local levelNameStatusFormat = "|cff%02x%02x%02x%d|r %s%s"
local onlineInfoFormat = join("", GUILD, ": %d/%d")

local guildMotDFormat = "%s |cffaaaaaa- |cffffffff%s"
local moreMembersOnlineFormat = join("", "+ %d ", FRIENDS_LIST_ONLINE, "...")
local nameRankFormat = "%s |cff999999-|cffffffff %s"
local noteFormat = join("", "|cff999999   ", LABEL_NOTE, ":|r %s")
local officerNoteFormat = join("", "|cff999999   ", GUILD_RANK1_DESC, ":|r %s")

local inGroupStamp = "|cffaaaaaa*|r"
local friendOnlineString = string.gsub(ERR_FRIEND_ONLINE_SS, ".+|h", "")
local friendOfflineString = string.gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")

local onlineStatusString = "|cffFFFFFF[|r|cffFF0000%s|r|cffFFFFFF]|r"
local onlineStatus = {
	[0] = "",
	[1] = format(onlineStatusString, L["AFK"]),
	[2] = format(onlineStatusString, L["DND"]),
}

local displayString = ""
local noGuildString = ""
local lastPanel

local dataTable = {}
local guildMotD = ""
local currentSortMode = false
local dataUpdated
local rosterDelay

local totalOnline = 0
local totalMembers = 0

local menuFrame = CreateFrame("Frame", "GuildDatatTextRightClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{text = OPTIONS_MENU, isTitle = true, notCheckable = true},
	{text = INVITE, hasArrow = true, notCheckable = true, keepShownOnClick = true, noClickSound = true, menuList = {}},
	{text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true, keepShownOnClick = true, noClickSound = true, menuList = {}}
}

local function inviteClick(_, playerName)
	menuFrame:Hide()
	InviteUnit(playerName)
end

local function whisperClick(_, playerName)
	menuFrame:Hide()
	SetItemRef("player:"..playerName, format("|Hplayer:%1$s|h[%1$s]|h", playerName), "LeftButton")
end

local function sortByRank(a, b)
	if a and b then
		return a[10] < b[10]
	end
end

local function sortByName(a, b)
	if a and b then
		return a[1] < b[1]
	end
end

local function SortDataTable(shiftKeyDown)
	if currentSortMode == shiftKeyDown and not dataUpdated then return end

	if shiftKeyDown then
		sort(dataTable, sortByRank)
	else
		sort(dataTable, sortByName)
	end

	currentSortMode = shiftKeyDown
	dataUpdated = nil
end

local function BuildDataTable()
	wipe(dataTable)

	totalMembers = GetNumGuildMembers()
	totalOnline = 0

	local _, name, rank, rankIndex, level, zone, note, officernote, connected, status, englishClass

	for i = 1, totalMembers do
		name, rank, rankIndex, level, _, zone, note, officernote, connected, status, englishClass = GetGuildRosterInfo(i)
		if not name then break end

		if connected then
			totalOnline = totalOnline + 1
			dataTable[#dataTable + 1] = {name, rank, level, zone, note, officernote, connected, onlineStatus[status], englishClass, rankIndex}
		end
	end

	dataUpdated = true
end

local function OnClick(_, btn)
	if btn == "RightButton" and IsInGuild() then
		if totalOnline <= 1 then return end

		DT.tooltip:Hide()

		wipe(menuList[2].menuList)
		wipe(menuList[3].menuList)

		local menuCountWhispers, menuCountInvites = 0, 0
		local classc, levelc, info, grouped

		for i = 1, #dataTable do
			info = dataTable[i]

			if info[7] and info[1] ~= E.myname then
				classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[9]]
				levelc = GetQuestDifficultyColor(info[3])

				if UnitInParty(info[1]) or UnitInRaid(info[1]) then
					grouped = inGroupStamp
				else
					grouped = ""

					menuCountInvites = menuCountInvites + 1
					menuList[2].menuList[menuCountInvites] = {
						text = format(levelNameFormat, levelc.r*255,levelc.g*255,levelc.b*255, info[3], classc.r*255,classc.g*255,classc.b*255, info[1], grouped),
						arg1 = info[1],
						notCheckable = true,
						func = inviteClick
					}
				end

				menuCountWhispers = menuCountWhispers + 1
				menuList[3].menuList[menuCountWhispers] = {
					text = format(levelNameFormat, levelc.r*255,levelc.g*255,levelc.b*255, info[3], classc.r*255,classc.g*255,classc.b*255, info[1], grouped),
					arg1 = info[1],
					notCheckable = true,
					func = whisperClick
				}
			end
		end

		menuList[2].disabled = menuCountInvites == 0
		menuList[3].disabled = menuCountWhispers == 0

		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	else
		ToggleFriendsFrame(3)
	end
end

local function OnEnter(self, _, noUpdate)
	if not IsInGuild() then return end

	DT:SetupTooltip(self)

	if totalOnline == 0 then
		BuildDataTable()
	end

	local guildName, guildRank = GetGuildInfo("player")

	local playerZone = GetRealZoneText()
	local shiftKeyDown = IsShiftKeyDown()
	local zonec, classc, levelc, info, grouped
	local shown = 0

	if totalOnline > 1 then
		SortDataTable(shiftKeyDown)
	end

	if guildName and guildRank then
		DT.tooltip:AddDoubleLine(
			guildName,
			format(onlineInfoFormat, totalOnline, totalMembers),
			tthead.r, tthead.g, tthead.b,
			tthead.r, tthead.g, tthead.b
		)
		DT.tooltip:AddLine(guildRank, tthead.r,tthead.g,tthead.b)
	end

	if guildMotD ~= "" then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddLine(format(guildMotDFormat, GUILD_MOTD, guildMotD), ttsubh.r, ttsubh.g, ttsubh.b, 1)
	end

	DT.tooltip:AddLine(" ")

	for i = 1, #dataTable do
		info = dataTable[i]

		if playerZone == info[4] then
			zonec = activezone
		else
			zonec = inactivezone
		end

		classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[9]]

		if shiftKeyDown then
			DT.tooltip:AddDoubleLine(
				format(nameRankFormat, info[1], info[2]),
				info[4],
				classc.r, classc.g, classc.b,
				zonec.r, zonec.g, zonec.b
			)

			if info[5] ~= "" then
				DT.tooltip:AddLine(format(noteFormat, info[5]), ttsubh.r, ttsubh.g, ttsubh.b, 1)
			end

			if info[6] ~= "" then
				DT.tooltip:AddLine(format(officerNoteFormat, info[6]), ttoff.r, ttoff.g, ttoff.b, 1)
			end
		else
			levelc = GetQuestDifficultyColor(info[3])

			if UnitInParty(info[1]) or UnitInRaid(info[1]) then
				grouped = inGroupStamp
			else
				grouped = ""
			end

			DT.tooltip:AddDoubleLine(
				format(levelNameStatusFormat, levelc.r*255, levelc.g*255, levelc.b*255, info[3], info[1], grouped, info[8]),
				info[4],
				classc.r, classc.g, classc.b,
				zonec.r, zonec.g, zonec.b
			)
		end

		shown = shown + 1

		if shown == 30 then
			if totalOnline > 30 then
				DT.tooltip:AddLine(format(moreMembersOnlineFormat, totalOnline - 30), ttsubh.r, ttsubh.g, ttsubh.b)
			end
			break
		end
	end

	DT.tooltip:Show()

	if not noUpdate then
		GuildRoster()
	end
end

local eventHandlers = {
	["ELVUI_FORCE_RUN"] = function(self)
		guildMotD = GetGuildRosterMOTD()
		GuildRoster()
	end,
	["GUILD_MOTD"] = function(_, message)
		guildMotD = message
	end,
	["CHAT_MSG_SYSTEM"] = function(_, message)
		if rosterDelay then return end

		if find(message, friendOnlineString) or find(message, friendOfflineString) then
			rosterDelay = E:Delay(10, function()
				GuildRoster()
				rosterDelay = nil
			end)
		end
	end,
	["GUILD_ROSTER_UPDATE"] = function(self)
		GuildRoster()
		BuildDataTable()

		if GetMouseFocus() == self then
			self:GetScript("OnEnter")(self, nil, true)
		end
	end,
	["PLAYER_GUILD_UPDATE"] = GuildRoster,
	["ELVUI_COLOR_UPDATE"] = E.noop,
}

local function OnEvent(self, event, ...)
	lastPanel = self

	if IsInGuild() then
		eventHandlers[event](self, ...)

		self.text:SetFormattedText(displayString, totalOnline)
	else
		self.text:SetText(noGuildString)
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", GUILD, ": ", hex, "%d|r")
	noGuildString = join("", hex, L["No Guild"])

	if lastPanel ~= nil then
		OnEvent(lastPanel, "ELVUI_COLOR_UPDATE")
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Guild", {"CHAT_MSG_SYSTEM", "GUILD_ROSTER_UPDATE", "PLAYER_GUILD_UPDATE", "GUILD_MOTD"}, OnEvent, nil, OnClick, OnEnter, nil, GUILD)