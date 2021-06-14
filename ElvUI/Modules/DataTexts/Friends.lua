local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local next = next
local find, format, join = string.find, string.format, string.join
local sort, wipe = table.sort, table.wipe
--WoW API / Variables
local EasyMenu = EasyMenu
local GetFriendInfo = GetFriendInfo
local GetMouseFocus = GetMouseFocus
local GetNumFriends = GetNumFriends
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealZoneText = GetRealZoneText
local InviteUnit = InviteUnit
local SendChatMessage = SendChatMessage
local SetItemRef = SetItemRef
local ToggleFriendsFrame = ToggleFriendsFrame
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local AFK = AFK
local DND = DND
local FRIENDS = FRIENDS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local tthead = {r=0.4, g=0.78, b=1}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}

local levelNameFormat = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s"
local levelNameStatusFormat = "|cff%02x%02x%02x%d|r %s%s %s"
local onlineInfoFormat = join("", FRIENDS_LIST_ONLINE, ": %s/%s")

local afkStatusString = format("<%s>", AFK)
local dndStatusString = format("<%s>", DND)

local inGroupStamp = "|cffaaaaaa*|r"
local friendOnlineString = string.gsub(ERR_FRIEND_ONLINE_SS, ".+|h", "")
local friendOfflineString = string.gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")

local onlineStatusString = "|cffFFFFFF[|r|cff%s%s|r|cffFFFFFF]|r"
local onlineStatus = {
	[""] = "",
	[afkStatusString] = format(onlineStatusString, "FF9900", L["AFK"]),
	[dndStatusString] = format(onlineStatusString, "FF3333", L["DND"]),
}

local displayString = ""
local lastPanel

local dataTable = {}
local dataUpdated

local menuFrame = CreateFrame("Frame", "FriendDatatextRightClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{text = OPTIONS_MENU, isTitle = true, notCheckable = true},
	{text = INVITE, hasArrow = true, notCheckable = true, keepShownOnClick = true, noClickSound = true, menuList = {}},
	{text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true, keepShownOnClick = true, noClickSound = true, menuList = {}},
	{text = PLAYER_STATUS, hasArrow = true, notCheckable = true, keepShownOnClick = true, noClickSound = true,
		menuList = {
			{
				text = format("|cff2BC226%s|r", AVAILABLE),
				notCheckable = true,
				func = function()
					if UnitIsAFK("player") then
						SendChatMessage("", "AFK")
					elseif UnitIsDND("player") then
						SendChatMessage("", "DND")
					end
				end
			},
			{
				text = format("|cffE7E716%s|r", DND),
				notCheckable = true,
				func = function()
					if not UnitIsDND("player") then
						SendChatMessage("", "DND")
					end
				end
			},
			{
				text = format("|cffFF0000%s|r", AFK),
				notCheckable = true,
				func = function()
					if not UnitIsAFK("player") then
						SendChatMessage("", "AFK")
					end
				end
			}
		}
	}
}

local function inviteClick(_, playerName)
	menuFrame:Hide()
	InviteUnit(playerName)
end

local function whisperClick(_, playerName)
	menuFrame:Hide()
	SetItemRef("player:"..playerName, format("|Hplayer:%1$s|h[%1$s]|h", playerName), "LeftButton")
end

local function sortByName(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
end

local function BuildDataTable(total)
	wipe(dataTable)

	if total == 0 then return end

	local name, level, class, area, connected, status, note, className

	for i = 1, total do
		name, level, class, area, connected, status, note = GetFriendInfo(i)

		if connected then
			className = E:UnlocalizedClassName(class) or ""
			status = onlineStatus[status] or ""

			dataTable[i] = {name, level, className, area, connected, status, note}
		end
	end

	if next(dataTable) then
		sort(dataTable, sortByName)
	end
end

local function OnClick(_, btn)
	if btn == "RightButton" then
		DT.tooltip:Hide()

		wipe(menuList[2].menuList)
		wipe(menuList[3].menuList)

		local menuCountWhispers, menuCountInvites = 0, 0
		local classc, levelc, info, grouped, shouldSkip

		local db = E.db.datatexts.friends

		for i = 1, #dataTable do
			info = dataTable[i]

			if info[5] then
				if (info[6] == onlineStatus[afkStatusString]) and db.hideAFK then
					shouldSkip = true
				elseif (info[6] == onlineStatus[dndStatusString]) and db.hideDND then
					shouldSkip = true
				else
					shouldSkip = nil
				end

				if not shouldSkip then
					classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]]
					classc = classc or GetQuestDifficultyColor(info[2])
					levelc = GetQuestDifficultyColor(info[2])

					if UnitInParty(info[1]) or UnitInRaid(info[1]) then
						grouped = inGroupStamp
					else
						grouped = ""

						menuCountInvites = menuCountInvites + 1
						menuList[2].menuList[menuCountInvites] = {
							text = format(levelNameFormat, levelc.r*255, levelc.g*255, levelc.b*255, info[2], classc.r*255, classc.g*255, classc.b*255, info[1], grouped),
							arg1 = info[1],
							notCheckable = true,
							func = inviteClick
						}
					end

					menuCountWhispers = menuCountWhispers + 1
					menuList[3].menuList[menuCountWhispers] = {
						text = format(levelNameFormat, levelc.r*255, levelc.g*255, levelc.b*255, info[2], classc.r*255, classc.g*255, classc.b*255, info[1], grouped),
						arg1 = info[1],
						notCheckable = true,
						func = whisperClick
					}
				end
			end
		end

		menuList[2].disabled = menuCountInvites == 0
		menuList[3].disabled = menuCountWhispers == 0

		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	else
		ToggleFriendsFrame(1)
	end
end

local function OnEnter(self)
	local numberOfFriends, onlineFriends = GetNumFriends()
	if onlineFriends == 0 then return end

	DT:SetupTooltip(self)

	if not dataUpdated then
		if numberOfFriends > 0 then
			BuildDataTable(numberOfFriends)
		end

		dataUpdated = true
	end

	DT.tooltip:AddDoubleLine(
		L["Friends List"],
		format(onlineInfoFormat, onlineFriends, numberOfFriends),
		tthead.r, tthead.g, tthead.b,
		tthead.r, tthead.g, tthead.b
	)

	local playerZone = GetRealZoneText()
	local db = E.db.datatexts.friends
	local zonec, classc, levelc, info, grouped, shouldSkip

	for i = 1, #dataTable do
		info = dataTable[i]

		if info[5] then
			if (info[6] == onlineStatus[afkStatusString]) and db.hideAFK then
				shouldSkip = true
			elseif (info[6] == onlineStatus[dndStatusString]) and db.hideDND then
				shouldSkip = true
			else
				shouldSkip = nil
			end

			if not shouldSkip then
				if playerZone == info[4] then
					zonec = activezone
				else
					zonec = inactivezone
				end

				classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]]
				classc = classc or GetQuestDifficultyColor(info[2])
				levelc = GetQuestDifficultyColor(info[2])

				if UnitInParty(info[1]) or UnitInRaid(info[1]) then
					grouped = inGroupStamp
				else
					grouped = ""
				end

				DT.tooltip:AddDoubleLine(
					format(levelNameStatusFormat, levelc.r*255, levelc.g*255, levelc.b*255, info[2], info[1], grouped, info[6]),
					info[4],
					classc.r, classc.g, classc.b,
					zonec.r, zonec.g, zonec.b
				)
			end
		end
	end

	DT.tooltip:Show()
end

local function OnEvent(self, event, message)
	lastPanel = self

	-- special handler to detect friend coming online or going offline
	if event == "CHAT_MSG_SYSTEM" and not (find(message, friendOnlineString) or find(message, friendOfflineString)) then
		return
	end

	local _, onlineFriends = GetNumFriends()

	self.text:SetFormattedText(displayString, onlineFriends)

	-- force update when showing tooltip
	dataUpdated = nil

	if GetMouseFocus() == self then
		self:GetScript("OnEnter")(self)
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", FRIENDS, ": ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel, "ELVUI_COLOR_UPDATE")
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Friends", {"PLAYER_ENTERING_WORLD", "CHAT_MSG_SYSTEM", "FRIENDLIST_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, FRIENDS)