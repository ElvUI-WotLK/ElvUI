local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CH = E:GetModule("Chat")
local LO = E:GetModule("Layout")
local Skins = E:GetModule("Skins")
local LibBase64 = E.Libs.Base64
local LSM = E.Libs.LSM

--Lua functions
local _G = _G
local time = time
local pairs, ipairs, unpack, select, tostring, pcall, next, tonumber, type = pairs, ipairs, unpack, select, tostring, pcall, next, tonumber, type
local tinsert, tremove, tconcat, wipe = table.insert, table.remove, table.concat, table.wipe
local gsub, find, gmatch, format, strtrim = string.gsub, string.find, string.gmatch, string.format, string.trim
local strlower, strmatch, strsub, strlen, strupper = strlower, strmatch, strsub, strlen, strupper
--WoW API / Variables
local BetterDate = BetterDate
local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatEdit_ParseText = ChatEdit_ParseText
local ChatEdit_SetLastTellTarget = ChatEdit_SetLastTellTarget
local ChatFrame_ConfigEventHandler = ChatFrame_ConfigEventHandler
local ChatFrame_GetMessageEventFilters = ChatFrame_GetMessageEventFilters
local ChatFrame_SendTell = ChatFrame_SendTell
local ChatFrame_SystemEventHandler = ChatFrame_SystemEventHandler
local ChatHistory_GetAccessID = ChatHistory_GetAccessID
local Chat_GetChatCategory = Chat_GetChatCategory
local CreateFrame = CreateFrame
local FCFManager_ShouldSuppressMessage = FCFManager_ShouldSuppressMessage
local FCFTab_UpdateAlpha = FCFTab_UpdateAlpha
local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_SetLocked = FCF_SetLocked
local FCF_StartAlertFlash = FCF_StartAlertFlash
local FloatingChatFrame_OnEvent = FloatingChatFrame_OnEvent
local GMChatFrame_IsGM = GMChatFrame_IsGM
local GetChannelName = GetChannelName
local GetGuildRosterMOTD = GetGuildRosterMOTD
local GetMouseFocus = GetMouseFocus
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local HasLFGRestrictions = HasLFGRestrictions
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsInInstance = IsInInstance
local IsMouseButtonDown = IsMouseButtonDown
local IsShiftKeyDown = IsShiftKeyDown
local PlaySoundFile = PlaySoundFile
local ScrollFrameTemplate_OnMouseWheel = ScrollFrameTemplate_OnMouseWheel
local StaticPopup_Visible = StaticPopup_Visible
local ToggleFrame = ToggleFrame
local UnitIsSameServer = UnitIsSameServer
local UnitName = UnitName
local hooksecurefunc = hooksecurefunc

local AFK = AFK
local CHAT_BN_CONVERSATION_GET_LINK = CHAT_BN_CONVERSATION_GET_LINK
local CHAT_FILTERED = CHAT_FILTERED
local CHAT_FRAMES = CHAT_FRAMES
local CHAT_IGNORED = CHAT_IGNORED
local CHAT_OPTIONS = CHAT_OPTIONS
local CHAT_RESTRICTED = CHAT_RESTRICTED
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local DND = DND
local ICON_LIST = ICON_LIST
local ICON_TAG_LIST = ICON_TAG_LIST
local MAX_WOW_CHAT_CHANNELS = MAX_WOW_CHAT_CHANNELS
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local RAID_WARNING = RAID_WARNING

local throttle = {}

CH.ClassNames = {}
CH.Keywords = {}
CH.Smileys = {}

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

local historyTypes = { -- the events set on the chats are still in FindURL_Events, this is used to ignore some types only
	CHAT_MSG_WHISPER = "WHISPER",
	CHAT_MSG_WHISPER_INFORM = "WHISPER",
	CHAT_MSG_BN_WHISPER = "WHISPER",
	CHAT_MSG_BN_WHISPER_INFORM = "WHISPER",
	CHAT_MSG_GUILD = "GUILD",
	CHAT_MSG_GUILD_ACHIEVEMENT = "GUILD",
	CHAT_MSG_OFFICER = "OFFICER",
	CHAT_MSG_PARTY = "PARTY",
	CHAT_MSG_PARTY_LEADER = "PARTY",
	CHAT_MSG_RAID = "RAID",
	CHAT_MSG_RAID_LEADER = "RAID",
	CHAT_MSG_RAID_WARNING = "RAID",
	CHAT_MSG_BATTLEGROUND = "BATTLEGROUND",
	CHAT_MSG_BATTLEGROUND_LEADER = "BATTLEGROUND",
	CHAT_MSG_CHANNEL = "CHANNEL",
	CHAT_MSG_SAY = "SAY",
	CHAT_MSG_YELL = "YELL",
	CHAT_MSG_EMOTE = "EMOTE" -- this never worked, check it sometime.
}

function CH:RemoveSmiley(key)
	if key and (type(key) == "string") then
		CH.Smileys[key] = nil
	end
end

function CH:AddSmiley(key, texture)
	if key and (type(key) == "string" and not find(key, ":%%", 1, true)) and texture then
		CH.Smileys[key] = texture
	end
end

local specialChatIcons
do --this can save some main file locals
	local y = ":13:25"
--	local ElvMelon		= E:TextureString(E.Media.ChatLogos.ElvMelon,y)
--	local ElvRainbow	= E:TextureString(E.Media.ChatLogos.ElvRainbow,y)
--	local ElvRed		= E:TextureString(E.Media.ChatLogos.ElvRed,y)
--	local ElvOrange		= E:TextureString(E.Media.ChatLogos.ElvOrange,y)
--	local ElvYellow		= E:TextureString(E.Media.ChatLogos.ElvYellow,y)
--	local ElvGreen		= E:TextureString(E.Media.ChatLogos.ElvGreen,y)
--	local ElvBlue		= E:TextureString(E.Media.ChatLogos.ElvBlue,y)
--	local ElvPurple		= E:TextureString(E.Media.ChatLogos.ElvPurple,y)
	local ElvPink		= E:TextureString(E.Media.ChatLogos.ElvPink,y)

	specialChatIcons = {
		["Крольчонак-x100"] = ElvPink,
	}
end

local function ChatFrame_OnMouseScroll(frame, delta)
	if delta < 0 then
		if IsShiftKeyDown() then
			frame:ScrollToBottom()
		elseif IsAltKeyDown() then
			frame:ScrollDown()
		else
			for _ = 1, (CH.db.numScrollMessages or 3) do
				frame:ScrollDown()
			end
		end
	elseif delta > 0 then
		if IsShiftKeyDown() then
			frame:ScrollToTop()
		elseif IsAltKeyDown() then
			frame:ScrollUp()
		else
			for _ = 1, (CH.db.numScrollMessages or 3) do
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
	elseif GetNumRaidMembers() > 0 then
		return "/ra "
	elseif GetNumPartyMembers() > 0 then
		return "/p "
	else
		return "/s "
	end
end

function CH:InsertEmotions(msg)
	for word in gmatch(msg, "%s-(%S+)%s*") do
		local pattern = E:EscapeString(word)
		local emoji = CH.Smileys[pattern]

		if emoji then
			pattern = format("%s%s%s", "([%s%p]-)", pattern, "([%s%p]*)")

			if strmatch(msg, pattern) then
				local base64 = LibBase64:Encode(word)

				if base64 then
					msg = gsub(msg, pattern, format("%s%s%s%s%s", "%1|Helvmoji:%%", base64, "|h|cFFffffff|r|h", emoji, "%2"))
				else
					msg = gsub(msg, pattern, format("%s%s%s", "%1", emoji, "%2"))
				end
			end
		end
	end

	return msg
end

function CH:GetSmileyReplacementText(msg)
	if not msg or not self.db.emotionIcons or find(msg, "/run") or find(msg, "/dump") or find(msg, "/script") then
		return msg
	end

	local origlen = strlen(msg)
	local startpos = 1
	local outstr = ""
	local _, pos, endpos

	while startpos <= origlen do
		pos = find(msg, "|H", startpos, true)
		endpos = pos or origlen
		outstr = outstr .. CH:InsertEmotions(strsub(msg, startpos, endpos)) --run replacement on this bit
		startpos = endpos + 1

		if pos then
			_, endpos = find(msg, "|h.-|h", startpos)
			endpos = endpos or origlen

			if startpos < endpos then
				outstr = outstr .. strsub(msg, startpos, endpos) --don't run replacement on this bit
				startpos = endpos + 1
			end
		end
	end

	return outstr
end

function CH:StyleChat(frame)
	local name = frame:GetName()
	_G[name.."TabText"]:FontTemplate(LSM:Fetch("font", self.db.tabFont), self.db.tabFontSize, self.db.tabFontOutline)

	if frame.styled then return end

	frame:SetFrameLevel(4)
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:StripTextures(true)

	_G[name.."ButtonFrame"]:Kill()

	local id = frame:GetID()
	local tab = _G[name.."Tab"]
	local editbox = _G[name.."EditBox"]
	local language = _G[name.."EditBoxLanguage"]

	--Character count
	local charCount = editbox:CreateFontString()
	charCount:FontTemplate()
	charCount:SetTextColor(190, 190, 190, 0.4)
	charCount:Point("TOPRIGHT", editbox, "TOPRIGHT", -5, 0)
	charCount:Point("BOTTOMRIGHT", editbox, "BOTTOMRIGHT", -5, 0)
	charCount:SetJustifyH("CENTER")
	charCount:Width(40)
	editbox.characterCount = charCount

	for _, texName in ipairs(tabTexs) do
		_G[format("%sTab%sLeft", name, texName)]:SetTexture(nil)
		_G[format("%sTab%sMiddle", name, texName)]:SetTexture(nil)
		_G[format("%sTab%sRight", name, texName)]:SetTexture(nil)
	end

	tab:SetHitRectInsets(0, 0, 11, 1)

	tab.glow:Point("BOTTOMLEFT", 8, 2)
	tab.glow:Point("BOTTOMRIGHT", -8, 2)

	hooksecurefunc(tab, "SetAlpha", function(t, alpha)
		if alpha ~= 1 and (not t.isDocked or GeneralDockManager.selected:GetID() == t:GetID()) then
			t:SetAlpha(1)
		elseif alpha < 0.6 then
			t:SetAlpha(0.6)
		end
	end)

	tab.text = _G[name.."TabText"]

	if tab.conversationIcon then
		tab.text:Point("LEFT", tab.leftTexture, "RIGHT", 10, -5)

		tab.conversationIcon:ClearAllPoints()
		tab.conversationIcon:Point("RIGHT", tab.text, "LEFT", -1, 0)
	end

	local function OnTextChanged(editBox)
		local text = editBox:GetText()
		local len = strlen(text)
		local MIN_REPEAT_CHARACTERS = CH.db.numAllowedCombatRepeat

		if MIN_REPEAT_CHARACTERS ~= 0 and InCombatLockdown() then
			if len > MIN_REPEAT_CHARACTERS then
				local repeatChar = true
				for i = 1, MIN_REPEAT_CHARACTERS do
					if strsub(text, -i, -i) ~= strsub(text, (-1 - i), (-1 - i)) then
						repeatChar = false
						break
					end
				end
				if repeatChar then
					editBox:Hide()
					return
				end
			end
		end

		if text == "/tt " then
			local unitname, realm = UnitName("target")
			if unitname and realm and not UnitIsSameServer("player", "target") then
				unitname = format("%s-%s", unitname, gsub(realm, " ", ""))
			end
			if unitname then
				ChatFrame_SendTell(unitname, editBox.chatFrame)
			else
				UIErrorsFrame:AddMessage(E.InfoColor..L["Invalid Target"])
			end
		elseif text == "/gr " then
			editBox:SetText(CH:GetGroupDistribution()..strsub(text, 5))
			ChatEdit_ParseText(editBox, 0)
		end

		editbox.characterCount:SetText(len > 0 and (255 - len) or "")
	end

	local a, b, c = select(6, editbox:GetRegions())
	a:Kill()
	b:Kill()
	c:Kill()

	_G[format("%sEditBoxFocusLeft", name)]:Kill()
	_G[format("%sEditBoxFocusMid", name)]:Kill()
	_G[format("%sEditBoxFocusRight", name)]:Kill()

	editbox:SetTemplate(nil, true)
	editbox:SetAltArrowKeyMode(CH.db.useAltKey)
	editbox:SetAllPoints(LeftChatDataPanel)
	editbox:Hide()

	for _, text in ipairs(ElvCharacterDB.ChatEditHistory) do
		editbox:AddHistoryLine(text)
	end

	editbox:HookScript("OnTextChanged", OnTextChanged)
	self:SecureHook(editbox, "AddHistoryLine", "ChatEdit_AddHistory")

	editbox:HookScript("OnEditFocusGained", function(editBox)
		if not LeftChatPanel:IsShown() then
			LeftChatPanel.editboxforced = true
			LeftChatToggleButton:GetScript("OnEnter")(LeftChatToggleButton)
			editBox:Show()
		end
	end)
	editbox:HookScript("OnEditFocusLost", function(editBox)
		if LeftChatPanel.editboxforced then
			LeftChatPanel.editboxforced = nil
			if LeftChatPanel:IsShown() then
				LeftChatToggleButton:GetScript("OnLeave")(LeftChatToggleButton)
				editBox:Hide()
			end
		end
	end)

	language:Height(22)
	language:StripTextures()
	language:SetTemplate("Transparent")
	language:Point("LEFT", editbox, "RIGHT", -32, 0)

	--copy chat button
	local copyButton = CreateFrame("Frame", format("CopyChatButton%d", id), frame)
	copyButton:EnableMouse(true)
	copyButton:SetAlpha(0.35)
	copyButton:Size(20, 22)
	copyButton:Point("TOPRIGHT", 0, id == 2 and -7 or -2)
	copyButton:SetFrameLevel(frame:GetFrameLevel() + 5)
	frame.copyButton = copyButton

	local copyTexture = frame.copyButton:CreateTexture(nil, "OVERLAY")
	copyTexture:SetInside()
	copyTexture:SetTexture(E.Media.Textures.Copy)
	copyButton.texture = copyTexture

	copyButton:SetScript("OnMouseUp", function(_, btn)
		if btn == "RightButton" and id == 1 then
			ToggleFrame(ChatMenu)
		else
			CH:CopyChat(frame)
		end
	end)

	copyButton:SetScript("OnEnter", function(button) button:SetAlpha(1) end)
	copyButton:SetScript("OnLeave", function(button)
		if _G[button:GetParent():GetName().."TabText"]:IsShown() then
			button:SetAlpha(0.35)
		else
			button:SetAlpha(0)
		end
	end)

	frame.styled = true
end

function CH:AddMessage(msg, infoR, infoG, infoB, infoID, accessID, typeID, extraData, isHistory, historyTime)
	if CH.db.timeStampFormat ~= "NONE" then
		local timeStamp = BetterDate(CH.db.timeStampFormat, isHistory == "ElvUI_ChatHistory" and historyTime or time())

		if CH.db.useCustomTimeColor then
			local color = CH.db.customTimeColor
			local hexColor = E:RGBToHex(color.r, color.g, color.b)
			msg = format("%s[%s]|r %s", hexColor, timeStamp, msg)
		else
			msg = format("[%s] %s", timeStamp, msg)
		end
	end

	self.OldAddMessage(self, msg, infoR, infoG, infoB, infoID, accessID, typeID, extraData)
end

function CH:UpdateSettings()
	for _, frameName in ipairs(CHAT_FRAMES) do
		_G[frameName.."EditBox"]:SetAltArrowKeyMode(CH.db.useAltKey)
	end
end

local removeIconFromLine
do
	local raidIconFunc = function(x)
		x = x ~= "" and _G["RAID_TARGET_"..x]
		return x and ("{"..strlower(x).."}") or ""
	end
	local stripTextureFunc = function(w, x, y)
		if x == "" then
			return (w ~= "" and w) or (y ~= "" and y) or ""
		end
	end
	local hyperLinkFunc = function(w, x, y)
		if w ~= "" then return end
		local emoji = (x ~= "" and x) and strmatch(x, "elvmoji:%%(.+)")
		return (emoji and LibBase64:Decode(emoji)) or y
	end
	removeIconFromLine = function(text)
		text = gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d+):0|t", raidIconFunc) --converts raid icons into {star} etc, if possible.
		text = gsub(text, "(%s?)(|?)|T.-|t(%s?)", stripTextureFunc) --strip any other texture out but keep a single space from the side(s).
		text = gsub(text, "(|?)|H(.-)|h(.-)|h", hyperLinkFunc) --strip hyperlink data only keeping the actual text.
		return text
	end
end

local function colorizeLine(text, r, g, b)
	local hexCode = E:RGBToHex(r, g, b)
	local hexReplacement = format("|r%s", hexCode)

	text = gsub(text, "|r", hexReplacement) -- If the message contains color strings then we need to add message color hex code after every "|r"
	text = format("%s%s|r", hexCode, text) -- Add message color

	return text
end

local chatTypeIndexToName = {}
local copyLines = {}

for chatType in pairs(ChatTypeInfo) do
	chatTypeIndexToName[GetChatTypeIndex(chatType)] = chatType
end

function CH:GetLines(frame)
	local lineCount = 0
	local _, message, lineID, info, r, g, b

	for i = 1, frame:GetNumMessages() do
		message, _, lineID = frame:GetMessageInfo(i)

		if message then
			info = ChatTypeInfo[chatTypeIndexToName[lineID]]

			if info then
				r, g, b = info.r, info.g, info.b
			else
				r, g, b = 1, 1, 1
			end

			message = removeIconFromLine(message)
			message = colorizeLine(message, r, g, b)

			lineCount = lineCount + 1
			copyLines[lineCount] = message
		end
	end

	return lineCount
end

function CH:CopyChat(frame)
	if not self.copyChatFrame:IsShown() then
		local lineCount = self:GetLines(frame)
		local text = tconcat(copyLines, "\n", 1, lineCount)

		self.copyChatFrame.editBox:SetText(text)
		self.copyChatFrame:Show()
	else
		self.copyChatFrame:Hide()
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
	for _, frameName in ipairs(CHAT_FRAMES) do
		local frame = _G[frameName.."EditBox"]

		frame:ClearAllPoints()
		if not E.db.datatexts.leftChatPanel and self.db.editBoxPosition == "BELOW_CHAT" then
			frame:Point("TOPLEFT", ChatFrame1, "BOTTOMLEFT", -4, -4)
			frame:Point("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 7, -LeftChatTab:GetHeight() - 4)
		elseif self.db.editBoxPosition == "BELOW_CHAT" then
			frame:SetAllPoints(LeftChatDataPanel)
		else
			frame:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -1, 3)
			frame:Point("TOPRIGHT", ChatFrame1, "TOPRIGHT", 4, LeftChatTab:GetHeight() + 3)
		end
	end

	CH:PositionChat(true)
end

local function FindRightChatID()
	local rightChatID

	for id, frameName in ipairs(CHAT_FRAMES) do
		local chat = _G[frameName]

		if E:FramesOverlap(chat, RightChatPanel) and not E:FramesOverlap(chat, LeftChatPanel) then
			rightChatID = id
			break
		end
	end

	return rightChatID
end

function CH:UpdateChatTabs()
	local fadeUndockedTabs = self.db.fadeUndockedTabs
	local fadeTabsNoBackdrop = self.db.fadeTabsNoBackdrop

	for id, frameName in ipairs(CHAT_FRAMES) do
		local chat = _G[frameName]
		local tab = _G[format("%sTab", frameName)]

		if chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and (id == self.RightChatWindowID) then
			if self.db.panelBackdrop == "HIDEBOTH" or self.db.panelBackdrop == "LEFT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not chat.isDocked and chat:IsShown() then
			tab:SetParent(RightChatPanel)
			chat:SetParent(RightChatPanel)
			CH:SetupChatTabs(tab, fadeUndockedTabs and true or false)
		else
			if self.db.panelBackdrop == "HIDEBOTH" or self.db.panelBackdrop == "RIGHT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		end
	end
end

function CH:RefreshToggleButtons()
	LeftChatToggleButton:SetAlpha(E.db.LeftChatPanelFaded and E.db.chat.fadeChatToggles and 0 or 1)
	RightChatToggleButton:SetAlpha(E.db.RightChatPanelFaded and E.db.chat.fadeChatToggles and 0 or 1)
end

function CH:PositionChat(override)
	if (InCombatLockdown() and not override and self.initialMove) or (IsMouseButtonDown("LeftButton") and not override) then return end
	if not RightChatPanel or not LeftChatPanel then return end
	if not self.db.lockPositions or not E.private.chat.enable then return end

	RightChatPanel:Size(self.db.separateSizes and self.db.panelWidthRight or self.db.panelWidth, self.db.separateSizes and self.db.panelHeightRight or self.db.panelHeight)
	LeftChatPanel:Size(self.db.panelWidth, self.db.panelHeight)

	CombatLogQuickButtonFrame_Custom:Size(LeftChatTab:GetWidth(), LeftChatTab:GetHeight())

	self.RightChatWindowID = FindRightChatID()

	local fadeUndockedTabs = self.db.fadeUndockedTabs
	local fadeTabsNoBackdrop = self.db.fadeTabsNoBackdrop

	for id, frameName in ipairs(CHAT_FRAMES) do
		local BASE_OFFSET = 57 + E.Spacing*3

		local chat = _G[frameName]
		local tab = _G[format("%sTab", frameName)]

		tab.isDocked = chat.isDocked
		tab.owner = chat

		if chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and id == self.RightChatWindowID then
			chat:ClearAllPoints()

			if E.db.datatexts.rightChatPanel then
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 4)
			else
				BASE_OFFSET = BASE_OFFSET - 24
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "BOTTOMLEFT", 1, 2)
			end
			if id ~= 2 then
				chat:Size((self.db.separateSizes and self.db.panelWidthRight or self.db.panelWidth) - 11, (self.db.separateSizes and self.db.panelHeightRight or self.db.panelHeight) - BASE_OFFSET)
			else
				chat:Size(self.db.panelWidth - 11, (self.db.panelHeight - BASE_OFFSET) - CombatLogQuickButtonFrame_Custom:GetHeight())
			end

			--Pass a 2nd argument which prevents an infinite loop in our ON_FCF_SavePositionAndDimensions function
			if chat:GetLeft() then
				FCF_SavePositionAndDimensions(chat, true)
			end

			tab:SetParent(RightChatPanel)
			chat:SetParent(RightChatPanel)

			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end
			if self.db.panelBackdrop == "HIDEBOTH" or self.db.panelBackdrop == "LEFT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not chat.isDocked and chat:IsShown() then
			tab:SetParent(UIParent)
			chat:SetParent(UIParent)
			CH:SetupChatTabs(tab, fadeUndockedTabs and true or false)
		else
			if id ~= 2 and not (id > NUM_CHAT_WINDOWS) then
				chat:ClearAllPoints()
				if E.db.datatexts.leftChatPanel then
					chat:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 4)
				else
					BASE_OFFSET = BASE_OFFSET - 24
					chat:Point("BOTTOMLEFT", LeftChatToggleButton, "BOTTOMLEFT", 1, 2)
				end
				chat:Size(self.db.panelWidth - 11, (self.db.panelHeight - BASE_OFFSET))

				--Pass a 2nd argument which prevents an infinite loop in our ON_FCF_SavePositionAndDimensions function
				if chat:GetLeft() then
					FCF_SavePositionAndDimensions(chat, true)
				end
			end
			chat:SetParent(LeftChatPanel)
			if id > 2 then
				tab:SetParent(GeneralDockManagerScrollFrameChild)
			else
				tab:SetParent(GeneralDockManager)
			end
			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end

			if self.db.panelBackdrop == "HIDEBOTH" or self.db.panelBackdrop == "RIGHT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		end
	end

	LO:RepositionChatDataPanels()

	self.initialMove = true
end

function CH:Panels_ColorUpdate()
	local panelColor = self.db.panelColor
	LeftChatPanel.backdrop:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)
	RightChatPanel.backdrop:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)
end

function CH:UpdateChatTabColors()
	for _, frameName in ipairs(CHAT_FRAMES) do
		local tab = _G[format("%sTab", frameName)]
		CH:FCFTab_UpdateColors(tab, tab.selected)
	end
end
E.valueColorUpdateFuncs[CH.UpdateChatTabColors] = true

function CH:ScrollToBottom(frame)
	frame:ScrollToBottom()

	self:CancelTimer(frame.ScrollTimer, true)
end

function CH:PrintURL(url)
	return "|cFFFFFFFF[|Hurl:"..url.."|h"..url.."|h]|r "
end

local tempURLs = {}
local tempURLsCount = 0
local function tempReplaceURL(url)
	tempURLsCount = tempURLsCount + 1
	local id = "|Hurl:"..tempURLsCount.."|h"
	tempURLs[id] = CH:PrintURL(url)
	return id
end

function CH:FindURL(event, msg, author, ...)
	if not CH.db.url then
		msg = CH:CheckKeyword(msg, author)
		msg = CH:GetSmileyReplacementText(msg)
		return false, msg, author, ...
	end

	local text, tag = msg, strmatch(msg, "{(.-)}")
	if tag and ICON_TAG_LIST[strlower(tag)] then
		text = gsub(gsub(text, "(%S)({.-})", "%1 %2"), "({.-})(%S)", "%1 %2")
	end

	local x, found = 0
	local newMsg = gsub(gsub(text, "(%S)(|c.-|H.-|h.-|h|r)", "%1 %2"), "(|c.-|H.-|h.-|h|r)(%S)", "%1 %2")

	-- https://example.com
	newMsg, found = gsub(newMsg, "([A-z][A-z0-9+-%.]+://%S+)", tempReplaceURL)
	x = x + found
	-- www.example.com
	newMsg, found = gsub(newMsg, "(www%.[A-z0-9-]+%.%S+)", tempReplaceURL)
	x = x + found
	-- example@example.com
	newMsg, found = gsub(newMsg, "(%S+@[A-z][A-z0-9-]+%.[A-z0-9-]+)", tempReplaceURL)
	x = x + found
	-- 1.1.1.1[:1337]
	newMsg, found = gsub(newMsg, "(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?[:%d]*)", tempReplaceURL)
	x = x + found

	if x > 0 then
		newMsg = gsub(newMsg, "(|Hurl:%d+|h)", tempURLs)
		wipe(tempURLs)
		tempURLsCount = 0

		newMsg = CH:CheckKeyword(newMsg, author)
		newMsg = CH:GetSmileyReplacementText(newMsg)
		return false, newMsg, author, ...
	end

	msg = CH:CheckKeyword(msg, author)
	msg = CH:GetSmileyReplacementText(msg)

	return false, msg, author, ...
end

function CH:SetChatEditBoxMessage(message)
	local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
	local editBoxText = ChatFrameEditBox:GetText()

	if not ChatFrameEditBox:IsShown() then
		ChatEdit_ActivateChat(ChatFrameEditBox)
	end

	if editBoxText and editBoxText ~= "" then
		ChatFrameEditBox:SetText("")
	end

	ChatFrameEditBox:Insert(message)
	ChatFrameEditBox:HighlightText()
end

local function HyperLinkedURL(data)
	if strsub(data, 1, 3) == "url" then
		local currentLink = strsub(data, 5)
		if currentLink and currentLink ~= "" then
			CH:SetChatEditBoxMessage(currentLink)
		end
	end
end

local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(data, ...)
	if strsub(data, 1, 3) == "url" then
		HyperLinkedURL(data)
	else
		SetHyperlink(self, data, ...)
	end
end

local hyperLinkEntered
function CH:OnHyperlinkEnter(frame, refString)
	if InCombatLockdown() then return end
	local linkToken = strmatch(refString, "^([^:]+)")
	if hyperlinkTypes[linkToken] then
		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(refString)
		GameTooltip:Show()
		hyperLinkEntered = frame
	end
end

function CH:OnHyperlinkLeave()
	if hyperLinkEntered then
		hyperLinkEntered = nil
		GameTooltip:Hide()
	end
end

function CH:OnMessageScrollChanged(frame)
	if hyperLinkEntered == frame then
		hyperLinkEntered = nil
		GameTooltip:Hide()
	end
end

function CH:ToggleHyperlink(enable)
	for _, frameName in ipairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		local hooked = self.hooks and self.hooks[frame] and self.hooks[frame].OnHyperlinkEnter
		if enable and not hooked then
			self:HookScript(frame, "OnHyperlinkEnter")
			self:HookScript(frame, "OnHyperlinkLeave")
			self:HookScript(frame, "OnMessageScrollChanged")
		elseif not enable and hooked then
			self:Unhook(frame, "OnHyperlinkEnter")
			self:Unhook(frame, "OnHyperlinkLeave")
			self:Unhook(frame, "OnMessageScrollChanged")
		end
	end
end

function CH:DisableChatThrottle()
	wipe(throttle)
end

function CH:ShortChannel()
	return format("|Hchannel:%s|h[%s]|h", self, DEFAULT_STRINGS[strupper(self)] or gsub(self, "channel:", ""))
end

function CH:HandleShortChannels(msg)
	msg = gsub(msg, "|Hchannel:(.-)|h%[(.-)%]|h", self.ShortChannel)
	msg = gsub(msg, "CHANNEL:", "")
	msg = gsub(msg, "^(.-|h) "..L["whispers"], "%1")
	msg = gsub(msg, "^(.-|h) "..L["says"], "%1")
	msg = gsub(msg, "^(.-|h) "..L["yells"], "%1")
	msg = gsub(msg, "<"..AFK..">", "[|cffFF0000"..AFK.."|r] ")
	msg = gsub(msg, "<"..DND..">", "[|cffE7E716"..DND.."|r] ")
	msg = gsub(msg, "^%["..RAID_WARNING.."%]", "["..L["RW"].."]")

	return msg
end

local PluginIconsCalls = {}
function CH:AddPluginIcons(func)
	tinsert(PluginIconsCalls, func)
end

function CH:GetPluginIcon(sender, name, realm)
	local icon
	for _,func in ipairs(PluginIconsCalls) do
		icon = func(sender, name, realm)
		if icon and icon ~= "" then break end
	end
	return icon
end

function CH:GetColoredName(event, _, arg2, _, _, _, _, _, arg8, _, _, _, arg12)
	local chatType = strsub(event, 10)
	if strsub(chatType, 1, 7) == "WHISPER" then
		chatType = "WHISPER"
	elseif strsub(chatType, 1, 7) == "CHANNEL" then
		chatType = "CHANNEL"..arg8
	end

	local info = ChatTypeInfo[chatType]
	if info and info.colorNameByClass and arg12 ~= "" then
		local _, englishClass = GetPlayerInfoByGUID(arg12)

		if englishClass then
			local classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[englishClass] or RAID_CLASS_COLORS[englishClass]
			if not classColorTable then
				return arg2
			end
			return format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..arg2.."\124r"
		end
	end

	return arg2
end

function CH:ChatFrame_MessageEventHandler(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, isHistory, historyTime, historyName)
	if strsub(event, 1, 8) == "CHAT_MSG" then
		local historySavedName --we need to extend the arguments on CH.ChatFrame_MessageEventHandler so we can properly handle saved names without overriding
		if isHistory == "ElvUI_ChatHistory" then
			historySavedName = historyName
		end

		local chatType = strsub(event, 10)
		local info = ChatTypeInfo[chatType]

		local chatFilters = ChatFrame_GetMessageEventFilters(event)
		if chatFilters then
			for _, filterFunc in next, chatFilters do
				local filter, newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12 = filterFunc(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
				if filter then
					return true
				elseif newarg1 then
					arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12
				end
			end
		end

		local _, _, englishClass, _, _, _, name, realm = pcall(GetPlayerInfoByGUID, arg12)
		local coloredName = historySavedName or CH:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)

		local nameWithRealm = strmatch(realm ~= "" and realm or E.myrealm, "%s*(%S+)$")
		if name and name ~= "" then
			nameWithRealm = name.."-"..nameWithRealm
			CH.ClassNames[strlower(name)] = englishClass
			CH.ClassNames[strlower(nameWithRealm)] = englishClass
		end

		local channelLength = strlen(arg4)
		local infoType = chatType
		if (strsub(chatType, 1, 7) == "CHANNEL") and (chatType ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (chatType ~= "CHANNEL_NOTICE_USER")) then
			if arg1 == "WRONG_PASSWORD" then
				local staticPopup = _G[StaticPopup_Visible("CHAT_CHANNEL_PASSWORD") or ""]
				if staticPopup and strupper(staticPopup.data) == strupper(arg9) then
					-- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
					return
				end
			end

			local found = 0
			for index, value in pairs(frame.channelList) do
				if channelLength > strlen(value) then
					-- arg9 is the channel name without the number in front...
					if ((arg7 > 0) and (frame.zoneChannelList[index] == arg7)) or (strupper(value) == strupper(arg9)) then
						found = 1
						infoType = "CHANNEL"..arg8
						info = ChatTypeInfo[infoType]
						if (chatType == "CHANNEL_NOTICE") and (arg1 == "YOU_LEFT") then
							frame.channelList[index] = nil
							frame.zoneChannelList[index] = nil
						end
						break
					end
				end
			end
			if (found == 0) or not info then
				return true
			end
		end

		local chatGroup = Chat_GetChatCategory(chatType)
		local chatTarget
		if chatGroup == "CHANNEL" or chatGroup == "BN_CONVERSATION" then
			chatTarget = tostring(arg8)
		elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
			chatTarget = strupper(arg2)
		end

		if FCFManager_ShouldSuppressMessage(frame, chatGroup, chatTarget) then
			return true
		end

		if chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
			if frame.privateMessageList and not frame.privateMessageList[strlower(arg2)] then
				return true
			elseif frame.excludePrivateMessageList and frame.excludePrivateMessageList[strlower(arg2)] then
				return true
			end
		elseif chatGroup == "BN_CONVERSATION" then
			if frame.bnConversationList and not frame.bnConversationList[arg8] then
				return true
			elseif frame.excludeBNConversationList and frame.excludeBNConversationList[arg8] then
				return true
			end
		end

		if chatType == "SYSTEM" or chatType == "SKILL" or chatType == "LOOT" or chatType == "MONEY"
		or chatType == "OPENING" or chatType == "TRADESKILLS" or chatType == "PET_INFO" or chatType == "TARGETICONS" then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,7) == "COMBAT_" then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,6) == "SPELL_" then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,10) == "BG_SYSTEM_" then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,11) == "ACHIEVEMENT" then
			frame:AddMessage(format(arg1, "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,18) == "GUILD_ACHIEVEMENT" then
			frame:AddMessage(format(arg1, "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
		elseif chatType == "IGNORED" then
			frame:AddMessage(format(CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
		elseif chatType == "FILTERED" then
			frame:AddMessage(format(CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
		elseif chatType == "RESTRICTED" then
			frame:AddMessage(CHAT_RESTRICTED, info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
		elseif chatType == "CHANNEL_LIST" then
			if channelLength > 0 then
				frame:AddMessage(format(_G["CHAT_"..chatType.."_GET"]..arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
			else
				frame:AddMessage(arg1, info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
			end
		elseif chatType == "CHANNEL_NOTICE_USER" then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"]
			if not globalstring then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"]
			end

			if arg5 ~= "" then
				-- TWO users in this notice (E.G. x kicked y)
				frame:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
			elseif arg1 == "INVITE" then
				frame:AddMessage(format(globalstring, arg4, arg2), info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
			else
				frame:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id, false, nil, nil, isHistory, historyTime)
			end
		elseif chatType == "CHANNEL_NOTICE" then
			if arg1 == "NOT_IN_LFG" then return end
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"]
			if not globalstring then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"]
			end
			if arg10 > 0 then
				arg4 = arg4.." "..arg10
			end

			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(chatType), arg8)
			local typeID = ChatHistory_GetAccessID(infoType, arg8)
			frame:AddMessage(format(globalstring, arg8, arg4), info.r, info.g, info.b, info.id, false, accessID, typeID, isHistory, historyTime)
		else
			local body

			-- Add AFK/DND flags
			-- Player Flags
			local pflag, chatIcon, pluginChatIcon = "", specialChatIcons[nameWithRealm], CH:GetPluginIcon(nameWithRealm, name, realm)
			if type(chatIcon) == "function" then chatIcon = chatIcon() end
			if arg6 ~= "" then
				if arg6 == "GM" then
					--If it was a whisper, dispatch it to the GMChat addon.
					if chatType == "WHISPER" then
						return
					end
					--Add Blizzard Icon, this was sent by a GM
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t "
				elseif arg6 == "DEV" then
					--Add Blizzard Icon, this was sent by a Dev
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t "
				elseif arg6 == "DND" or arg6 == "AFK" then
					pflag = (pflag or "").._G["CHAT_FLAG_"..arg6]
				else
					pflag = _G["CHAT_FLAG_"..arg6]
				end
			else
				-- Special Chat Icon
				if chatIcon then
					pflag = pflag..chatIcon
				end
				-- Plugin Chat Icon
				if pluginChatIcon then
					pflag = pflag..pluginChatIcon
				end
			end

			if chatType == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) then
				return
			end

			local showLink = 1
			if strsub(chatType, 1, 7) == "MONSTER" or strsub(chatType, 1, 9) == "RAID_BOSS" then
				showLink = nil
			else
				arg1 = gsub(arg1, "%%", "%%%%")
			end

			if chatType == "PARTY_LEADER" and HasLFGRestrictions() then
				chatType = "PARTY_GUIDE"
			end

			-- Search for icon links and replace them with texture links.
			local term
			for tag in gmatch(arg1, "%b{}") do
				term = strlower(gsub(tag, "[{}]", ""))
				if ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] then
					arg1 = gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]].."0|t")
				end
			end

			local playerLink

			if chatType ~= "BN_WHISPER" and chatType ~= "BN_WHISPER_INFORM" and chatType ~= "BN_CONVERSATION" then
				playerLink = "|Hplayer:"..arg2..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h"
			else
				playerLink = "|HBNplayer:"..arg2..":"..arg13..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h"
			end

			if arg3 ~= "" and arg3 ~= "Universal" and arg3 ~= frame.defaultLanguage then
				local languageHeader = "["..arg3.."] "
				if showLink and arg2 ~= "" then
					body = format(_G["CHAT_"..chatType.."_GET"]..languageHeader..arg1, pflag..playerLink.."["..coloredName.."]".."|h")
				else
					body = format(_G["CHAT_"..chatType.."_GET"]..languageHeader..arg1, pflag..arg2)
				end
			else
				if not showLink or strlen(arg2) == 0 then
					body = format(_G["CHAT_"..chatType.."_GET"]..arg1, pflag..arg2, arg2)
				else
					if chatType == "EMOTE" then
						body = format(_G["CHAT_"..chatType.."_GET"]..arg1, pflag..playerLink..coloredName.."|h")
					elseif chatType == "TEXT_EMOTE" then
						body = gsub(arg1, arg2, pflag..playerLink..coloredName.."|h", 1)
					else
						body = format(_G["CHAT_"..chatType.."_GET"]..arg1, pflag..playerLink.."["..coloredName.."]".."|h")
					end
				end
			end

			-- Add Channel
			arg4 = gsub(arg4, "%s%-%s.*", "")
			if chatGroup == "BN_CONVERSATION" then
				body = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8)..body
			elseif channelLength > 0 then
				body = "|Hchannel:channel:"..arg8.."|h["..arg4.."]|h "..body
			end

			if CH.db.shortChannels and (chatType ~= "EMOTE" and chatType ~= "TEXT_EMOTE") then
				body = CH:HandleShortChannels(body)
			end

			local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget)
			local typeID = ChatHistory_GetAccessID(infoType, chatTarget)

			if not historySavedName and arg2 ~= E.myname and not CH.SoundTimer and (not CH.db.noAlertInCombat or not InCombatLockdown()) then
				local channels = chatGroup ~= "WHISPER" and chatGroup or (chatType == "WHISPER" or chatType == "BN_WHISPER") and "WHISPER"
				local alertType = CH.db.channelAlerts[channels]

				if alertType and alertType ~= "None" then
					PlaySoundFile(LSM:Fetch("sound", alertType), "Master")
					CH.SoundTimer = E:Delay(1, CH.ThrottleSound)
				end
			end

			frame:AddMessage(body, info.r, info.g, info.b, info.id, false, accessID, typeID, isHistory, historyTime)


			if not historySavedName and (chatType == "WHISPER" or chatType == "BN_WHISPER") then
				ChatEdit_SetLastTellTarget(arg2)
			end
		end

		if not historySavedName and not frame:IsShown() then
			if (frame == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (frame ~= DEFAULT_CHAT_FRAME and info.flashTab) then
				if not CHAT_OPTIONS.HIDE_FRAME_ALERTS or chatType == "WHISPER" or chatType == "BN_WHISPER" then
					FCF_StartAlertFlash(frame) --This would taint if we were not using LibChatAnims
				end
			end
		end

		return true
	end
end

function CH:ChatFrame_ConfigEventHandler(...)
	return ChatFrame_ConfigEventHandler(...)
end

function CH:ChatFrame_SystemEventHandler(...)
	return ChatFrame_SystemEventHandler(...)
end

function CH:ChatFrame_OnEvent(...)
	if CH:ChatFrame_ConfigEventHandler(...) then return end
	if CH:ChatFrame_SystemEventHandler(...) then return end
	if CH:ChatFrame_MessageEventHandler(...) then return end
end

function CH:FloatingChatFrame_OnEvent(...)
	CH:ChatFrame_OnEvent(...)
	FloatingChatFrame_OnEvent(...)
end

local function FloatingChatFrameOnEvent(...)
	CH:FloatingChatFrame_OnEvent(...)
end

function CH:UpdateDockState()
	if self.db.lockPositions then
		FCF_SetLocked(ChatFrame1, 1)
		GeneralDockManager:SetParent(LeftChatPanel)
		GeneralDockManagerOverflowButton:ClearAllPoints()
		GeneralDockManagerOverflowButton:Point("BOTTOMRIGHT", LeftChatTab, "BOTTOMRIGHT", -2, 2)
	else
		GeneralDockManager:SetParent(UIParent)
		GeneralDockManagerOverflowButton:ClearAllPoints()
		GeneralDockManagerOverflowButton:Point("BOTTOMRIGHT", GeneralDockManager, 0, -1)
	end
end

function CH:SetupChat()
	if not E.private.chat.enable then return end

	for id, frameName in ipairs(CHAT_FRAMES) do
		local frame = _G[frameName]

		self:StyleChat(frame)
		FCFTab_UpdateAlpha(frame)

		local _, fontSize = frame:GetFont()
		frame:FontTemplate(LSM:Fetch("font", self.db.font), fontSize, self.db.fontOutline)

		if self.db.fontOutline ~= "NONE" then
			frame:SetShadowColor(0, 0, 0, 0.2)
		else
			frame:SetShadowColor(0, 0, 0, 1)
		end

		if self.db.maxLines ~= frame:GetMaxLines() then
			frame:SetMaxLines(self.db.maxLines)
		end
		frame:SetTimeVisible(self.db.inactivityTimer)
		frame:SetShadowOffset(E.mult, -E.mult)
		frame:SetFading(self.db.fade)

		if id ~= 2 and not frame.OldAddMessage then
			--Don't add timestamps to combat log, they don't work.
			--This usually taints, but LibChatAnims should make sure it doesn't.
			frame.OldAddMessage = frame.AddMessage
			frame.AddMessage = CH.AddMessage
		end

		if not frame.scriptsSet then
			frame:SetScript("OnMouseWheel", ChatFrame_OnMouseScroll)

			if id ~= 2 then
				frame:SetScript("OnEvent", FloatingChatFrameOnEvent)
			end

			hooksecurefunc(frame, "SetScript", function(f, script, func)
				if script == "OnMouseWheel" and func ~= ChatFrame_OnMouseScroll then
					f:SetScript(script, ChatFrame_OnMouseScroll)
				end
			end)
			frame.scriptsSet = true
		end
	end

	self:ToggleHyperlink(self.db.hyperlinkHover)

	self:UpdateDockState()
	self:PositionChat(true)

	if not self.HookSecured then
		self:SecureHook("FCF_OpenTemporaryWindow", "SetupChat")
		self.HookSecured = true
	end
end

local function PrepareMessage(author, message)
	if author ~= "" and message ~= "" then
		return format("%s%s", strupper(author), message)
	end
end

function CH:ChatThrottleHandler(author, msg, when)
	msg = PrepareMessage(author, msg)

	if msg then
		for message, msgTime in pairs(throttle) do
			if (when - msgTime) >= self.db.throttleInterval then
				throttle[message] = nil
			end
		end

		if not throttle[msg] then
			throttle[msg] = when
		end
	end
end

function CH:ChatThrottleBlockFlag(author, message, when)
	if author ~= E.myname and self.db.throttleInterval ~= 0 then
		message = PrepareMessage(author, message)
		local msgTime = message and throttle[message]

		if msgTime then
			if (when - msgTime) > self.db.throttleInterval then
				return false, message
			end
		else
			return false
		end
	else
		return false
	end
	return true
end

function CH:ChatThrottleIntervalHandler(event, message, author, ...)
	local when = time()
	local blockFlag, formattedMessage = self:ChatThrottleBlockFlag(author, message, when)

	if blockFlag then
		return true
	else
		if formattedMessage then
			throttle[formattedMessage] = when
		end
		return self:FindURL(event, message, author, ...)
	end
end

function CH:CHAT_MSG_CHANNEL(event, message, author, ...)
	return CH:ChatThrottleIntervalHandler(event, message, author, ...)
end

function CH:CHAT_MSG_YELL(event, message, author, ...)
	return CH:ChatThrottleIntervalHandler(event, message, author, ...)
end

function CH:CHAT_MSG_SAY(event, message, author, ...)
	return CH:ChatThrottleIntervalHandler(event, message, author, ...)
end

function CH:ThrottleSound()
	CH.SoundTimer = nil
end

local protectLinks = {}
function CH:CheckKeyword(message, author)
	local canPlaySound = author ~= E.myname and not self.SoundTimer and self.db.keywordSound ~= "None" and (not self.db.noAlertInCombat or not InCombatLockdown())

	for hyperLink in gmatch(message, "|%x+|H.-|h.-|h|r") do
		local tempLink = gsub(hyperLink, "%s", "|s")
		message = gsub(message, E:EscapeString(hyperLink), tempLink)
		protectLinks[hyperLink] = tempLink

		if canPlaySound then
			for keyword in pairs(CH.Keywords) do
				if hyperLink == keyword then
					PlaySoundFile(LSM:Fetch("sound", self.db.keywordSound), "Master")
					self.SoundTimer = E:Delay(1, self.ThrottleSound)
					canPlaySound = nil
					break
				end
			end
		end
	end

	local rebuiltString
	local isFirstWord = true
	local protectLinksNext = next(protectLinks)

	for word in gmatch(message, "%s-%S+%s*") do
		if not protectLinksNext or not protectLinks[gsub(gsub(word, "%s", ""), "|s", " ")] then
			local tempWord = gsub(word, "[%s%p]", "")
			local lowerCaseWord = strlower(tempWord)

			for keyword in pairs(CH.Keywords) do
				if lowerCaseWord == strlower(keyword) then
					word = gsub(word, tempWord, format("%s%s|r", E.media.hexvaluecolor, tempWord))

					if canPlaySound then
						PlaySoundFile(LSM:Fetch("sound", self.db.keywordSound), "Master")
						self.SoundTimer = E:Delay(1, self.ThrottleSound)
						canPlaySound = nil
					end
				end
			end

			if self.db.classColorMentionsChat then
				tempWord = gsub(word, "^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$", "%1%2")
				lowerCaseWord = strlower(tempWord)

				local classMatch = CH.ClassNames[lowerCaseWord]
				local wordMatch = classMatch and lowerCaseWord

				if wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch] then
					local classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classMatch] or RAID_CLASS_COLORS[classMatch]
					word = gsub(word, gsub(tempWord, "%-", "%%-"), format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
				end
			end
		end

		if isFirstWord then
			rebuiltString = word
			isFirstWord = nil
		else
			rebuiltString = rebuiltString..word
		end
	end

	for hyperLink, tempLink in pairs(protectLinks) do
		rebuiltString = gsub(rebuiltString, E:EscapeString(tempLink), hyperLink)
		protectLinks[hyperLink] = nil
	end

	return rebuiltString
end

function CH:AddLines(lines, ...)
	for i = select("#", ...), 1, -1 do
		local x = select(i, ...)
		if x:IsObjectType("FontString") and not x:GetName() then
			tinsert(lines, x:GetText())
		end
	end
end

function CH:ChatEdit_OnEnterPressed(editBox)
	local chatType = editBox:GetAttribute("chatType")
	local chatFrame = chatType and editBox:GetParent()
	if chatFrame and (not chatFrame.isTemporary) and (ChatTypeInfo[chatType].sticky == 1) then
		if not self.db.sticky then chatType = "SAY" end
		editBox:SetAttribute("chatType", chatType)
	end
end

function CH:SetChatFont(dropDown, chatFrame, fontSize)
	if not chatFrame then
		chatFrame = FCF_GetCurrentChatFrame()
	end
	if not fontSize then
		fontSize = dropDown.value
	end

	chatFrame:FontTemplate(LSM:Fetch("font", self.db.font), fontSize, self.db.fontOutline)

	if self.db.fontOutline ~= "NONE" then
		chatFrame:SetShadowColor(0, 0, 0, 0.2)
	else
		chatFrame:SetShadowColor(0, 0, 0, 1)
	end
	chatFrame:SetShadowOffset(E.mult, -E.mult)
end

CH.SecureSlashCMD = {
	"^/assist",
	"^/camp",
	"^/cancelaura",
	"^/cancelform",
	"^/cast",
	"^/castsequence",
	"^/equip",
	"^/exit",
	"^/logout",
	"^/reload",
	"^/rl",
	"^/startattack",
	"^/stopattack",
	"^/tar",
	"^/target",
	"^/use"
}

function CH:ChatEdit_AddHistory(_, text)
	text = strtrim(text)

	if text ~= "" then
		for _, command in ipairs(CH.SecureSlashCMD) do
			if find(text, command) then
				return
			end
		end

		for i, historyText in ipairs(ElvCharacterDB.ChatEditHistory) do
			if historyText == text then
				tremove(ElvCharacterDB.ChatEditHistory, i)
				break
			end
		end

		tinsert(ElvCharacterDB.ChatEditHistory, text)

		if #ElvCharacterDB.ChatEditHistory > CH.db.editboxHistorySize then
			tremove(ElvCharacterDB.ChatEditHistory, 1)
		end
	end
end

function CH:UpdateChatKeywords()
	wipe(CH.Keywords)

	local keywords = self.db.keywords
	keywords = gsub(keywords, ",%s", ",")

	for stringValue in gmatch(keywords, "[^,]+") do
		if stringValue ~= "" then
			CH.Keywords[stringValue] = true
		end
	end
end

function CH:UpdateFading()
	for _, frameName in ipairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		frame:SetTimeVisible(self.db.inactivityTimer)
		frame:SetFading(self.db.fade)
	end
end

function CH:DisplayChatHistory()
	local data = ElvCharacterDB.ChatHistoryLog
	if not next(data) then return end

	CH.SoundTimer = true
	for _, frameName in ipairs(CHAT_FRAMES) do
		for _, d in ipairs(data) do
			if type(d) == "table" then
				for _, messageType in ipairs(_G[frameName].messageTypeList) do
					if (not historyTypes[d[50]] or self.db.showHistory[historyTypes[d[50]]]) and gsub(strsub(d[50], 10), "_INFORM", "") == messageType then
						self:ChatFrame_MessageEventHandler(_G[frameName],d[50],d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8],d[9],d[10],d[11],d[12],0,"ElvUI_ChatHistory",d[51],d[52])
					end
				end
			end
		end
	end
	CH.SoundTimer = nil
end

tremove(ChatTypeGroup.GUILD, 2)
function CH:DelayGuildMOTD()
	tinsert(ChatTypeGroup.GUILD, 2, "GUILD_MOTD")

	local registerGuildEvents = function(msg)
		for _, frameName in ipairs(CHAT_FRAMES) do
			local chat = _G[frameName]
			if chat:IsEventRegistered("CHAT_MSG_GUILD") then
				if msg then
					CH:ChatFrame_SystemEventHandler(chat, "GUILD_MOTD", msg)
				end
				chat:RegisterEvent("GUILD_MOTD")
			end
		end
	end

	if not IsInGuild() then
		registerGuildEvents()
		return
	end

	local delay, checks = 0, 0
	CreateFrame("Frame"):SetScript("OnUpdate", function(df, elapsed)
		delay = delay + elapsed
		if delay < 5 then return end

		local msg = GetGuildRosterMOTD()

		if msg and msg ~= "" then
			registerGuildEvents(msg)
			df:SetScript("OnUpdate", nil)
		else -- 5 seconds can be too fast for the API response. let's try once every 5 seconds (max 5 checks).
			delay, checks = 0, checks + 1
			if checks >= 5 then
				registerGuildEvents()
				df:SetScript("OnUpdate", nil)
			end
		end
	end)
end

function CH:SaveChatHistory(event, ...)
	if historyTypes[event] and not self.db.showHistory[historyTypes[event]] then return end

	if self.db.throttleInterval ~= 0 and (event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_CHANNEL") then
		local message, author = ...
		local when = time()

		if not self:ChatThrottleBlockFlag(author, message, when) then
			self:ChatThrottleHandler(author, message, when)
		else
			return
		end
	end

	if not CH.db.chatHistory then return end

	if select("#", ...) > 0 then
		local historyLog = ElvCharacterDB.ChatHistoryLog

		local historyEntry = {...}
		historyEntry[50] = event
		historyEntry[51] = time()
		historyEntry[52] = self:GetColoredName(event, ...)

		while #historyLog >= self.db.historySize do
			tremove(historyLog, 1)
		end

		tinsert(historyLog, historyEntry)
	end
end

function CH:FCF_SetWindowAlpha(frame, alpha)
	frame.oldAlpha = alpha or 1
end

function CH:ON_FCF_SavePositionAndDimensions(_, noLoop)
	if not noLoop then
		CH:PositionChat()
	end

	if not self.db.lockPositions then
		CH:UpdateChatTabs() --It was not done in PositionChat, so do it now
	end
end

local FindURL_Events = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_BATTLEGROUND",
	"CHAT_MSG_BATTLEGROUND_LEADER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_AFK",
	"CHAT_MSG_DND",
}

function CH:DefaultSmileys()
	local x = ":16:16"
	if next(CH.Smileys) then
		wipe(CH.Smileys)
	end

	-- new keys
	CH:AddSmiley(":angry:", E:TextureString(E.Media.ChatEmojis.Angry, x))
	CH:AddSmiley(":blush:", E:TextureString(E.Media.ChatEmojis.Blush, x))
	CH:AddSmiley(":broken_heart:", E:TextureString(E.Media.ChatEmojis.BrokenHeart, x))
	CH:AddSmiley(":call_me:", E:TextureString(E.Media.ChatEmojis.CallMe, x))
	CH:AddSmiley(":cry:", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":facepalm:", E:TextureString(E.Media.ChatEmojis.Facepalm, x))
	CH:AddSmiley(":grin:", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(":heart:", E:TextureString(E.Media.ChatEmojis.Heart, x))
	CH:AddSmiley(":heart_eyes:", E:TextureString(E.Media.ChatEmojis.HeartEyes, x))
	CH:AddSmiley(":joy:", E:TextureString(E.Media.ChatEmojis.Joy, x))
	CH:AddSmiley(":kappa:", E:TextureString(E.Media.ChatEmojis.Kappa, x))
	CH:AddSmiley(":middle_finger:", E:TextureString(E.Media.ChatEmojis.MiddleFinger, x))
	CH:AddSmiley(":murloc:", E:TextureString(E.Media.ChatEmojis.Murloc, x))
	CH:AddSmiley(":ok_hand:", E:TextureString(E.Media.ChatEmojis.OkHand, x))
	CH:AddSmiley(":open_mouth:", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":poop:", E:TextureString(E.Media.ChatEmojis.Poop, x))
	CH:AddSmiley(":rage:", E:TextureString(E.Media.ChatEmojis.Rage, x))
	CH:AddSmiley(":sadkitty:", E:TextureString(E.Media.ChatEmojis.SadKitty, x))
	CH:AddSmiley(":scream:", E:TextureString(E.Media.ChatEmojis.Scream, x))
	CH:AddSmiley(":scream_cat:", E:TextureString(E.Media.ChatEmojis.ScreamCat, x))
	CH:AddSmiley(":slight_frown:", E:TextureString(E.Media.ChatEmojis.SlightFrown, x))
	CH:AddSmiley(":smile:", E:TextureString(E.Media.ChatEmojis.Smile, x))
	CH:AddSmiley(":smirk:", E:TextureString(E.Media.ChatEmojis.Smirk, x))
	CH:AddSmiley(":sob:", E:TextureString(E.Media.ChatEmojis.Sob, x))
	CH:AddSmiley(":sunglasses:", E:TextureString(E.Media.ChatEmojis.Sunglasses, x))
	CH:AddSmiley(":thinking:", E:TextureString(E.Media.ChatEmojis.Thinking, x))
	CH:AddSmiley(":thumbs_up:", E:TextureString(E.Media.ChatEmojis.ThumbsUp, x))
	CH:AddSmiley(":semi_colon:", E:TextureString(E.Media.ChatEmojis.SemiColon, x))
	CH:AddSmiley(":wink:", E:TextureString(E.Media.ChatEmojis.Wink, x))
	CH:AddSmiley(":zzz:", E:TextureString(E.Media.ChatEmojis.ZZZ, x))
	CH:AddSmiley(":stuck_out_tongue:", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(":stuck_out_tongue_closed_eyes:", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))

	-- Darth's keys
	CH:AddSmiley(":meaw:", E:TextureString(E.Media.ChatEmojis.Meaw, x))

	-- Simpy's keys
	CH:AddSmiley(">:%(", E:TextureString(E.Media.ChatEmojis.Rage, x))
	CH:AddSmiley(":%$", E:TextureString(E.Media.ChatEmojis.Blush, x))
	CH:AddSmiley("<\\3", E:TextureString(E.Media.ChatEmojis.BrokenHeart, x))
	CH:AddSmiley(":\'%)", E:TextureString(E.Media.ChatEmojis.Joy, x))
	CH:AddSmiley(";\'%)", E:TextureString(E.Media.ChatEmojis.Joy, x))
	CH:AddSmiley(",,!,,", E:TextureString(E.Media.ChatEmojis.MiddleFinger, x))
	CH:AddSmiley("D:<", E:TextureString(E.Media.ChatEmojis.Rage, x))
	CH:AddSmiley(":o3", E:TextureString(E.Media.ChatEmojis.ScreamCat, x))
	CH:AddSmiley("XP", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley("8%-%)", E:TextureString(E.Media.ChatEmojis.Sunglasses, x))
	CH:AddSmiley("8%)", E:TextureString(E.Media.ChatEmojis.Sunglasses, x))
	CH:AddSmiley(":%+1:", E:TextureString(E.Media.ChatEmojis.ThumbsUp, x))
	CH:AddSmiley(":;:", E:TextureString(E.Media.ChatEmojis.SemiColon, x))
	CH:AddSmiley(";o;", E:TextureString(E.Media.ChatEmojis.Sob, x))

	-- old keys
	CH:AddSmiley(":%-@", E:TextureString(E.Media.ChatEmojis.Angry, x))
	CH:AddSmiley(":@", E:TextureString(E.Media.ChatEmojis.Angry, x))
	CH:AddSmiley(":%-%)", E:TextureString(E.Media.ChatEmojis.Smile, x))
	CH:AddSmiley(":%)", E:TextureString(E.Media.ChatEmojis.Smile, x))
	CH:AddSmiley(":D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(":%-D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(";%-D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(";D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley("=D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley("xD", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley("XD", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(":%-%(", E:TextureString(E.Media.ChatEmojis.SlightFrown, x))
	CH:AddSmiley(":%(", E:TextureString(E.Media.ChatEmojis.SlightFrown, x))
	CH:AddSmiley(":o", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":%-o", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":%-O", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":O", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":%-0", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":P", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(":%-P", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(":p", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(":%-p", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley("=P", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley("=p", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(";%-p", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley(";p", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley(";P", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley(";%-P", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley(";%-%)", E:TextureString(E.Media.ChatEmojis.Wink, x))
	CH:AddSmiley(";%)", E:TextureString(E.Media.ChatEmojis.Wink, x))
	CH:AddSmiley(":S", E:TextureString(E.Media.ChatEmojis.Smirk, x))
	CH:AddSmiley(":%-S", E:TextureString(E.Media.ChatEmojis.Smirk, x))
	CH:AddSmiley(":,%(", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":,%-%(", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":\'%(", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":\'%-%(", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":F", E:TextureString(E.Media.ChatEmojis.MiddleFinger, x))
	CH:AddSmiley("<3", E:TextureString(E.Media.ChatEmojis.Heart, x))
	CH:AddSmiley("</3", E:TextureString(E.Media.ChatEmojis.BrokenHeart, x))
end

function CH:BuildCopyChatFrame()
	local frame = CreateFrame("Frame", "CopyChatFrame", E.UIParent)
	frame:Hide()
	frame:SetTemplate("Transparent")
	frame:Size(700, 200)
	frame:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 3)
	frame:SetFrameStrata("DIALOG")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetMinResize(350, 100)
	tinsert(UISpecialFrames, "CopyChatFrame")
	self.copyChatFrame = frame

	local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollFrame:Point("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollFrame:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -29, 8)
	frame.scrollFrame = scrollFrame

	scrollFrame.scrollBar = CopyChatFrameScrollFrameScrollBar
	Skins:HandleScrollBar(scrollFrame.scrollBar)
	scrollFrame.scrollBar:Point("TOPLEFT", scrollFrame, "TOPRIGHT", 3, -19)
	scrollFrame.scrollBar:Point("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 3, 19)

	local editBox = CreateFrame("EditBox", "$parentEditBox", frame)
	editBox:Size(scrollFrame:GetWidth(), 200)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetAutoFocus(false)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	scrollFrame:SetScrollChild(editBox)
	frame.editBox = editBox

	local closeButton = CreateFrame("Button", "$parentCloseButton", frame, "UIPanelCloseButton")
	closeButton:Point("TOPRIGHT", -1, 1)
	closeButton:SetFrameLevel(closeButton:GetFrameLevel() + 1)
	Skins:HandleCloseButton(closeButton)
	frame.closeButton = closeButton

	frame:SetScript("OnMouseDown", function(f, button)
		if button == "LeftButton" and not f.isMoving then
			f:StartMoving()
			f.isMoving = true
		elseif button == "RightButton" and not f.isSizing then
			f:StartSizing()
			f.isSizing = true
		end
	end)
	frame:SetScript("OnMouseUp", function(f, button)
		if button == "LeftButton" and f.isMoving then
			f:StopMovingOrSizing()
			f.isMoving = nil
		elseif button == "RightButton" and f.isSizing then
			f:StopMovingOrSizing()
			f.isSizing = nil
		end
	end)
	frame:SetScript("OnHide", function(f)
		if f.isMoving or f.isSizing then
			f:StopMovingOrSizing()
			f.isMoving = nil
			f.isSizing = nil
		end
	end)

	scrollFrame:SetScript("OnSizeChanged", function(f)
		editBox:Size(f:GetSize())
	end)
	scrollFrame:HookScript("OnVerticalScroll", function(f, offset)
		editBox:SetHitRectInsets(0, 0, offset, (editBox:GetHeight() - offset - f:GetHeight()))
	end)

	editBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then return end

		local _, max = scrollFrame.scrollBar:GetMinMaxValues()
		for _ = 1, max do
			ScrollFrameTemplate_OnMouseWheel(scrollFrame, -1)
		end
	end)
	editBox:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
end

CH.TabStyles = {
	NONE	= "%s",
	ARROW	= "%s>|r%s%s<|r",
	ARROW1	= "%s>|r %s %s<|r",
	ARROW2	= "%s<|r%s%s>|r",
	ARROW3	= "%s<|r %s %s>|r",
	BOX		= "%s[|r%s%s]|r",
	BOX1	= "%s[|r %s %s]|r",
	CURLY	= "%s{|r%s%s}|r",
	CURLY1	= "%s{|r %s %s}|r",
	CURVE	= "%s(|r%s%s)|r",
	CURVE1	= "%s(|r %s %s)|r"
}

function CH:FCFTab_UpdateColors(tab, selected)
	local chat = _G[format("ChatFrame%s", tab:GetID())]

	tab.selected = selected

	if selected and chat.isDocked then
		if self.db.tabSelector ~= "NONE" then
			local color = self.db.tabSelectorColor
			local hexColor = E:RGBToHex(color.r, color.g, color.b)
			tab:SetFormattedText(self.TabStyles[self.db.tabSelector] or self.TabStyles.ARROW1, hexColor, chat.name, hexColor)
			tab.textReformatted = true
		elseif tab.textReformatted then
			tab:SetText(chat.name)
			tab.textReformatted = nil
		end

		if self.db.tabSelectedTextEnabled then
			local color = self.db.tabSelectedTextColor
			tab:GetFontString():SetTextColor(color.r, color.g, color.b)
			return
		end
	elseif tab.textReformatted then
		tab:SetText(chat.name)
		tab.textReformatted = nil
	end

	tab:GetFontString():SetTextColor(unpack(E.media.rgbvaluecolor))
end

function CH:ResetEditboxHistory()
	wipe(ElvCharacterDB.ChatEditHistory)
end

function CH:ResetHistory()
	wipe(ElvCharacterDB.ChatHistoryLog)
end

function CH:Initialize()
	self:DelayGuildMOTD() --Keep this before `is Chat Enabled` check

	if not E.private.chat.enable then return end

	self.Initialized = true
	self.db = E.db.chat

	if not ElvCharacterDB.ChatEditHistory then ElvCharacterDB.ChatEditHistory = {} end
	if not ElvCharacterDB.ChatHistoryLog or not self.db.chatHistory then ElvCharacterDB.ChatHistoryLog = {} end

	FriendsMicroButton:Kill()
	ChatFrameMenuButton:Kill()

	self:SetupChat()
	self:DefaultSmileys()
	self:UpdateChatKeywords()
	self:UpdateFading()
	self:UpdateAnchors()
	self:Panels_ColorUpdate()

	self:SecureHook("ChatEdit_OnEnterPressed")
	self:SecureHook("FCF_SetWindowAlpha")
	self:SecureHook("FCFTab_UpdateColors")
	self:SecureHook("FCF_SetChatWindowFontSize", "SetChatFont")
	self:SecureHook("FCF_SavePositionAndDimensions", "ON_FCF_SavePositionAndDimensions")
	self:RegisterEvent("UPDATE_CHAT_WINDOWS", "SetupChat")
	self:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", "SetupChat")

	if WIM then
		WIM.RegisterWidgetTrigger("chat_display", "whisper,chat,w2w,demo", "OnHyperlinkClick", function(self) CH.clickedframe = self end)
		WIM.RegisterItemRefHandler("url", HyperLinkedURL)
	end

	if not self.db.lockPositions then CH:UpdateChatTabs() end --It was not done in PositionChat, so do it now

	for _, event in ipairs(FindURL_Events) do
		ChatFrame_AddMessageEventFilter(event, CH[event] or CH.FindURL)
		local nType = strsub(event, 10)
		if nType ~= "AFK" and nType ~= "DND" then
			self:RegisterEvent(event, "SaveChatHistory")
		end
	end

	if self.db.chatHistory then self:DisplayChatHistory() end
	self:BuildCopyChatFrame()

	-- Editbox Backdrop Color
	hooksecurefunc("ChatEdit_UpdateHeader", function(editbox)
		local chatType = editbox:GetAttribute("chatType")
		if not chatType then return end

		local chanTarget = editbox:GetAttribute("channelTarget")
		local chanName = chanTarget and GetChannelName(chanTarget)

		--Increase inset on right side to make room for character count text
		local insetLeft, insetRight, insetTop, insetBottom = editbox:GetTextInsets()
		editbox:SetTextInsets(insetLeft, insetRight + 30, insetTop, insetBottom)

		if chanName and (chatType == "CHANNEL") then
			if chanName == 0 then
				editbox:SetBackdropBorderColor(unpack(E.media.bordercolor))
			else
				local info = ChatTypeInfo[chatType..chanName]
				editbox:SetBackdropBorderColor(info.r, info.g, info.b)
			end
		else
			local info = ChatTypeInfo[chatType]
			editbox:SetBackdropBorderColor(info.r, info.g, info.b)
		end
	end)

	GeneralDockManagerOverflowButton:Size(17)
	GeneralDockManagerOverflowButtonList:SetTemplate("Transparent")
	hooksecurefunc(GeneralDockManagerScrollFrame, "SetPoint", function(self, point, anchor, attachTo, x, y)
		if anchor == GeneralDockManagerOverflowButton and x == 0 and y == 0 then
			self:Point(point, anchor, attachTo, -2, -4)
		end
	end)

	CombatLogQuickButtonFrame_Custom:StripTextures()
	CombatLogQuickButtonFrame_Custom:CreateBackdrop("Default", true)
	CombatLogQuickButtonFrame_Custom.backdrop:Point("TOPLEFT", 0, -1)
	CombatLogQuickButtonFrame_Custom.backdrop:Point("BOTTOMRIGHT", -22, -1)

	CombatLogQuickButtonFrame_CustomProgressBar:StripTextures()
	CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture(E.media.normTex)
	CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarColor(0.31, 0.31, 0.31)
	CombatLogQuickButtonFrame_CustomProgressBar:ClearAllPoints()
	CombatLogQuickButtonFrame_CustomProgressBar:SetInside(CombatLogQuickButtonFrame_Custom.backdrop)

	Skins:HandleNextPrevButton(CombatLogQuickButtonFrame_CustomAdditionalFilterButton)
	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Size(22)
	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Point("TOPRIGHT", CombatLogQuickButtonFrame_Custom, "TOPRIGHT", 3, -1)
	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetHitRectInsets(0, 0, 0, 0)
end

local function InitializeCallback()
	CH:Initialize()
end

E:RegisterModule(CH:GetName(), InitializeCallback)