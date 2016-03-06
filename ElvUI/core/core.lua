local E, L, V, P, G = unpack(select(2, ...));
local LSM = LibStub("LibSharedMedia-3.0");

local _G = _G;
local tonumber, pairs, ipairs, error, unpack, select, tostring = tonumber, pairs, ipairs, error, unpack, select, tostring;
local assert, print, type, collectgarbage, pcall, date = assert, print, type, collectgarbage, pcall, date;
local twipe, tinsert, tremove = table.wipe, tinsert, tremove;
local floor = floor;
local format, find, split, match, strrep, len, sub, gsub = string.format, string.find, string.split, string.match, strrep, string.len, string.sub, string.gsub;

local CreateFrame = CreateFrame;
local GetCVar, SetCVar = GetCVar, SetCVar;
local IsAddOnLoaded = IsAddOnLoaded;
local GetSpellInfo = GetSpellInfo;
local IsInInstance, GetNumPartyMembers, GetNumRaidMembers = IsInInstance, GetNumPartyMembers, GetNumRaidMembers;
local RequestBattlefieldScoreData = RequestBattlefieldScoreData;
local GetSpecialization, GetActiveSpecGroup = GetSpecialization, GetActiveSpecGroup;
local GetCombatRatingBonus = GetCombatRatingBonus;
local UnitLevel, UnitStat, UnitAttackPower, UnitBuff = UnitLevel, UnitStat, UnitAttackPower, UnitBuff;
local SendAddonMessage = SendAddonMessage;
local InCombatLockdown = InCombatLockdown;
local GetFunctionCPUUsage = GetFunctionCPUUsage;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT;

E.myclass = select(2, UnitClass("player")); -- Constants
E.myrace = select(2, UnitRace("player"));
E.myfaction = select(2, UnitFactionGroup("player"));
E.myname = UnitName("player");
E.myguid = UnitGUID("player");
E.version = GetAddOnMetadata("ElvUI", "Version"); 
E.myrealm = GetRealmName();
E.wowbuild = select(2, GetBuildInfo()); E.wowbuild = tonumber(E.wowbuild);
E.resolution = GetCVar("gxResolution");
E.screenheight = tonumber(match(E.resolution, "%d+x(%d+)"));
E.screenwidth = tonumber(match(E.resolution, "(%d+)x+%d"));
E.isMacClient = IsMacClient();
E.LSM = LSM;

E["media"] = {};
E["frames"] = {};
E["statusBars"] = {};
E["texts"] = {};
E["snapBars"] = {};
E["RegisteredModules"] = {};
E['RegisteredInitialModules'] = {};
E['valueColorUpdateFuncs'] = {};
E.TexCoords = {.08, .92, .08, .92};
E.FrameLocks = {};
E.CreditsList = {};
E.PixelMode = false;

E.InversePoints = {
	TOP = "BOTTOM",
	BOTTOM = "TOP",
	TOPLEFT = "BOTTOMLEFT",
	TOPRIGHT = "BOTTOMRIGHT",
	LEFT = "RIGHT",
	RIGHT = "LEFT",
	BOTTOMLEFT = "TOPLEFT",
	BOTTOMRIGHT = "TOPRIGHT",
	CENTER = "CENTER"
};

E.noop = function() end;

local colorizedName;
local length = len(E.UIName)
for i = 1, length do
	local letter = sub(E.UIName, i, i);
	if(i == 1) then
		colorizedName = format("|cffA11313%s", letter);
	elseif(i == 2) then
		colorizedName = format("%s|r|cffC4C4C4%s", colorizedName, letter);
	elseif(i == length) then
		colorizedName = format("%s%s|r|cffA11313:|r", colorizedName, letter);
	else
		colorizedName = colorizedName .. letter;
	end
end

function E:Print(...)
	print(colorizedName, ...);
end

E.PriestColors = {
	r = 0.99,
	g = 0.99,
	b = 0.99
};

function E:CheckClassColor(r, g, b)
	r, g, b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
	local matchFound = false;
	for class, _ in pairs(RAID_CLASS_COLORS) do
		if(class ~= E.myclass) then
			local colorTable = class == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]);
			if(colorTable.r == r and colorTable.g == g and colorTable.b == b) then
				matchFound = true;
			end
		end
	end
	
	return matchFound;
end

function E:GetColorTable(data)
	if(not data.r or not data.g or not data.b) then
		error("Could not unpack color values.");
	end
	
	if(data.a) then
		return {data.r, data.g, data.b, data.a};
	else
		return {data.r, data.g, data.b};
	end
end

function E:UpdateMedia()
	if(not self.db["general"] or not self.private["general"]) then return; end
	
	self["media"].normFont = LSM:Fetch("font", self.db["general"].font);
	self["media"].combatFont = LSM:Fetch("font", self.db["general"].dmgfont);
	self["media"].blankTex = LSM:Fetch("background", "ElvUI Blank");
	self["media"].normTex = LSM:Fetch("statusbar", self.private["general"].normTex);
	self["media"].glossTex = LSM:Fetch("statusbar", self.private["general"].glossTex);
	
	local border = E.db["general"].bordercolor;
	if(self:CheckClassColor(border.r, border.g, border.b)) then
		local classColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]);
		E.db["general"].bordercolor.r = classColor.r;
		E.db["general"].bordercolor.g = classColor.g;
		E.db["general"].bordercolor.b = classColor.b;
	elseif(E.PixelMode) then
		border = {r = 0, g = 0, b = 0};
	end
	
	if(self.global.tukuiMode) then
		border = {r=0.6, g = 0.6, b = 0.6};
	end
	
	self["media"].bordercolor = {border.r, border.g, border.b};
	self["media"].backdropcolor = E:GetColorTable(self.db["general"].backdropcolor);
	self["media"].backdropfadecolor = E:GetColorTable(self.db["general"].backdropfadecolor);
	
	local value = self.db["general"].valuecolor;
	if(self:CheckClassColor(value.r, value.g, value.b)) then
		value = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]);
		self.db["general"].valuecolor.r = value.r;
		self.db["general"].valuecolor.g = value.g;
		self.db["general"].valuecolor.b = value.b;
	end
	
	if(self.global.tukuiMode) then
		value = {r = 1, g = 1, b = 1};
	end
	
	self["media"].hexvaluecolor = self:RGBToHex(value.r, value.g, value.b);
	self["media"].rgbvaluecolor = {value.r, value.g, value.b};
	
	if(LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex) then
		LeftChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameLeft);
		local a = E.db.general.backdropfadecolor.a or 0.5;
		LeftChatPanel.tex:SetAlpha(a);
		
		RightChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameRight);
		RightChatPanel.tex:SetAlpha(a);
	end
	
	self:ValueFuncCall();
	self:UpdateBlizzardFonts();
end

local function LSMCallback()
	E:UpdateMedia();
end
E.LSM.RegisterCallback(E, "LibSharedMedia_Registered", LSMCallback);

function E:RequestBGInfo()
	RequestBattlefieldScoreData();
end

function E:PLAYER_ENTERING_WORLD()
	self:CheckRole()
	if(not self.MediaUpdated) then
		self:UpdateMedia();
		self.MediaUpdated = true;
	end
	
	local _, instanceType = IsInInstance();
	if(instanceType == "pvp") then
		self.BGTimer = self:ScheduleRepeatingTimer("RequestBGInfo", 5);
		self:RequestBGInfo();
	elseif(self.BGTimer) then
		self:CancelTimer(self.BGTimer);
		self.BGTimer = nil;
	end
end

function E:ValueFuncCall()
	for func, _ in pairs(self["valueColorUpdateFuncs"]) do
		func(self["media"].hexvaluecolor, unpack(self["media"].rgbvaluecolor));
	end
end

function E:UpdateFrameTemplates()
	for frame, _ in pairs(self["frames"]) do
		if(frame and frame.template) then
			frame:SetTemplate(frame.template, frame.glossTex);
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateBorderColors()
	for frame, _ in pairs(self["frames"]) do
		if(frame) then
			if(frame.template == "Default" or frame.template == "Transparent" or frame.template == nil) then
				frame:SetBackdropBorderColor(unpack(self["media"].bordercolor));
			end
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateBackdropColors()
	for frame, _ in pairs(self["frames"]) do
		if(frame) then
			if(frame.template == "Default" or frame.template == nil) then
				if(frame.backdropTexture) then
					frame.backdropTexture:SetVertexColor(unpack(self["media"].backdropcolor));
				else
					frame:SetBackdropColor(unpack(self["media"].backdropcolor));
				end
			elseif(frame.template == "Transparent") then
				frame:SetBackdropColor(unpack(self["media"].backdropfadecolor));
			end
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateFontTemplates()
	for text, _ in pairs(self["texts"]) do
		if(text) then
			text:FontTemplate(text.font, text.fontSize, text.fontStyle);
		else
			self["texts"][text] = nil;
		end
	end
end

function E:RegisterStatusBar(statusBar)
	tinsert(self.statusBars, statusBar);
end

function E:UpdateStatusBars()
	for _, statusBar in pairs(self.statusBars) do
		if(statusBar and statusBar:GetObjectType() == "StatusBar") then
			statusBar:SetStatusBarTexture(self.media.normTex);
		elseif(statusBar and statusBar:GetObjectType() == "Texture") then
			statusBar:SetTexture(self.media.normTex);
		end
	end
end

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame("Frame", "ElvUIParent", UIParent);
E.UIParent:SetFrameLevel(UIParent:GetFrameLevel());
E.UIParent:SetPoint("CENTER", UIParent, "CENTER");
E.UIParent:SetSize(UIParent:GetSize());
E["snapBars"][#E["snapBars"] + 1] = E.UIParent;

E.HiddenFrame = CreateFrame("Frame");
E.HiddenFrame:Hide();

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

function E:IncompatibleAddOn(addon, module)
	E.PopupDialogs["INCOMPATIBLE_ADDON"].button1 = addon;
	E.PopupDialogs["INCOMPATIBLE_ADDON"].button2 = "ElvUI "..module;
	E.PopupDialogs["INCOMPATIBLE_ADDON"].addon = addon;
	E.PopupDialogs["INCOMPATIBLE_ADDON"].module = module;
	E:StaticPopup_Show("INCOMPATIBLE_ADDON", addon, module);
end

function E:CheckIncompatible()
	if(E.global.ignoreIncompatible) then return; end
	if(IsAddOnLoaded("Prat-3.0") and E.private.chat.enable) then
		E:IncompatibleAddOn("Prat-3.0", "Chat");
	end
	
	if(IsAddOnLoaded("Chatter") and E.private.chat.enable) then
		E:IncompatibleAddOn("Chatter", "Chat");
	end
	
	if(IsAddOnLoaded("TidyPlates") and E.private.nameplate.enable) then
		E:IncompatibleAddOn("TidyPlates", "NamePlate");
	end
end

function E:IsFoolsDay()
	if(find(date(), "04/01/") and not E.global.aprilFools) then
		return true;
	else
		return false;
	end
end

function E:CopyTable(currentTable, defaultTable)
	if(type(currentTable) ~= "table") then currentTable = {}; end
	
	if type(defaultTable) == "table" then
		for option, value in pairs(defaultTable) do
			if(type(value) == "table") then
				value = self:CopyTable(currentTable[option], value);
			end
			
			currentTable[option] = value;
		end
	end
	
	return currentTable;
end

local function IsTableEmpty(tbl)
	for _, _ in pairs(tbl) do
		return false;
	end
	return true;
end

function E:RemoveEmptySubTables(tbl)
	if(type(tbl) ~= "table") then
		E:Print("Bad argument #1 to 'RemoveEmptySubTables' (table expected)");
		return;
	end
	
	for k, v in pairs(tbl) do
		if(type(v) == "table") then
			if(IsTableEmpty(v)) then
				tbl[k] = nil;
			else
				self:RemoveEmptySubTables(v);
			end
		end
	end
end

function E:RemoveTableDuplicates(cleanTable, checkTable)
	if(type(cleanTable) ~= "table") then
		E:Print("Bad argument #1 to 'RemoveTableDuplicates' (table expected)");
		return;
	end
	if(type(checkTable) ~= "table") then
		E:Print("Bad argument #2 to 'RemoveTableDuplicates' (table expected)");
		return;
	end
	
	local cleaned = {};
	for option, value in pairs(cleanTable) do
		if(type(value) == "table" and checkTable[option] and type(checkTable[option]) == "table") then
			cleaned[option] = self:RemoveTableDuplicates(value, checkTable[option]);
		else
			if(cleanTable[option] ~= checkTable[option]) then
				cleaned[option] = value;
			end
		end
	end
	
	self:RemoveEmptySubTables(cleaned);
	
	return cleaned;
end

function E:TableToLuaString(inTable)
	if(type(inTable) ~= "table") then
		E:Print("Invalid argument #1 to E:TableToLuaString (table expected)");
		return;
	end

	local ret = "{\n";
	local function recurse(table, level)
		for i, v in pairs(table) do
			ret = ret .. strrep("    ", level).."[";
			if(type(i) == "string") then
				ret = ret .. "\"" .. i .. "\"";
			else
				ret = ret .. i;
			end
			ret = ret .. "] = ";
			
			if(type(v) == "number") then
				ret = ret .. v .. ",\n"
			elseif(type(v) == "string") then
				ret = ret .. "\"" .. v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\"") .. "\",\n"
			elseif(type(v) == "boolean") then
				if(v) then
					ret = ret .. "true,\n";
				else
					ret = ret .. "false,\n";
				end
			elseif(type(v) == "table") then
				ret = ret .. "{\n";
				recurse(v, level + 1);
				ret = ret .. strrep("    ", level) .. "},\n";
			else
				ret = ret .. "\""..tostring(v) .. "\",\n";
			end
		end
	end
	
	if(inTable) then
		recurse(inTable, 1);
	end
	ret = ret.."}";
	
	return ret;
end

local profileFormat = {
	["profile"] = "E.db",
	["private"] = "E.private",
	["global"] = "E.global",
	["filtersNP"] = "E.global",
	["filtersUF"] = "E.global",
	["filtersAll"] = "E.global"
};

local lineStructureTable = {};

function E:ProfileTableToPluginFormat(inTable, profileType)
	local profileText = profileFormat[profileType];
	if(not profileText) then
		return;
	end
	
	twipe(lineStructureTable);
	local returnString = "";
	local lineStructure = "";
	local sameLine = false;
	
	local function buildLineStructure()
		local str = profileText;
		for _, v in ipairs(lineStructureTable) do
			if(type(v) == "string") then
				str = str .. "[\"" .. v .. "\"]";
			else
				str = str .. "[" .. v .. "]";
			end
		end
		
		return str;
	end
	
	local function recurse(tbl)
		lineStructure = buildLineStructure();
		for k, v in pairs(tbl) do
			if(not sameLine) then
				returnString = returnString .. lineStructure;
			end
			
			returnString = returnString .. "[";
			
			if(type(k) == "string") then
				returnString = returnString.."\"" .. k .. "\"";
			else
				returnString = returnString .. k;
			end
			
			if(type(v) == "table") then
				tinsert(lineStructureTable, k);
				sameLine = true;
				returnString = returnString .. "]";
				recurse(v);
			else
				sameLine = false;
				returnString = returnString .. "] = ";
				
				if(type(v) == "number") then
					returnString = returnString .. v .. ";\n";
				elseif(type(v) == "string") then
					returnString = returnString .. "\"" .. v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\"") .. "\";\n";
				elseif(type(v) == "boolean") then
					if(v) then
						returnString = returnString .. "true;\n";
					else
						returnString = returnString .. "false;\n";
					end
				else
					returnString = returnString .. "\"" .. tostring(v) .. "\"\n";
				end
			end
		end
		
		tremove(lineStructureTable);
		lineStructure = buildLineStructure();
	end
	
	if(inTable and profileType) then
		recurse(inTable);
	end
	
	return returnString;
end

function E:StringSplitMultiDelim(s, delim)
	assert(type (delim) == "string" and len(delim) > 0, "bad delimiter");
	
	local start = 1;
	local t = {};
	
	while(true) do
		local pos = find(s, delim, start, true);
		if(not pos) then
			break;
		end

		tinsert(t, sub(s, start, pos - 1));
		start = pos + len(delim);
	end
	
	tinsert(t, sub(s, start));
	
	return unpack(t);
end

function E:SendMessage()
	local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers();
	local inInstance, instanceType = IsInInstance();
	if(inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		SendAddonMessage("ELVUI_VERSIONCHK", E.version, "BATTLEGROUND");
	else
		if(numRaid > 0) then
			SendAddonMessage("ELVUI_VERSIONCHK", E.version, "RAID");
		elseif(numParty > 0) then
			SendAddonMessage("ELVUI_VERSIONCHK", E.version, "PARTY");
		end
	end
	
	if(E.SendMSGTimer) then
		self:CancelTimer(E.SendMSGTimer);
		E.SendMSGTimer = nil;
	end
end

local myName = E.myname.."-"..E.myrealm;
myName = myName:gsub("%s+", "");
local frames = {};
local function SendRecieve(self, event, prefix, message, channel, sender)
	if(event == "CHAT_MSG_ADDON") then
		if(sender == myName) then return; end
		if(prefix == "ELVUI_VERSIONCHK" and not E.recievedOutOfDateMessage) then
			if(tonumber(message) ~= nil and tonumber(message) > tonumber(E.version)) then
				E:Print(L["ElvUI is out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"]:gsub("ElvUI", E.UIName));
				
				if((tonumber(message) - tonumber(E.version)) >= 0.05) then
					E:StaticPopup_Show("ELVUI_UPDATE_AVAILABLE");
				end
				
				E.recievedOutOfDateMessage = true;
			end
		end
	else
		E.SendMSGTimer = E:ScheduleTimer("SendMessage", 12);
	end
end

local f = CreateFrame("Frame");
f:RegisterEvent("RAID_ROSTER_UPDATE");
f:RegisterEvent("PARTY_MEMBERS_CHANGED");
f:RegisterEvent("CHAT_MSG_ADDON");
f:SetScript("OnEvent", SendRecieve);

function E:UpdateAll(ignoreInstall)
	self.private = self.charSettings.profile;
	self.db = self.data.profile;
	self.global = self.data.global;
	self.db.theme = nil;
	self.db.install_complete = nil;
	--LibStub('LibDualSpec-1.0'):EnhanceDatabase(self.data, "ElvUI");
	
	self:SetMoversPositions();
	self:UpdateMedia();
	self:UpdateCooldownSettings();
	
	local UF = self:GetModule("UnitFrames")
	UF.db = self.db.unitframe;
	UF:Update_AllFrames();
	
	local CH = self:GetModule("Chat");
	CH.db = self.db.chat;
	CH:PositionChat(true);
	CH:SetupChat();
	
	local AB = self:GetModule("ActionBars");
	AB.db = self.db.actionbar;
	AB:UpdateButtonSettings();
	
	local bags = E:GetModule("Bags"); 
	bags.db = self.db.bags;
	bags:Layout();
	bags:Layout(true);
	bags:PositionBagFrames();
	bags:SizeAndPositionBagBar();
	bags:UpdateItemLevelDisplay();
	bags:UpdateCountDisplay();
	
	local totems = E:GetModule("Totems"); 
	totems.db = self.db.general.totems;
	totems:PositionAndSize();
	totems:ToggleEnable();
	
	self:GetModule("Layout"):ToggleChatPanels();
	
	local DT = self:GetModule("DataTexts");
	DT.db = self.db.datatexts;
	DT:LoadDataTexts();
	
	local NP = self:GetModule("NamePlates");
	NP.db = self.db.nameplate;
	NP:UpdateAllPlates();
	
	local M = self:GetModule("Misc");
	M:UpdateExpRepDimensions();
	M:EnableDisable_ExperienceBar();
	M:EnableDisable_ReputationBar()	;
	
	local T = self:GetModule("Threat");
	T.db = self.db.general.threat;
	T:UpdatePosition();
	T:ToggleEnable();
	
	self:GetModule("Auras").db = self.db.auras
	self:GetModule("Tooltip").db = self.db.tooltip
	
	if(ElvUIPlayerBuffs) then
		E:GetModule("Auras"):UpdateHeader(ElvUIPlayerBuffs);
	end
	
	if(ElvUIPlayerDebuffs) then
		E:GetModule("Auras"):UpdateHeader(ElvUIPlayerDebuffs);
	end
	
	if(self.private.install_complete == nil or (self.private.install_complete and type(self.private.install_complete) == 'boolean') or (self.private.install_complete and type(tonumber(self.private.install_complete)) == 'number' and tonumber(self.private.install_complete) <= 3.83)) then
		if(not ignoreInstall) then
			self:Install();
		end
	end
	
	self:GetModule("Minimap"):UpdateSettings();
	
	self:UpdateBorderColors();
	self:UpdateBackdropColors();
	
	self:UpdateFrameTemplates();
	self:UpdateStatusBars();
	
	local LO = E:GetModule("Layout");
	LO:ToggleChatPanels();
	LO:BottomPanelVisibility();
	LO:TopPanelVisibility();
	LO:SetDataPanelStyle();
	
	collectgarbage("collect");
end

function E:ResetAllUI()
	self:ResetMovers();
	
	if(E.db.lowresolutionset) then
		E:SetupResolution(true)
	end
	
	if(E.db.layoutSet) then
		E:SetupLayout(E.db.layoutSet, true);
	end
end

function E:ResetUI(...)
	if(InCombatLockdown()) then E:Print(ERR_NOT_IN_COMBAT) return; end
	
	if(... == "" or ... == " " or ... == nil) then
		E:StaticPopup_Show("RESETUI_CHECK");
		return;
	end
	
	self:ResetMovers(...);
end

function E:RegisterModule(name)
	if(self.initialized) then
		self:GetModule(name):Initialize();
	else
		self["RegisteredModules"][#self["RegisteredModules"] + 1] = name;
	end
end

function E:RegisterInitialModule(name)
	self["RegisteredInitialModules"][#self["RegisteredInitialModules"] + 1] = name;
end

function E:InitializeInitialModules()
	for _, module in pairs(E["RegisteredInitialModules"]) do
		local module = self:GetModule(module, true);
		if(module and module.Initialize) then
			local _, catch = pcall(module.Initialize, module);
			if(catch and GetCVarBool("scriptErrors") == 1) then
				ScriptErrorsFrame_OnError(catch, false);
			end
		end
	end
end

function E:RefreshModulesDB()
	--local UF = self:GetModule("UnitFrames");
	--twipe(UF.db);
	--UF.db = self.db.unitframe;
end

function E:InitializeModules()	
	for _, module in pairs(E["RegisteredModules"]) do
		local module = self:GetModule(module);
		if(module.Initialize) then
			local _, catch = pcall(module.Initialize, module);
			if(catch and GetCVarBool("scriptErrors") == 1) then
				ScriptErrorsFrame_OnError(catch, false);
			end
		end
	end
end

--DATABASE CONVERSIONS
function E:DBConversions()
	local fonts = {
		["ElvUI Alt-Font"] = "Continuum Medium",
		["ElvUI Alt-Combat"] = "Die Die Die!",
		["ElvUI Combat"] = "Action Man",
		["ElvUI Font"] = "PT Sans Narrow",
		["ElvUI Pixel"] = "Homespun"
	};
	
	if(fonts[E.db.general.font]) then E.db.general.font = fonts[E.db.general.font]; end
	if(fonts[E.db.general.itemLevelFont]) then E.db.general.itemLevelFont = fonts[E.db.general.itemLevelFont]; end
	if(fonts[E.db.general.countFont]) then E.db.general.itemLevelFont = fonts[E.db.general.countFont]; end
	if(fonts[E.db.nameplate.font]) then E.db.nameplate.font = fonts[E.db.nameplate.font]; end
	if(fonts[E.db.nameplate.buffs.font]) then E.db.nameplate.buffs.font = fonts[E.db.nameplate.buffs.font]; end
	if(fonts[E.db.nameplate.debuffs.font]) then E.db.nameplate.debuffs.font = fonts[E.db.nameplate.debuffs.font]; end
	if(fonts[E.db.bags.itemLevelFont]) then E.db.bags.itemLevelFont = fonts[E.db.bags.itemLevelFont]; end
	if(fonts[E.db.bags.countFont]) then E.db.bags.countFont = fonts[E.db.bags.countFont]; end
	if(fonts[E.db.auras.font]) then E.db.auras.font = fonts[E.db.auras.font]; end
	if(fonts[E.db.general.reminder.font]) then E.db.general.reminder.font = fonts[E.db.general.reminder.font]; end
	if(fonts[E.db.chat.font]) then E.db.chat.font = fonts[E.db.chat.font]; end
	if(fonts[E.db.chat.tabFont]) then E.db.chat.tabFont = fonts[E.db.chat.tabFont]; end
	if(fonts[E.db.datatexts.font]) then E.db.datatexts.font = fonts[E.db.datatexts.font]; end
	if(fonts[E.db.tooltip.font]) then E.db.tooltip.font = fonts[E.db.tooltip.font]; end
	if(fonts[E.db.tooltip.healthBar.font]) then E.db.tooltip.healthBar.font = fonts[E.db.tooltip.healthBar.font]; end
	if(fonts[E.db.unitframe.font]) then E.db.unitframe.font = fonts[E.db.unitframe.font]; end
	if(fonts[E.db.unitframe.units.party.rdebuffs.font]) then E.db.unitframe.units.party.rdebuffs.font = fonts[E.db.unitframe.units.party.rdebuffs.font]; end
	if(fonts[E.db.unitframe.units.raid.rdebuffs.font]) then E.db.unitframe.units.raid.rdebuffs.font = fonts[E.db.unitframe.units.raid.rdebuffs.font]; end
	if(fonts[E.db.unitframe.units.raid40.rdebuffs.font]) then E.db.unitframe.units.raid40.rdebuffs.font = fonts[E.db.unitframe.units.raid40.rdebuffs.font]; end
	
	if(E.global.unitframe["aurafilters"]["RaidDebuffs"].spells) then
		local matchFound;
		for k, v in pairs(E.global.unitframe["aurafilters"]["RaidDebuffs"].spells) do
			if(type(v) == "table") then
				matchFound = false;
				for k_,v_ in pairs(v) do
					if(k_ == "stackThreshold") then
						matchFound = true;
					end
				end
			end
			
			if(not matchFound) then
				E.global.unitframe["aurafilters"]["RaidDebuffs"]["spells"][k].stackThreshold = 0;
			end
		end
	end
	
	if(E.global.unitframe["aurafilters"]["Whitelist (Strict)"].spells) then
		for k, v in pairs(E.global.unitframe["aurafilters"]["Whitelist (Strict)"].spells) do
			if(type(v) == "table") then
				for k_, v_ in pairs(v) do
					if(k_ == "spellID" and type(v_) == "string" and tonumber(v_)) then
						E.global.unitframe["aurafilters"]["Whitelist (Strict)"]["spells"][k].spellID = tonumber(v_);
					end
				end
			end
		end
	end
	
	if(E.db.general.experience.width > 100 and E.db.general.experience.height > 100) then
		E.db.general.experience.width = P.general.experience.width;
		E.db.general.experience.height = P.general.experience.height;
		E:Print("Experience bar appears to be an odd shape. Resetting to default size.");
	end
	
	if(E.db.general.reputation.width > 100 and E.db.general.reputation.height > 100) then
		E.db.general.reputation.width = P.general.reputation.width;
		E.db.general.reputation.height = P.general.reputation.height;
		E:Print("Reputation bar appears to be an odd shape. Resetting to default size.");
	end
	
	if(E.db.chat.panelHeight < 60) then E.db.chat.panelHeight = 60; end
	if(E.db.chat.panelHeightRight < 60) then E.db.chat.panelHeightRight = 60; end
	
	if(E.db.movers) then
		for mover, moverString in pairs(E.db.movers) do
			if(find(moverString, "\031")) then
				moverString = gsub(moverString, "\031", ",");
				E.db.movers[mover] = moverString;
			end
		end
	end
	
	if(not E.global.unitframe.buffwatchBackup) then E.global.unitframe.buffwatchBackup = {}; end
	local shouldRemove;
	for class in pairs(E.global.unitframe.buffwatch) do
		if(not E.global.unitframe.buffwatchBackup[class]) then E.global.unitframe.buffwatchBackup[class] = {}; end
		shouldRemove = {};
		for i, values in pairs(E.global.unitframe.buffwatch[class]) do
			if(values.id) then
				if(i ~= values.id) then
					shouldRemove[i] = true;
				end
				E.global.unitframe.buffwatch[class][values.id] = values;
				if(not E.global.unitframe.buffwatchBackup[class][values.id]) then E.global.unitframe.buffwatchBackup[class][values.id] = values; end
			elseif(G.oldBuffWatch[class] and G.oldBuffWatch[class][i]) then
				local spellID = G.oldBuffWatch[class][i].id;
				if(spellID) then
					if(not E.global.unitframe.buffwatchBackup[class][spellID]) then
						E.global.unitframe.buffwatchBackup[class][spellID] = G.oldBuffWatch[class][i];
						E:CopyTable(E.global.unitframe.buffwatchBackup[class][spellID], values);
					end
					E.global.unitframe.buffwatch[class][spellID] = G.oldBuffWatch[class][i];
					E:CopyTable(E.global.unitframe.buffwatch[class][spellID], values);
					E.global.unitframe.buffwatch[class][i] = nil;
				end
			end
		end
		for id in pairs(shouldRemove) do
			E.global.unitframe.buffwatch[class][id] = nil;
		end
	end
end

local CPU_USAGE = {};
local function CompareCPUDiff(module, minCalls)
	local greatestUsage, greatestCalls, greatestName;
	local greatestDiff = 0;
	local mod = E:GetModule(module, true) or E;
	
	for name, oldUsage in pairs(CPU_USAGE) do
		local newUsage, calls = GetFunctionCPUUsage(mod[name], true);
		local differance = newUsage - oldUsage;
		
		if(differance > greatestDiff and calls > (minCalls or 15)) then
			greatestName = name;
			greatestUsage = newUsage;
			greatestCalls = calls;
			greatestDiff = differance;
		end
	end
	
	if(greatestName) then
		E:Print(greatestName .. " had the CPU usage of: " .. greatestUsage .. "ms. And has been called " .. greatestCalls .. " times.");
	end
end

function E:GetTopCPUFunc(msg)
	local module, delay, minCalls = msg:match("^([^%s]+)%s+(.*)$");
	
	module = module == "nil" and nil or module;
	delay = delay == "nil" and nil or tonumber(delay);
	minCalls = minCalls == "nil" and nil or tonumber(minCalls);
	
	twipe(CPU_USAGE);
	local mod = self:GetModule(module, true) or self;
	for name, func in pairs(mod) do
		if(type(mod[name]) == "function" and name ~= "GetModule") then
			CPU_USAGE[name] = GetFunctionCPUUsage(mod[name], true);
		end
	end
	
	self:Delay(delay or 5, CompareCPUDiff, module, minCalls);
	self:Print("Calculating CPU Usage..");
end

function E:Initialize()
	twipe(self.db);
	twipe(self.global);
	twipe(self.private)
	
	self.data = LibStub("AceDB-3.0"):New("ElvDB", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll");
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll");
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset");
	LibStub("LibDualSpec-1.0"):EnhanceDatabase(self.data, "ElvUI");
	self.charSettings = LibStub("AceDB-3.0"):New("ElvPrivateDB", self.privateVars);	
	self.private = self.charSettings.profile;
	self.db = self.data.profile;
	self.global = self.data.global;
	self:CheckIncompatible();
	self:DBConversions();
	
	self:CheckRole();
	self:UIScale("PLAYER_LOGIN");
	
	self:LoadCommands();
	self:InitializeModules();
	self:LoadMovers();
	self:UpdateCooldownSettings();
	self.initialized = true;
	
	if(self.private.install_complete == nil) then
		self:Install();
	end
	
	if(not find(date(), "04/01/")) then
		E.global.aprilFools = nil;
	end
	
	if(self:HelloKittyFixCheck()) then
		self:HelloKittyFix();
	end
	
	if(self.global.tukuiMode) then
		self.UIName = "Tukui";
	end
	
	self:UpdateMedia();
	self:UpdateFrameTemplates();
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckRole");
	self:RegisterEvent("UNIT_AURA", "CheckRole");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "CheckRole");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CheckRole");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckRole");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "CheckRole");
	self:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", "UIScale");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	if(self.db.general.kittys) then
		self:CreateKittys();
		self:Delay(5, self.Print, self, L["Type /hellokitty to revert to old settings."]);
	end
	
	self:Tutorials();
	self:GetModule("Minimap"):UpdateSettings();
	self:RefreshModulesDB()
	collectgarbage("collect");
	
	if(self:IsFoolsDay() and not E.global.aprilFools and not self.global.tukuiMode) then
		self:StaticPopup_Show("TUKUI_MODE");
	end
	
	if(self.db.general.loginmessage) then
		print(select(2, E:GetModule("Chat"):FindURL("CHAT_MSG_DUMMY", format(L["LOGIN_MSG"]:gsub("ElvUI", E.UIName), self["media"].hexvaluecolor, self["media"].hexvaluecolor, self.version)))..".");
	end
	
	if(self.global.tukuiMode) then
		if(self:IsFoolsDay()) then
			self:ShowTukuiFrame();
		end
		self:Print("Thank you for being a good sport, type /aprilfools to revert the changes.");
	end
end