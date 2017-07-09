local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local type, pairs, select = type, pairs, select;
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
local AFK = AFK;
local DND = DND;
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE;
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;
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

local function inviteClick(self, name)
	menuFrame:Hide();

	if(type(name) ~= "number") then
		InviteUnit(name);
	end
end

local function whisperClick(self, name)
	menuFrame:Hide();

	SetItemRef("player:" .. name, ("|Hplayer:%1$s|h[%1$s]|h"):format(name), "LeftButton");
end

local lastPanel;
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r";
local levelNameClassString = "|cff%02x%02x%02x%d|r %s%s%s";
local worldOfWarcraftString = WORLD_OF_WARCRAFT;
local totalOnlineString = join("", FRIENDS_LIST_ONLINE, ": %s/%s");
local tthead = {r = 0.4, g = 0.78, b = 1};
local activezone, inactivezone = {r = 0.3, g = 1.0, b = 0.3}, {r = 0.65, g = 0.65, b = 0.65};
local displayString = "";
local groupedTable = {"|cffaaaaaa*|r", ""};
local friendTable = {};
local friendOnline, friendOffline = gsub(ERR_FRIEND_ONLINE_SS, "\124Hplayer:%%s\124h%[%%s%]\124h", ""), gsub(ERR_FRIEND_OFFLINE_S, "%%s", "");
local dataValid = false;

local function SortAlphabeticName(a, b)
	if(a[1] and b[1]) then
		return a[1] < b[1];
	end
end

local function BuildFriendTable(total)
	wipe(friendTable);
	local name, level, class, area, connected, status, note;
	for i = 1, total do
		name, level, class, area, connected, status, note = GetFriendInfo(i);

		if(status == "<" .. AFK .. ">") then
			status = "|cffFFFFFF[|r|cffFF0000" .. L["AFK"] .. "|r|cffFFFFFF]|r";
		elseif status == "<" .. DND .. ">" then
			status = "|cffFFFFFF[|r|cffFF0000" .. L["DND"] .. "|r|cffFFFFFF]|r";
		end

		if(connected) then
			for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if(class == v) then class = k; end end
			for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if(class == v) then class = k; end end
			friendTable[i] = {name, level, class, area, connected, status, note};
		end
	end
	sort(friendTable, SortAlphabeticName);
end

local function OnEvent(self, event, ...)
	local _, onlineFriends = GetNumFriends();

	if(event == "CHAT_MSG_SYSTEM") then
		local message = select(1, ...);
		if not (find(message, friendOnline) or find(message, friendOffline)) then return; end
	end
	dataValid = false;

	self.text:SetFormattedText(displayString, L["Friends"], onlineFriends);

	lastPanel = self;
end

local function OnClick(self, btn)
	DT.tooltip:Hide();

	if(btn == "RightButton") then
		local menuCountWhispers = 0;
		local menuCountInvites = 0;
		local classc, levelc, info;

		menuList[2].menuList = {};
		menuList[3].menuList = {};

		if(#friendTable > 0) then
			for i = 1, #friendTable do
				info = friendTable[i];
				if (info[5]) then
					menuCountInvites = menuCountInvites + 1;
					menuCountWhispers = menuCountWhispers + 1;

					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2]);
					classc = classc or GetQuestDifficultyColor(info[2]);

					menuList[2].menuList[menuCountInvites] = {text = format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, info[2],classc.r*255,classc.g*255,classc.b*255, info[1]), arg1 = info[1], notCheckable = true, func = inviteClick};
					menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, info[2],classc.r*255,classc.g*255,classc.b*255, info[1]), arg1 = info[1], notCheckable = true, func = whisperClick};
				end
			end
		end
		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2);
	else
		ToggleFriendsFrame(1);
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self);

	local numberOfFriends, onlineFriends = GetNumFriends();
	if(onlineFriends == 0) then return; end

	if(not dataValid) then
		if(numberOfFriends > 0) then BuildFriendTable(numberOfFriends); end
		dataValid = true;
	end

	local zonec, classc, levelc, info, grouped;
	DT.tooltip:AddDoubleLine(L["Friends List"], format(totalOnlineString, onlineFriends, numberOfFriends), tthead.r, tthead.g, tthead.b, tthead.r, tthead.g, tthead.b);
	if(onlineFriends > 0) then
		DT.tooltip:AddLine(" ");
		DT.tooltip:AddLine(worldOfWarcraftString);
		for i = 1, #friendTable do
			info = friendTable[i];
			if(info[5]) then
				if(GetRealZoneText() == info[4]) then zonec = activezone; else zonec = inactivezone; end
				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2]);

				classc = classc or GetQuestDifficultyColor(info[2]);

				if UnitInParty(info[1]) or UnitInRaid(info[1]) then grouped = 1; else grouped = 2; end
				DT.tooltip:AddDoubleLine(format(levelNameClassString, levelc.r*255,levelc.g*255,levelc.b*255, info[2], info[1], groupedTable[grouped], " " .. info[6]), info[4], classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b);
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

DT:RegisterDatatext("Friends", {"PLAYER_ENTERING_WORLD", "FRIENDLIST_UPDATE", "CHAT_MSG_SYSTEM"}, OnEvent, nil, OnClick, OnEnter, nil, L["Friends"])