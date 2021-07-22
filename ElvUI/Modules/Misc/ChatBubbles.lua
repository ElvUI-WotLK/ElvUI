local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Misc")
local CH = E:GetModule("Chat")

--Lua functions
local select, unpack = select, unpack
local format, gmatch, gsub, lower, match = string.format, string.gmatch, string.gsub, string.lower, string.match
--WoW API / Variables
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local WorldFrame = WorldFrame
local WorldGetChildren = WorldFrame.GetChildren
local WorldGetNumChildren = WorldFrame.GetNumChildren
local ICON_LIST = ICON_LIST
local ICON_TAG_LIST = ICON_TAG_LIST
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

--Message caches
local messageToGUID = {}
local messageToSender = {}

local function replaceIconTags(value)
	value = lower(value)
	if ICON_TAG_LIST[value] and ICON_LIST[ICON_TAG_LIST[value]] then
		return format("%s0|t", ICON_LIST[ICON_TAG_LIST[value]])
	end
end

function M:UpdateBubbleBorder()
	if not self.text then return end

	if E.private.general.chatBubbles == "backdrop" then
		if E.PixelMode then
			self:SetBackdropBorderColor(self.text:GetTextColor())
		else
			local r, g, b = self.text:GetTextColor()
			self.bordertop:SetTexture(r, g, b)
			self.borderbottom:SetTexture(r, g, b)
			self.borderleft:SetTexture(r, g, b)
			self.borderright:SetTexture(r, g, b)
		end
	end

	local text = self.text:GetText()
	if self.Name then
		self.Name:SetText("") --Always reset it
		if text and E.private.general.chatBubbleName then
			M:AddChatBubbleName(self, messageToGUID[text], messageToSender[text])
		end
	end

	local rebuiltString

	if E.private.chat.enable and E.private.general.classColorMentionsSpeech then
		if text and match(text, "%s-%S+%s*") then
			local classColorTable, lowerCaseWord, isFirstWord, tempWord, wordMatch, classMatch

			for word in gmatch(text, "%s-%S+%s*") do
				tempWord = gsub(word, "^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$", "%1%2")
				lowerCaseWord = lower(tempWord)

				classMatch = CH.ClassNames[lowerCaseWord]
				wordMatch = classMatch and lowerCaseWord

				if wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch] then
					classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classMatch] or RAID_CLASS_COLORS[classMatch]
					word = gsub(word, gsub(tempWord, "%-", "%%-"), format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
				end

				if not isFirstWord then
					rebuiltString = word
					isFirstWord = true
				else
					rebuiltString = format("%s%s", rebuiltString, word)
				end
			end
		end
	end

	if text then
		rebuiltString = gsub(rebuiltString or text, "{([^}]+)}", replaceIconTags)
	end

	if rebuiltString then
		self.text:SetText(rebuiltString)
	end
end

function M:AddChatBubbleName(chatBubble, guid, name)
	if not name then return end

	local color
	if guid and guid ~= "" then
		local _, class = GetPlayerInfoByGUID(guid)
		if class then
			color = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] and E:RGBToHex(CUSTOM_CLASS_COLORS[class].r, CUSTOM_CLASS_COLORS[class].g, CUSTOM_CLASS_COLORS[class].b))
				or (RAID_CLASS_COLORS[class] and E:RGBToHex(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b))
		end
	else
		color = "|cffffffff"
	end

	chatBubble.Name:SetFormattedText("%s%s|r", color, name)
end

function M:SkinBubble(frame)
	local mult = E.mult * UIParent:GetScale()
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:IsObjectType("Texture") then
			region:SetTexture(nil)
		elseif region:IsObjectType("FontString") then
			frame.text = region
		end
	end

	local name = frame:CreateFontString(nil, "OVERLAY")
	if E.private.general.chatBubbles == "backdrop" then
		name:SetPoint("TOPLEFT", 5, E.PixelMode and 15 or 18)
	else
		name:SetPoint("TOPLEFT", 5, 6)
	end
	name:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -5, -5)
	name:SetJustifyH("LEFT")
	name:FontTemplate(E.Libs.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize * 0.85, E.private.general.chatBubbleFontOutline)
	frame.Name = name

	if E.private.general.chatBubbles == "backdrop" then
		if E.PixelMode then
			frame:SetBackdrop({
				bgFile = E.media.blankTex,
				edgeFile = E.media.blankTex,
				tile = false, tileSize = 0, edgeSize = mult,
				insets = {left = 0, right = 0, top = 0, bottom = 0}
			})
			frame:SetBackdropColor(unpack(E.media.backdropfadecolor))
			frame:SetBackdropBorderColor(0, 0, 0)
		else
			frame:SetBackdrop(nil)
		end

		local r, g, b = frame.text:GetTextColor()
		if not E.PixelMode then
			local mult2 = mult * 2
			local mult3 = mult * 3

			frame.backdrop = frame:CreateTexture(nil, "BACKGROUND")
			frame.backdrop:SetAllPoints(frame)
			frame.backdrop:SetTexture(unpack(E.media.backdropfadecolor))

			frame.bordertop = frame:CreateTexture(nil, "ARTWORK")
			frame.bordertop:SetPoint("TOPLEFT", -mult2, mult2)
			frame.bordertop:SetPoint("TOPRIGHT", mult2, mult2)
			frame.bordertop:SetHeight(mult)
			frame.bordertop:SetTexture(r, g, b)

			frame.bordertop.backdrop = frame:CreateTexture(nil, "BORDER")
			frame.bordertop.backdrop:SetPoint("TOPLEFT", frame.bordertop, "TOPLEFT", -mult, mult)
			frame.bordertop.backdrop:SetPoint("TOPRIGHT", frame.bordertop, "TOPRIGHT", mult, mult)
			frame.bordertop.backdrop:SetHeight(mult3)
			frame.bordertop.backdrop:SetTexture(0, 0, 0)

			frame.borderbottom = frame:CreateTexture(nil, "ARTWORK")
			frame.borderbottom:SetPoint("BOTTOMLEFT", -mult2, -mult2)
			frame.borderbottom:SetPoint("BOTTOMRIGHT", mult2, -mult2)
			frame.borderbottom:SetHeight(mult)
			frame.borderbottom:SetTexture(r, g, b)

			frame.borderbottom.backdrop = frame:CreateTexture(nil, "BORDER")
			frame.borderbottom.backdrop:SetPoint("BOTTOMLEFT", frame.borderbottom, "BOTTOMLEFT", -mult, -mult)
			frame.borderbottom.backdrop:SetPoint("BOTTOMRIGHT", frame.borderbottom, "BOTTOMRIGHT", mult, -mult)
			frame.borderbottom.backdrop:SetHeight(mult3)
			frame.borderbottom.backdrop:SetTexture(0, 0, 0)

			frame.borderleft = frame:CreateTexture(nil, "ARTWORK")
			frame.borderleft:SetPoint("TOPLEFT", -mult2, mult2)
			frame.borderleft:SetPoint("BOTTOMLEFT", mult2, -mult2)
			frame.borderleft:SetWidth(mult)
			frame.borderleft:SetTexture(r, g, b)

			frame.borderleft.backdrop = frame:CreateTexture(nil, "BORDER")
			frame.borderleft.backdrop:SetPoint("TOPLEFT", frame.borderleft, "TOPLEFT", -mult, mult)
			frame.borderleft.backdrop:SetPoint("BOTTOMLEFT", frame.borderleft, "BOTTOMLEFT", -mult, -mult)
			frame.borderleft.backdrop:SetWidth(mult3)
			frame.borderleft.backdrop:SetTexture(0, 0, 0)

			frame.borderright = frame:CreateTexture(nil, "ARTWORK")
			frame.borderright:SetPoint("TOPRIGHT", mult2, mult2)
			frame.borderright:SetPoint("BOTTOMRIGHT", -mult2, -mult2)
			frame.borderright:SetWidth(mult)
			frame.borderright:SetTexture(r, g, b)

			frame.borderright.backdrop = frame:CreateTexture(nil, "BORDER")
			frame.borderright.backdrop:SetPoint("TOPRIGHT", frame.borderright, "TOPRIGHT", mult, mult)
			frame.borderright.backdrop:SetPoint("BOTTOMRIGHT", frame.borderright, "BOTTOMRIGHT", mult, -mult)
			frame.borderright.backdrop:SetWidth(mult3)
			frame.borderright.backdrop:SetTexture(0, 0, 0)
		else
			frame:SetBackdropColor(unpack(E.media.backdropfadecolor))
			frame:SetBackdropBorderColor(r, g, b)
		end

		frame.text:FontTemplate(E.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
	elseif E.private.general.chatBubbles == "backdrop_noborder" then
		frame:SetBackdrop(nil)

		if not frame.backdrop then
			frame.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.backdrop:SetInside(frame, 4, 4)
			frame.backdrop:SetTexture(unpack(E.media.backdropfadecolor))
		end
		frame.text:FontTemplate(E.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)

		frame:SetClampedToScreen(false)
	elseif E.private.general.chatBubbles == "nobackdrop" then
		frame:SetBackdrop(nil)
		frame.text:FontTemplate(E.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
		frame:SetClampedToScreen(false)
	end

	frame:HookScript("OnShow", M.UpdateBubbleBorder)
	frame:SetFrameStrata("BACKGROUND")
	M.UpdateBubbleBorder(frame)

	frame.isSkinnedElvUI = true
end

function M:IsChatBubble(frame)
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region.GetTexture and region:GetTexture() and region:GetTexture() == [[Interface\Tooltips\ChatBubble-Background]] then
			return true
		end
	end
end

local function ChatBubble_OnEvent(self, event, msg, sender, _, _, _, _, _, _, _, _, _, guid)
	if not E.private.general.chatBubbleName then return end

	messageToGUID[msg] = guid
	messageToSender[msg] = sender
end

local lastChildern, numChildren = 0, 0
local function findChatBubbles(...)
	for i = lastChildern + 1, numChildren do
		local frame = select(i, ...)
		if not frame.isSkinnedElvUI and M:IsChatBubble(frame) then
			M:SkinBubble(frame)
		end
	end
end

local function ChatBubble_OnUpdate(self, elapsed)
	self.lastupdate = self.lastupdate + elapsed
	if self.lastupdate < .1 then return end
	self.lastupdate = 0

	numChildren = WorldGetNumChildren(WorldFrame)
	if lastChildern ~= numChildren then
		findChatBubbles(WorldGetChildren(WorldFrame))
		lastChildern = numChildren
	end
end

function M:LoadChatBubbles()
	if E.private.general.chatBubbles == "disabled" then return end

	self.BubbleFrame = CreateFrame("Frame")
	self.BubbleFrame.lastupdate = -2 -- wait 2 seconds before hooking frames

	self.BubbleFrame:RegisterEvent("CHAT_MSG_SAY")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_YELL")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_PARTY")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self.BubbleFrame:SetScript("OnEvent", ChatBubble_OnEvent)
	self.BubbleFrame:SetScript("OnUpdate", ChatBubble_OnUpdate)
end
