local E, L, V, P, G = unpack(select(2, ...));
local AFKString = _G['AFK'];
local AFK = E:NewModule('AFK', 'AceEvent-3.0', 'AceTimer-3.0');
local CH = E:GetModule('Chat');

local _G = _G;
local GetTime = GetTime;
local tostring = tostring;
local floor = floor;
local format, strsub = string.format, string.sub;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;
local DND = DND;

local CAMERA_SPEED = 0.035;
local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true
};

function AFK:UpdateTimer()
	local time = GetTime() - self.startTime;
	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", floor(time/60), time % 60);
end

function AFK:SetAFK(status)
	if(InCombatLockdown()) then
		return;
	end
	
	if(status) then
		MoveViewLeftStart(CAMERA_SPEED);
		self.AFKMode:Show();
		UIParent:Hide();
		
		if(IsInGuild()) then
			local guildName, guildRankName = GetGuildInfo('player');
			self.AFKMode.bottom.guild:SetFormattedText("%s-%s", guildName, guildRankName);
		else
			self.AFKMode.bottom.guild:SetText(L['No Guild']);
		end
		
		self.AFKMode.bottom.model:SetUnit('player');
		self.startTime = GetTime();
		self.timer = self:ScheduleRepeatingTimer('UpdateTimer', 1);
		
		self.AFKMode.chat:RegisterEvent('CHAT_MSG_WHISPER');
		self.AFKMode.chat:RegisterEvent('CHAT_MSG_BN_WHISPER');
		self.AFKMode.chat:RegisterEvent('CHAT_MSG_BN_CONVERSATION');
		self.AFKMode.chat:RegisterEvent('CHAT_MSG_GUILD');
		
		self.isAFK = true;
	elseif(self.isAFK) then
		UIParent:Show();
		self.AFKMode:Hide();
		MoveViewLeftStop();
		
		self:CancelTimer(self.timer);
		self.AFKMode.bottom.time:SetText('00:00');
		
		self.AFKMode.chat:UnregisterAllEvents();
		self.AFKMode.chat:Clear();
		
		self.isAFK = false;
	end
end

function AFK:OnEvent(event, ...)
	if(event == 'PLAYER_REGEN_DISABLED' or event == 'UPDATE_BATTLEFIELD_STATUS') then
		if(event == 'UPDATE_BATTLEFIELD_STATUS') then
			local status = GetBattlefieldStatus(...);
			if(status == 'confirm') then
				self:SetAFK(false);
			end
		else
			self:SetAFK(false);
		end

		if(event == 'PLAYER_REGEN_DISABLED') then
			self:RegisterEvent('PLAYER_REGEN_ENABLED', 'OnEvent');
		end
		
		return;
	end
	
	if(event == 'PLAYER_REGEN_ENABLED') then
		self:UnregisterEvent('PLAYER_REGEN_ENABLED');
	end
	
	if(UnitIsAFK('player')) then
		self:SetAFK(true);
	else
		self:SetAFK(false);
	end
end

function AFK:Toggle()
	if(E.db.general.afk) then
		self:RegisterEvent('PLAYER_FLAGS_CHANGED', 'OnEvent');
		self:RegisterEvent('PLAYER_REGEN_DISABLED', 'OnEvent');
		self:RegisterEvent('UPDATE_BATTLEFIELD_STATUS', 'OnEvent');
		
		SetCVar('autoClearAFK', '1');
	else
		self:UnregisterEvent('PLAYER_FLAGS_CHANGED');
		self:UnregisterEvent('PLAYER_REGEN_DISABLED');
		self:UnregisterEvent('UPDATE_BATTLEFIELD_STATUS');
	end
end

local function OnKeyDown(self, key)
	if(ignoreKeys[key]) then
		return;
	end
	
	AFK:SetAFK(false);
	AFK:ScheduleTimer('OnEvent', 60);
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

local function Chat_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
	local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
	local type = strsub(event, 10);
	local info = ChatTypeInfo[type];
	
	local chatGroup = Chat_GetChatCategory(type);
	local chatTarget, body;
	if ( chatGroup == "BN_CONVERSATION" ) then
		chatTarget = tostring(arg8);
	elseif ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
		if(not(strsub(arg2, 1, 2) == "|K")) then
			chatTarget = arg2:upper()
		else
			chatTarget = arg2;
		end
	end

	local playerLink
	if ( type ~= 'BN_WHISPER' and type ~= 'BN_CONVERSATION' ) then
		playerLink = '|Hplayer:'..arg2..':'..arg11..':'..chatGroup..(chatTarget and ':'..chatTarget or '')..'|h';
	else
		playerLink = '|HBNplayer:'..arg2..':'..arg13..':'..arg11..':'..chatGroup..(chatTarget and ':'..chatTarget or '')..'|h';
	end
	
	body = format(_G['CHAT_'..type..'_GET']..arg1, playerLink..'['..coloredName..']'..'|h');
	
	local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
	local typeID = ChatHistory_GetAccessID(type, chatTarget, arg12 == "" and arg13 or arg12);
	if CH.db.shortChannels then
		body = body:gsub("|Hchannel:(.-)|h%[(.-)%]|h", CH.ShortChannel);
		body = body:gsub("^(.-|h) "..L["whispers"], "%1");
		body = body:gsub("<"..AFKString..">", "[|cffFF0000"..L["AFK"].."|r] ");
		body = body:gsub("<"..DND..">", "[|cffE7E716"..L["DND"].."|r] ");
		body = body:gsub("%[BN_CONVERSATION:", '%['.."");
	end

	self:AddMessage(CH:ConcatenateTimeStamp(body), info.r, info.g, info.b, info.id, false, accessID, typeID);
end

function AFK:Initialize()
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass];
	
	self.AFKMode = CreateFrame('Frame', 'ElvUIAFKFrame');
	self.AFKMode:SetScale(UIParent:GetScale());
	self.AFKMode:SetAllPoints(UIParent);
	self.AFKMode:Hide();
	self.AFKMode:EnableKeyboard(true);
	self.AFKMode:SetScript('OnKeyDown', OnKeyDown);
	
	self.AFKMode.chat = CreateFrame('ScrollingMessageFrame', nil, self.AFKMode);
	self.AFKMode.chat:SetSize(500, 200);
	self.AFKMode.chat:SetPoint('TOPLEFT', self.AFKMode, 'TOPLEFT', 4, -4);
	self.AFKMode.chat:FontTemplate();
	self.AFKMode.chat:SetJustifyH('LEFT');
	self.AFKMode.chat:SetMaxLines(500);
	self.AFKMode.chat:EnableMouseWheel(true);
	self.AFKMode.chat:SetFading(false);
	self.AFKMode.chat:SetScript('OnMouseWheel', Chat_OnMouseWheel);
	self.AFKMode.chat:SetScript('OnEvent', CH.ChatFrame_OnEvent);
	
	self.AFKMode.bottom = CreateFrame('Frame', nil, self.AFKMode);
	self.AFKMode.bottom:SetTemplate('Transparent');
	self.AFKMode.bottom:SetPoint('BOTTOM', self.AFKMode, 'BOTTOM', 0, -2);
	self.AFKMode.bottom:SetWidth(GetScreenWidth());
	self.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 10));
	
	self.AFKMode.bottom.logo = self.AFKMode.bottom:CreateTexture(nil, 'OVERLAY');
	self.AFKMode.bottom.logo:SetSize(320, 150);
	self.AFKMode.bottom.logo:SetPoint('CENTER', self.AFKMode.bottom, 'CENTER', 0, 50);
	self.AFKMode.bottom.logo:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\logo_elvui');
	
	local factionGroup = UnitFactionGroup('player');
	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, 'OVERLAY');
	self.AFKMode.bottom.faction:SetPoint('BOTTOMLEFT', self.AFKMode.bottom, 'BOTTOMLEFT', -20, -16);
	self.AFKMode.bottom.faction:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\'..factionGroup..'-Logo');
	self.AFKMode.bottom.faction:SetSize(140, 140);
	
	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY');
	self.AFKMode.bottom.name:FontTemplate(nil, 20);
	self.AFKMode.bottom.name:SetFormattedText("%s-%s", E.myname, E.myrealm);
	self.AFKMode.bottom.name:SetPoint('TOPLEFT', self.AFKMode.bottom.faction, 'TOPRIGHT', -10, -28);
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b);
	
	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY');
	self.AFKMode.bottom.guild:FontTemplate(nil, 20);
	self.AFKMode.bottom.guild:SetText(L['No Guild']);
	self.AFKMode.bottom.guild:SetPoint('TOPLEFT', self.AFKMode.bottom.name, 'BOTTOMLEFT', 0, -6);
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7);
	
	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY');
	self.AFKMode.bottom.time:FontTemplate(nil, 20);
	self.AFKMode.bottom.time:SetText('00:00');
	self.AFKMode.bottom.time:SetPoint('TOPLEFT', self.AFKMode.bottom.guild, 'BOTTOMLEFT', 0, -6);
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7);
	
	self.AFKMode.bottom.model = CreateFrame('PlayerModel', 'ElvUIAFKPlayerModel', self.AFKMode.bottom);
	self.AFKMode.bottom.model:SetPoint('BOTTOMRIGHT', self.AFKMode.bottom, 'BOTTOMRIGHT', 120, -100);
	self.AFKMode.bottom.model:SetSize(800, 800);
	self.AFKMode.bottom.model:SetFacing(6);
	
	self:Toggle();
	self.isActive = false;
end

E:RegisterModule(AFK:GetName());