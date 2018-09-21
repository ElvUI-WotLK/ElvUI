--[[
~AddOn Engine~

To load the AddOn engine add this to the top of your file:

	local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

local _G = _G;
local pairs, unpack = pairs, unpack;
local format = string.format

BINDING_HEADER_ELVUI = GetAddOnMetadata(..., "Title");

local AddOnName, Engine = ...;
local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0");
AddOn.callbacks = AddOn.callbacks or
	LibStub("CallbackHandler-1.0"):New(AddOn);
AddOn.DF = {}; AddOn.DF["profile"] = {}; AddOn.DF["global"] = {}; AddOn.privateVars = {}; AddOn.privateVars["profile"] = {}; -- Defaults
AddOn.Options = {
	type = "group",
	name = AddOnName,
	args = {},
};

local Locale = LibStub("AceLocale-3.0"):GetLocale(AddOnName, false);
Engine[1] = AddOn;
Engine[2] = Locale;
Engine[3] = AddOn.privateVars["profile"];
Engine[4] = AddOn.DF["profile"];
Engine[5] = AddOn.DF["global"];

_G[AddOnName] = Engine;
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

	if(self.private.general.pixelPerfect) then
		self.Border = self.mult;
		self.Spacing = 0;
		self.PixelMode = true;
	end

	self:UIScale();
	self:UpdateMedia();

	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	--self:RegisterEvent("PLAYER_LOGIN", "Initialize")
	self:Contruct_StaticPopups()
	self:InitializeInitialModules()

	if IsAddOnLoaded("Tukui") then
		self:StaticPopup_Show("TUKUI_ELVUI_INCOMPATIBLE")
	end

	local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate");
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
		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonContinue:GetHeight() + 1);
        if ElvUI_ButtonAddons ~= nil then
            GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonContinue:GetHeight() + 1);
            GameMenuButtonLogout:SetPoint("TOP", ElvUI_ButtonAddons, "BOTTOM", 0, -16);
        end

		local _, relTo = GameMenuButtonContinue:GetPoint();
		if(relTo ~= GameMenuFrame[AddOnName]) then
			GameMenuFrame[AddOnName]:ClearAllPoints();
			GameMenuFrame[AddOnName]:SetPoint("TOP", GameMenuButtonContinue, "BOTTOM", 0, -1);
		end
	end);
	local S = AddOn:GetModule("Skins");
	S:HandleButton(GameMenuButton);
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
