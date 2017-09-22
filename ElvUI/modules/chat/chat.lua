local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CH = E:NewModule("Chat", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0");

local _G = _G;
local time, difftime = time, difftime;
local pairs, unpack, select, tostring, pcall, next, tonumber, type, assert = pairs, unpack, select, tostring, pcall, next, tonumber, type, assert;
local tinsert, tremove, tsort, twipe, tconcat = table.insert, table.remove, table.sort, table.wipe, table.concat;
local random = math.random;
local len, gsub, find, sub, gmatch, format, split = string.len, string.gsub, string.find, string.sub, string.gmatch, string.format, string.split;
local strlower, strsub, strlen, strupper = strlower, strsub, strlen, strupper;

local hooksecurefunc = hooksecurefunc;
local CreateFrame = CreateFrame;
local GetTime = GetTime;
local UnitName = UnitName;
local IsShiftKeyDown = IsShiftKeyDown;
local InCombatLockdown = InCombatLockdown;
local ChatFrame_SendTell = ChatFrame_SendTell;
local GetChannelName = GetChannelName;
local ToggleFrame = ToggleFrame;
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo;
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize;
local GetMouseFocus = GetMouseFocus;
local GetChatWindowSavedPosition = GetChatWindowSavedPosition;
local IsMouseButtonDown = IsMouseButtonDown;
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions;
local PlaySoundFile = PlaySoundFile;
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend;
local ChatEdit_ActivateChat = ChatEdit_ActivateChat;
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel;
local BetterDate = BetterDate;
local GetPlayerInfoByGUID = GetPlayerInfoByGUID;
local StaticPopup_Visible = StaticPopup_Visible;
local Chat_GetChatCategory = Chat_GetChatCategory;
local FCFManager_ShouldSuppressMessage = FCFManager_ShouldSuppressMessage;
local ChatHistory_GetAccessID = ChatHistory_GetAccessID;
local GMChatFrame_IsGM = GMChatFrame_IsGM
local ChatEdit_SetLastTellTarget = ChatEdit_SetLastTellTarget;
local PlaySound = PlaySound;
local FCF_StartAlertFlash = FCF_StartAlertFlash;
local ChatFrame_ConfigEventHandler = ChatFrame_ConfigEventHandler;
local ChatFrame_SystemEventHandler = ChatFrame_SystemEventHandler;
local FloatingChatFrame_OnEvent = FloatingChatFrame_OnEvent;
local FCFTab_UpdateAlpha = FCFTab_UpdateAlpha;
local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame;
local GetGuildRosterMOTD = GetGuildRosterMOTD;
local ScrollFrameTemplate_OnMouseWheel = ScrollFrameTemplate_OnMouseWheel;
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS;

local GlobalStrings = {
	["AFK"] = AFK,
	["CHAT_FILTERED"] = CHAT_FILTERED,
	["CHAT_IGNORED"] = CHAT_IGNORED,
	["CHAT_RESTRICTED"] = CHAT_RESTRICTED,
	["CHAT_TELL_ALERT_TIME"] = CHAT_TELL_ALERT_TIME,
	["DND"] = DND,
	["MAX_WOW_CHAT_CHANNELS"] = MAX_WOW_CHAT_CHANNELS,
	["RAID_WARNING"] = RAID_WARNING
};

local CreatedFrames = 0;
local lines = {};
local msgList, msgCount, msgTime = {}, {}, {}
local chatFilters = {};

local PLAYER_REALM = gsub(E.myrealm,"[%s%-]","")

local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;

local DEFAULT_STRINGS = {
	BATTLEGROUND = L["BG"],
	GUILD = L["G"],
	PARTY = L["P"],
	RAID = L["R"],
	OFFICER = L["O"],
	BATTLEGROUND_LEADER = L["BGL"],
	PARTY_LEADER = L["PL"],
	RAID_LEADER = L["RL"],
}

local hyperlinkTypes = {
	["item"] = true,
	["spell"] = true,
	["unit"] = true,
	["quest"] = true,
	["enchant"] = true,
	["achievement"] = true,
	["instancelock"] = true,
	["talent"] = true,
	["glyph"] = true,
}

local tabTexs = {
	"",
	"Selected",
	"Highlight"
}

local smileyPack = {
	["Angry"] = [[Interface\AddOns\ElvUI\media\textures\smileys\angry.blp]],
	["Grin"] = [[Interface\AddOns\ElvUI\media\textures\smileys\grin.blp]],
	["Hmm"] = [[Interface\AddOns\ElvUI\media\textures\smileys\hmm.blp]],
	["MiddleFinger"] = [[Interface\AddOns\ElvUI\media\textures\smileys\middle_finger.blp]],
	["Sad"] = [[Interface\AddOns\ElvUI\media\textures\smileys\sad.blp]],
	["Surprise"] = [[Interface\AddOns\ElvUI\media\textures\smileys\surprise.blp]],
	["Tongue"] = [[Interface\AddOns\ElvUI\media\textures\smileys\tongue.blp]],
	["Cry"] = [[Interface\AddOns\ElvUI\media\textures\smileys\weepy.blp]],
	["Wink"] = [[Interface\AddOns\ElvUI\media\textures\smileys\winky.blp]],
	["Happy"] = [[Interface\AddOns\ElvUI\media\textures\smileys\happy.blp]],
	["Heart"] = [[Interface\AddOns\ElvUI\media\textures\smileys\heart.blp]],
	["BrokenHeart"] = [[Interface\AddOns\ElvUI\media\textures\smileys\broken_heart.blp]],
}

local smileyKeys = {
	["%:%-%@"] = "Angry",
	["%:%@"] = "Angry",
	["%:%-%)"]="Happy",
	["%:%)"]="Happy",
	["%:D"]="Grin",
	["%:%-D"]="Grin",
	["%;%-D"]="Grin",
	["%;D"]="Grin",
	["%=D"]="Grin",
	["xD"]="Grin",
	["XD"]="Grin",
	["%:%-%("]="Sad",
	["%:%("]="Sad",
	["%:o"]="Surprise",
	["%:%-o"]="Surprise",
	["%:%-O"]="Surprise",
	["%:O"]="Surprise",
	["%:%-0"]="Surprise",
	["%:P"]="Tongue",
	["%:%-P"]="Tongue",
	["%:p"]="Tongue",
	["%:%-p"]="Tongue",
	["%=P"]="Tongue",
	["%=p"]="Tongue",
	["%;%-p"]="Tongue",
	["%;p"]="Tongue",
	["%;P"]="Tongue",
	["%;%-P"]="Tongue",
	["%;%-%)"]="Wink",
	["%;%)"]="Wink",
	["%:S"]="Hmm",
	["%:%-S"]="Hmm",
	["%:%,%("]="Cry",
	["%:%,%-%("]="Cry",
	["%:%'%("]="Cry",
	["%:%'%-%("]="Cry",
	["%:%F"]="MiddleFinger",
	["<3"]="Heart",
	["</3"]="BrokenHeart",
};

local specialChatIcons = {
	["WoW Circle 3.3.5a x10"] = {
		["Крольченок"] = "|TInterface\\AddOns\\ElvUI\\media\\textures\\ElvUI_Chat_Logo:13:22|t",
		["Неумеряющый"] = "|TInterface\\AddOns\\ElvUI\\media\\textures\\ElvUI_Chat_Logo:13:22|t"
	}
}

CH.Keywords = {};
CH.ClassNames = {};

local numScrollMessages
local function ChatFrame_OnMouseScroll(frame, delta)
	numScrollMessages = CH.db.numScrollMessages or 3
	if delta < 0 then
		if IsShiftKeyDown() then
			frame:ScrollToBottom()
		else
			for i = 1, numScrollMessages do
				frame:ScrollDown()
			end
		end
	elseif delta > 0 then
		if IsShiftKeyDown() then
			frame:ScrollToTop()
		else
			for i = 1, numScrollMessages do
				frame:ScrollUp()
			end
		end

		if CH.db.scrollDownInterval ~= 0 then
			if frame.ScrollTimer then
				CH:CancelTimer(frame.ScrollTimer, true)
			end

			frame.ScrollTimer = CH:ScheduleTimer("ScrollToBottom", CH.db.scrollDownInterval, frame)
		end
	end
end

function CH:GetGroupDistribution()
	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp") then
		return "/bg "
	end
	if GetNumRaidMembers() > 0 then
		return "/ra "
	end
	if GetNumPartyMembers() > 0 then
		return "/p "
	end
	return "/s "
end

function CH:InsertEmotions(msg)
	for k,v in pairs(smileyKeys) do
		msg = gsub(msg,k,"|T"..smileyPack[v]..":16|t");
	end
	return msg;
end

function CH:GetSmileyReplacementText(msg)
	if not msg then return end
	if not self.db.emotionIcons or msg:find("/run") or msg:find("/dump") or msg:find("/script") then return msg end
	local outstr = "";
	local origlen = len(msg);
	local startpos = 1;
	local endpos;

	while(startpos <= origlen) do
		endpos = origlen;
		local pos = find(msg,"|H",startpos,true);
		if(pos ~= nil) then
			endpos = pos;
		end
		outstr = outstr .. CH:InsertEmotions(sub(msg,startpos,endpos)); --run replacement on this bit
		startpos = endpos + 1;
		if(pos ~= nil) then
			endpos = find(msg,"|h]|r",startpos,-1) or find(msg,"|h",startpos,-1);
			endpos = endpos or origlen;
			if(startpos < endpos) then
				outstr = outstr .. sub(msg,startpos,endpos); --don't run replacement on this bit
				startpos = endpos + 1;
			end
		end
	end

	return outstr;
end

function CH:StyleChat(frame)
	local name = frame:GetName()
	_G[name.."TabText"]:FontTemplate(LSM:Fetch("font", self.db.tabFont), self.db.tabFontSize, self.db.tabFontOutline)

	if frame.styled then return end

	frame:SetFrameLevel(4)

	local id = frame:GetID()

	local tab = _G[name.."Tab"]
	local editbox = _G[name.."EditBox"]
	local language = _G[name.."EditBoxLanguage"]

	for _, texName in pairs(tabTexs) do
		_G[tab:GetName()..texName.."Left"]:SetTexture(nil)
		_G[tab:GetName()..texName.."Middle"]:SetTexture(nil)
		_G[tab:GetName()..texName.."Right"]:SetTexture(nil)
	end

	hooksecurefunc(tab, "SetAlpha", function(t, alpha)
		if alpha ~= 1 and (not t.isDocked or GeneralDockManager.selected:GetID() == t:GetID()) then
			t:SetAlpha(1)
		elseif alpha < 0.6 then
			t:SetAlpha(0.6)
		end
	end)

	tab.text = _G[name.."TabText"]
	tab.text:SetTextColor(unpack(E["media"].rgbvaluecolor));
	hooksecurefunc(tab.text, "SetTextColor", function(self, r, g, b)
		local rR, gG, bB = unpack(E["media"].rgbvaluecolor)
		if r ~= rR or g ~= gG or b ~= bB then
			self:SetTextColor(rR, gG, bB)
		end
	end)

	if tab.conversationIcon then
		tab.conversationIcon:ClearAllPoints()
		tab.conversationIcon:Point("RIGHT", tab.text, "LEFT", -1, 0)
	end

	frame:SetClampRectInsets(0,0,0,0)
	frame:SetClampedToScreen(false)
	frame:StripTextures(true)
	_G[name.."ButtonFrame"]:Kill()

	local function OnTextChanged(self)
		local text = self:GetText()

		if InCombatLockdown() then
			local MIN_REPEAT_CHARACTERS = E.db.chat.numAllowedCombatRepeat
			if (len(text) > MIN_REPEAT_CHARACTERS) then
			local repeatChar = true;
			for i=1, MIN_REPEAT_CHARACTERS, 1 do
				if ( sub(text,(0-i), (0-i)) ~= sub(text,(-1-i),(-1-i)) ) then
					repeatChar = false;
					break;
				end
			end
				if ( repeatChar ) then
					self:Hide()
					return;
				end
			end
		end

		if text:len() < 5 then
			if text:sub(1, 4) == "/tt " then
				local unitname, realm = UnitName("target")
				if unitname and realm and not UnitIsSameServer("player", "target") then
					unitname = unitname .. "-" .. realm:gsub(" ", "")
				end
				ChatFrame_SendTell((unitname or L["Invalid Target"]), ChatFrame1)
			end

			if text:sub(1, 4) == "/gr " then
				self:SetText(CH:GetGroupDistribution() .. text:sub(5))
				ChatEdit_ParseText(self, 0)
			end
		end

		local new, found = gsub(text, "|Kf(%S+)|k(%S+)%s(%S+)|k", "%2 %3")
		if found > 0 then
			new = new:gsub("|", "")
			self:SetText(new)
		end
	end

	local a, b, c = select(6, editbox:GetRegions()); a:Kill(); b:Kill(); c:Kill();
	_G[format(editbox:GetName() .. "FocusLeft", id)]:Kill();
	_G[format(editbox:GetName() .. "FocusMid", id)]:Kill();
	_G[format(editbox:GetName() .. "FocusRight", id)]:Kill();
	editbox:SetTemplate("Default", true);
	editbox:SetAltArrowKeyMode(CH.db.useAltKey);
	editbox:HookScript("OnEditFocusGained", function(self) self:Show(); if(not LeftChatPanel:IsShown()) then LeftChatPanel.editboxforced = true; LeftChatToggleButton:GetScript("OnEnter")(LeftChatToggleButton); end end);
	editbox:HookScript("OnEditFocusLost", function(self) if(LeftChatPanel.editboxforced) then LeftChatPanel.editboxforced = nil; if(LeftChatPanel:IsShown()) then LeftChatToggleButton:GetScript("OnLeave")(LeftChatToggleButton); end end self:Hide(); end);
	editbox:SetAllPoints(LeftChatDataPanel);
	self:SecureHook(editbox, "AddHistoryLine", "ChatEdit_AddHistory");
	editbox:HookScript("OnTextChanged", OnTextChanged);

	editbox.historyLines = ElvCharacterDB.ChatEditHistory;
	editbox.historyIndex = 0;

	for i, text in pairs(ElvCharacterDB.ChatEditHistory) do
		editbox:AddHistoryLine(text)
	end

	hooksecurefunc("ChatEdit_UpdateHeader", function()
		local type = editbox:GetAttribute("chatType")
		if ( type == "CHANNEL" ) then
			local id = GetChannelName(editbox:GetAttribute("channelTarget"))
			if id == 0 then
				editbox:SetBackdropBorderColor(unpack(E.media.bordercolor))
			else
				editbox:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
			end
		elseif type then
			editbox:SetBackdropBorderColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
		end
	end)

	language:Height(22)
	language:StripTextures()
	language:SetTemplate("Transparent")
	language:Point("LEFT", editbox, "RIGHT", -32, 0)

	--copy chat button
	frame.button = CreateFrame("Button", format("CopyChatButton%d", id), frame)
	frame.button:EnableMouse(true)
	frame.button:SetAlpha(0.35)
	frame.button:Size(20, 22)
	frame.button:SetPoint("TOPRIGHT")
	frame.button:SetFrameLevel(frame:GetFrameLevel() + 5)

	frame.button.tex = frame.button:CreateTexture(nil, "OVERLAY")
	frame.button.tex:SetInside()
	frame.button.tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\copy.tga]])

	frame.button:SetScript("OnMouseUp", function(_, btn)
		if btn == "LeftButton" then
			CH:CopyChat(frame)
		elseif btn == "RightButton" and id ~= 2 then
			ToggleFrame(ChatMenu)
		end
	end)

	frame.button:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
	frame.button:SetScript("OnLeave", function(self)
		if _G[self:GetParent():GetName().."TabText"]:IsShown() then
			self:SetAlpha(0.35)
		else
			self:SetAlpha(0)
		end

	end)

	CreatedFrames = id
	frame.styled = true
end

function CH:UpdateSettings()
	for i = 1, CreatedFrames do
		local chat = _G[format("ChatFrame%d", i)];
		local name = chat:GetName();
		local editbox = _G[name .. "EditBox"];
		editbox:SetAltArrowKeyMode(CH.db.useAltKey);
	end
end

local function removeIconFromLine(text)
	for i = 1, 8 do
		text = gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_"..i..":0|t", "{"..strlower(_G["RAID_TARGET_"..i]).."}")
	end
	text = gsub(text, "(|TInterface(.*)|t)", "")

	return text
end

local function colorizeLine(text, r, g, b)
	local hexCode = E:RGBToHex(r, g, b)
	local hexReplacement = format("|r%s", hexCode)

	text = gsub(text, "|r", hexReplacement) -- If the message contains color strings then we need to add message color hex code after every "|r"
	text = format("%s%s|r", hexCode, text) -- Add message color

	return text
end

function CH:GetLines(...)
	local index = 1
	wipe(lines);
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			local line = tostring(region:GetText())
			local r, g, b = region:GetTextColor();

			line = removeIconFromLine(line);

			line = colorizeLine(line, r, g, b);

			lines[index] = line;
			index = index + 1;
		end
	end
	return index - 1
end

function CH:CopyChat(frame)
	if not CopyChatFrame:IsShown() then
		local _, fontSize = FCF_GetChatWindowInfo(frame:GetID());
		if fontSize < 10 then fontSize = 12 end
		FCF_SetChatWindowFontSize(frame, frame, 0.01)
		CopyChatFrame:Show()
		local lineCt = self:GetLines(frame:GetRegions())
		local text = tconcat(lines, "\n", 1, lineCt)
		FCF_SetChatWindowFontSize(frame, frame, fontSize)
		CopyChatFrameEditBox:SetText(text)
	else
		CopyChatFrame:Hide()
	end
end

function CH:OnEnter(frame)
	_G[frame:GetName().."Text"]:Show()

	if frame.conversationIcon then
		frame.conversationIcon:Show()
	end
end

function CH:OnLeave(frame)
	_G[frame:GetName().."Text"]:Hide()

	if frame.conversationIcon then
		frame.conversationIcon:Hide()
	end
end

function CH:SetupChatTabs(frame, hook)
	if hook and (not self.hooks or not self.hooks[frame] or not self.hooks[frame].OnEnter) then
		self:HookScript(frame, "OnEnter")
		self:HookScript(frame, "OnLeave")
	elseif not hook and self.hooks and self.hooks[frame] and self.hooks[frame].OnEnter then
		self:Unhook(frame, "OnEnter")
		self:Unhook(frame, "OnLeave")
	end

	if not hook then
		_G[frame:GetName().."Text"]:Show()

		if frame.owner and frame.owner.button and GetMouseFocus() ~= frame.owner.button then
			frame.owner.button:SetAlpha(0.35)
		end
		if frame.conversationIcon then
			frame.conversationIcon:Show()
		end
	elseif GetMouseFocus() ~= frame then
		_G[frame:GetName().."Text"]:Hide()

		if frame.owner and frame.owner.button and GetMouseFocus() ~= frame.owner.button then
			frame.owner.button:SetAlpha(0)
		end

		if frame.conversationIcon then
			frame.conversationIcon:Hide()
		end
	end
end

function CH:UpdateAnchors()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName .. "EditBox"];
		if(not frame) then break; end
		if(not E.db.datatexts.leftChatPanel and (self.db.panelBackdrop == "HIDEBOTH" or self.db.panelBackdrop == "RIGHT")) then
			frame:ClearAllPoints();
			if(E.db.chat.editBoxPosition == "BELOW_CHAT") then
				frame:SetPoint("TOPLEFT", ChatFrame1, "BOTTOMLEFT");
				frame:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, -LeftChatTab:GetHeight());
			else
				frame:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT");
				frame:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT", 0, LeftChatTab:GetHeight());
			end
		else
			if(E.db.datatexts.leftChatPanel and E.db.chat.editBoxPosition == "BELOW_CHAT") then
				frame:SetAllPoints(LeftChatDataPanel);
			else
				frame:SetAllPoints(LeftChatTab);
			end
		end
	end

	CH:PositionChat(true);
end

local function FindRightChatID()
	local rightChatID

	for _, frameName in pairs(CHAT_FRAMES) do
		local chat = _G[frameName]
		local id = chat:GetID()

		if(E:FramesOverlap(chat, RightChatPanel) and not E:FramesOverlap(chat, LeftChatPanel)) then
			rightChatID = id
			break
		end
	end

	return rightChatID
end

function CH:UpdateChatTabs()
	local fadeUndockedTabs = E.db["chat"].fadeUndockedTabs
	local fadeTabsNoBackdrop = E.db["chat"].fadeTabsNoBackdrop

	for i = 1, CreatedFrames do
		local chat = _G[format("ChatFrame%d", i)]
		local tab = _G[format("ChatFrame%sTab", i)]
		local id = chat:GetID()
		local point = GetChatWindowSavedPosition(id)
		local isDocked = chat.isDocked
		local chatbg = format("ChatFrame%dBackground", i);
		if id > NUM_CHAT_WINDOWS then
			point = point or select(1, chat:GetPoint());
			if select(2, tab:GetPoint()):GetName() ~= chatbg then
				isDocked = true
			else
				isDocked = false
			end
		end

		if chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and (id == self.RightChatWindowID) then
			if E.db.chat.panelBackdrop == "HIDEBOTH" or E.db.chat.panelBackdrop == "LEFT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not isDocked and chat:IsShown() then
			CH:SetupChatTabs(tab, fadeUndockedTabs and true or false)
		else
			if E.db.chat.panelBackdrop == "HIDEBOTH" or E.db.chat.panelBackdrop == "RIGHT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		end
	end
end

function CH:PositionChat(override)
	if ((InCombatLockdown() and not override and self.initialMove) or (IsMouseButtonDown("LeftButton") and not override)) then return end
	if not RightChatPanel or not LeftChatPanel then return; end
	RightChatPanel:SetSize(E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth, E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight)
	LeftChatPanel:SetSize(E.db.chat.panelWidth, E.db.chat.panelHeight)

	self.RightChatWindowID = FindRightChatID()

	if not self.db.lockPositions or E.private.chat.enable ~= true then return end

	local chat, chatbg, tab, id, point, isDocked
	local fadeUndockedTabs = E.db["chat"].fadeUndockedTabs
	local fadeTabsNoBackdrop = E.db["chat"].fadeTabsNoBackdrop

	for i=1, CreatedFrames do
		local BASE_OFFSET = 57 + E.Spacing*3;

		chat = _G[format("ChatFrame%d", i)]
		chatbg = format("ChatFrame%dBackground", i)
		id = chat:GetID()
		tab = _G[format("ChatFrame%sTab", i)]
		point = GetChatWindowSavedPosition(id)
		isDocked = chat.isDocked
		tab.isDocked = chat.isDocked
		tab.owner = chat
		if id > NUM_CHAT_WINDOWS then
			point = point or select(1, chat:GetPoint());
			if select(2, tab:GetPoint()):GetName() ~= chatbg then
				isDocked = true
			else
				isDocked = false
			end
		end

		if chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and id == self.RightChatWindowID then
			chat:ClearAllPoints()

			if E.db.datatexts.rightChatPanel then
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
			else
				BASE_OFFSET = BASE_OFFSET - 24
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "BOTTOMLEFT", 1, 1)
			end
			if id ~= 2 then
				chat:SetSize((E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth) - 11, (E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight) - BASE_OFFSET)
			else
				chat:SetSize(E.db.chat.panelWidth - 11, (E.db.chat.panelHeight - BASE_OFFSET) - CombatLogQuickButtonFrame_Custom:GetHeight())
			end

			FCF_SavePositionAndDimensions(chat, true);

			tab:SetParent(RightChatPanel)
			chat:SetParent(RightChatPanel)

			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end
			if E.db.chat.panelBackdrop == "HIDEBOTH" or E.db.chat.panelBackdrop == "LEFT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not isDocked and chat:IsShown() then
			tab:SetParent(UIParent)
			chat:SetParent(UIParent)
			CH:SetupChatTabs(tab, fadeUndockedTabs and true or false)
		else
			if id ~= 2 and not (id > NUM_CHAT_WINDOWS) then
				chat:ClearAllPoints()
				if E.db.datatexts.leftChatPanel then
					chat:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
				else
					BASE_OFFSET = BASE_OFFSET - 24
					chat:Point("BOTTOMLEFT", LeftChatToggleButton, "BOTTOMLEFT", 1, 1)
				end
				chat:SetSize(E.db.chat.panelWidth - 11, (E.db.chat.panelHeight - BASE_OFFSET))

				FCF_SavePositionAndDimensions(chat, true);
			end
			chat:SetParent(LeftChatPanel)
			if i > 2 then
				tab:SetParent(GeneralDockManagerScrollFrameChild)
			else
				tab:SetParent(GeneralDockManager)
			end
			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end

			if E.db.chat.panelBackdrop == "HIDEBOTH" or E.db.chat.panelBackdrop == "RIGHT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		end
	end

	self.initialMove = true;
end

local function UpdateChatTabColor(_, r, g, b)
	for i=1, CreatedFrames do
		_G["ChatFrame"..i.."TabText"]:SetTextColor(r, g, b)
	end
end
E["valueColorUpdateFuncs"][UpdateChatTabColor] = true

function CH:ScrollToBottom(frame)
	frame:ScrollToBottom()

	self:CancelTimer(frame.ScrollTimer, true)
end

function CH:PrintURL(url)
	return "|cFFFFFFFF[|Hurl:"..url.."|h"..url.."|h]|r "
end

function CH:FindURL(event, msg, ...)
	if (event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER") and CH.db.whisperSound ~= "None" and not CH.SoundPlayed then
		if (CH.db.noAlertInCombat and not InCombatLockdown()) or not CH.db.noAlertInCombat then
			PlaySoundFile(LSM:Fetch("sound", CH.db.whisperSound), "Master")
		end
		CH.SoundPlayed = true
		CH.SoundTimer = CH:ScheduleTimer("ThrottleSound", 1)
	end

	if not CH.db.url then
		msg = CH:CheckKeyword(msg);
		msg = CH:GetSmileyReplacementText(msg);
		return false, msg, ...
	end

	-- http://example.com
	local newMsg, found = gsub(msg, "(%a+)://(%S+)%s?", CH:PrintURL("%1://%2"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	-- www.example.com
	newMsg, found = gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", CH:PrintURL("www.%1.%2"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	-- example@example.com
	newMsg, found = gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", CH:PrintURL("%1@%2%3%4"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	-- IP address with port 1.1.1.1:1
	newMsg, found = gsub(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)(:%d+)%s?", CH:PrintURL("%1.%2.%3.%4%5"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end
	-- IP address 1.1.1.1
	newMsg, found = gsub(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", CH:PrintURL("%1.%2.%3.%4"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg)), ... end

	msg = CH:CheckKeyword(msg)
	msg = CH:GetSmileyReplacementText(msg)

	return false, msg, ...
end

local SetHyperlink = ItemRefTooltip.SetHyperlink;
function ItemRefTooltip:SetHyperlink(data, ...)
	if((data):sub(1, 3) == "url") then
		local ChatFrameEditBox = ChatEdit_ChooseBoxForSend();
		local currentLink = (data):sub(5);
		if(not ChatFrameEditBox:IsShown()) then
			ChatEdit_ActivateChat(ChatFrameEditBox);
		end
		ChatFrameEditBox:Insert(currentLink);
		ChatFrameEditBox:HighlightText();
	else
		SetHyperlink(self, data, ...);
	end
end

local function WIM_URLLink(link)
	if (link):sub(1, 3) == "url" then
		local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
		local currentLink = (link):sub(5)
		if (not ChatFrameEditBox:IsShown()) then
			ChatEdit_ActivateChat(ChatFrameEditBox)
		end
		ChatFrameEditBox:Insert(currentLink)
		ChatFrameEditBox:HighlightText()
		return
	end
end

local hyperLinkEntered
function CH:OnHyperlinkEnter(frame, refString)
	if InCombatLockdown() then return; end
	local linkToken = refString:match("^([^:]+)")
	if hyperlinkTypes[linkToken] then
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(refString)
		hyperLinkEntered = frame;
		GameTooltip:Show()
	end
end

function CH:OnHyperlinkLeave(_, refString)
	local linkToken = refString:match("^([^:]+)")
	if hyperlinkTypes[linkToken] then
		HideUIPanel(GameTooltip)
		hyperLinkEntered = nil;
	end
end

function CH:OnMessageScrollChanged(frame)
	if hyperLinkEntered == frame then
		HideUIPanel(GameTooltip)
		hyperLinkEntered = false;
	end
end

function CH:EnableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if (not self.hooks or not self.hooks[frame] or not self.hooks[frame].OnHyperlinkEnter) then
			self:HookScript(frame, "OnHyperlinkEnter")
			self:HookScript(frame, "OnHyperlinkLeave")
			self:HookScript(frame, "OnMessageScrollChanged")
		end
	end
end

function CH:DisableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if self.hooks and self.hooks[frame] and self.hooks[frame].OnHyperlinkEnter then
			self:Unhook(frame, "OnHyperlinkEnter")
			self:Unhook(frame, "OnHyperlinkLeave")
			self:Unhook(frame, "OnMessageScrollChanged")
		end
	end
end

function CH:DisableChatThrottle()
	twipe(msgList); twipe(msgCount); twipe(msgTime)
end

function CH:ShortChannel()
	return format("|Hchannel:%s|h[%s]|h", self, DEFAULT_STRINGS[self:upper()] or self:gsub("channel:", ""))
end

function CH:ConcatenateTimeStamp(msg)
	if (CH.db.timeStampFormat and CH.db.timeStampFormat ~= "NONE" ) then
		local timeStamp = BetterDate(CH.db.timeStampFormat, CH.timeOverride or time());
		timeStamp = timeStamp:gsub(" ", "")
		timeStamp = timeStamp:gsub("AM", " AM")
		timeStamp = timeStamp:gsub("PM", " PM")
		if CH.db.useCustomTimeColor then
			local color = CH.db.customTimeColor
			local hexColor = E:RGBToHex(color.r, color.g, color.b)
			msg = format("%s[%s]|r %s", hexColor, timeStamp, msg)
		else
			msg = format("[%s] %s", timeStamp, msg)
		end
		CH.timeOverride = nil;
	end

	return msg
end

function GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
	local chatType = strsub(event, 10);
	if(strsub(chatType, 1, 7) == "WHISPER") then
		chatType = "WHISPER";
	end
	if(strsub(chatType, 1, 7) == "CHANNEL") then
		chatType = "CHANNEL"..arg8;
	end
	local info = ChatTypeInfo[chatType];

	if(info and info.colorNameByClass and arg12 ~= "") then
		local _, _, englishClass, _, _, _, name = pcall(GetPlayerInfoByGUID, arg12);
		if(englishClass) then
			local classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[englishClass] or RAID_CLASS_COLORS[englishClass];
			if(not classColorTable) then
				return arg2;
			end
			CH.ClassNames[name:lower()] = englishClass;
			return format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..arg2.."\124r";
		end
	end

	return arg2;
end

local function GetChatIcons(sender)
	if(specialChatIcons[PLAYER_REALM] and specialChatIcons[PLAYER_REALM][E.myname] ~= true) then
		for realm, _ in pairs(specialChatIcons) do
			for character, texture in pairs(specialChatIcons[realm]) do
				if sender == character or sender == character.."-"..realm then
					return texture
				end
			end
		end
	end
end

function CH:ChatFrame_MessageEventHandler(event, ...)
	if ( strsub(event, 1, 8) == "CHAT_MSG" ) then
		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = ...;
		local type = strsub(event, 10);
		local info = ChatTypeInfo[type];

		local filter = false;
		if ( chatFilters[event] ) then
			local newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12;
			for _, filterFunc in next, chatFilters[event] do
				filter, newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12 = filterFunc(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
				if ( filter ) then
					return true;
				elseif ( newarg1 ) then
					arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12;
				end
			end
		end

		local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);

		local channelLength = strlen(arg4);
		local infoType = type;
		if ( (strsub(type, 1, 7) == "CHANNEL") and (type ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (type ~= "CHANNEL_NOTICE_USER")) ) then
			if ( arg1 == "WRONG_PASSWORD" ) then
				local staticPopup = _G[StaticPopup_Visible("CHAT_CHANNEL_PASSWORD") or ""];
				if ( staticPopup and strupper(staticPopup.data) == strupper(arg9) ) then
					-- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
					return;
				end
			end

			local found = 0;
			for index, value in pairs(self.channelList) do
				if ( channelLength > strlen(value) ) then
					-- arg9 is the channel name without the number in front...
					if ( ((arg7 > 0) and (self.zoneChannelList[index] == arg7)) or (strupper(value) == strupper(arg9)) ) then
						found = 1;
						infoType = "CHANNEL"..arg8;
						info = ChatTypeInfo[infoType];
						if ( (type == "CHANNEL_NOTICE") and (arg1 == "YOU_LEFT") ) then
							self.channelList[index] = nil;
							self.zoneChannelList[index] = nil;
						end
						break;
					end
				end
			end
			if ( (found == 0) or not info ) then
				return true;
			end
		end

		local chatGroup = Chat_GetChatCategory(type);
		local chatTarget;
		if ( chatGroup == "CHANNEL" or chatGroup == "BN_CONVERSATION" ) then
			chatTarget = tostring(arg8);
		elseif ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			chatTarget = strupper(arg2);
		end

		if ( FCFManager_ShouldSuppressMessage(self, chatGroup, chatTarget) ) then
			return true;
		end

		--[[if not (chatGroup == "CHANNEL") and not (self:GetName() == "AFKChat") then
			local found2 = false

			for i = 1, #self.messageTypeList, 1 do
				if self.messageTypeList[i] == chatGroup then
					found2 = true
					break
				end
				if self.messageTypeList[i] == "EMOTE" and (chatGroup == "TEXT_EMOTE" or chatGroup == "RAID_BOSS_EMOTE") then
					found2 = true
					break
				end
			end

			if not found2 then
				return true
			end
		end]]

		if ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			if ( self.privateMessageList and not self.privateMessageList[strlower(arg2)] ) then
				return true;
			elseif ( self.excludePrivateMessageList and self.excludePrivateMessageList[strlower(arg2)] ) then
				return true;
			end
		elseif ( chatGroup == "BN_CONVERSATION" ) then
			if ( self.bnConversationList and not self.bnConversationList[arg8] ) then
				return true;
			elseif ( self.excludeBNConversationList and self.excludeBNConversationList[arg8] ) then
				return true;
			end
		end

		if ( type == "SYSTEM" or type == "SKILL" or type == "LOOT" or type == "MONEY" or
			type == "OPENING" or type == "TRADESKILLS" or type == "PET_INFO" or type == "TARGETICONS") then
			self:AddMessage(CH:ConcatenateTimeStamp(arg1), info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,7) == "COMBAT_" ) then
			self:AddMessage(CH:ConcatenateTimeStamp(arg1), info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,6) == "SPELL_" ) then
			self:AddMessage(CH:ConcatenateTimeStamp(arg1), info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,10) == "BG_SYSTEM_" ) then
			self:AddMessage(CH:ConcatenateTimeStamp(arg1), info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,11) == "ACHIEVEMENT" ) then
			self:AddMessage(format(CH:ConcatenateTimeStamp(arg1), "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,18) == "GUILD_ACHIEVEMENT" ) then
			self:AddMessage(format(CH:ConcatenateTimeStamp(arg1), "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id);
		elseif ( type == "IGNORED" ) then
			self:AddMessage(format(CH:ConcatenateTimeStamp(GlobalStrings.CHAT_IGNORED), arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "FILTERED" ) then
			self:AddMessage(format(CH:ConcatenateTimeStamp(GlobalStrings.CHAT_FILTERED), arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "RESTRICTED" ) then
			self:AddMessage(CH:ConcatenateTimeStamp(GlobalStrings.CHAT_RESTRICTED), info.r, info.g, info.b, info.id);
		elseif ( type == "CHANNEL_LIST") then
			if(channelLength > 0) then
				self:AddMessage(format(CH:ConcatenateTimeStamp(_G["CHAT_"..type.."_GET"]..arg1), tonumber(arg8), arg4), info.r, info.g, info.b, info.id);
			else
				self:AddMessage(CH:ConcatenateTimeStamp(arg1), info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE_USER") then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
			if ( not globalstring ) then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"];
			end

			globalstring = CH:ConcatenateTimeStamp(globalstring);

			if(strlen(arg5) > 0) then
				-- TWO users in this notice (E.G. x kicked y)
				self:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id);
			elseif ( arg1 == "INVITE" ) then
				self:AddMessage(format(globalstring, arg4, arg2), info.r, info.g, info.b, info.id);
			else
				self:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE") then
			if arg1 == "NOT_IN_LFG" then return; end
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
			if ( not globalstring ) then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"];
			end
			if ( arg10 > 0 ) then
				arg4 = arg4.." "..arg10;
			end

			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(type), arg8);
			local typeID = ChatHistory_GetAccessID(infoType, arg8);
			self:AddMessage(format(CH:ConcatenateTimeStamp(globalstring), arg8, arg4), info.r, info.g, info.b, info.id, false, accessID, typeID);
		else
			local body;
			local _, fontHeight = FCF_GetChatWindowInfo(self:GetID());

			if ( fontHeight == 0 ) then
				--fontHeight will be 0 if it's still at the default (14)
				fontHeight = 14;
			end

			-- Add AFK/DND flags
			local pflag = GetChatIcons(arg2);
			if(arg6 ~= "") then
				if (arg6 == "GM") then
					--If it was a whisper, dispatch it to the GMChat addon.
					if (type == "WHISPER") then
						return;
					end
					--Add Blizzard Icon, this was sent by a GM
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
				elseif (arg6 == "DEV") then
					--Add Blizzard Icon, this was sent by a Dev
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
				elseif (arg6 == "DND" or arg6 == "AFK") then
					pflag = (pflag or "").._G["CHAT_FLAG_"..arg6];
				else
					pflag = _G["CHAT_FLAG_"..arg6];
				end
			else
				if(pflag == true) then
					pflag = ""
				end
			end

			pflag = pflag or ""

			if ( type == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) ) then
				return;
			end

			local showLink = 1;
			if ( strsub(type, 1, 7) == "MONSTER" or strsub(type, 1, 9) == "RAID_BOSS") then
				showLink = nil;
			else
				arg1 = gsub(arg1, "%%", "%%%%");
			end

			if ((type == "PARTY_LEADER") and (HasLFGRestrictions())) then
				type = "PARTY_GUIDE";
			end

			-- Search for icon links and replace them with texture links.
			local term;
			for tag in gmatch(arg1, "%b{}") do
				term = strlower(gsub(tag, "[{}]", ""));
				if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
					arg1 = gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
				end
			end

			local playerLink;

			if ( type ~= "BN_WHISPER" and type ~= "BN_WHISPER_INFORM" and type ~= "BN_CONVERSATION" ) then
				playerLink = "|Hplayer:"..arg2..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h";
			else
				playerLink = "|HBNplayer:"..arg2..":"..arg13..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h";
			end

			if ( (strlen(arg3) > 0) and (arg3 ~= "Universal") and (arg3 ~= self.defaultLanguage) ) then
				local languageHeader = "["..arg3.."] ";
				if ( showLink and (strlen(arg2) > 0) ) then
					body = format(_G["CHAT_"..type.."_GET"]..languageHeader..arg1, pflag..playerLink.."["..coloredName.."]".."|h");
				else
					body = format(_G["CHAT_"..type.."_GET"]..languageHeader..arg1, pflag..arg2);
				end
			else
				if ( not showLink or strlen(arg2) == 0 ) then
					if(arg1:find("% ") and GetLocale() == "ruRU") then
						arg1 = arg1:gsub("%%", "%%s");
					end
					body = format(_G["CHAT_" .. type .. "_GET"] .. arg1, pflag .. arg2, arg2);
				else
					if ( type == "EMOTE" ) then
						body = format(_G["CHAT_"..type.."_GET"]..arg1, pflag..playerLink..coloredName.."|h");
					elseif ( type == "TEXT_EMOTE") then
						body = string.gsub(arg1, arg2, pflag..playerLink..coloredName.."|h", 1);
					else
						body = format(_G["CHAT_"..type.."_GET"]..arg1, pflag..playerLink.."["..coloredName.."]".."|h");
					end
				end
			end

			-- Add Channel
			arg4 = gsub(arg4, "%s%-%s.*", "");
			if(chatGroup == "BN_CONVERSATION") then
				body = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, GlobalStrings.MAX_WOW_CHAT_CHANNELS + arg8)..body;
			elseif(channelLength > 0) then
				body = "|Hchannel:channel:"..arg8.."|h["..arg4.."]|h "..body;
			end

			--Add Timestamps
			if ( CHAT_TIMESTAMP_FORMAT ) then
				body = BetterDate(CHAT_TIMESTAMP_FORMAT, time())..body;
			end

			local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
			local typeID = ChatHistory_GetAccessID(infoType, chatTarget);
			if CH.db.shortChannels then
				body = body:gsub("|Hchannel:(.-)|h%[(.-)%]|h", CH.ShortChannel)
				body = body:gsub("CHANNEL:", "")
				body = body:gsub("^(.-|h) "..L["whispers"], "%1")
				body = body:gsub("^(.-|h) "..L["says"], "%1")
				body = body:gsub("^(.-|h) "..L["yells"], "%1")
				body = body:gsub("<"..GlobalStrings.AFK..">", "[|cffFF0000"..L["AFK"].."|r] ")
				body = body:gsub("<"..GlobalStrings.DND..">", "[|cffE7E716"..L["DND"].."|r] ")
				body = body:gsub("%[BN_CONVERSATION:", "%[".."")
				body = body:gsub("^%["..GlobalStrings.RAID_WARNING.."%]", "["..L["RW"].."]")
			end
			self:AddMessage(CH:ConcatenateTimeStamp(body), info.r, info.g, info.b, info.id, false, accessID, typeID);
		end

		if ( type == "WHISPER" or type == "BN_WHISPER" ) then
			--BN_WHISPER FIXME
			ChatEdit_SetLastTellTarget(arg2);
			if ( self.tellTimer and (GetTime() > self.tellTimer) ) then
				PlaySound("TellMessage");
			end
			self.tellTimer = GetTime() + GlobalStrings.CHAT_TELL_ALERT_TIME;
			--FCF_FlashTab(self);
		end

		if ( not self:IsShown() ) then
			if ( (self == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (self ~= DEFAULT_CHAT_FRAME and info.flashTab) ) then
				if ( not CHAT_OPTIONS.HIDE_FRAME_ALERTS or type == "WHISPER" or type == "BN_WHISPER" ) then
					FCF_StartAlertFlash(self);
				end
			end
		end

		return true;
	end
end

function CH:ChatFrame_OnEvent(event, ...)
	if ( ChatFrame_ConfigEventHandler(self, event, ...) ) then
		return;
	end
	if ( ChatFrame_SystemEventHandler(self, event, ...) ) then
		return
	end
	if ( CH.ChatFrame_MessageEventHandler(self, event, ...) ) then
		return
	end
end

function CH:FloatingChatFrame_OnEvent(event, ...)
	CH.ChatFrame_OnEvent(self, event, ...);
	FloatingChatFrame_OnEvent(self, event, ...);
end

function CH:SetupChat()
	if E.private.chat.enable ~= true then return end
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		local id = frame:GetID();
		local _, fontSize = FCF_GetChatWindowInfo(id);
		self:StyleChat(frame)
		FCFTab_UpdateAlpha(frame)
		frame:SetFont(LSM:Fetch("font", self.db.font), fontSize, self.db.fontOutline)
		if self.db.fontOutline ~= "NONE" then
			frame:SetShadowColor(0, 0, 0, 0.2)
		else
			frame:SetShadowColor(0, 0, 0, 1)
		end
		frame:SetTimeVisible(100)
		frame:SetShadowOffset((E.mult or 1), -(E.mult or 1))
		frame:SetFading(self.db.fade)

		if not frame.scriptsSet then
			frame:SetScript("OnMouseWheel", ChatFrame_OnMouseScroll)

			--[[THIS CAUSES LUA ERROR WHEN RESETTING CHAT TO DEFAULTS OR WHEN RUNNING FCF_ResetChatWindows()
			if id > NUM_CHAT_WINDOWS then
				frame:SetScript("OnEvent", CH.FloatingChatFrame_OnEvent)
			elseif id ~= 2 then
				frame:SetScript("OnEvent", CH.ChatFrame_OnEvent)
			end]]
			--Use this instead for the time being
			if id ~= 2 then
				frame:SetScript("OnEvent", CH.FloatingChatFrame_OnEvent)
			end

			hooksecurefunc(frame, "SetScript", function(f, script, func)
				if script == "OnMouseWheel" and func ~= ChatFrame_OnMouseScroll then
					f:SetScript(script, ChatFrame_OnMouseScroll)
				end
			end)
			frame.scriptsSet = true
		end
	end

	if self.db.hyperlinkHover then
		self:EnableHyperlink()
	end

	GeneralDockManager:SetParent(LeftChatPanel)
	-- self:ScheduleRepeatingTimer("PositionChat", 1)
	self:PositionChat(true)

	if not self.HookSecured then
		self:SecureHook("FCF_OpenTemporaryWindow", "SetupChat")
		self.HookSecured = true;
	end
end

local function PrepareMessage(author, message)
	return format("%s%s", author:upper(), message)
end

function CH:ChatThrottleHandler(_, ...)
	local arg1, arg2 = ...

	if arg2 ~= "" then
		local message = PrepareMessage(arg2, arg1)
		if msgList[message] == nil then
			msgList[message] = true
			msgCount[message] = 1
			msgTime[message] = time()
		else
			msgCount[message] = msgCount[message] + 1
		end
	end
end

function CH:CHAT_MSG_CHANNEL(event, message, author, ...)
	local blockFlag = false
	local msg = PrepareMessage(author, message)

	-- ignore player messages
	if author == UnitName("player") then return CH.FindURL(self, event, message, author, ...) end
	if msgList[msg] and CH.db.throttleInterval ~= 0 then
		if difftime(time(), msgTime[msg]) <= CH.db.throttleInterval then
			blockFlag = true
		end
	end

	if blockFlag then
		return true;
	else
		if CH.db.throttleInterval ~= 0 then
			msgTime[msg] = time()
		end

		return CH.FindURL(self, event, message, author, ...)
	end
end

function CH:CHAT_MSG_YELL(event, message, author, ...)
	local blockFlag = false
	local msg = PrepareMessage(author, message)

	if msg == nil then return CH.FindURL(self, event, message, author, ...) end

	-- ignore player messages
	if author == UnitName("player") then return CH.FindURL(self, event, message, author, ...) end
	if msgList[msg] and msgCount[msg] > 1 and CH.db.throttleInterval ~= 0 then
		if difftime(time(), msgTime[msg]) <= CH.db.throttleInterval then
			blockFlag = true
		end
	end

	if blockFlag then
		return true;
	else
		if CH.db.throttleInterval ~= 0 then
			msgTime[msg] = time()
		end

		return CH.FindURL(self, event, message, author, ...)
	end
end

function CH:CHAT_MSG_SAY(event, message, author, ...)
	return CH.FindURL(self, event, message, author, ...)
end

function CH:ThrottleSound()
	self.SoundPlayed = nil;
end

local protectLinks = {}
function CH:CheckKeyword(message)
	for itemLink in message:gmatch("|%x+|Hitem:.-|h.-|h|r") do
		protectLinks[itemLink]=itemLink:gsub("%s","|s")
		for keyword, _ in pairs(CH.Keywords) do
			if itemLink == keyword then
				if(self.db.keywordSound ~= "None" and not self.SoundPlayed) then
					if (self.db.noAlertInCombat and not InCombatLockdown()) or not self.db.noAlertInCombat then
						PlaySoundFile(LSM:Fetch("sound", self.db.keywordSound), "Master")
					end
					self.SoundPlayed = true
					self.SoundTimer = CH:ScheduleTimer("ThrottleSound", 1)
				end
			end
		end
	end

	for itemLink, tempLink in pairs(protectLinks) do
		message = message:gsub(itemLink:gsub("([%(%)%.%%%+%-%*%?%[%^%$])","%%%1"), tempLink)
	end

	local classColorTable, tempWord, rebuiltString, lowerCaseWord, wordMatch, classMatch
	local isFirstWord = true
	for word in message:gmatch("%s-[^%s]+%s*") do
		tempWord = word:gsub("[%s%p]", "")
		lowerCaseWord = tempWord:lower()
		for keyword, _ in pairs(CH.Keywords) do
			if lowerCaseWord == keyword:lower() then
				word = word:gsub(tempWord, format("%s%s|r", E.media.hexvaluecolor, tempWord))
				if self.db.keywordSound ~= "None" and not self.SoundPlayed then
					if (self.db.noAlertInCombat and not InCombatLockdown()) or not self.db.noAlertInCombat then
						PlaySoundFile(LSM:Fetch("sound", self.db.keywordSound), "Master")
					end
					self.SoundPlayed = true
					self.SoundTimer = CH:ScheduleTimer("ThrottleSound", 1)
				end
			end
		end

		if self.db.classColorMentionsChat then
			tempWord = word:gsub("^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$","%1%2")
			lowerCaseWord = tempWord:lower()

			classMatch = CH.ClassNames[lowerCaseWord]
			wordMatch = classMatch and lowerCaseWord

			if(wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch]) then
				classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classMatch] or RAID_CLASS_COLORS[classMatch]
				word = word:gsub(tempWord:gsub("%-","%%-"), format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
			end
		end

		if isFirstWord then
			rebuiltString = word
			isFirstWord = false
		else
			rebuiltString = format("%s%s", rebuiltString, word)
		end
	end

	for itemLink, tempLink in pairs(protectLinks) do
		rebuiltString = rebuiltString:gsub(tempLink:gsub("([%(%)%.%%%+%-%*%?%[%^%$])","%%%1"), itemLink)
		protectLinks[itemLink] = nil
	end

	return rebuiltString
end

function CH:AddLines(lines, ...)
	for i = select("#", ...), 1, -1 do
		local x = select(i, ...);
		if(x:GetObjectType() == "FontString" and not x:GetName()) then
			tinsert(lines, x:GetText());
		end
	end
end

function CH:ChatEdit_OnEnterPressed(editBox)
	local type = editBox:GetAttribute("chatType");
	local chatFrame = editBox:GetParent();
	if not chatFrame.isTemporary and ChatTypeInfo[type].sticky == 1 then
		if not self.db.sticky then type = "SAY"; end
		editBox:SetAttribute("chatType", type);
	end
end

function CH:SetChatFont(dropDown, chatFrame, fontSize)
	if ( not chatFrame ) then
		chatFrame = FCF_GetCurrentChatFrame();
	end
	if ( not fontSize ) then
		fontSize = dropDown.value;
	end
	chatFrame:SetFont(LSM:Fetch("font", self.db.font), fontSize, self.db.fontOutline)
	if self.db.fontOutline ~= "NONE" then
		chatFrame:SetShadowColor(0, 0, 0, 0.2)
	else
		chatFrame:SetShadowColor(0, 0, 0, 1)
	end
	chatFrame:SetShadowOffset((E.mult or 1), -(E.mult or 1))
end

function CH:ChatEdit_AddHistory(_, line)
	if line:find("/rl") then return; end

	if ( strlen(line) > 0 ) then
		for i, text in pairs(ElvCharacterDB.ChatEditHistory) do
			if text == line then
				return
			end
		end

		tinsert(ElvCharacterDB.ChatEditHistory, #ElvCharacterDB.ChatEditHistory + 1, line)
		if #ElvCharacterDB.ChatEditHistory > 5 then
			tremove(ElvCharacterDB.ChatEditHistory, 1)
		end
	end
end

function CH:UpdateChatKeywords()
	twipe(CH.Keywords)
	local keywords = self.db.keywords
	keywords = keywords:gsub(",%s", ",")

	for i=1, #{split(",", keywords)} do
		local stringValue = select(i, split(",", keywords));
		if stringValue ~= "" then
			CH.Keywords[stringValue] = true;
		end
	end
end

function CH:UpdateFading()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if frame then
			frame:SetFading(self.db.fade)
		end
	end
end

function CH:DisplayChatHistory()
	local temp, data = {}
	for id, _ in pairs(ElvCharacterDB.ChatLog) do
		tinsert(temp, tonumber(id))
	end

	tsort(temp, function(a, b)
		return a < b
	end)

	for i = 1, #temp do
		data = ElvCharacterDB.ChatLog[tostring(temp[i])]

		if type(data) == "table" and data[20] ~= nil then
			CH.timeOverride = temp[i]

			CH.ChatFrame_MessageEventHandler(DEFAULT_CHAT_FRAME, data[20], unpack(data))
		end
	end
end

local function GetTimeForSavedMessage()
	local randomTime = select(2, ("."):split(GetTime() or "0."..random(1, 999), 2)) or 0
	return time().."."..randomTime
end

function CH:SaveChatHistory(event, ...)
	if self.db.throttleInterval ~= 0 and (event == "CHAT_MESSAGE_SAY" or event == "CHAT_MESSAGE_YELL" or event == "CHAT_MSG_CHANNEL") then
		self:ChatThrottleHandler(event, ...)

		local message, author = ...
		local msg = PrepareMessage(author, message)
		if author ~= UnitName("player") and msgList[msg] then
			if difftime(time(), msgTime[msg]) <= CH.db.throttleInterval then
				return;
			end
		end
	end

	local temp = {}
	for i = 1, select("#", ...) do
		temp[i] = select(i, ...) or false
	end

	if(#temp > 0) then
		temp[20] = event;
		local timeForMessage = GetTimeForSavedMessage();
		ElvCharacterDB.ChatLog[timeForMessage] = temp;

		local c, k = 0;
		for id, data in pairs(ElvCharacterDB.ChatLog) do
			c = c + 1;
			if((not k) or k > id) then
				k = id;
			end
		end

		if c > 128 then
			ElvCharacterDB.ChatLog[k] = nil
		end
	end
end

function CH:ChatFrame_AddMessageEventFilter (event, filter)
	assert(event and filter);

	if ( chatFilters[event] ) then
		-- Only allow a filter to be added once
		for index, filterFunc in next, chatFilters[event] do
			if ( filterFunc == filter ) then
				return;
			end
		end
	else
		chatFilters[event] = {};
	end

	tinsert(chatFilters[event], filter);
end

function CH:ChatFrame_RemoveMessageEventFilter (event, filter)
	assert(event and filter);

	if ( chatFilters[event] ) then
		for index, filterFunc in next, chatFilters[event] do
			if ( filterFunc == filter ) then
				tremove(chatFilters[event], index);
			end
		end

		if ( #chatFilters[event] == 0 ) then
			chatFilters[event] = nil;
		end
	end
end

function CH:FCF_SetWindowAlpha(frame, alpha)
	frame.oldAlpha = alpha or 1;
end

local stopScript = false
hooksecurefunc(DEFAULT_CHAT_FRAME, "RegisterEvent", function(self, event)
	if event == "GUILD_MOTD" and not stopScript then
		self:UnregisterEvent("GUILD_MOTD")
	end
end)

local cachedMsg = GetGuildRosterMOTD()
if cachedMsg == "" then cachedMsg = nil end
function CH:DelayGMOTD()
	E:Delay(5, function()
		stopScript = true
		DEFAULT_CHAT_FRAME:RegisterEvent("GUILD_MOTD")
		local msg = cachedMsg or GetGuildRosterMOTD()
		if msg == "" then msg = nil end

		if msg then
			ChatFrame_SystemEventHandler(DEFAULT_CHAT_FRAME, "GUILD_MOTD", msg)
		end
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end)
end

function CH:ON_FCF_SavePositionAndDimensions(_, noLoop)
	if not noLoop then
		CH:PositionChat()
	end

	if not E.db.chat.lockPositions then
		CH:UpdateChatTabs() --It was not done in PositionChat, so do it now
	end
end

function CH:Initialize()
	if ElvCharacterDB.ChatHistory then
		ElvCharacterDB.ChatHistory = nil --Depreciated
	end

	self.db = E.db.chat

	if E.private.chat.enable ~= true then
		stopScript = true
		DEFAULT_CHAT_FRAME:RegisterEvent("GUILD_MOTD")

		local msg = GetGuildRosterMOTD()
		if msg == "" then msg = nil end
		if msg then
			ChatFrame_SystemEventHandler(DEFAULT_CHAT_FRAME, "GUILD_MOTD", msg)
		end

		return
	end

	if not ElvCharacterDB.ChatEditHistory then
		ElvCharacterDB.ChatEditHistory = {};
	end

	if not ElvCharacterDB.ChatLog or not self.db.chatHistory then
		ElvCharacterDB.ChatLog = {};
	end

	self:UpdateChatKeywords()

	self:UpdateFading()
	E.Chat = self
	self:SecureHook("ChatEdit_OnEnterPressed")
	FriendsMicroButton:Kill()
	ChatFrameMenuButton:Kill()

	if(WIM) then
		WIM.RegisterWidgetTrigger("chat_display", "whisper,chat,w2w,demo", "OnHyperlinkClick", function(self) CH.clickedframe = self end);
		WIM.RegisterItemRefHandler("url", WIM_URLLink);
	end

	self:SecureHook("FCF_SetChatWindowFontSize", "SetChatFont")
	self:SecureHook("FCF_SavePositionAndDimensions", "ON_FCF_SavePositionAndDimensions")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "DelayGMOTD")
	self:RegisterEvent("UPDATE_CHAT_WINDOWS", "SetupChat")
	self:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", "SetupChat")

	self:SetupChat()
	self:UpdateAnchors()
	if not E.db.chat.lockPositions then
		CH:UpdateChatTabs() --It was not done in PositionChat, so do it now
	end

	self:RegisterEvent("CHAT_MSG_BATTLEGROUND", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_BATTLEGROUND_LEADER", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_CHANNEL", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_EMOTE", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_TEXT_EMOTE", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_GUILD", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_OFFICER", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_PARTY", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_RAID", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_RAID_WARNING", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_SAY", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_WHISPER", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_SYSTEM", "SaveChatHistory")
	self:RegisterEvent("CHAT_MSG_YELL", "SaveChatHistory")

	--First get all pre-existing filters and copy them to our version of chatFilters using ChatFrame_GetMessageEventFilters
	for name, _ in pairs(ChatTypeGroup) do
		for i=1, #ChatTypeGroup[name] do
			local filterFuncTable = ChatFrame_GetMessageEventFilters(ChatTypeGroup[name][i])
			if filterFuncTable then
				chatFilters[ChatTypeGroup[name][i]] = {};

				for j=1, #filterFuncTable do
					local filterFunc = filterFuncTable[j]
					tinsert(chatFilters[ChatTypeGroup[name][i]], filterFunc);
				end
			end
		end
	end

	--CHAT_MSG_CHANNEL isn't located inside ChatTypeGroup
	local filterFuncTable = ChatFrame_GetMessageEventFilters("CHAT_MSG_CHANNEL")
	if filterFuncTable then
		chatFilters["CHAT_MSG_CHANNEL"] = {};

		for j=1, #filterFuncTable do
			local filterFunc = filterFuncTable[j]
			tinsert(chatFilters["CHAT_MSG_CHANNEL"], filterFunc);
		end
	end

	--Now hook onto Blizzards functions for other addons
	self:SecureHook("ChatFrame_AddMessageEventFilter");
	self:SecureHook("ChatFrame_RemoveMessageEventFilter");

	self:SecureHook("FCF_SetWindowAlpha")

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", CH.CHAT_MSG_CHANNEL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", CH.CHAT_MSG_YELL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CH.CHAT_MSG_SAY)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", CH.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_INLINE_TOAST_BROADCAST", CH.FindURL)

	GeneralDockManagerOverflowButton:ClearAllPoints()
	GeneralDockManagerOverflowButton:Point("BOTTOMRIGHT", LeftChatTab, "BOTTOMRIGHT", -2, 2)
	GeneralDockManagerOverflowButton:SetTemplate("Default")
	GeneralDockManagerOverflowButtonList:SetTemplate("Transparent")
	hooksecurefunc(GeneralDockManagerScrollFrame, "SetPoint", function(self, point, anchor, attachTo, x, y)
		if anchor == GeneralDockManagerOverflowButton and x == 0 and y == 0 then
			self:SetPoint(point, anchor, attachTo, -2, -6)
		end
	end)

	if self.db.chatHistory then
		self.SoundPlayed = true
		self:DisplayChatHistory()
		self.SoundPlayed = nil
	end

	local S = E:GetModule("Skins")
	S:HandleNextPrevButton(CombatLogQuickButtonFrame_CustomAdditionalFilterButton, true)
	local frame = CreateFrame("Frame", "CopyChatFrame", E.UIParent)
	tinsert(UISpecialFrames, "CopyChatFrame")
	frame:SetTemplate("Transparent")
	frame:Size(700, 200)
	frame:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 3)
	frame:Hide()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetResizable(true);
	frame:SetMinResize(350, 100);
	frame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving();
			self.isMoving = true;
		elseif(button == "RightButton" and not self.isSizing) then
			self:StartSizing();
			self.isSizing = true;
		end
	end)
	frame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing();
			self.isMoving = false;
		elseif(button == "RightButton" and self.isSizing) then
			self:StopMovingOrSizing();
			self.isSizing = false;
		end
	end)
	frame:SetScript("OnHide", function(self)
		if(self.isMoving or self.isSizing) then
			self:StopMovingOrSizing();
			self.isMoving = false;
			self.isSizing = false;
		end
	end)
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:Point("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	S:HandleScrollBar(CopyChatScrollFrameScrollBar)
	scrollArea:SetScript("OnSizeChanged", function(self)
		CopyChatFrameEditBox:Width(self:GetWidth());
		CopyChatFrameEditBox:Height(self:GetHeight());
	end);
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		CopyChatFrameEditBox:SetHitRectInsets(0, 0, offset, (CopyChatFrameEditBox:GetHeight() - offset - self:GetHeight()));
	end);

	local editBox = CreateFrame("EditBox", "CopyChatFrameEditBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:Width(scrollArea:GetWidth())
	editBox:Height(200)
	editBox:SetScript("OnEscapePressed", function() CopyChatFrame:Hide() end)
	scrollArea:SetScrollChild(editBox)
	CopyChatFrameEditBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then return end
		local _, max = CopyChatScrollFrameScrollBar:GetMinMaxValues()
		for i=1, max do
			ScrollFrameTemplate_OnMouseWheel(CopyChatScrollFrame, -1)
		end
	end)

	local close = CreateFrame("Button", "CopyChatFrameCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT")
	close:SetFrameLevel(close:GetFrameLevel() + 1)
	close:EnableMouse(true)

	S:HandleCloseButton(close)

	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Size(20, 22)
	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Point("TOPRIGHT", CombatLogQuickButtonFrame_Custom, "TOPRIGHT", 0, -1)
end

local function InitializeCallback()
	CH:Initialize()
end

E:RegisterModule(CH:GetName(), InitializeCallback)