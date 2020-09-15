local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars")

--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
local ceil = math.ceil
local format, gsub, match, split = string.format, string.gsub, string.match, string.split
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitAffectingCombat = UnitAffectingCombat
local UnitExists = UnitExists
local PetDismiss = PetDismiss
local CanExitVehicle = CanExitVehicle
local InCombatLockdown = InCombatLockdown
local ClearOverrideBindings = ClearOverrideBindings
local GetBindingKey = GetBindingKey
local SetOverrideBindingClick = SetOverrideBindingClick
local SetCVar = SetCVar
local SetModifiedClick = SetModifiedClick
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local LEAVE_VEHICLE = LEAVE_VEHICLE

local LAB = E.Libs.LAB
local LSM = E.Libs.LSM
local LBF = E.Libs.LBF

local UIHider

AB.RegisterCooldown = E.RegisterCooldown

AB.handledBars = {} --List of all bars
AB.handledbuttons = {} --List of all buttons that have been modified.
AB.barDefaults = {
	bar1 = {
		page = 1,
		bindButtons = "ACTIONBUTTON",
		conditions = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
		position = "BOTTOM,ElvUIParent,BOTTOM,0,4",
	},
	bar2 = {
		page = 5,
		bindButtons = "MULTIACTIONBAR2BUTTON",
		conditions = "",
		position = "BOTTOM,ElvUI_Bar1,TOP,0,2"
	},
	bar3 = {
		page = 6,
		bindButtons = "MULTIACTIONBAR1BUTTON",
		conditions = "",
		position = "LEFT,ElvUI_Bar1,RIGHT,4,0"
	},
	bar4 = {
		page = 4,
		bindButtons = "MULTIACTIONBAR4BUTTON",
		conditions = "",
		position = "RIGHT,ElvUIParent,RIGHT,-4,0"
	},
	bar5 = {
		page = 3,
		bindButtons = "MULTIACTIONBAR3BUTTON",
		conditions = "",
		position = "RIGHT,ElvUI_Bar1,LEFT,-4,0"
	},
	bar6 = {
		page = 2,
		bindButtons = "ELVUIBAR6BUTTON",
		conditions = "",
		position = "BOTTOM,ElvUI_Bar2,TOP,0,2"
	}
}

AB.customExitButton = {
	func = function()
		if UnitExists("vehicle") then
			VehicleExit()
		else
			PetDismiss()
		end
	end,
	texture = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
	tooltip = LEAVE_VEHICLE
}

function AB:PositionAndSizeBar(barName)
	local buttonSpacing = E:Scale(self.db[barName].buttonspacing)
	local backdropSpacing = E:Scale((self.db[barName].backdropSpacing or self.db[barName].buttonspacing))
	local buttonsPerRow = self.db[barName].buttonsPerRow
	local numButtons = self.db[barName].buttons
	local size = E:Scale(self.db[barName].buttonsize)
	local point = self.db[barName].point
	local numColumns = ceil(numButtons / buttonsPerRow)
	local widthMult = self.db[barName].widthMult
	local heightMult = self.db[barName].heightMult
	local visibility = self.db[barName].visibility
	local bar = self.handledBars[barName]

	bar.db = self.db[barName]

	if visibility and match(visibility, "[\n\r]") then
		visibility = gsub(visibility, "[\n\r]","")
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	if numColumns < 1 then
		numColumns = 1
	end

	if bar.db.backdrop then
		bar.backdrop:Show()
	else
		bar.backdrop:Hide()
		--Set size multipliers to 1 when backdrop is disabled
		widthMult = 1
		heightMult = 1
	end

	local sideSpacing = (bar.db.backdrop == true and (E.Border + backdropSpacing) or E.Spacing)
	--Size of all buttons + Spacing between all buttons + Spacing between additional rows of buttons + Spacing between backdrop and buttons + Spacing on end borders with non-thin borders
	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult - 1)) + (sideSpacing*2)
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult - 1)) + (sideSpacing*2)
	bar:Width(barWidth)
	bar:Height(barHeight)

	bar.mouseover = bar.db.mouseover

	local horizontalGrowth, verticalGrowth
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN"
	else
		verticalGrowth = "UP"
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT"
	else
		horizontalGrowth = "LEFT"
	end

	if bar.db.mouseover then
		bar:SetAlpha(0)
	else
		bar:SetAlpha(bar.db.alpha)
	end

	if bar.db.inheritGlobalFade then
		bar:SetParent(self.fadeParent)
	else
		bar:SetParent(E.UIParent)
	end

	local button, lastButton, lastColumnButton
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i]
		lastButton = bar.buttons[i - 1]
		lastColumnButton = bar.buttons[i-buttonsPerRow]
		button:SetParent(bar)
		button:ClearAllPoints()
		button:Size(size)
		button:SetAttribute("showgrid", 1)

		if i == 1 then
			local x, y
			if point == "BOTTOMLEFT" then
				x, y = sideSpacing, sideSpacing
			elseif point == "TOPRIGHT" then
				x, y = -sideSpacing, -sideSpacing
			elseif point == "TOPLEFT" then
				x, y = sideSpacing, -sideSpacing
			else
				x, y = -sideSpacing, sideSpacing
			end

			button:Point(point, bar, point, x, y)
		elseif (i - 1) % buttonsPerRow == 0 then
			local y = -buttonSpacing
			local buttonPoint, anchorPoint = "TOP", "BOTTOM"
			if verticalGrowth == "UP" then
				y = buttonSpacing
				buttonPoint = "BOTTOM"
				anchorPoint = "TOP"
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, 0, y)
		else
			local x = buttonSpacing
			local buttonPoint, anchorPoint = "LEFT", "RIGHT"
			if horizontalGrowth == "LEFT" then
				x = -buttonSpacing
				buttonPoint = "RIGHT"
				anchorPoint = "LEFT"
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, 0)
		end

		if i > numButtons then
			button:Hide()
		else
			button:Show()
		end

		self:StyleButton(button, nil, self.LBFGroup and E.private.actionbar.lbf.enable and true or nil)
	end

	if bar.db.enabled or not bar.initialized then
		if not bar.db.mouseover then
			bar:SetAlpha(bar.db.alpha)
		end

		local page = self:GetPage(barName, self.barDefaults[barName].page, self.barDefaults[barName].conditions)
		bar:Show()
		RegisterStateDriver(bar, "visibility", visibility) -- this is ghetto
		RegisterStateDriver(bar, "page", page)
		bar:SetAttribute("page", page)

		if not bar.initialized then
			bar.initialized = true
			AB:PositionAndSizeBar(barName)
			return
		end
		E:EnableMover(bar.mover:GetName())
	else
		E:DisableMover(bar.mover:GetName())
		bar:Hide()
		UnregisterStateDriver(bar, "visibility")
	end

	E:SetMoverSnapOffset("ElvAB_"..bar.id, bar.db.buttonspacing / 2)

	if self.LBFGroup and E.private.actionbar.lbf.enable then
		self.LBFGroup:Skin(E.private.actionbar.lbf.skin)
	end
end

function AB:CreateBar(id)
	local bar = CreateFrame("Frame", "ElvUI_Bar"..id, E.UIParent, "SecureHandlerStateTemplate")
	local point, anchor, attachTo, x, y = split(",", self.barDefaults["bar"..id].position)
	bar:Point(point, anchor, attachTo, x, y)
	bar.id = id
	bar:CreateBackdrop(self.db.transparentBackdrops and "Transparent")
	bar:SetFrameStrata("LOW")

	--Use this method instead of :SetAllPoints, as the size of the mover would otherwise be incorrect
	bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", E.Spacing, -E.Spacing)
	bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -E.Spacing, E.Spacing)

	bar.buttons = {}
	bar.bindButtons = self.barDefaults["bar"..id].bindButtons
	self:HookScript(bar, "OnEnter", "Bar_OnEnter")
	self:HookScript(bar, "OnLeave", "Bar_OnLeave")

	for i = 1, 12 do
		bar.buttons[i] = LAB:CreateButton(i, format(bar:GetName().."Button%d", i), bar, nil)
		bar.buttons[i]:SetState(0, "action", i)
		for k = 1, 11 do
			bar.buttons[i]:SetState(k, "action", (k - 1) * 12 + i)
		end

		if i == 12 then
			bar.buttons[i]:SetState(11, "custom", AB.customExitButton)
		end

		if self.LBFGroup and E.private.actionbar.lbf.enable then
			self.LBFGroup:AddButton(bar.buttons[i])
		end

		self:HookScript(bar.buttons[i], "OnEnter", "Button_OnEnter")
		self:HookScript(bar.buttons[i], "OnLeave", "Button_OnLeave")
	end
	self:UpdateButtonConfig(bar, bar.bindButtons)

	bar:SetAttribute("_onstate-page", [[
		if newstate ~= 0 then
			self:SetAttribute("state", newstate)
			control:ChildUpdate("state", newstate)
		else
			local newCondition = self:GetAttribute("newCondition")
			if newCondition then
				newstate = SecureCmdOptionParse(newCondition)
				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
			end
		end
	]])

	self.handledBars["bar"..id] = bar
	E:CreateMover(bar, "ElvAB_"..id, L["Bar "]..id, nil, nil, nil,"ALL,ACTIONBARS",nil,"actionbar,bar"..id)
	self:PositionAndSizeBar("bar"..id)
	return bar
end

function AB:PLAYER_REGEN_ENABLED()
	if AB.NeedsUpdateButtonSettings then
		self:UpdateButtonSettings()
		AB.NeedsUpdateButtonSettings = nil
	end
	if AB.NeedsUpdateMicroBarVisibility then
		self:UpdateMicroBarVisibility()
		AB.NeedsUpdateMicroBarVisibility = nil
	end
	if AB.NeedsAdjustMaxStanceButtons then
		AB:AdjustMaxStanceButtons(AB.NeedsAdjustMaxStanceButtons) --sometimes it holds the event, otherwise true. pass it before we nil it.
		AB.NeedsAdjustMaxStanceButtons = nil
	end
	if AB.NeedsPositionAndSizeBarTotem then
		self:PositionAndSizeBarTotem()
		AB.NeedsPositionAndSizeBarTotem = nil
	end
	if AB.NeedRecallButtonUpdate then
		MultiCastRecallSpellButton_Update(MultiCastRecallSpellButton)
		AB.NeedRecallButtonUpdate = nil
	end

	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

local function Vehicle_OnEvent(self, event)
	if CanExitVehicle() and not E.db.general.minimap.icons.vehicleLeave.hide then
		self:Show()
	else
		self:Hide()
	end
end

function AB:UpdateVehicleLeave()
	if not self.vehicle then return end

	local pos = E.db.general.minimap.icons.vehicleLeave.position

	self.vehicle:ClearAllPoints()
	self.vehicle:Point(pos, Minimap, pos, E.db.general.minimap.icons.vehicleLeave.xOffset, E.db.general.minimap.icons.vehicleLeave.yOffset)
	self.vehicle:Size(26 * E.db.general.minimap.icons.vehicleLeave.scale)

	Vehicle_OnEvent(self.vehicle)
end

function AB:CreateVehicleLeave()
	local vehicle = CreateFrame("Button", "ElvUI_LeaveVehicleButton", E.UIParent)
	vehicle:Hide()
	vehicle:SetFrameStrata("HIGH")
	vehicle:SetNormalTexture(E.Media.Textures.ExitVehicle)
	vehicle:SetPushedTexture(E.Media.Textures.ExitVehicle)
	vehicle:SetHighlightTexture(E.Media.Textures.ExitVehicle)
	vehicle:SetTemplate()
	vehicle:EnableMouse(true)
	vehicle:RegisterForClicks("AnyUp")

	vehicle:SetScript("OnClick", VehicleExit)
	vehicle:SetScript("OnEvent", Vehicle_OnEvent)
	vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")
	vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
	vehicle:RegisterEvent("UNIT_EXITED_VEHICLE")
	vehicle:RegisterEvent("VEHICLE_UPDATE")

	self.vehicle = vehicle
	self:UpdateVehicleLeave()
end

function AB:ReassignBindings(event)
	if event == "UPDATE_BINDINGS" then
		self:UpdatePetBindings()
		self:UpdateStanceBindings()

		if E.myclass == "SHAMAN" then
			self:UpdateTotemBindings()
		end
	end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED")

	if InCombatLockdown() then return end

	for _, bar in pairs(self.handledBars) do
		if bar then
			ClearOverrideBindings(bar)
			for i = 1, #bar.buttons do
				local button = format(bar.bindButtons.."%d", i)
				local real_button = format(bar:GetName().."Button%d", i)
				for k = 1, select("#", GetBindingKey(button)) do
					local key = select(k, GetBindingKey(button))
					if key and key ~= "" then
						SetOverrideBindingClick(bar, false, key, real_button)
					end
				end
			end
		end
	end
end

function AB:RemoveBindings()
	if InCombatLockdown() then return end

	for _, bar in pairs(self.handledBars) do
		if bar then
			ClearOverrideBindings(bar)
		end
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ReassignBindings")
end

function AB:UpdateBar1Paging()
	if self.db.bar6.enabled then
		AB.barDefaults.bar1.conditions = "[bonusbar:5] 11; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;"
	else
		AB.barDefaults.bar1.conditions = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;"
	end

	if (E.private.actionbar.enable ~= true or InCombatLockdown()) or not self.isInitialized then return end
	local bar2Option = InterfaceOptionsActionBarsPanelBottomRight
	local bar3Option = InterfaceOptionsActionBarsPanelBottomLeft
	local bar4Option = InterfaceOptionsActionBarsPanelRightTwo
	local bar5Option = InterfaceOptionsActionBarsPanelRight

	if (self.db.bar2.enabled and not bar2Option:GetChecked()) or (not self.db.bar2.enabled and bar2Option:GetChecked()) then
		bar2Option:Click()
	end

	if (self.db.bar3.enabled and not bar3Option:GetChecked()) or (not self.db.bar3.enabled and bar3Option:GetChecked()) then
		bar3Option:Click()
	end

	if not self.db.bar5.enabled and not self.db.bar4.enabled then
		if bar4Option:GetChecked() then
			bar4Option:Click()
		end

		if bar5Option:GetChecked() then
			bar5Option:Click()
		end
	elseif not self.db.bar5.enabled then
		if not bar5Option:GetChecked() then
			bar5Option:Click()
		end

		if not bar4Option:GetChecked() then
			bar4Option:Click()
		end
	elseif (self.db.bar4.enabled and not bar4Option:GetChecked()) or (not self.db.bar4.enabled and bar4Option:GetChecked()) then
		bar4Option:Click()
	elseif (self.db.bar5.enabled and not bar5Option:GetChecked()) or (not self.db.bar5.enabled and bar5Option:GetChecked()) then
		bar5Option:Click()
	end
end

function AB:UpdateButtonSettingsForBar(barName)
	local bar = self.handledBars[barName]
	self:UpdateButtonConfig(bar, bar.bindButtons)
end

function AB:UpdateButtonSettings()
	if E.private.actionbar.enable ~= true then return end

	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	for button in pairs(self.handledbuttons) do
		if button then
			self:StyleButton(button, button.noBackdrop, button.useMasque)
		else
			self.handledbuttons[button] = nil
		end
	end

	self:UpdatePetBindings()
	self:UpdateStanceBindings()

	if E.myclass == "SHAMAN" then
		self:UpdateTotemBindings()
	end

	for barName, bar in pairs(self.handledBars) do
		if bar then
			self:UpdateButtonConfig(bar, bar.bindButtons)
			self:PositionAndSizeBar(barName)
		end
	end

	self:AdjustMaxStanceButtons()
	self:PositionAndSizeBarPet()
	self:PositionAndSizeBarShapeShift()
end

function AB:GetPage(bar, defaultPage, condition)
	local page = self.db[bar].paging[E.myclass]
	if not condition then condition = "" end
	if not page then
		page = ""
	elseif match(page, "[\n\r]") then
		page = gsub(page, "[\n\r]","")
	end

	if page then
		condition = condition.." "..page
	end
	condition = condition.." "..defaultPage

	return condition
end

function AB:StyleButton(button, noBackdrop, useMasque)
	local name = button:GetName()
	local icon = _G[name.."Icon"]
	local count = _G[name.."Count"]
	local flash = _G[name.."Flash"]
	local hotkey = _G[name.."HotKey"]
	local border = _G[name.."Border"]
	local macroText = _G[name.."Name"]
	local normal = _G[name.."NormalTexture"]
	local normal2 = button:GetNormalTexture()
	local buttonCooldown = _G[name.."Cooldown"]

	local color = self.db.fontColor
	local countPosition = self.db.countTextPosition or "BOTTOMRIGHT"
	local countXOffset = self.db.countTextXOffset or 0
	local countYOffset = self.db.countTextYOffset or 2

	button.noBackdrop = noBackdrop
	button.useMasque = useMasque

	if flash then flash:SetTexture(nil) end
	if normal then normal:SetTexture(nil) normal:Hide() normal:SetAlpha(0) end
	if normal2 then normal2:SetTexture(nil) normal2:Hide() normal2:SetAlpha(0) end
	if border and not button.useMasque then border:Kill() end

	if count then
		count:ClearAllPoints()
		count:Point(countPosition, countXOffset, countYOffset)
		count:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
		count:SetTextColor(color.r, color.g, color.b)
	end

	if macroText then
		macroText:ClearAllPoints()
		macroText:Point("BOTTOM", 0, 1)
		macroText:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
		macroText:SetTextColor(color.r, color.g, color.b)
	end

	if not button.noBackdrop and not button.backdrop and not button.useMasque then
		button:CreateBackdrop(self.db.transparentButtons and "Transparent", true)
		button.backdrop:SetAllPoints()
	end

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	if self.db.hotkeytext or self.db.useRangeColorText then
		hotkey:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
		if button.config and (button.config.outOfRangeColoring ~= "hotkey") then
			button.hotkey:SetTextColor(color.r, color.g, color.b)
		end
	end

	self:FixKeybindText(button)

	if not button.useMasque then
		button:StyleButton()
	else
		button:StyleButton(true, true, true)
	end

	if not self.handledbuttons[button] then
		buttonCooldown.CooldownOverride = "actionbar"

		E:RegisterCooldown(buttonCooldown)

		self.handledbuttons[button] = true
	end
end

function AB:Bar_OnEnter(bar)
	if bar:GetParent() == self.fadeParent then
		if not self.fadeParent.mouseLock then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1)
		end
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
	end
end

function AB:Bar_OnLeave(bar)
	if bar:GetParent() == self.fadeParent then
		if not self.fadeParent.mouseLock then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha)
		end
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	if bar:GetParent() == self.fadeParent then
		if not self.fadeParent.mouseLock then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1)
		end
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	if bar:GetParent() == self.fadeParent then
		if not self.fadeParent.mouseLock then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha)
		end
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:BlizzardOptionsPanel_OnEvent()
	InterfaceOptionsActionBarsPanelBottomRightText:SetFormattedText(L["Remove Bar %d Action Page"], 2)
	InterfaceOptionsActionBarsPanelBottomLeftText:SetFormattedText(L["Remove Bar %d Action Page"], 3)
	InterfaceOptionsActionBarsPanelRightTwoText:SetFormattedText(L["Remove Bar %d Action Page"], 4)
	InterfaceOptionsActionBarsPanelRightText:SetFormattedText(L["Remove Bar %d Action Page"], 5)

	InterfaceOptionsActionBarsPanelBottomRight:SetScript("OnEnter", nil)
	InterfaceOptionsActionBarsPanelBottomLeft:SetScript("OnEnter", nil)
	InterfaceOptionsActionBarsPanelRightTwo:SetScript("OnEnter", nil)
	InterfaceOptionsActionBarsPanelRight:SetScript("OnEnter", nil)
end

function AB:FadeParent_OnEvent(event, unit)
	if (event == "UNIT_SPELLCAST_START"
	or event == "UNIT_SPELLCAST_STOP"
	or event == "UNIT_SPELLCAST_CHANNEL_START"
	or event == "UNIT_SPELLCAST_CHANNEL_STOP"
	or event == "UNIT_HEALTH") and unit ~= "player" then return end

	local cur, max = UnitHealth("player"), UnitHealthMax("player")
	local cast, channel = UnitCastingInfo("player"), UnitChannelInfo("player")
	local target, focus = UnitExists("target"), UnitExists("focus")
	local combat = UnitAffectingCombat("player")
	if (cast or channel) or (cur ~= max) or (target or focus) or combat then
		self.mouseLock = true
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	else
		self.mouseLock = false
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 1 - AB.db.globalFadeAlpha)
	end
end

function AB:DisableBlizzard()
	UIHider = CreateFrame("Frame")
	UIHider:Hide()

	MultiBarBottomLeft:SetParent(UIHider)
	MultiBarBottomLeft.Show = E.noop
	MultiBarBottomLeft.Hide = E.noop
	MultiBarBottomRight:SetParent(UIHider)
	MultiBarBottomRight.Hide = E.noop
	MultiBarBottomRight.Show = E.noop
	MultiBarLeft:SetParent(UIHider)
	MultiBarLeft.Show = E.noop
	MultiBarLeft.Hide = E.noop
	MultiBarRight:SetParent(UIHider)
	MultiBarRight.Show = E.noop
	MultiBarRight.Hide = E.noop

	-- Hide MultiBar Buttons, but keep the bars alive
	for i = 1, 12 do
		_G["ActionButton"..i]:Hide()
		_G["ActionButton"..i]:UnregisterAllEvents()
		_G["ActionButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomLeftButton"..i]:Hide()
		_G["MultiBarBottomLeftButton"..i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton"..i]:Hide()
		_G["MultiBarBottomRightButton"..i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarRightButton"..i]:Hide()
		_G["MultiBarRightButton"..i]:UnregisterAllEvents()
		_G["MultiBarRightButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarLeftButton"..i]:Hide()
		_G["MultiBarLeftButton"..i]:UnregisterAllEvents()
		_G["MultiBarLeftButton"..i]:SetAttribute("statehidden", true)

		if _G["VehicleMenuBarActionButton"..i] then
			_G["VehicleMenuBarActionButton"..i]:Hide()
			_G["VehicleMenuBarActionButton"..i]:UnregisterAllEvents()
			_G["VehicleMenuBarActionButton"..i]:SetAttribute("statehidden", true)
		end

		_G["BonusActionButton"..i]:Hide()
		_G["BonusActionButton"..i]:UnregisterAllEvents()
		_G["BonusActionButton"..i]:SetAttribute("statehidden", true)

		if E.myclass ~= "SHAMAN" then
			_G["MultiCastActionButton"..i]:Hide()
			_G["MultiCastActionButton"..i]:UnregisterAllEvents()
			_G["MultiCastActionButton"..i]:SetAttribute("statehidden", true)
		end
	end

	MultiCastActionBarFrame.ignoreFramePositionManager = true

	MainMenuBar:Hide()
	MainMenuBar:SetParent(UIHider)

	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetParent(UIHider)

	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(UIHider)

	MainMenuBarArtFrame:UnregisterAllEvents()
	MainMenuBarArtFrame:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
	MainMenuBarArtFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIHider)

	ShapeshiftBarFrame:UnregisterAllEvents()
	ShapeshiftBarFrame:Hide()
	ShapeshiftBarFrame:SetParent(UIHider)

	BonusActionBarFrame:UnregisterAllEvents()
	BonusActionBarFrame:Hide()
	BonusActionBarFrame:SetParent(UIHider)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIHider)

	VehicleMenuBar:UnregisterAllEvents()
	VehicleMenuBar:Hide()
	VehicleMenuBar:SetParent(UIHider)

	if E.myclass ~= "SHAMAN" then
		MultiCastActionBarFrame:UnregisterAllEvents()
		MultiCastActionBarFrame:Hide()
		MultiCastActionBarFrame:SetParent(UIHider)
	end

	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)

	InterfaceOptionsActionBarsPanelLockActionBars:EnableMouse(false)
	InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)

	InterfaceOptionsStatusTextPanelXP:SetAlpha(0)
	InterfaceOptionsStatusTextPanelXP:SetScale(0.0001)

	self:SecureHook("BlizzardOptionsPanel_OnEvent")

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
end

function AB:UpdateButtonConfig(bar, buttonName)
	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if not bar.buttonConfig then bar.buttonConfig = {hideElements = {}, colors = {}} end
	bar.buttonConfig.hideElements.macro = not self.db.macrotext
	bar.buttonConfig.hideElements.hotkey = not self.db.hotkeytext
	bar.buttonConfig.showGrid = self.db["bar"..bar.id].showGrid
	bar.buttonConfig.clickOnDown = self.db.keyDown
	bar.buttonConfig.outOfRangeColoring = (self.db.useRangeColorText and "hotkey") or "button"
	SetModifiedClick("PICKUPACTION", self.db.movementModifier)
	bar.buttonConfig.colors.range = E:SetColorTable(bar.buttonConfig.colors.range, self.db.noRangeColor)
	bar.buttonConfig.colors.mana = E:SetColorTable(bar.buttonConfig.colors.mana, self.db.noPowerColor)
	bar.buttonConfig.colors.usable = E:SetColorTable(bar.buttonConfig.colors.usable, self.db.usableColor)
	bar.buttonConfig.colors.notUsable = E:SetColorTable(bar.buttonConfig.colors.notUsable, self.db.notUsableColor)

	for i, button in pairs(bar.buttons) do
		bar.buttonConfig.keyBoundTarget = format(buttonName.."%d", i)
		button.keyBoundTarget = bar.buttonConfig.keyBoundTarget
		button.postKeybind = AB.FixKeybindText
		button:SetAttribute("buttonlock", self.db.lockActionBars)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)
		if self.db.rightClickSelfCast then
			button:SetAttribute("unit2", "player")
		else
			button:SetAttribute("unit2", nil)
		end

		button:UpdateConfig(bar.buttonConfig)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName().."HotKey"]
	local text = hotkey:GetText()

	local hotkeyPosition = E.db.actionbar.hotkeyTextPosition or "TOPRIGHT"
	local hotkeyXOffset = E.db.actionbar.hotkeyTextXOffset or 0
	local hotkeyYOffset = E.db.actionbar.hotkeyTextYOffset or -3

	local justify = "RIGHT"
	if hotkeyPosition == "TOPLEFT" or hotkeyPosition == "BOTTOMLEFT" then
		justify = "LEFT"
	elseif hotkeyPosition == "TOP" or hotkeyPosition == "BOTTOM" then
		justify = "CENTER"
	end

	if text then
		text = gsub(text, "SHIFT%-", L["KEY_SHIFT"])
		text = gsub(text, "ALT%-", L["KEY_ALT"])
		text = gsub(text, "CTRL%-", L["KEY_CTRL"])
		text = gsub(text, "BUTTON", L["KEY_MOUSEBUTTON"])
		text = gsub(text, "MOUSEWHEELUP", L["KEY_MOUSEWHEELUP"])
		text = gsub(text, "MOUSEWHEELDOWN", L["KEY_MOUSEWHEELDOWN"])
		text = gsub(text, "NUMPAD", L["KEY_NUMPAD"])
		text = gsub(text, "PAGEUP", L["KEY_PAGEUP"])
		text = gsub(text, "PAGEDOWN", L["KEY_PAGEDOWN"])
		text = gsub(text, "SPACE", L["KEY_SPACE"])
		text = gsub(text, "INSERT", L["KEY_INSERT"])
		text = gsub(text, "HOME", L["KEY_HOME"])
		text = gsub(text, "DELETE", L["KEY_DELETE"])
		text = gsub(text, "NMULTIPLY", "*")
		text = gsub(text, "NMINUS", "N-")
		text = gsub(text, "NPLUS", "N+")

		hotkey:SetText(text)
		hotkey:SetJustifyH(justify)
	end

	if not button.useMasque then
		hotkey:ClearAllPoints()
		hotkey:Point(hotkeyPosition, hotkeyXOffset, hotkeyYOffset)
	end
end

function AB:LAB_ButtonUpdate(button)
	local color = AB.db.fontColor
	button.count:SetTextColor(color.r, color.g, color.b)
	if button.config and (button.config.outOfRangeColoring ~= "hotkey") then
		button.hotkey:SetTextColor(color.r, color.g, color.b)
	end

	if button.backdrop then
		if AB.db.equippedItem then
			if button:IsEquipped() and AB.db.equippedItemColor then
				color = AB.db.equippedItemColor
				button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
				button.backdrop.isColored = true
			elseif button.backdrop.isColored then
				button.backdrop.isColored = nil
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		elseif button.backdrop.isColored then
			button.backdrop.isColored = nil
			button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end
end
LAB.RegisterCallback(AB, "OnButtonUpdate", AB.LAB_ButtonUpdate)

local function OnCooldownUpdate(_, button, start, duration)
	if not button._state_type == "action" then return end

	if duration and duration > 1.5 then
		button.saturationLocked = true --Lock any new actions that are created after we activated desaturation option

		button.icon:SetDesaturated(true)

		if (E.db.cooldown.enable and AB.db.cooldown.reverse) or (not E.db.cooldown.enable and not AB.db.cooldown.reverse) then
			if not button.onCooldownDoneHooked then
				AB:HookScript(button.cooldown, "OnHide", function()
					button.icon:SetDesaturated(false)
				end)

				button.onCooldownDoneHooked = true
			end
		else
			if not button.onCooldownTimerDoneHooked then
				if button.cooldown.timer then
					AB:HookScript(button.cooldown.timer, "OnHide", function()
						if (E.db.cooldown.enable and AB.db.cooldown.reverse) or (not E.db.cooldown.enable and not AB.db.cooldown.reverse) then return end

						button.icon:SetDesaturated(false)
					end)

					button.onCooldownTimerDoneHooked = true
				end
			end
		end
	end
end

function AB:ToggleDesaturation(value)
	value = value or self.db.desaturateOnCooldown

	if value then
		LAB.RegisterCallback(AB, "OnCooldownUpdate", OnCooldownUpdate)
		local start, duration
		for button in pairs(LAB.actionButtons) do
			button.saturationLocked = true
			start, duration = button:GetCooldown()
			OnCooldownUpdate(nil, button, start, duration)
		end
	else
		LAB.UnregisterCallback(AB, "OnCooldownUpdate")
		for button in pairs(LAB.actionButtons) do
			button.saturationLocked = nil
			button.icon:SetDesaturated(false)
			if (E.db.cooldown.enable and AB.db.cooldown.reverse) or (not E.db.cooldown.enable and not AB.db.cooldown.reverse) then
				if button.onCooldownDoneHooked then
					AB:Unhook(button.cooldown, "OnHide")

					button.onCooldownDoneHooked = nil
				end
			else
				if button.onCooldownTimerDoneHooked then
					if button.cooldown.timer then
						if (E.db.cooldown.enable and AB.db.cooldown.reverse) or (not E.db.cooldown.enable and not AB.db.cooldown.reverse) then return end

						AB:Unhook(button.cooldown.timer, "OnHide")

						button.onCooldownTimerDoneHooked = nil
					end
				end
			end
		end
	end
end

function AB:Initialize()
	self.db = E.db.actionbar
	if E.private.actionbar.enable ~= true then return end
	self.Initialized = true

	self.LBFGroup = LBF and LBF:Group("ElvUI", "ActionBars")

	self.fadeParent = CreateFrame("Frame", "Elv_ABFade", UIParent)
	self.fadeParent:SetAlpha(1 - self.db.globalFadeAlpha)
	self.fadeParent:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.fadeParent:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.fadeParent:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_START")
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_STOP")
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	self.fadeParent:RegisterEvent("UNIT_HEALTH")
	self.fadeParent:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self.fadeParent:SetScript("OnEvent", self.FadeParent_OnEvent)

	self:DisableBlizzard()
	self:SetupMicroBar()
	self:UpdateBar1Paging()

	for i = 1, 6 do
		self:CreateBar(i)
	end

	self:CreateBarPet()
	self:CreateBarShapeShift()
	self:CreateVehicleLeave()

	if E.myclass == "SHAMAN" and self.db.barTotem.enabled then
		self:CreateTotemBar()
	end

	self:UpdateButtonSettings()
	self:LoadKeyBinder()

	self:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")
	self:ReassignBindings()

	--We handle actionbar lock for regular bars, but the lock on PetBar needs to be handled by WoW so make some necessary updates
	SetCVar("lockActionBars", (self.db.lockActionBars == true and 1 or 0))
	LOCK_ACTIONBAR = (self.db.lockActionBars == true and "1" or "0") --Keep an eye on this, in case it taints

	self:ToggleDesaturation()
end

local function InitializeCallback()
	AB:Initialize()
end

E:RegisterModule(AB:GetName(), InitializeCallback)