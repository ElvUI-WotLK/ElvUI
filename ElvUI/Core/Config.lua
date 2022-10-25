local E, L, V, P, G = unpack(select(2, ...)); -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local strupper, ipairs, tonumber = strupper, ipairs, tonumber
local floor, select = floor, select
--WoW API / Variables
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown
local EditBox_ClearFocus = EditBox_ClearFocus
local RESET = RESET
-- GLOBALS: ElvUIMoverPopupWindow, ElvUIMoverNudgeWindow, ElvUIMoverPopupWindowDropDown

local grid
E.ConfigModeLayouts = {
	"ALL",
	"GENERAL",
	"SOLO",
	"PARTY",
	"ARENA",
	"RAID",
	"ACTIONBARS"
}

E.ConfigModeLocalizedStrings = {
	ALL = ALL,
	GENERAL = GENERAL,
	SOLO = SOLO,
	PARTY = PARTY,
	ARENA = ARENA,
	RAID = RAID,
	ACTIONBARS = ACTIONBARS_LABEL
}

function E:Grid_Show()
	if not grid then
		E:Grid_Create()
	elseif grid.boxSize ~= E.db.gridSize then
		grid:Hide()
		E:Grid_Create()
	else
		grid:Show()
	end
end

function E:Grid_Hide()
	if grid then
		grid:Hide()
	end
end

function E:ToggleMoveMode(which)
	if InCombatLockdown() then return end
	local mode = not E.ConfigurationMode

	if not which or which == "" then
		E.ConfigurationMode = mode
		which = "ALL"
	else
		E.ConfigurationMode = true
		mode = true
	end

	self:ToggleMovers(mode, which)

	if mode then
		E:Grid_Show()
		ElvUIGrid:SetAlpha(0.4)

		if not ElvUIMoverPopupWindow then
			E:CreateMoverPopup()
		end

		ElvUIMoverPopupWindow:Show()
		UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, strupper(which))

		if IsAddOnLoaded("ElvUI_OptionsUI") then
			E:Config_CloseWindow()
		end
	else
		E:Grid_Hide()
		ElvUIGrid:SetAlpha(1)

		if ElvUIMoverPopupWindow then
			ElvUIMoverPopupWindow:Hide()
		end
	end
end

function E:Grid_GetRegion()
	if grid then
		if grid.regionCount and grid.regionCount > 0 then
			local line = select(grid.regionCount, grid:GetRegions())
			grid.regionCount = grid.regionCount - 1
			line:SetAlpha(1)
			return line
		else
			return grid:CreateTexture()
		end
	end
end

function E:Grid_Create()
	if not grid then
		grid = CreateFrame("Frame", "ElvUIGrid", E.UIParent)
		grid:SetFrameStrata("BACKGROUND")
	else
		grid.regionCount = 0
		local numRegions = grid:GetNumRegions()
		for i = 1, numRegions do
			local region = select(i, grid:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				grid.regionCount = grid.regionCount + 1
				region:SetAlpha(0)
			end
		end
	end

	local width, height = E.UIParent:GetSize()
	local size, half = E.mult * 0.5, height * 0.5

	local gSize = E.db.gridSize
	local gHalf = gSize * 0.5

	local ratio = width / height
	local hHeight = height * ratio
	local wStep = width / gSize
	local hStep = hHeight / gSize

	grid.boxSize = gSize
	grid:SetPoint("CENTER", E.UIParent)
	grid:Size(width, height)
	grid:Show()

	for i = 0, gSize do
		local tx = E:Grid_GetRegion()
		if i == gHalf then
			tx:SetTexture(1, 0, 0)
			tx:SetDrawLayer("BACKGROUND", 1)
		else
			tx:SetTexture(0, 0, 0)
			tx:SetDrawLayer("BACKGROUND", 0)
		end

		local iwStep = i*wStep
		tx:ClearAllPoints()
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", iwStep - size, 0)
		tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", iwStep + size, 0)
	end

	do
		local tx = E:Grid_GetRegion()
		tx:SetTexture(1, 0, 0)
		tx:SetDrawLayer("BACKGROUND", 1)
		tx:ClearAllPoints()
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -half + size)
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(half + size))
	end

	local hSteps = floor((height*0.5)/hStep)
	for i = 1, hSteps do
		local ihStep = i*hStep

		local tx = E:Grid_GetRegion()
		tx:SetTexture(0, 0, 0)
		tx:SetDrawLayer("BACKGROUND", 0)
		tx:ClearAllPoints()
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(half+ihStep) + size)
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(half+ihStep + size))

		tx = E:Grid_GetRegion()
		tx:SetTexture(0, 0, 0)
		tx:SetDrawLayer("BACKGROUND", 0)
		tx:ClearAllPoints()
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(half-ihStep) + size)
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(half-ihStep + size))
	end
end


local function ConfigMode_OnClick(self)
	E:ToggleMoveMode(self.value)
end

local function ConfigMode_Initialize()
	local info = UIDropDownMenu_CreateInfo()
	info.func = ConfigMode_OnClick

	for _, configMode in ipairs(E.ConfigModeLayouts) do
		info.text = E.ConfigModeLocalizedStrings[configMode]
		info.value = configMode
		UIDropDownMenu_AddButton(info)
	end

	local dd = ElvUIMoverPopupWindowDropDown
	UIDropDownMenu_SetSelectedValue(dd, dd.selectedValue or "ALL")
end

function E:NudgeMover(nudgeX, nudgeY)
	local mover = ElvUIMoverNudgeWindow.child
	if not mover then return end

	local x, y, point = E:CalculateMoverPoints(mover, nudgeX, nudgeY)

	mover:ClearAllPoints()
	mover:SetPoint(point, E.UIParent, point, x, y)
	E:SaveMoverPosition(mover.name)

	--Update coordinates in Nudge Window
	E:UpdateNudgeFrame(mover, x, y)
end

function E:UpdateNudgeFrame(mover, x, y)
	if not (x and y) then
		x, y = E:CalculateMoverPoints(mover)
	end

	x = E:Round(x)
	y = E:Round(y)

	local ElvUIMoverNudgeWindow = ElvUIMoverNudgeWindow
	ElvUIMoverNudgeWindow.xOffset:SetText(x)
	ElvUIMoverNudgeWindow.yOffset:SetText(y)
	ElvUIMoverNudgeWindow.xOffset.currentValue = x
	ElvUIMoverNudgeWindow.yOffset.currentValue = y
	ElvUIMoverNudgeWindow.title:SetText(mover.textString)
end

function E:AssignFrameToNudge()
	ElvUIMoverNudgeWindow.child = self
	E:UpdateNudgeFrame(self)
end

function E:CreateMoverPopup()
	local r, g, b = unpack(E.media.rgbvaluecolor)

	local f = CreateFrame("Frame", "ElvUIMoverPopupWindow", UIParent)
	f:SetFrameStrata("FULLSCREEN_DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetFrameLevel(99)
	f:SetClampedToScreen(true)
	f:Size(370, 190)
	f:SetTemplate("Transparent")
	f:Point("BOTTOM", UIParent, "CENTER", 0, 100)
	f:Hide()

	local header = CreateFrame("Button", nil, f)
	header:SetTemplate(nil, true)
	header:Size(100, 25)
	header:Point("CENTER", f, "TOP")
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:EnableMouse(true)
	header:RegisterForClicks("AnyUp", "AnyDown")
	header:SetScript("OnMouseDown", function() f:StartMoving() end)
	header:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)
	f.header = header

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:Point("CENTER", header, "CENTER")
	title:SetText("ElvUI")
	f.title = title

	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:Point("TOPLEFT", 18, -20)
	desc:Point("BOTTOMRIGHT", -18, 48)
	desc:SetText(L["DESC_MOVERCONFIG"])
	f.desc = desc

	local snapName = f:GetName().."CheckButton"
	local snapping = CreateFrame("CheckButton", snapName, f, "OptionsCheckButtonTemplate")
	snapping:SetScript("OnShow", function(cb) cb:SetChecked(E.db.general.stickyFrames) end)
	snapping:SetScript("OnClick", function(cb) E.db.general.stickyFrames = cb:GetChecked() end)
	snapping.text = _G[snapName.."Text"]
	snapping.text:SetText(L["Sticky Frames"])
	f.snapping = snapping


	local lock = CreateFrame("Button", f:GetName().."CloseButton", f, "OptionsButtonTemplate")
	lock.text = _G[lock:GetName().."Text"]
	lock.text:SetText(L["Lock"])
	lock:SetScript("OnClick", function()
		E:ToggleMoveMode()

		if E.ConfigurationToggled then
			E.ConfigurationToggled = nil

			if IsAddOnLoaded("ElvUI_OptionsUI") then
				E:Config_OpenWindow()
			end
		end
	end)
	f.lock = lock

	local align = CreateFrame("EditBox", f:GetName().."EditBox", f, "InputBoxTemplate")
	align:Size(24, 17)
	align:SetAutoFocus(false)
	align:SetScript("OnEscapePressed", function(eb)
		eb:SetText(E.db.gridSize)
		EditBox_ClearFocus(eb)
	end)
	align:SetScript("OnEnterPressed", function(eb)
		local text = eb:GetText()
		if tonumber(text) then
			if tonumber(text) <= 256 and tonumber(text) >= 4 then
				E.db.gridSize = tonumber(text)
			else
				eb:SetText(E.db.gridSize)
			end
		else
			eb:SetText(E.db.gridSize)
		end
		E:Grid_Show()
		EditBox_ClearFocus(eb)
	end)
	align:SetScript("OnEditFocusLost", function(eb)
		eb:SetText(E.db.gridSize)
	end)
	align:SetScript("OnEditFocusGained", align.HighlightText)
	align:SetScript("OnShow", function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E.db.gridSize)
	end)

	align.text = align:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	align.text:Point("RIGHT", align, "LEFT", -4, 0)
	align.text:SetText(L["Grid Size:"])
	f.align = align

	--position buttons
	snapping:Point("BOTTOMLEFT", 14, 10)
	lock:Point("BOTTOMRIGHT", -14, 14)
	align:Point("TOPRIGHT", lock, "TOPLEFT", -4, -2)

	S:HandleCheckBox(snapping)
	S:HandleButton(lock)
	S:HandleEditBox(align)

	f:RegisterEvent("PLAYER_REGEN_DISABLED")
	f:SetScript("OnEvent", function(mover)
		if mover:IsShown() then
			mover:Hide()
			E:Grid_Hide()
			E:ToggleMoveMode()
		end
	end)

	local dropDown = CreateFrame("Frame", f:GetName().."DropDown", f, "UIDropDownMenuTemplate")
	dropDown:Point("BOTTOMRIGHT", lock, "TOPRIGHT", 8, -5)
	S:HandleDropDownBox(dropDown, 165)
	dropDown.text = dropDown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dropDown.text:Point("RIGHT", dropDown.backdrop, "LEFT", -2, 0)
	dropDown.text:SetText(L["Config Mode:"])
	f.dropDown = dropDown

	UIDropDownMenu_Initialize(dropDown, ConfigMode_Initialize)

	local nudgeFrame = CreateFrame("Frame", "ElvUIMoverNudgeWindow", E.UIParent)
	nudgeFrame:SetFrameStrata("DIALOG")
	nudgeFrame:Size(200, 110)
	nudgeFrame:SetTemplate("Transparent")
	nudgeFrame:CreateShadow(5)
	nudgeFrame.shadow:SetBackdropBorderColor(r, g, b, 0.9)
	nudgeFrame:SetFrameLevel(100)
	nudgeFrame:Hide()
	nudgeFrame:EnableMouse(true)
	nudgeFrame:SetClampedToScreen(true)
	nudgeFrame:SetScript("OnKeyDown", function(_, btn)
		local Mod = IsAltKeyDown() or IsControlKeyDown()
		if btn == "NUMPAD4" then
			E:NudgeMover(-1 * (Mod and 10 or 1))
		elseif btn == "NUMPAD6" then
			E:NudgeMover(1 * (Mod and 10 or 1))
		elseif btn == "NUMPAD8" then
			E:NudgeMover(nil, 1 * (Mod and 10 or 1))
		elseif btn == "NUMPAD2" then
			E:NudgeMover(nil, -1 * (Mod and 10 or 1))
		end
	end)

	ElvUIMoverPopupWindow:HookScript("OnHide", function() ElvUIMoverNudgeWindow:Hide() end)

	desc = nudgeFrame:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:Point("TOPLEFT", 18, -15)
	desc:Point("BOTTOMRIGHT", -18, 28)
	desc:SetJustifyH("CENTER")
	nudgeFrame.title = desc

	header = CreateFrame("Button", nil, nudgeFrame)
	header:SetTemplate(nil, true)
	header:Size(100, 25)
	header:Point("CENTER", nudgeFrame, "TOP")
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	nudgeFrame.header = header

	title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:Point("CENTER", header, "CENTER")
	title:SetText(L["Nudge"])
	nudgeFrame.title = title

	local xOffset = CreateFrame("EditBox", nudgeFrame:GetName().."XEditBox", nudgeFrame, "InputBoxTemplate")
	xOffset:Size(50, 17)
	xOffset:SetAutoFocus(false)
	xOffset.currentValue = 0
	xOffset:SetScript("OnEscapePressed", function(eb)
		eb:SetText(E:Round(xOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	xOffset:SetScript("OnEnterPressed", function(eb)
		local num = eb:GetText()
		if tonumber(num) then
			local diff = num - xOffset.currentValue
			xOffset.currentValue = num
			E:NudgeMover(diff)
		end
		eb:SetText(E:Round(xOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	xOffset:SetScript("OnEditFocusLost", function(eb)
		eb:SetText(E:Round(xOffset.currentValue))
	end)
	xOffset:SetScript("OnEditFocusGained", xOffset.HighlightText)
	xOffset:SetScript("OnShow", function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E:Round(xOffset.currentValue))
	end)

	xOffset.text = xOffset:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	xOffset.text:Point("RIGHT", xOffset, "LEFT", -4, 0)
	xOffset.text:SetText("X:")
	xOffset:Point("BOTTOMRIGHT", nudgeFrame, "CENTER", -6, 8)
	nudgeFrame.xOffset = xOffset
	S:HandleEditBox(xOffset)

	local yOffset = CreateFrame("EditBox", nudgeFrame:GetName().."YEditBox", nudgeFrame, "InputBoxTemplate")
	yOffset:Size(50, 17)
	yOffset:SetAutoFocus(false)
	yOffset.currentValue = 0
	yOffset:SetScript("OnEscapePressed", function(eb)
		eb:SetText(E:Round(yOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	yOffset:SetScript("OnEnterPressed", function(eb)
		local num = eb:GetText()
		if tonumber(num) then
			local diff = num - yOffset.currentValue
			yOffset.currentValue = num
			E:NudgeMover(nil, diff)
		end
		eb:SetText(E:Round(yOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	yOffset:SetScript("OnEditFocusLost", function(eb)
		eb:SetText(E:Round(yOffset.currentValue))
	end)
	yOffset:SetScript("OnEditFocusGained", yOffset.HighlightText)
	yOffset:SetScript("OnShow", function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E:Round(yOffset.currentValue))
	end)

	yOffset.text = yOffset:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	yOffset.text:Point("RIGHT", yOffset, "LEFT", -4, 0)
	yOffset.text:SetText("Y:")
	yOffset:Point("BOTTOMLEFT", nudgeFrame, "CENTER", 16, 8)
	nudgeFrame.yOffset = yOffset
	S:HandleEditBox(yOffset)

	local resetButton = CreateFrame("Button", nudgeFrame:GetName().."ResetButton", nudgeFrame, "UIPanelButtonTemplate")
	resetButton:SetText(RESET)
	resetButton:Point("TOP", nudgeFrame, "CENTER", 0, 2)
	resetButton:Size(100, 25)
	resetButton:SetScript("OnClick", function()
		if ElvUIMoverNudgeWindow.child.textString then
			E:ResetMovers(ElvUIMoverNudgeWindow.child.textString)
		end
	end)
	S:HandleButton(resetButton)
	nudgeFrame.resetButton = resetButton

	local upButton = CreateFrame("Button", nudgeFrame:GetName().."UpButton", nudgeFrame)
	upButton:Point("BOTTOMRIGHT", nudgeFrame, "BOTTOM", -6, 4)
	upButton:SetScript("OnClick", function() E:NudgeMover(nil, 1) end)
	S:HandleNextPrevButton(upButton)
	S:HandleButton(upButton)
	upButton:Size(22)
	nudgeFrame.upButton = upButton

	local downButton = CreateFrame("Button", nudgeFrame:GetName().."DownButton", nudgeFrame)
	downButton:Point("BOTTOMLEFT", nudgeFrame, "BOTTOM", 6, 4)
	downButton:SetScript("OnClick", function() E:NudgeMover(nil, -1) end)
	S:HandleNextPrevButton(downButton)
	S:HandleButton(downButton)
	downButton:Size(22)
	nudgeFrame.downButton = downButton

	local leftButton = CreateFrame("Button", nudgeFrame:GetName().."LeftButton", nudgeFrame)
	leftButton:Point("RIGHT", upButton, "LEFT", -6, 0)
	leftButton:SetScript("OnClick", function() E:NudgeMover(-1) end)
	S:HandleNextPrevButton(leftButton)
	S:HandleButton(leftButton)
	leftButton:Size(22)
	nudgeFrame.leftButton = leftButton

	local rightButton = CreateFrame("Button", nudgeFrame:GetName().."RightButton", nudgeFrame)
	rightButton:Point("LEFT", downButton, "RIGHT", 6, 0)
	rightButton:SetScript("OnClick", function() E:NudgeMover(1) end)
	S:HandleNextPrevButton(rightButton)
	S:HandleButton(rightButton)
	rightButton:Size(22)
	nudgeFrame.rightButton = rightButton
end

function E:Config_CloseWindow()
	local ACD = E.Libs.AceConfigDialog
	if ACD then
		ACD:Close("ElvUI")
	end
end