local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local RU = E:GetModule("RaidUtility")
local S = E:GetModule("Skins")

--Lua functions
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local GetNumRaidMembers = GetNumRaidMembers
local GetNumPartyMembers = GetNumPartyMembers
local IsPartyLeader = IsPartyLeader
local IsRaidLeader = IsRaidLeader
local IsRaidOfficer = IsRaidOfficer
local InCombatLockdown = InCombatLockdown
local DoReadyCheck = DoReadyCheck
local ToggleFriendsFrame = ToggleFriendsFrame

local PANEL_HEIGHT = 100

local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if (((IsRaidLeader() or IsRaidOfficer()) and GetNumRaidMembers() > 0) or (IsPartyLeader() and GetNumPartyMembers() > 0)) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

-- Function to create buttons in this module
function RU:CreateUtilButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, text, texture)
	local button = CreateFrame("Button", name, parent, template)
	button:Width(width)
	button:Height(height)
	button:Point(point, relativeto, point2, xOfs, yOfs)
	S:HandleButton(button)

	if text then
		button.text = button:CreateFontString(nil, "OVERLAY", button)
		button.text:FontTemplate()
		button.text:Point("CENTER", button, "CENTER", 0, -1)
		button.text:SetJustifyH("CENTER")
		button.text:SetText(text)
		button:SetFontString(button.text)
	elseif texture then
		button.texture = button:CreateTexture(nil, "OVERLAY", nil)
		button.texture:SetTexture(texture)
		button.texture:Point("TOPLEFT", button, "TOPLEFT", E.mult, -E.mult)
		button.texture:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -E.mult, E.mult)
	end
end

function RU:ToggleRaidUtil(event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil")
		return
	end

	if CheckRaidStatus() then
		if RaidUtilityPanel.toggled == true then
			RaidUtility_ShowButton:Hide()
			RaidUtilityPanel:Show()
		else
			RaidUtility_ShowButton:Show()
			RaidUtilityPanel:Hide()
		end
	else
		RaidUtility_ShowButton:Hide()
		RaidUtilityPanel:Hide()
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil")
	end
end

function RU:Initialize()
	if not E.private.general.raidUtility then return end
	self.Initialized = true

	--Create main frame
	local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", E.UIParent, "SecureHandlerClickTemplate")
	RaidUtilityPanel:SetTemplate("Transparent")
	RaidUtilityPanel:Width(230)
	RaidUtilityPanel:Height(PANEL_HEIGHT)
	RaidUtilityPanel:Point("TOP", E.UIParent, "TOP", -400, 1)
	RaidUtilityPanel:SetFrameLevel(3)
	RaidUtilityPanel.toggled = false
	RaidUtilityPanel:SetFrameStrata("HIGH")

	self:CreateUtilButton("RaidUtility_ShowButton", E.UIParent, "SecureHandlerClickTemplate", 136, 18, "TOP", E.UIParent, "TOP", -400, E.Border, RAID_CONTROL, nil)
	RaidUtility_ShowButton:SetFrameRef("RaidUtilityPanel", RaidUtilityPanel)
	RaidUtility_ShowButton:SetAttribute("_onclick", ([=[
		local raidUtil = self:GetFrameRef("RaidUtilityPanel")
		local closeButton = raidUtil:GetFrameRef("RaidUtility_CloseButton")

		self:Hide()
		raidUtil:Show()

		local point = self:GetPoint()
		local raidUtilPoint, closeButtonPoint, yOffset

		if string.find(point, "BOTTOM") then
			raidUtilPoint = "BOTTOM"
			closeButtonPoint = "TOP"
			yOffset = 1
		else
			raidUtilPoint = "TOP"
			closeButtonPoint = "BOTTOM"
			yOffset = -1
		end

		yOffset = yOffset * (tonumber(%d))

		raidUtil:ClearAllPoints()
		closeButton:ClearAllPoints()
		raidUtil:SetPoint(raidUtilPoint, self, raidUtilPoint)
		closeButton:SetPoint(raidUtilPoint, raidUtil, closeButtonPoint, 0, yOffset)
	]=]):format(-E.Border + E.Spacing * 3))
	RaidUtility_ShowButton:SetScript("OnMouseUp", function()
		RaidUtilityPanel.toggled = true
	end)
	RaidUtility_ShowButton:SetMovable(true)
	RaidUtility_ShowButton:SetClampedToScreen(true)
	RaidUtility_ShowButton:SetClampRectInsets(0, 0, -1, 1)
	RaidUtility_ShowButton:RegisterForDrag("RightButton")
	RaidUtility_ShowButton:SetFrameStrata("HIGH")
	RaidUtility_ShowButton:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		self:StartMoving()
	end)

	RaidUtility_ShowButton:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point = self:GetPoint()
		local xOffset = self:GetCenter()
		local screenWidth = E.UIParent:GetWidth() / 2
		xOffset = xOffset - screenWidth
		self:ClearAllPoints()
		if find(point, "BOTTOM") then
			self:Point("BOTTOM", E.UIParent, "BOTTOM", xOffset, -1)
		else
			self:Point("TOP", E.UIParent, "TOP", xOffset, 1)
		end
	end)

	self:CreateUtilButton("RaidUtility_CloseButton", RaidUtilityPanel, "SecureHandlerClickTemplate", 136, 18, "TOP", RaidUtilityPanel, "BOTTOM", 0, -1, CLOSE, nil)
	RaidUtility_CloseButton:SetFrameRef("RaidUtility_ShowButton", RaidUtility_ShowButton)
	RaidUtility_CloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("RaidUtility_ShowButton"):Show();]=])
	RaidUtility_CloseButton:SetScript("OnMouseUp", function() RaidUtilityPanel.toggled = false end)
	RaidUtilityPanel:SetFrameRef("RaidUtility_CloseButton", RaidUtility_CloseButton)

	self:CreateUtilButton("DisbandRaidButton", RaidUtilityPanel, nil, RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityPanel, "TOP", 0, -5, L["Disband Group"], nil)
	DisbandRaidButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			E:StaticPopup_Show("DISBAND_RAID")
		end
	end)

	self:CreateUtilButton("MainTankButton", RaidUtilityPanel, "SecureActionButtonTemplate", (DisbandRaidButton:GetWidth() / 2) - 2, 18, "TOPLEFT", DisbandRaidButton, "BOTTOMLEFT", 0, -5, MAINTANK, nil)
	MainTankButton:SetAttribute("type", "maintank")
	MainTankButton:SetAttribute("unit", "target")
	MainTankButton:SetAttribute("action", "toggle")

	self:CreateUtilButton("MainAssistButton", RaidUtilityPanel, "SecureActionButtonTemplate", (DisbandRaidButton:GetWidth() / 2) - 2, 18, "TOPRIGHT", DisbandRaidButton, "BOTTOMRIGHT", 0, -5, MAINASSIST, nil)
	MainAssistButton:SetAttribute("type", "mainassist")
	MainAssistButton:SetAttribute("unit", "target")
	MainAssistButton:SetAttribute("action", "toggle")

	self:CreateUtilButton("ReadyCheckButton", RaidUtilityPanel, nil, RaidUtilityPanel:GetWidth() * 0.8, 18, "TOPLEFT", MainTankButton, "BOTTOMLEFT", 0, -5, READY_CHECK, nil)
	ReadyCheckButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			DoReadyCheck()
		end
	end)
	ReadyCheckButton:SetScript("OnEvent", function(btn)
		if not (IsRaidLeader("player") or IsRaidOfficer("player")) then
			btn:Disable()
		else
			btn:Enable()
		end
	end)
	ReadyCheckButton:RegisterEvent("RAID_ROSTER_UPDATE")
	ReadyCheckButton:RegisterEvent("PARTY_MEMBERS_CHANGED")
	ReadyCheckButton:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:CreateUtilButton("RaidControlButton", RaidUtilityPanel, nil, MainTankButton:GetWidth(), 18, "TOPLEFT", ReadyCheckButton, "BOTTOMLEFT", 0, -5, L["Raid Menu"], nil)
	RaidControlButton:SetScript("OnMouseUp", function()
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		ToggleFriendsFrame(5)
	end)

	self:CreateUtilButton("ConvertRaidButton", RaidUtilityPanel, nil, MainAssistButton:GetWidth(), 18, "TOPRIGHT", ReadyCheckButton, "BOTTOMRIGHT", 0, -5, CONVERT_TO_RAID, nil)
	ConvertRaidButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			ConvertToRaid()
			SetLootMethod("master", "player")
		end
	end)
	ConvertRaidButton:SetScript("OnEvent", function(btn)
		if GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0 and IsPartyLeader() then
			if not btn:IsShown() then
				RaidControlButton:Width(MainAssistButton:GetWidth())
				btn:Show()
			end
		elseif btn:IsShown() then
			RaidControlButton:Width(DisbandRaidButton:GetWidth())
			btn:Hide()
		end
	end)
	ConvertRaidButton:RegisterEvent("RAID_ROSTER_UPDATE")
	ConvertRaidButton:RegisterEvent("PARTY_MEMBERS_CHANGED")
	ConvertRaidButton:RegisterEvent("PLAYER_ENTERING_WORLD")

	--Automatically show/hide the frame if we have RaidLeader or RaidOfficer
	self:RegisterEvent("RAID_ROSTER_UPDATE", "ToggleRaidUtil")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ToggleRaidUtil")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "ToggleRaidUtil")
end

local function InitializeCallback()
	RU:Initialize()
end

E:RegisterInitialModule(RU:GetName(), InitializeCallback)
