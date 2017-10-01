local E, L, V, P, G = unpack(select(2, ...));
local AFKString = _G["AFK"];
local AFK = E:NewModule("AFK", "AceEvent-3.0", "AceTimer-3.0");
local CH = E:GetModule("Chat");

local _G = _G;
local GetTime = GetTime;
local tostring = tostring;
local floor = math.floor;
local format, strsub = string.format, string.sub;

--local ChatHistory_GetAccessID = ChatHistory_GetAccessID;
--local Chat_GetChatCategory = Chat_GetChatCategory;
local CinematicFrame = CinematicFrame;
local CreateFrame = CreateFrame;
local GetBattlefieldStatus = GetBattlefieldStatus;
--local GetColoredName = GetColoredName;
local GetGuildInfo = GetGuildInfo;
local GetScreenHeight = GetScreenHeight;
local GetScreenWidth = GetScreenWidth;
local InCombatLockdown = InCombatLockdown;
local IsInGuild = IsInGuild;
local IsShiftKeyDown = IsShiftKeyDown;
local MoveViewLeftStart = MoveViewLeftStart;
local MoveViewLeftStop = MoveViewLeftStop;
local MovieFrame = MovieFrame;
local Screenshot = Screenshot;
local SetCVar = SetCVar;
local UnitCastingInfo = UnitCastingInfo;
local UnitFactionGroup = UnitFactionGroup;
local UnitIsAFK = UnitIsAFK;

local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;
local DND = DND;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;

local CAMERA_SPEED = 0.035;
local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true
};

local printKeys = {
	["PRINTSCREEN"] = true,
};

if IsMacClient() then
	printKeys[_G["KEY_PRINTSCREEN_MAC"]] = true
end

function AFK:UpdateTimer()
	local time = GetTime() - self.startTime;
	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", floor(time / 60), time % 60);
end

local function StopAnimation(self)
	self:SetSequenceTime(0, 0);
	self:SetScript("OnUpdate", nil);
	self:SetScript("OnAnimFinished", nil);
end

local function UpdateAnimation(self, elapsed)
	self.animTime = self.animTime + (elapsed * 1000);
	self:SetSequenceTime(67, self.animTime);

	if(self.animTime >= 3000) then
		StopAnimation(self);
	end
end

local function OnAnimFinished(self)
	if(self.animTime > 500) then
		StopAnimation(self);
	end
end

function AFK:SetAFK(status)
	if(status and not self.isAFK) then
		if(InspectFrame) then
			InspectPaperDollFrame:Hide();
		end

		UIParent:Hide();
		self.AFKMode:Show();

		E.global.afkEnabled = true

		MoveViewLeftStart(CAMERA_SPEED);

		if(IsInGuild()) then
			local guildName, guildRankName = GetGuildInfo("player");
			self.AFKMode.bottom.guild:SetFormattedText("%s - %s", guildName, guildRankName);
		else
			self.AFKMode.bottom.guild:SetText(L["No Guild"]);
		end

		self.startTime = GetTime();
		self.timer = self:ScheduleRepeatingTimer("UpdateTimer", 1);

		self.AFKMode.chat:RegisterEvent("CHAT_MSG_WHISPER");
		self.AFKMode.chat:RegisterEvent("CHAT_MSG_BN_WHISPER");
		self.AFKMode.chat:RegisterEvent("CHAT_MSG_BN_CONVERSATION");
		self.AFKMode.chat:RegisterEvent("CHAT_MSG_GUILD");

		self.AFKMode.bottom.model:SetModelScale(1);
		self.AFKMode.bottom.model:RefreshUnit();
		self.AFKMode.bottom.model:SetModelScale(0.8);

		self.AFKMode.bottom.model.animTime = 0;
		self.AFKMode.bottom.model:SetScript("OnUpdate", UpdateAnimation);
		self.AFKMode.bottom.model:SetScript("OnAnimFinished", OnAnimFinished);

		self.isAFK = true;
	elseif(not status and self.isAFK) then
		self.AFKMode:Hide();
		UIParent:Show();

		E.global.afkEnabled = nil

		MoveViewLeftStop();

		self:CancelTimer(self.timer);
		self.AFKMode.bottom.time:SetText("00:00");

		self.AFKMode.chat:UnregisterAllEvents();
		self.AFKMode.chat:Clear();

		self.isAFK = false;
	end
end

function AFK:OnEvent(event, ...)
	if(event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS") then
		if(event == "UPDATE_BATTLEFIELD_STATUS") then
			local status = GetBattlefieldStatus(...);
			if(status == "confirm") then
				self:SetAFK(false);
			end
		else
			self:SetAFK(false);
		end

		if(event == "PLAYER_REGEN_DISABLED") then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent");
		end
		return;
	end

	if(event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	end

	if(not E.db.general.afk) then return; end
	if(InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then return; end
	if(UnitCastingInfo("player") ~= nil) then
		--Don't activate afk if player is crafting stuff, check back in 30 seconds
		self:ScheduleTimer("OnEvent", 30);
		return;
	end

	self:SetAFK(UnitIsAFK("player"));
end

function AFK:Toggle()
	if(E.db.general.afk) then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent");
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent");
		self:RegisterEvent("LFG_PROPOSAL_SHOW", "OnEvent");
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "OnEvent");

		SetCVar("autoClearAFK", "1");
	else
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED");
		self:UnregisterEvent("PLAYER_REGEN_DISABLED");
		self:UnregisterEvent("LFG_PROPOSAL_SHOW");
		self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS");

		self:CancelAllTimers()
	end
end

local function OnKeyDown(self, key)
	if(ignoreKeys[key]) then return end
	if printKeys[key] then
		Screenshot()
	else
		AFK:SetAFK(false);
		AFK:ScheduleTimer("OnEvent", 60);
	end
end

local function Chat_OnMouseWheel(self, delta)
	if(delta == 1 and IsShiftKeyDown()) then
		self:ScrollToTop();
	elseif(delta == -1 and IsShiftKeyDown()) then
		self:ScrollToBottom();
	elseif(delta == -1) then
		self:ScrollDown();
	else
		self:ScrollUp();
	end
end

--[[
local function Chat_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
	local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
	local type = strsub(event, 10);
	local info = ChatTypeInfo[type];

	local chatGroup = Chat_GetChatCategory(type);
	local chatTarget, body;
	if(chatGroup == "BN_CONVERSATION") then
		chatTarget = tostring(arg8);
	elseif(chatGroup == "WHISPER" or chatGroup == "BN_WHISPER") then
		if(not(strsub(arg2, 1, 2) == "|K")) then
			chatTarget = arg2:upper()
		else
			chatTarget = arg2;
		end
	end

	local playerLink
	if(type ~= "BN_WHISPER" and type ~= "BN_CONVERSATION") then
		playerLink = "|Hplayer:"..arg2..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h";
	else
		playerLink = "|HBNplayer:"..arg2..":"..arg13..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h";
	end

	body = format(_G["CHAT_"..type.."_GET"]..arg1, playerLink.."["..coloredName.."]".."|h");

	local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
	local typeID = ChatHistory_GetAccessID(type, chatTarget, arg12 == "" and arg13 or arg12);
	if CH.db.shortChannels then
		body = body:gsub("|Hchannel:(.-)|h%[(.-)%]|h", CH.ShortChannel);
		body = body:gsub("^(.-|h) "..L["whispers"], "%1");
		body = body:gsub("<"..AFKString..">", "[|cffFF0000"..L["AFK"].."|r] ");
		body = body:gsub("<"..DND..">", "[|cffE7E716"..L["DND"].."|r] ");
		body = body:gsub("%[BN_CONVERSATION:", "%[".."");
	end

	self:AddMessage(CH:ConcatenateTimeStamp(body), info.r, info.g, info.b, info.id, false, accessID, typeID);
end
]]

function AFK:Initialize()
	if E.global.afkEnabled then
		E.global.afkEnabled = nil
	end

	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass];

	self.AFKMode = CreateFrame("Frame", "ElvUIAFKFrame");
	self.AFKMode:SetFrameLevel(1);
	self.AFKMode:SetScale(UIParent:GetScale());
	self.AFKMode:SetAllPoints(UIParent);
	self.AFKMode:Hide();
	self.AFKMode:EnableKeyboard(true);
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown);

	self.AFKMode.chat = CreateFrame("ScrollingMessageFrame", "AFKChat", self.AFKMode);
	self.AFKMode.chat:Size(500, 200);
	self.AFKMode.chat:Point("TOPLEFT", self.AFKMode, "TOPLEFT", 4, -3);
	self.AFKMode.chat:FontTemplate();
	self.AFKMode.chat:SetJustifyH("LEFT");
	self.AFKMode.chat:SetMaxLines(500);
	self.AFKMode.chat:EnableMouseWheel(true);
	self.AFKMode.chat:SetFading(false);
	self.AFKMode.chat:SetMovable(true);
	self.AFKMode.chat:EnableMouse(true);
	self.AFKMode.chat:SetClampedToScreen(true);
	self.AFKMode.chat:SetClampRectInsets(-4, 3, 3, -4);
	self.AFKMode.chat:RegisterForDrag("LeftButton");
	self.AFKMode.chat:SetScript("OnDragStart", self.AFKMode.chat.StartMoving);
	self.AFKMode.chat:SetScript("OnDragStop", self.AFKMode.chat.StopMovingOrSizing);
	self.AFKMode.chat:SetScript("OnMouseWheel", Chat_OnMouseWheel);
	self.AFKMode.chat:SetScript("OnEvent", CH.ChatFrame_OnEvent);

	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode);
	self.AFKMode.bottom:SetFrameLevel(0);
	self.AFKMode.bottom:SetTemplate("Transparent");
	self.AFKMode.bottom:Point("BOTTOM", self.AFKMode, "BOTTOM", 0, -E.Border);
	self.AFKMode.bottom:Width(GetScreenWidth() + (E.Border*2));
	self.AFKMode.bottom:Height(GetScreenHeight() * 0.1);

	self.AFKMode.bottom.logo = self.AFKMode:CreateTexture(nil, "OVERLAY");
	self.AFKMode.bottom.logo:Size(320, 150);
	self.AFKMode.bottom.logo:Point("CENTER", self.AFKMode.bottom, "CENTER", 0, 50);
	self.AFKMode.bottom.logo:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\logo");

	local factionGroup = UnitFactionGroup("player");
	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, "OVERLAY");
	self.AFKMode.bottom.faction:Point("BOTTOMLEFT", self.AFKMode.bottom, "BOTTOMLEFT", -20, -16);
	self.AFKMode.bottom.faction:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\"..factionGroup.."-Logo");
	self.AFKMode.bottom.faction:Size(140);

	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY");
	self.AFKMode.bottom.name:FontTemplate(nil, 20);
	self.AFKMode.bottom.name:SetFormattedText("%s - %s", E.myname, E.myrealm);
	self.AFKMode.bottom.name:Point("TOPLEFT", self.AFKMode.bottom.faction, "TOPRIGHT", -10, -28);
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b);

	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY");
	self.AFKMode.bottom.guild:FontTemplate(nil, 20);
	self.AFKMode.bottom.guild:SetText(L["No Guild"]);
	self.AFKMode.bottom.guild:Point("TOPLEFT", self.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6);
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7);

	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY");
	self.AFKMode.bottom.time:FontTemplate(nil, 20);
	self.AFKMode.bottom.time:SetText("00:00");
	self.AFKMode.bottom.time:Point("TOPLEFT", self.AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6);
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7);

	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "ElvUIAFKPlayerModel", self.AFKMode.bottom);
	self.AFKMode.bottom.model:Point("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", 120, -100);
	self.AFKMode.bottom.model:Size(800);
	self.AFKMode.bottom.model:SetFacing(6);
	self.AFKMode.bottom.model:SetUnit("player");

	self:Toggle();
end

local function InitializeCallback()
	AFK:Initialize()
end

E:RegisterModule(AFK:GetName(), InitializeCallback)