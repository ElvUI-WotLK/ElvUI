local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Minimap")
local Reminder = E:GetModule("ReminderBuffs")

--Lua functions
local match, utf8sub = string.match, string.utf8sub
--WoW API / Variables
local CreateFrame = CreateFrame
local ToggleCharacter = ToggleCharacter
local ToggleFrame = ToggleFrame
local ToggleAchievementFrame = ToggleAchievementFrame
local ToggleFriendsFrame = ToggleFriendsFrame
local IsAddOnLoaded = IsAddOnLoaded
local ToggleHelpFrame = ToggleHelpFrame
local GetZonePVPInfo = GetZonePVPInfo
local IsShiftKeyDown = IsShiftKeyDown
local ToggleDropDownMenu = ToggleDropDownMenu
local Minimap_OnClick = Minimap_OnClick
local GetMinimapZoneText = GetMinimapZoneText
local InCombatLockdown = InCombatLockdown

local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{
		text = CHARACTER_BUTTON,
		notCheckable = 1,
		func = function()
			ToggleCharacter("PaperDollFrame")
		end
	},
	{
		text = SPELLBOOK_ABILITIES_BUTTON,
		notCheckable = 1,
		func = function()
			ToggleFrame(SpellBookFrame)
		end
	},
	{
		text = TALENTS_BUTTON,
		notCheckable = 1,
		func = ToggleTalentFrame
	},
	{
		text = ACHIEVEMENT_BUTTON,
		notCheckable = 1,
		func = ToggleAchievementFrame
	},
	{
		text = QUESTLOG_BUTTON,
		notCheckable = 1,
		func = function()
			ToggleFrame(QuestLogFrame)
		end
	},
	{
		text = SOCIAL_BUTTON,
		notCheckable = 1,
		func = function()
			ToggleFriendsFrame(1)
		end
	},
	{
		text = L["Calendar"],
		notCheckable = 1,
		func = function()
			GameTimeFrame:Click()
		end
	},
	{
		text = L["Farm Mode"],
		notCheckable = 1,
		func = FarmMode
	},
	{
		text = BATTLEFIELD_MINIMAP,
		notCheckable = 1,
		func = ToggleBattlefieldMinimap
	},
	{
		text = TIMEMANAGER_TITLE,
		notCheckable = 1,
		func = ToggleTimeManager
	},
	{
		text = PLAYER_V_PLAYER,
		notCheckable = 1,
		func = function()
			ToggleFrame(PVPParentFrame)
		end
	},
	{
		text = LFG_TITLE,
		notCheckable = 1,
		func = function()
			ToggleFrame(LFDParentFrame)
		end
	},
	{
		text = LOOKING_FOR_RAID,
		notCheckable = 1,
		func = function()
			ToggleFrame(LFRParentFrame)
		end
	},
	{
		text = MAINMENU_BUTTON,
		notCheckable = 1,
		func = function()
			if GameMenuFrame:IsShown() then
				PlaySound("igMainMenuQuit")
				HideUIPanel(GameMenuFrame)
			else
				PlaySound("igMainMenuOpen")
				ShowUIPanel(GameMenuFrame)
			end
		end
	},
	{
		text = HELP_BUTTON,
		notCheckable = 1,
		func = ToggleHelpFrame
	}
}

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "arena" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	else
		return 0.84, 0.03, 0.03
	end
end

function M:ADDON_LOADED(event, addon)
	if addon == "Blizzard_TimeManager" then
		self:UnregisterEvent(event)
		TimeManagerClockButton:Kill()
	end
end

function M:Minimap_OnMouseUp(btn)
	local position = self:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if match(position, "LEFT") then
			EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
		else
			EasyMenu(menuList, menuFrame, "cursor", -160, 0, "MENU", 2)
		end
	elseif btn == "RightButton" then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor")
	else
		Minimap_OnClick(self)
	end
end

function M:Minimap_OnMouseWheel(d)
	local zoomLevel = Minimap:GetZoom()

	if d > 0 and zoomLevel < 5 then
		Minimap:SetZoom(zoomLevel + 1)
	elseif d < 0 and zoomLevel > 0 then
		Minimap:SetZoom(zoomLevel - 1)
	end
end

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == "HIDE" or not E.private.general.minimap.enable then return end
	Minimap.location:SetText(utf8sub(GetMinimapZoneText(),1,46))
	Minimap.location:SetTextColor(self:GetLocTextColor())
	Minimap.location:FontTemplate(E.Libs.LSM:Fetch("font", E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)
end

function M:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UpdateSettings()
end

function M:CreateFarmModeMap()
	local fm = CreateFrame("Minimap", "FarmModeMap", E.UIParent)
	fm:Size(E.db.farmSize)
	fm:Point("TOP", E.UIParent, "TOP", 0, -120)
	fm:SetClampedToScreen(true)
	fm:CreateBackdrop("Default")
	fm:EnableMouseWheel(true)
	fm:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	fm:SetScript("OnMouseUp", M.Minimap_OnMouseUp)
	fm:RegisterForDrag("LeftButton", "RightButton")
	fm:SetMovable(true)
	fm:SetScript("OnDragStart", function(self) self:StartMoving() end)
	fm:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	fm:Hide()

	self.farmModeMap = fm

	fm:SetScript("OnShow", function()
		if BuffsMover and not E:HasMoverBeenMoved("BuffsMover") then
			BuffsMover:ClearAllPoints()
			BuffsMover:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
		end

		if DebuffsMover and not E:HasMoverBeenMoved("DebuffsMover") then
			DebuffsMover:ClearAllPoints()
			DebuffsMover:Point("TOPRIGHT", ElvUIPlayerBuffs, "BOTTOMRIGHT", 0, -3)
		end

		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(fm)

		if IsAddOnLoaded("Routes") then
			LibStub("AceAddon-3.0"):GetAddon("Routes"):ReparentMinimap(fm)
		end

		if IsAddOnLoaded("GatherMate2") then
			LibStub("AceAddon-3.0"):GetAddon("GatherMate2"):GetModule("Display"):ReparentMinimapPins(fm)
		end
	end)

	fm:SetScript("OnHide", function()
		if BuffsMover and not E:HasMoverBeenMoved("BuffsMover") then
			E:ResetMovers(L["Player Buffs"])
		end

		if DebuffsMover and not E:HasMoverBeenMoved("DebuffsMover") then
			E:ResetMovers(L["Player Debuffs"])
		end

		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(Minimap)

		if IsAddOnLoaded("Routes") then
			LibStub("AceAddon-3.0"):GetAddon("Routes"):ReparentMinimap(Minimap)
		end

		if IsAddOnLoaded("GatherMate2") then
			LibStub("AceAddon-3.0"):GetAddon("GatherMate2"):GetModule("Display"):ReparentMinimapPins(Minimap)
		end
	end)
end

local isResetting
local function ResetZoom()
	Minimap:SetZoom(0)
	isResetting = nil
end
local function SetupZoomReset(self, zoomLevel)
	if not isResetting and zoomLevel > 0 and E.db.general.minimap.resetZoom.enable then
		isResetting = true
		E:Delay(E.db.general.minimap.resetZoom.time, ResetZoom)
	end
end

function M:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end

	E.MinimapSize = E.private.general.minimap.enable and E.db.general.minimap.size or Minimap:GetWidth() + 10
	E.MinimapWidth, E.MinimapHeight = E.MinimapSize, E.MinimapSize

	if E.db.general.reminder.enable then
		E.RBRWidth = (E.MinimapHeight + ((E.Border - E.Spacing*3) * 5) + E.Border*2) / 6
	else
		E.RBRWidth = 0
	end

	if E.private.general.minimap.enable then
		Minimap:Size(E.MinimapSize, E.MinimapSize)
	end

	if LeftMiniPanel and RightMiniPanel then
		if E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			LeftMiniPanel:Show()
			RightMiniPanel:Show()
		else
			LeftMiniPanel:Hide()
			RightMiniPanel:Hide()
		end
	end

	if BottomMiniPanel then
		if E.db.datatexts.minimapBottom and E.private.general.minimap.enable then
			BottomMiniPanel:Show()
		else
			BottomMiniPanel:Hide()
		end
	end

	if BottomLeftMiniPanel then
		if E.db.datatexts.minimapBottomLeft and E.private.general.minimap.enable then
			BottomLeftMiniPanel:Show()
		else
			BottomLeftMiniPanel:Hide()
		end
	end

	if BottomRightMiniPanel then
		if E.db.datatexts.minimapBottomRight and E.private.general.minimap.enable then
			BottomRightMiniPanel:Show()
		else
			BottomRightMiniPanel:Hide()
		end
	end

	if TopMiniPanel then
		if E.db.datatexts.minimapTop and E.private.general.minimap.enable then
			TopMiniPanel:Show()
		else
			TopMiniPanel:Hide()
		end
	end

	if TopLeftMiniPanel then
		if E.db.datatexts.minimapTopLeft and E.private.general.minimap.enable then
			TopLeftMiniPanel:Show()
		else
			TopLeftMiniPanel:Hide()
		end
	end

	if TopRightMiniPanel then
		if E.db.datatexts.minimapTopRight and E.private.general.minimap.enable then
			TopRightMiniPanel:Show()
		else
			TopRightMiniPanel:Hide()
		end
	end

	if MMHolder then
		MMHolder:Width((Minimap:GetWidth() + E.Border*2 + E.Spacing*3) + E.RBRWidth)

		if E.db.datatexts.minimapPanels then
			MMHolder:Height(Minimap:GetHeight() + (LeftMiniPanel and (LeftMiniPanel:GetHeight() + E.Border) or 24) + E.Spacing*3)
		else
			MMHolder:Height(Minimap:GetHeight() + E.Border + E.Spacing*3)
		end
	end

	if Minimap.location then
		Minimap.location:Width(E.MinimapSize)

		if E.db.general.minimap.locationText ~= "SHOW" or not E.private.general.minimap.enable then
			Minimap.location:Hide()
		else
			Minimap.location:Show()
		end
	end

	if MinimapMover then
		MinimapMover:Size(MMHolder:GetSize())
	end

	if GameTimeFrame then
		if E.private.general.minimap.hideCalendar then
			GameTimeFrame:Hide()
		else
			local pos = E.db.general.minimap.icons.calendar.position or "TOPRIGHT"
			local scale = E.db.general.minimap.icons.calendar.scale or 1
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.calendar.xOffset or 0, E.db.general.minimap.icons.calendar.yOffset or 0)
			GameTimeFrame:SetScale(scale)
			GameTimeFrame:Show()
		end
	end

	if MiniMapMailFrame then
		local pos = E.db.general.minimap.icons.mail.position or "TOPRIGHT"
		local scale = E.db.general.minimap.icons.mail.scale or 1
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.mail.xOffset or 3, E.db.general.minimap.icons.mail.yOffset or 4)
		MiniMapMailFrame:SetScale(scale)
	end

	if MiniMapLFGFrame then
		local pos = E.db.general.minimap.icons.lfgEye.position or "BOTTOMRIGHT"
		local scale = E.db.general.minimap.icons.lfgEye.scale or 1
		MiniMapLFGFrame:ClearAllPoints()
		MiniMapLFGFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.lfgEye.xOffset or 3, E.db.general.minimap.icons.lfgEye.yOffset or 0)
		MiniMapLFGFrame:SetScale(scale)
		LFDSearchStatus:SetScale(scale)
	end

	if MiniMapBattlefieldFrame then
		local pos = E.db.general.minimap.icons.battlefield.position or "BOTTOMRIGHT"
		local scale = E.db.general.minimap.icons.battlefield.scale or 1
		MiniMapBattlefieldFrame:ClearAllPoints()
		MiniMapBattlefieldFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.battlefield.xOffset or 3, E.db.general.minimap.icons.battlefield.yOffset or 0)
		MiniMapBattlefieldFrame:SetScale(scale)
	end

	if MiniMapInstanceDifficulty then
		local pos = E.db.general.minimap.icons.difficulty.position or "TOPLEFT"
		local scale = E.db.general.minimap.icons.difficulty.scale or 1
		local x = E.db.general.minimap.icons.difficulty.xOffset or 0
		local y = E.db.general.minimap.icons.difficulty.yOffset or 0
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:Point(pos, Minimap, pos, x, y)
		MiniMapInstanceDifficulty:SetScale(scale)
	end

	if ElvConfigToggle then
		if E.db.general.reminder.enable and E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			ElvConfigToggle:Show()
			ElvConfigToggle:Width(E.RBRWidth)
		else
			ElvConfigToggle:Hide()
		end
	end

	if ElvUI_ReminderBuffs then
		Reminder:UpdateSettings()
	end
end

local function MinimapPostDrag()
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetAllPoints(Minimap)
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetAllPoints(Minimap)
end

function M:Initialize()
	menuFrame:SetTemplate("Transparent", true)

	self:UpdateSettings()

	if not E.private.general.minimap.enable then
		Minimap:SetMaskTexture("Textures\\MinimapMask")
		return
	end

	--Support for other mods
	function GetMinimapShape()
		return "SQUARE"
	end

	local mmholder = CreateFrame("Frame", "MMHolder", Minimap)
	mmholder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
	mmholder:Width((Minimap:GetWidth() + 29) + E.RBRWidth)
	mmholder:Height(Minimap:GetHeight() + 53)
	Minimap:ClearAllPoints()
	if E.db.general.reminder.position == "LEFT" then
		Minimap:Point("TOPRIGHT", mmholder, "TOPRIGHT", -E.Border, -E.Border)
	else
		Minimap:Point("TOPLEFT", mmholder, "TOPLEFT", E.Border, -E.Border)
	end
	Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
	Minimap:CreateBackdrop()
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Minimap:HookScript("OnEnter", function(mm)
		if E.db.general.minimap.locationText ~= "MOUSEOVER" or not E.private.general.minimap.enable then return end
		mm.location:Show()
	end)

	Minimap:HookScript("OnLeave", function(self)
		if E.db.general.minimap.locationText ~= "MOUSEOVER" or not E.private.general.minimap.enable then return end
		self.location:Hide()
	end)

	Minimap.location = Minimap:CreateFontString(nil, "OVERLAY")
	Minimap.location:FontTemplate(nil, nil, "OUTLINE")
	Minimap.location:Point("TOP", Minimap, "TOP", 0, -2)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")
	if E.db.general.minimap.locationText ~= "SHOW" or not E.private.general.minimap.enable then
		Minimap.location:Hide()
	end

	MinimapBorder:Hide()
	MinimapBorderTop:Hide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapVoiceChatFrame:Hide()
	MinimapNorthTag:Kill()
	MinimapZoneTextButton:Hide()
	MiniMapTracking:Kill()
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture(E.Media.Textures.Mail)

	if MiniMapBattlefieldBorder then
		MiniMapBattlefieldBorder:Hide()
	end

	MiniMapLFGFrameBorder:Hide()

	MiniMapWorldMapButton:Hide()

	MiniMapInstanceDifficulty:SetParent(Minimap)

	if TimeManagerClockButton then
		TimeManagerClockButton:Kill()
	else
		self:RegisterEvent("ADDON_LOADED")
	end

	E:CreateMover(MMHolder, "MinimapMover", L["Minimap"], nil, nil, MinimapPostDrag, nil, nil, "maps,minimap")

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", M.Minimap_OnMouseUp)

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")

	hooksecurefunc(Minimap, "SetZoom", SetupZoomReset)

	self:CreateFarmModeMap()

	self.Initialized = true
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterInitialModule(M:GetName(), InitializeCallback)