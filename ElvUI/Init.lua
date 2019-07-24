--[[
~AddOn Engine~

To load the AddOn engine add this to the top of your file:

	local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

local _G = _G;
local pairs, unpack = pairs, unpack;
local format = string.format

BINDING_HEADER_ELVUI = GetAddOnMetadata(..., "Title")

local AceAddon, AceAddonMinor = LibStub("AceAddon-3.0")
local CallbackHandler = LibStub("CallbackHandler-1.0")

local AddOnName, Engine = ...;
local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
AddOn.callbacks = AddOn.callbacks or CallbackHandler:New(AddOn)
AddOn.DF = {profile = {}, global = {}}; AddOn.privateVars = {profile = {}} -- Defaults
AddOn.Options = {type = "group", name = AddOnName, args = {}}

Engine[1] = AddOn
Engine[2] = {}
Engine[3] = AddOn.privateVars.profile
Engine[4] = AddOn.DF.profile
Engine[5] = AddOn.DF.global
_G[AddOnName] = Engine

do
	AddOn.Libs = {}
	AddOn.LibsMinor = {}
	function AddOn:AddLib(name, major, minor)
		if not name then return end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == "table" and type(minor) == "number" then
			self.Libs[name], self.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			self.Libs[name], self.LibsMinor[name] = LibStub(major, minor)
		end
	end

	AddOn:AddLib("AceAddon", AceAddon, AceAddonMinor)
	AddOn:AddLib("AceDB", "AceDB-3.0")
	AddOn:AddLib("EP", "LibElvUIPlugin-1.0")
	AddOn:AddLib("LSM", "LibSharedMedia-3.0")
	AddOn:AddLib("ACL", "AceLocale-3.0-ElvUI")
	AddOn:AddLib("LAB", "LibActionButton-1.0-ElvUI")
	AddOn:AddLib("LBF", "LibButtonFacade", true)
	AddOn:AddLib("LDB", "LibDataBroker-1.1")
	AddOn:AddLib("DualSpec", "LibDualSpec-1.0")
	AddOn:AddLib("SimpleSticky", "LibSimpleSticky-1.0")
	AddOn:AddLib("SpellRange", "SpellRange-1.0")
	AddOn:AddLib("ItemSearch", "LibItemSearch-1.2-ElvUI")
	AddOn:AddLib("Compress", "LibCompress")
	AddOn:AddLib("Base64", "LibBase64-1.0-ElvUI")
	AddOn:AddLib("Translit", "LibTranslit-1.0")
	-- added on ElvUI_OptionsUI load: AceGUI, AceConfig, AceConfigDialog, AceConfigRegistry, AceDBOptions

	-- backwards compatible for plugins
	AddOn.LSM = AddOn.Libs.LSM
	AddOn.Masque = AddOn.Libs.Masque
end

AddOn.oUF = Engine.oUF
AddOn.ActionBars = AddOn:NewModule("ActionBars","AceHook-3.0","AceEvent-3.0")
AddOn.AFK = AddOn:NewModule("AFK","AceEvent-3.0","AceTimer-3.0")
AddOn.Auras = AddOn:NewModule("Auras","AceHook-3.0","AceEvent-3.0")
AddOn.Bags = AddOn:NewModule("Bags","AceHook-3.0","AceEvent-3.0","AceTimer-3.0")
AddOn.Blizzard = AddOn:NewModule("Blizzard","AceEvent-3.0","AceHook-3.0")
AddOn.Chat = AddOn:NewModule("Chat","AceTimer-3.0","AceHook-3.0","AceEvent-3.0")
AddOn.DataBars = AddOn:NewModule("DataBars","AceEvent-3.0")
AddOn.DataTexts = AddOn:NewModule("DataTexts","AceTimer-3.0","AceHook-3.0","AceEvent-3.0")
AddOn.DebugTools = AddOn:NewModule("DebugTools","AceEvent-3.0","AceHook-3.0")
AddOn.Distributor = AddOn:NewModule("Distributor","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
AddOn.Layout = AddOn:NewModule("Layout","AceEvent-3.0")
AddOn.Minimap = AddOn:NewModule("Minimap","AceEvent-3.0")
AddOn.Misc = AddOn:NewModule("Misc","AceEvent-3.0","AceTimer-3.0")
--AddOn.ModuleCopy = AddOn:NewModule("ModuleCopy","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
AddOn.NamePlates = AddOn:NewModule("NamePlates","AceHook-3.0","AceEvent-3.0","AceTimer-3.0")
AddOn.PluginInstaller = AddOn:NewModule("PluginInstaller")
AddOn.RaidUtility = AddOn:NewModule("RaidUtility","AceEvent-3.0")
AddOn.ReminderBuffs = AddOn:NewModule("ReminderBuffs", "AceEvent-3.0")
AddOn.Skins = AddOn:NewModule("Skins","AceTimer-3.0","AceHook-3.0","AceEvent-3.0")
AddOn.Threat = AddOn:NewModule("Threat","AceEvent-3.0")
AddOn.Tooltip = AddOn:NewModule("Tooltip","AceTimer-3.0","AceHook-3.0","AceEvent-3.0")
AddOn.TotemBar = AddOn:NewModule("Totems","AceEvent-3.0")
AddOn.UnitFrames = AddOn:NewModule("UnitFrames","AceTimer-3.0","AceEvent-3.0","AceHook-3.0")
AddOn.WorldMap = AddOn:NewModule("WorldMap","AceHook-3.0","AceEvent-3.0","AceTimer-3.0")

local tcopy = table.copy
function AddOn:OnInitialize()
	if not ElvCharacterDB then
		ElvCharacterDB = {};
	end

	ElvCharacterData = nil; --Depreciated
	ElvPrivateData = nil; --Depreciated
	ElvData = nil; --Depreciated

	self.db = tcopy(self.DF.profile, true);
	self.global = tcopy(self.DF.global, true);
	if ElvDB then
		if ElvDB.global then
			self:CopyTable(self.global, ElvDB.global)
		end

		local profileKey
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[self.myname.." - "..self.myrealm]
		end

		if profileKey and ElvDB.profiles and ElvDB.profiles[profileKey] then
			self:CopyTable(self.db, ElvDB.profiles[profileKey])
		end
	end

	self.private = tcopy(self.privateVars.profile, true);
	if ElvPrivateDB then
		local profileKey
		if ElvPrivateDB.profileKeys then
			profileKey = ElvPrivateDB.profileKeys[self.myname.." - "..self.myrealm]
		end

		if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
			self:CopyTable(self.private, ElvPrivateDB.profiles[profileKey])
		end
	end

	self.twoPixelsPlease = false
	self.ScanTooltip = CreateFrame("GameTooltip", "ElvUI_ScanTooltip", _G.UIParent, "GameTooltipTemplate")
	self.PixelMode = self.twoPixelsPlease or self.private.general.pixelPerfect -- keep this over `UIScale`
	self:UIScale(true)
	self:UpdateMedia();

	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:Contruct_StaticPopups()
	self:InitializeInitialModules()

	if IsAddOnLoaded("Tukui") then
		self:StaticPopup_Show("TUKUI_ELVUI_INCOMPATIBLE")
	end

	local GameMenuButton = CreateFrame("Button", "ElvUI_MenuButton", GameMenuFrame, "GameMenuButtonTemplate");
	GameMenuButton:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight());

	GameMenuButton:SetText(self:ColorizedName(AddOnName))
	GameMenuButton:SetScript("OnClick", function()
		AddOn:ToggleConfig();
		HideUIPanel(GameMenuFrame);
	end);
	GameMenuFrame[AddOnName] = GameMenuButton;

	GameMenuButtonRatings:HookScript("OnShow", function(self)
		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + self:GetHeight());
	end)
	GameMenuButtonRatings:HookScript("OnHide", function(self)
		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() - self:GetHeight());
	end)

	GameMenuFrame:HookScript("OnShow", function()
		if(not GameMenuFrame.isElvUI) then
			GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() + 1);
			GameMenuFrame.isElvUI = true;
		end
		local _, relTo = GameMenuButtonLogout:GetPoint();
		if(relTo ~= GameMenuFrame[AddOnName]) then
			GameMenuFrame[AddOnName]:ClearAllPoints();
			GameMenuFrame[AddOnName]:Point("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1);
			GameMenuButtonLogout:ClearAllPoints();
			GameMenuButtonLogout:Point("TOPLEFT", GameMenuFrame[AddOnName], "BOTTOMLEFT", 0, -16);
		end
	end);

	self.loadedtime = GetTime()
end

local f = CreateFrame("Frame");
f:RegisterEvent("PLAYER_LOGIN");
f:SetScript("OnEvent", function()
	AddOn:Initialize();
end);

function AddOn:PLAYER_REGEN_ENABLED()
	self:ToggleConfig()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED");
end

function AddOn:PLAYER_REGEN_DISABLED()
	local err = false;

	if IsAddOnLoaded("ElvUI_Config") then
		local ACD = LibStub("AceConfigDialog-3.0-ElvUI")

		if ACD.OpenFrames[AddOnName] then
			self:RegisterEvent("PLAYER_REGEN_ENABLED");
			ACD:Close(AddOnName);
			err = true;
		end
	end

	if self.CreatedMovers then
		for name, _ in pairs(self.CreatedMovers) do
			if _G[name] and _G[name]:IsShown() then
				err = true;
				_G[name]:Hide();
			end
		end
	end

	if err == true then
		self:Print(ERR_NOT_IN_COMBAT);
	end
end

function AddOn:ResetProfile()
	local profileKey
	if ElvPrivateDB.profileKeys then
		profileKey = ElvPrivateDB.profileKeys[self.myname.." - "..self.myrealm]
	end

	if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
		ElvPrivateDB.profiles[profileKey] = nil;
	end

	ElvCharacterDB = nil;
	ReloadUI()
end

function AddOn:OnProfileReset()
	self:StaticPopup_Show("RESET_PROFILE_PROMPT")
end

function AddOn:ToggleConfig()
	if InCombatLockdown() then
		self:Print(ERR_NOT_IN_COMBAT)
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return;
	end

	if not IsAddOnLoaded("ElvUI_Config") then
		local _, _, _, _, _, reason = GetAddOnInfo("ElvUI_Config")
		if reason ~= "MISSING" and reason ~= "DISABLED" then
			self.GUIFrame = false;
			LoadAddOn("ElvUI_Config")
			if GetAddOnMetadata("ElvUI_Config", "Version") ~= "1.01" then
				self:StaticPopup_Show("CLIENT_UPDATE_REQUEST")
			end
		else
			self:Print("|cffff0000Error -- Addon 'ElvUI_Config' not found or is disabled.|r")
			return
		end
	end

	local ACD = LibStub("AceConfigDialog-3.0-ElvUI")

	local mode = "Close"
	if not ACD.OpenFrames[AddOnName] then
		mode = "Open"
	end

	if mode == "Open" then
		ElvConfigToggle.text:SetTextColor(unpack(AddOn.media.rgbvaluecolor));
		PlaySound("igMainMenuOpen");
	else
		ElvConfigToggle.text:SetTextColor(1, 1, 1);
		PlaySound("igMainMenuClose");
	end

	ACD[mode](ACD, AddOnName)

	GameTooltip:Hide() --Just in case you're mouseovered something and it closes.
end
