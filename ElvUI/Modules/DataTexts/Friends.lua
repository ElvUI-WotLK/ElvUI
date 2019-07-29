local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts");

local type, pairs, select, next = type, pairs, select, next
local sort, wipe = table.sort, wipe;
local format, find, join, gsub = string.format, string.find, string.join, string.gsub;

local UnitIsAFK = UnitIsAFK;
local UnitIsDND = UnitIsDND;
local SendChatMessage = SendChatMessage;
local InviteUnit = InviteUnit;
local SetItemRef = SetItemRef;
local GetFriendInfo = GetFriendInfo;
local GetNumFriends = GetNumFriends;
local GetQuestDifficultyColor = GetQuestDifficultyColor;
local UnitInParty = UnitInParty;
local UnitInRaid = UnitInRaid;
local ToggleFriendsFrame = ToggleFriendsFrame;
local EasyMenu = EasyMenu;
local FRIENDS = FRIENDS
local AFK = AFK;
local DND = DND;
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE;
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;

local menuFrame = CreateFrame("Frame", "FriendDatatextRightClickMenu", E.UIParent, "UIDropDownMenuTemplate");
local menuList = {
	{text = OPTIONS_MENU, isTitle = true, notCheckable = true},
	{text = INVITE, hasArrow = true, notCheckable = true},
	{text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable= true},
	{text = PLAYER_STATUS, hasArrow = true, notCheckable = true,
		menuList = {
			{text = "|cff2BC226" .. AVAILABLE .. "|r", notCheckable = true, func = function() if(UnitIsAFK("player")) then SendChatMessage("", "AFK") elseif(UnitIsDND("player")) then SendChatMessage("", "DND"); end end},
			{text = "|cffE7E716" .. AFK .. "|r", notCheckable = true, func = function() if(not UnitIsAFK("player")) then SendChatMessage("", "AFK"); end end},
			{text = "|cffFF0000" .. DND .. "|r", notCheckable = true, func = function() if(not UnitIsDND("player")) then SendChatMessage("", "DND"); end end}
		}
	}
};

local function inviteClick(_, name)
	menuFrame:Hide();

	if(type(name) ~= "number") then
		InviteUnit(name);
	end
end

local function whisperClick(_, name)
	menuFrame:Hide();

	SetItemRef("player:"..name, format("|Hplayer:%1$s|h[%1$s]|h",name), "LeftButton")
end

local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r";
local levelNameClassString = "|cff%02x%02x%02x%d|r %s%s%s";
local totalOnlineString = join("", FRIENDS_LIST_ONLINE, ": %s/%s");
local tthead = {r = 0.4, g = 0.78, b = 1};
local activezone, inactivezone = {r = 0.3, g = 1.0, b = 0.3}, {r = 0.65, g = 0.65, b = 0.65};
local displayString = "";
local statusTable = {" |cffFFFFFF[|r|cffFF9900"..L["AFK"].."|r|cffFFFFFF]|r", " |cffFFFFFF[|r|cffFF3333"..L["DND"].."|r|cffFFFFFF]|r", ""}
local groupedTable = {"|cffaaaaaa*|r", ""};
local friendTable = {};
local friendOnline, friendOffline = gsub(ERR_FRIEND_ONLINE_SS, "\124Hplayer:%%s\124h%[%%s%]\124h", ""), gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")
local dataValid = false;
local lastPanel;

local function SortAlphabeticName(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
end

local function BuildFriendTable(total)
	wipe(friendTable)
	local name, level, class, area, connected, status, note
	for i = 1, total do
		name, level, class, area, connected, status, note = GetFriendInfo(i)

		if status == "<"..AFK..">" then
			status = statusTable[1]
		elseif status == "<"..DND..">" then
			status = statusTable[2]
		else
			status = statusTable[3]
		end

		if connected then
			--other non-english locales require this
			for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
			for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end

			friendTable[i] = {name, level, class, area, connected, status, note}
		end
	end
	if next(friendTable) then
		sort(friendTable, SortAlphabeticName)
	end
end

local function OnEvent(self, event, ...)
	local _, onlineFriends = GetNumFriends();

	-- special handler to detect friend coming online or going offline
	-- when this is the case, we invalidate our buffered table and update the
	-- datatext information
	if(event == "CHAT_MSG_SYSTEM") then
		local message = select(1, ...);
		if not (find(message, friendOnline) or find(message, friendOffline)) then return; end
	end

	-- force update when showing tooltip
	dataValid = false;

	self.text:SetFormattedText(displayString, FRIENDS, onlineFriends);

	lastPanel = self;
end

local function OnClick(_, btn)
	DT.tooltip:Hide();

	if btn == "RightButton" then
		local menuCountWhispers = 0
		local menuCountInvites = 0
		local classc, levelc, info, shouldSkip

		menuList[2].menuList = {};
		menuList[3].menuList = {};

		if #friendTable > 0 then
			for i = 1, #friendTable do
				info = friendTable[i]
				if info[5] then
					shouldSkip = false
					if (info[6] == statusTable[1]) and E.db.datatexts.friends["hideAFK"] then
						shouldSkip = true
					elseif (info[6] == statusTable[2]) and E.db.datatexts.friends["hideDND"] then
						shouldSkip = true
					end
					if not shouldSkip then
						classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
						classc = classc or GetQuestDifficultyColor(info[2])

						menuCountWhispers = menuCountWhispers + 1
						menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString, levelc.r*255, levelc.g*255, levelc.b*255, info[2], classc.r*255, classc.g*255, classc.b*255, info[1]), arg1 = info[1], notCheckable=true, func = whisperClick}
						if not (UnitInParty(info[1]) or UnitInRaid(info[1])) then
							menuCountInvites = menuCountInvites + 1
							menuList[2].menuList[menuCountInvites] = {text = format(levelNameString, levelc.r*255, levelc.g*255, levelc.b*255, info[2], classc.r*255, classc.g*255, classc.b*255, info[1]), arg1 = info[1], notCheckable=true, func = inviteClick}
						end
					end
				end
			end
		end

		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	else
		ToggleFriendsFrame(1)
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self);

	local numberOfFriends, onlineFriends = GetNumFriends();

	-- no friends online, quick exit
	if onlineFriends == 0 then return end

	if not dataValid then
		-- only retrieve information for all on-line members when we actually view the tooltip
		if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
		dataValid = true
	end

	local zonec, classc, levelc, info, grouped, shouldSkip
	DT.tooltip:AddDoubleLine(L["Friends List"], format(totalOnlineString, onlineFriends, numberOfFriends), tthead.r, tthead.g, tthead.b, tthead.r, tthead.g, tthead.b);
	if onlineFriends > 0 then
		for i = 1, #friendTable do
			info = friendTable[i]
			if info[5] then
				shouldSkip = false
				if (info[6] == statusTable[1]) and E.db.datatexts.friends["hideAFK"] then
					shouldSkip = true
				elseif (info[6] == statusTable[2]) and E.db.datatexts.friends["hideDND"] then
					shouldSkip = true
				end
				if not shouldSkip then
					if GetRealZoneText() == info[4] then zonec = activezone else zonec = inactivezone end
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])

					classc = classc or GetQuestDifficultyColor(info[2])

					if UnitInParty(info[1]) or UnitInRaid(info[1]) then grouped = 1; else grouped = 2; end
					DT.tooltip:AddDoubleLine(format(levelNameClassString, levelc.r*255,levelc.g*255,levelc.b*255, info[2], info[1], groupedTable[grouped], " " .. info[6]), info[4], classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b);
				end
			end
		end
	end

	DT.tooltip:Show();
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d|r");

	if(lastPanel ~= nil) then
		OnEvent(lastPanel, "ELVUI_COLOR_UPDATE");
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Friends", {"PLAYER_ENTERING_WORLD", "FRIENDLIST_UPDATE", "CHAT_MSG_SYSTEM"}, OnEvent, nil, OnClick, OnEnter, nil, FRIENDS)