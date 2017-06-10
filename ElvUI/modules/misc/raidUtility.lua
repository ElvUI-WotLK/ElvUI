local E, L, DF = unpack(select(2, ...));
local RU = E:NewModule("RaidUtility", "AceEvent-3.0");

local _G = _G;
local unpack, pairs = unpack, pairs;
local find = string.find;

local CreateFrame = CreateFrame;
local IsInInstance = IsInInstance;
local GetNumRaidMembers = GetNumRaidMembers;
local GetNumPartyMembers = GetNumPartyMembers;
local IsPartyLeader = IsPartyLeader;
local IsRaidLeader = IsRaidLeader;
local IsRaidOfficer = IsRaidOfficer;
local InCombatLockdown = InCombatLockdown;
local DoReadyCheck = DoReadyCheck;
local ToggleFriendsFrame = ToggleFriendsFrame;

E.RaidUtility = RU;
local PANEL_HEIGHT = 100;

local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance();
	if((((IsRaidLeader() or IsRaidOfficer()) and GetNumRaidMembers() > 0) or (IsPartyLeader() and GetNumPartyMembers() > 0)) and not (inInstance and (instanceType == "pvp" or instanceType == "arena"))) then
		return true;
	else
		return false;
	end
end

local function ButtonEnter(self)
	self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor));
end

local function ButtonLeave(self)
	self:SetBackdropBorderColor(unpack(E["media"].bordercolor));
end

function RU:CreateUtilButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, text, texture)
	local b = CreateFrame("Button", name, parent, template);
	b:Width(width);
	b:Height(height);
	b:Point(point, relativeto, point2, xOfs, yOfs);
	b:HookScript("OnEnter", ButtonEnter);
	b:HookScript("OnLeave", ButtonLeave);
	b:SetTemplate("Transparent");

	if(text) then
		local t = b:CreateFontString(nil, "OVERLAY", b);
		t:FontTemplate();
		t:Point("CENTER", b, "CENTER", 0, -1);
		t:SetJustifyH("CENTER");
		t:SetText(text);
		b:SetFontString(t);
	elseif(texture) then
		local t = b:CreateTexture(nil, "OVERLAY", nil);
		t:SetTexture(texture);
		t:Point("TOPLEFT", b, "TOPLEFT", E.mult, -E.mult);
		t:Point("BOTTOMRIGHT", b, "BOTTOMRIGHT", -E.mult, E.mult);
	end
end

function RU:ToggleRaidUtil(event)
	if(InCombatLockdown()) then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil");
		return;
	end

	if(CheckRaidStatus()) then
		if(RaidUtilityPanel.toggled == true) then
			RaidUtility_ShowButton:Hide();
			RaidUtilityPanel:Show();
		else
			RaidUtility_ShowButton:Show();
			RaidUtilityPanel:Hide();
		end
	else
		RaidUtility_ShowButton:Hide();
		RaidUtilityPanel:Hide();
	end

	if(event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil");
	end
end

function RU:Initialize()
	if not E.private.general.raidUtility then return end

	local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", E.UIParent, "SecureHandlerClickTemplate");
	RaidUtilityPanel:SetTemplate("Transparent");
	RaidUtilityPanel:Width(230);
	RaidUtilityPanel:Height(PANEL_HEIGHT);
	RaidUtilityPanel:Point("TOP", E.UIParent, "TOP", -400, 1);
	RaidUtilityPanel:SetFrameLevel(3);
	RaidUtilityPanel.toggled = false;
	RaidUtilityPanel:SetFrameStrata("HIGH");

	self:CreateUtilButton("RaidUtility_ShowButton", E.UIParent, "SecureHandlerClickTemplate", 136, 18, "TOP", E.UIParent, "TOP", -400, E.Border, RAID_CONTROL, nil)
	RaidUtility_ShowButton:SetFrameRef("RaidUtilityPanel", RaidUtilityPanel);
	RaidUtility_ShowButton:SetAttribute("_onclick", ([=[
		local raidUtil = self:GetFrameRef("RaidUtilityPanel");
		local closeButton = raidUtil:GetFrameRef("RaidUtility_CloseButton");
		self:Hide();
		raidUtil:Show();

		local point = self:GetPoint();
		local raidUtilPoint, closeButtonPoint, yOffset
		if(string.find(point, "BOTTOM")) then
			raidUtilPoint = "BOTTOM";
			closeButtonPoint = "TOP";
			yOffset = 1
		else
			raidUtilPoint = "TOP";
			closeButtonPoint = "BOTTOM";
			yOffset = -1;
		end

		yOffset = yOffset * (tonumber(%d));

		raidUtil:ClearAllPoints();
		closeButton:ClearAllPoints();
		raidUtil:SetPoint(raidUtilPoint, self, raidUtilPoint);
		closeButton:SetPoint(raidUtilPoint, raidUtil, closeButtonPoint, 0, yOffset);
	]=]):format(-E.Border + E.Spacing*3));
	RaidUtility_ShowButton:SetScript("OnMouseUp", function(self) RaidUtilityPanel.toggled = true; end);
	RaidUtility_ShowButton:SetMovable(true);
	RaidUtility_ShowButton:SetClampedToScreen(true);
	RaidUtility_ShowButton:SetClampRectInsets(0, 0, -1, 1);
	RaidUtility_ShowButton:RegisterForDrag("RightButton");
	RaidUtility_ShowButton:SetFrameStrata("HIGH");
	RaidUtility_ShowButton:SetScript("OnDragStart", function(self)
		if(InCombatLockdown()) then E:Print(ERR_NOT_IN_COMBAT); return; end
		self:StartMoving();
	end);

	RaidUtility_ShowButton:SetScript("OnDragStop", function(self)
		if(InCombatLockdown()) then E:Print(ERR_NOT_IN_COMBAT); return; end
		self:StopMovingOrSizing();
		local point = self:GetPoint();
		local xOffset = self:GetCenter();
		local screenWidth = E.UIParent:GetWidth() / 2;
		xOffset = xOffset - screenWidth;
		self:ClearAllPoints();
		if(find(point, "BOTTOM")) then
			self:Point("BOTTOM", E.UIParent, "BOTTOM", xOffset, -1);
		else
			self:Point("TOP", E.UIParent, "TOP", xOffset, 1);
		end
	end);

	self:CreateUtilButton("RaidUtility_CloseButton", RaidUtilityPanel, "SecureHandlerClickTemplate", 136, 18, "TOP", RaidUtilityPanel, "BOTTOM", 0, -1, CLOSE, nil);
	RaidUtility_CloseButton:SetFrameRef("RaidUtility_ShowButton", RaidUtility_ShowButton);
	RaidUtility_CloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("RaidUtility_ShowButton"):Show();]=]);
	RaidUtility_CloseButton:SetScript("OnMouseUp", function(self) RaidUtilityPanel.toggled = false; end);
	RaidUtilityPanel:SetFrameRef("RaidUtility_CloseButton", RaidUtility_CloseButton);

	self:CreateUtilButton("DisbandRaidButton", RaidUtilityPanel, nil, RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityPanel, "TOP", 0, -5, L["Disband Group"], nil);
	DisbandRaidButton:SetScript("OnMouseUp", function(self)
		if(CheckRaidStatus()) then
			E:StaticPopup_Show("DISBAND_RAID");
		end
	end);

	self:CreateUtilButton("MainTankButton", RaidUtilityPanel, "SecureActionButtonTemplate", (DisbandRaidButton:GetWidth() / 2) - 2, 18, "TOPLEFT", DisbandRaidButton, "BOTTOMLEFT", 0, -5, MAINTANK, nil);
	MainTankButton:SetAttribute("type", "maintank");
	MainTankButton:SetAttribute("unit", "target");
	MainTankButton:SetAttribute("action", "toggle");

	self:CreateUtilButton("MainAssistButton", RaidUtilityPanel, "SecureActionButtonTemplate", (DisbandRaidButton:GetWidth() / 2) - 2, 18, "TOPRIGHT", DisbandRaidButton, "BOTTOMRIGHT", 0, -5, MAINASSIST, nil);
	MainAssistButton:SetAttribute("type", "mainassist");
	MainAssistButton:SetAttribute("unit", "target");
	MainAssistButton:SetAttribute("action", "toggle");

	self:CreateUtilButton("ReadyCheckButton", RaidUtilityPanel, nil, RaidUtilityPanel:GetWidth() * 0.8, 18, "TOPLEFT", MainTankButton, "BOTTOMLEFT", 0, -5, READY_CHECK, nil);
	ReadyCheckButton:SetScript("OnMouseUp", function(self)
		if(CheckRaidStatus()) then
			DoReadyCheck();
		end
	end);

	self:CreateUtilButton("RaidControlButton", RaidUtilityPanel, nil, DisbandRaidButton:GetWidth(), 18, "TOPLEFT", ReadyCheckButton, "BOTTOMLEFT", 0, -5, L["Raid Menu"], nil)
	RaidControlButton:SetScript("OnMouseUp", function(self)
		ToggleFriendsFrame(5);
	end);

	do
		local buttons = {
			"DisbandRaidButton",
			"MainTankButton",
			"MainAssistButton",
			"ReadyCheckButton",
			"RaidControlButton",
			"RaidUtility_ShowButton",
			"RaidUtility_CloseButton"
		};

		for i, button in pairs(buttons) do
			local f = _G[button];
			f:HookScript("OnEnter", ButtonEnter);
			f:HookScript("OnLeave", ButtonLeave)
			f:SetTemplate("Default", true);
		end
	end

	self:RegisterEvent("RAID_ROSTER_UPDATE", "ToggleRaidUtil");
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ToggleRaidUtil");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "ToggleRaidUtil");
end

local function InitializeCallback()
	RU:Initialize()
end

E:RegisterInitialModule(RU:GetName(), InitializeCallback)