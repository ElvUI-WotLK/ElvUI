local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("AFK")
local CH = E:GetModule("Chat")

--Lua functions
local _G = _G
local tostring = tostring
local floor = math.floor
local format, gsub, sub, upper = string.format, string.gsub, string.sub, string.upper
--WoW API / Variables
local ChatHistory_GetAccessID = ChatHistory_GetAccessID
local Chat_GetChatCategory = Chat_GetChatCategory
local CinematicFrame = CinematicFrame
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetColoredName = GetColoredName
local GetGuildInfo = GetGuildInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local MovieFrame = MovieFrame
local Screenshot = Screenshot
local SetCVar = SetCVar
local UnitCastingInfo = UnitCastingInfo
local UnitIsAFK = UnitIsAFK

local AFK, DND = AFK, DND
local CHAT_BN_CONVERSATION_GET_LINK = CHAT_BN_CONVERSATION_GET_LINK
local MAX_WOW_CHAT_CHANNELS = MAX_WOW_CHAT_CHANNELS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local cameraSpeed = 0.035

local ignoreKeys = {
	["LALT"] = true,
	["LSHIFT"] = true,
	["RSHIFT"] = true
}
local printKeys = {
	["PRINTSCREEN"] = true,
}

if E.isMacClient then
	printKeys[_G["KEY_PRINTSCREEN_MAC"]] = true
end

function mod:UpdateTimer()
	local time = GetTime() - self.startTime
	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", floor(time / 60), time % 60)
end

local function StopAnimation(self)
	self:SetSequenceTime(0, 0)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnAnimFinished", nil)
end

local function UpdateAnimation(self, elapsed)
	self.animTime = self.animTime + (elapsed * 1000)
	self:SetSequenceTime(67, self.animTime)

	if self.animTime >= 3000 then
		StopAnimation(self)
	end
end

local function OnAnimFinished(self)
	if self.animTime > 500 then
		StopAnimation(self)
	end
end

function mod:SetAFK(status)
	if status and not self.isAFK then
		if InspectFrame then
			InspectFrame:Hide()
		end

		UIParent:Hide()
		self.AFKMode:Show()

		E.global.afkEnabled = true

		MoveViewLeftStart(cameraSpeed)

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo("player")
			self.AFKMode.bottom.guild:SetFormattedText("%s - %s", guildName, guildRankName)
		else
			self.AFKMode.bottom.guild:SetText(L["No Guild"])
		end

		self.startTime = GetTime()
		self.timer = self:ScheduleRepeatingTimer("UpdateTimer", 1)

		self.AFKMode.chat:RegisterEvent("CHAT_MSG_WHISPER")
		self.AFKMode.chat:RegisterEvent("CHAT_MSG_BN_WHISPER")
		self.AFKMode.chat:RegisterEvent("CHAT_MSG_BN_CONVERSATION")
		self.AFKMode.chat:RegisterEvent("CHAT_MSG_GUILD")

		self.AFKMode.bottom.model:SetModelScale(1)
		self.AFKMode.bottom.model:RefreshUnit()
		self.AFKMode.bottom.model:SetModelScale(0.8)

		self.AFKMode.bottom.model.animTime = 0
		self.AFKMode.bottom.model:SetScript("OnUpdate", UpdateAnimation)
		self.AFKMode.bottom.model:SetScript("OnAnimFinished", OnAnimFinished)

		self.isAFK = true
	elseif not status and self.isAFK then
		self.AFKMode:Hide()
		UIParent:Show()

		E.global.afkEnabled = nil

		MoveViewLeftStop()

		self:CancelTimer(self.timer)
		self.AFKMode.bottom.time:SetText("00:00")

		self.AFKMode.chat:UnregisterEvent("CHAT_MSG_WHISPER")
		self.AFKMode.chat:UnregisterEvent("CHAT_MSG_BN_WHISPER")
		self.AFKMode.chat:UnregisterEvent("CHAT_MSG_BN_CONVERSATION")
		self.AFKMode.chat:UnregisterEvent("CHAT_MSG_GUILD")
		self.AFKMode.chat:Clear()

		self.isAFK = false
	end
end

function mod:OnEvent(event, ...)
	if event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS" then
		if event == "UPDATE_BATTLEFIELD_STATUS" then
			local status = GetBattlefieldStatus(...)
			if status == "confirm" then
				self:SetAFK(false)
			end
		else
			self:SetAFK(false)
		end

		if event == "PLAYER_REGEN_DISABLED" then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		end
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:ScheduleTimer("OnEvent", 10)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if not E.db.general.afk then return end
	if InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown() then return end
	if UnitCastingInfo("player") ~= nil then
		--Don't activate afk if player is crafting stuff, check back in 30 seconds
		self:ScheduleTimer("OnEvent", 30)
		return
	end

	self:SetAFK(UnitIsAFK("player"))
end

function mod:Toggle()
	if E.db.general.afk then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent")
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
		self:RegisterEvent("LFG_PROPOSAL_SHOW", "OnEvent")
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "OnEvent")

		SetCVar("autoClearAFK", "1")
	else
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("LFG_PROPOSAL_SHOW")
		self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")

		self:CancelAllTimers()
	end
end

local function OnKeyDown(_, key)
	if ignoreKeys[key] then return end

	if printKeys[key] then
		Screenshot()
	else
		mod:SetAFK(false)
		mod:ScheduleTimer("OnEvent", 60)
	end
end

local function Chat_OnMouseWheel(self, delta)
	if delta > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			self:ScrollUp()
		end
	elseif delta < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			self:ScrollDown()
		end
	end
end

local function Chat_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
	local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
	local chatType = sub(event, 10)
	local info = ChatTypeInfo[chatType]

	local chatGroup = Chat_GetChatCategory(chatType)
	local chatTarget
	if chatGroup == "BN_CONVERSATION" then
		chatTarget = tostring(arg8)
	elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
		chatTarget = upper(arg2)
	end

	local playerLink
	if chatType ~= "BN_WHISPER" and chatType ~= "BN_CONVERSATION" then
		playerLink = "|Hplayer:"..arg2..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h"
	else
		playerLink = "|HBNplayer:"..arg2..":"..arg13..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h"
	end

	arg1 = gsub(arg1, "%%", "%%%%")

	local body = format(_G["CHAT_"..chatType.."_GET"]..arg1, playerLink.."["..coloredName.."]".."|h")

	if chatGroup == "BN_CONVERSATION" then
		body = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8)..body
	end

	local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget)
	local typeID = ChatHistory_GetAccessID(chatType, chatTarget)

	if E.db.chat.shortChannels then
		body = gsub(body, "|Hchannel:(.-)|h%[(.-)%]|h", CH.ShortChannel)
		body = gsub(body, "^(.-|h) "..L["whispers"], "%1")
		body = gsub(body, "<"..AFK..">", "[|cffFF0000"..AFK.."|r] ")
		body = gsub(body, "<"..DND..">", "[|cffE7E716"..DND.."|r] ")
		body = gsub(body, "%[BN_CONVERSATION:", "%[".."")
	end

	if CH.db.timeStampFormat ~= "NONE" then
		local timeStamp = BetterDate(CH.db.timeStampFormat, time())

		if CH.db.useCustomTimeColor then
			local color = CH.db.customTimeColor
			local hexColor = E:RGBToHex(color.r, color.g, color.b)
			body = format("%s[%s]|r %s", hexColor, timeStamp, body)
		else
			body = format("[%s] %s", timeStamp, body)
		end
	end

	self:AddMessage(body, info.r, info.g, info.b, info.id, false, accessID, typeID)
end

function mod:Initialize()
	self.AFKMode = CreateFrame("Frame", "ElvUIAFKFrame")
	self.AFKMode:SetFrameLevel(1)
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	self.AFKMode.chat = CreateFrame("ScrollingMessageFrame", "AFKChat", self.AFKMode)
	self.AFKMode.chat:Size(500, 200)
	self.AFKMode.chat:Point("TOPLEFT", self.AFKMode, "TOPLEFT", 4, -3)
	self.AFKMode.chat:FontTemplate()
	self.AFKMode.chat:SetJustifyH("LEFT")
	self.AFKMode.chat:SetMaxLines(500)
	self.AFKMode.chat:EnableMouseWheel(true)
	self.AFKMode.chat:SetFading(false)
	self.AFKMode.chat:SetMovable(true)
	self.AFKMode.chat:EnableMouse(true)
	self.AFKMode.chat:SetClampedToScreen(true)
	self.AFKMode.chat:SetClampRectInsets(-4, 3, 3, -4)
	self.AFKMode.chat:RegisterForDrag("LeftButton")
	self.AFKMode.chat:SetScript("OnDragStart", self.AFKMode.chat.StartMoving)
	self.AFKMode.chat:SetScript("OnDragStop", self.AFKMode.chat.StopMovingOrSizing)
	self.AFKMode.chat:SetScript("OnMouseWheel", Chat_OnMouseWheel)
	self.AFKMode.chat:SetScript("OnEvent", Chat_OnEvent)

	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.bottom:SetFrameLevel(0)
	self.AFKMode.bottom:SetTemplate("Transparent")
	self.AFKMode.bottom:Point("BOTTOM", self.AFKMode, "BOTTOM", 0, -E.Border)
	self.AFKMode.bottom:Width(GetScreenWidth() + (E.Border*2))
	self.AFKMode.bottom:Height(GetScreenHeight() * 0.1)

	self.AFKMode.bottom.logo = self.AFKMode:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.logo:Size(320, 150)
	self.AFKMode.bottom.logo:Point("CENTER", self.AFKMode.bottom, "CENTER", 0, 50)
	self.AFKMode.bottom.logo:SetTexture(E.Media.Textures.Logo)

	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.faction:Point("BOTTOMLEFT", self.AFKMode.bottom, "BOTTOMLEFT", -20, -16)
	self.AFKMode.bottom.faction:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\"..E.myfaction.."-Logo")
	self.AFKMode.bottom.faction:Size(140)

	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]
	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.name:FontTemplate(nil, 20)
	self.AFKMode.bottom.name:SetFormattedText("%s - %s", E.myname, E.myrealm)
	self.AFKMode.bottom.name:Point("TOPLEFT", self.AFKMode.bottom.faction, "TOPRIGHT", -10, -28)
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)

	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.guild:FontTemplate(nil, 20)
	self.AFKMode.bottom.guild:SetText(L["No Guild"])
	self.AFKMode.bottom.guild:Point("TOPLEFT", self.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.time:FontTemplate(nil, 20)
	self.AFKMode.bottom.time:SetText("00:00")
	self.AFKMode.bottom.time:Point("TOPLEFT", self.AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "ElvUIAFKPlayerModel", self.AFKMode.bottom)
	self.AFKMode.bottom.model:Point("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", 120, -100)
	self.AFKMode.bottom.model:Size(800)
	self.AFKMode.bottom.model:SetFacing(6)
	self.AFKMode.bottom.model:SetUnit("player")

	if E.db.general.afk then
		self:Toggle()
	end

	self.Initialized = true
end

local function InitializeCallback()
	mod:Initialize()
end

E:RegisterModule(mod:GetName(), InitializeCallback)