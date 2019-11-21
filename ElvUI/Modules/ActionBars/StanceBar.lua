local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars")

--Lua functions
local _G = _G
local ceil = math.ceil
local format, gsub, match = string.format, string.gsub, string.match
--WoW API / Variables
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftForm = GetShapeshiftForm
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local GetSpellInfo = GetSpellInfo
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver

local NUM_SHAPESHIFT_SLOTS = NUM_SHAPESHIFT_SLOTS

local bar = CreateFrame("Frame", "ElvUI_StanceBar", E.UIParent, "SecureHandlerStateTemplate")
bar:SetFrameStrata("LOW")

function AB:UPDATE_SHAPESHIFT_COOLDOWN()
	local numForms = GetNumShapeshiftForms()
	local start, duration, enable, cooldown
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		if i <= numForms then
			cooldown = _G["ElvUI_StanceBarButton"..i.."Cooldown"]
			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_SetTimer(cooldown, start, duration, enable)
		end
	end

	self:StyleShapeShift("UPDATE_SHAPESHIFT_COOLDOWN")
end

function AB:StyleShapeShift()
	local numForms = GetNumShapeshiftForms()
	local texture, name, isActive, isCastable, _
	local buttonName, button, icon, cooldown
	local stance = GetShapeshiftForm()

	for i = 1, NUM_SHAPESHIFT_SLOTS do
		buttonName = "ElvUI_StanceBarButton"..i
		button = _G[buttonName]
		icon = _G[buttonName.."Icon"]
		cooldown = _G[buttonName.."Cooldown"]

		if i <= numForms then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)

			if self.db.stanceBar.style == "darkenInactive" then
				if name then
					_, _, texture = GetSpellInfo(name)
				end
			end

			if not texture then
				texture = "Interface\\Icons\\Spell_Nature_WispSplode"
			end

			if texture then
				cooldown:SetAlpha(1)
			else
				cooldown:SetAlpha(0)
			end

			if isActive then
				button:GetCheckedTexture():SetTexture(1, 1, 1, 0.5)

				if numForms == 1 and (E.myclass ~= "WARRIOR" and E.myclass ~= "DEATHKNIGHT") then
					button:SetChecked(true)
				else
					button:SetChecked(self.db.stanceBar.style ~= "darkenInactive")
				end
			else
				if numForms == 1 or stance == 0 then
					button:SetChecked(false)
				else
					button:SetChecked(self.db.stanceBar.style == "darkenInactive")
					button:GetCheckedTexture():SetAlpha(1)
					if self.db.stanceBar.style == "darkenInactive" then
						button:GetCheckedTexture():SetTexture(0, 0, 0, 0.5)
					else
						button:GetCheckedTexture():SetTexture(1, 1, 1, 0.5)
					end
				end
			end

			icon:SetTexture(texture)

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end

function AB:PositionAndSizeBarShapeShift()
	local buttonSpacing = E:Scale(self.db.stanceBar.buttonspacing)
	local backdropSpacing = E:Scale((self.db.stanceBar.backdropSpacing or self.db.stanceBar.buttonspacing))
	local buttonsPerRow = self.db.stanceBar.buttonsPerRow
	local numButtons = self.db.stanceBar.buttons
	local size = E:Scale(self.db.stanceBar.buttonsize)
	local point = self.db.stanceBar.point
	local widthMult = self.db.stanceBar.widthMult
	local heightMult = self.db.stanceBar.heightMult
	if bar.mover then
		bar.mover.positionOverride = point
		E:UpdatePositionOverride(bar.mover:GetName())
	end
	bar.db = self.db.stanceBar
	bar.mouseover = self.db.stanceBar.mouseover

	if bar.LastButton and numButtons > bar.LastButton then
		numButtons = bar.LastButton
	end

	if bar.LastButton and buttonsPerRow > bar.LastButton then
		buttonsPerRow = bar.LastButton
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	local numColumns = ceil(numButtons / buttonsPerRow)
	if numColumns < 1 then
		numColumns = 1
	end

	if self.db.stanceBar.backdrop then
		bar.backdrop:Show()
	else
		bar.backdrop:Hide()
		--Set size multipliers to 1 when backdrop is disabled
		widthMult = 1
		heightMult = 1
	end

	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult-1)) + ((self.db.stanceBar.backdrop and (E.Border + backdropSpacing) or E.Spacing)*2)
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult-1)) + ((self.db.stanceBar.backdrop and (E.Border + backdropSpacing) or E.Spacing)*2)
	bar:Width(barWidth)
	bar:Height(barHeight)

	if self.db.stanceBar.enabled then
		bar:SetScale(1)
		bar:SetAlpha(bar.db.alpha)
		E:EnableMover(bar.mover:GetName())
	else
		bar:SetScale(0.0001)
		bar:SetAlpha(0)
		E:DisableMover(bar.mover:GetName())
	end

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

	if self.db.stanceBar.inheritGlobalFade then
		bar:SetParent(self.fadeParent)
	else
		bar:SetParent(E.UIParent)
	end

	local button, lastButton, lastColumnButton
	local firstButtonSpacing = (self.db.stanceBar.backdrop and (E.Border + backdropSpacing) or E.Spacing)
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		button = _G["ElvUI_StanceBarButton"..i]
		lastButton = _G["ElvUI_StanceBarButton"..i - 1]
		lastColumnButton = _G["ElvUI_StanceBarButton"..i - buttonsPerRow]

		button:SetParent(bar)
		button:ClearAllPoints()
		button:Size(size)

		if self.db.stanceBar.mouseover then
			bar:SetAlpha(0)
		else
			bar:SetAlpha(bar.db.alpha)
		end

		if i == 1 then
			local x, y
			if point == "BOTTOMLEFT" then
				x, y = firstButtonSpacing, firstButtonSpacing
			elseif point == "TOPRIGHT" then
				x, y = -firstButtonSpacing, -firstButtonSpacing
			elseif point == "TOPLEFT" then
				x, y = firstButtonSpacing, -firstButtonSpacing
			else
				x, y = -firstButtonSpacing, firstButtonSpacing
			end

			button:Point(point, bar, point, x, y)
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0
			local y = -buttonSpacing
			local buttonPoint, anchorPoint = "TOP", "BOTTOM"
			if verticalGrowth == "UP" then
				y = buttonSpacing
				buttonPoint = "BOTTOM"
				anchorPoint = "TOP"
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y)
		else
			local x = buttonSpacing
			local y = 0
			local buttonPoint, anchorPoint = "LEFT", "RIGHT"
			if horizontalGrowth == "LEFT" then
				x = -buttonSpacing
				buttonPoint = "RIGHT"
				anchorPoint = "LEFT"
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y)
		end

		if i > numButtons then
			button:SetScale(0.0001)
			button:SetAlpha(0)
		else
			button:SetScale(1)
			button:SetAlpha(bar.db.alpha)
		end

		self:StyleButton(button, nil, self.LBFGroup and E.private.actionbar.lbf.enable or nil)
	end

	if self.LBFGroup and E.private.actionbar.lbf.enable then self.LBFGroup:Skin(E.private.actionbar.lbf.skin) end
end

function AB:AdjustMaxStanceButtons(event)
	if InCombatLockdown() then
		AB.NeedsAdjustMaxStanceButtons = event or true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local visibility = self.db.stanceBar.visibility
	if visibility and match(visibility, "[\n\r]") then
		visibility = gsub(visibility, "[\n\r]", "")
	end

	for i = 1, #bar.buttons do
		bar.buttons[i]:Hide()
	end

	local numButtons = GetNumShapeshiftForms()
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		if not bar.buttons[i] then
			bar.buttons[i] = CreateFrame("CheckButton", format(bar:GetName().."Button%d", i), bar, "ShapeshiftButtonTemplate")
			bar.buttons[i]:SetID(i)
			if self.LBFGroup and E.private.actionbar.lbf.enable then
				self.LBFGroup:AddButton(bar.buttons[i])
			end
			self:HookScript(bar.buttons[i], "OnEnter", "Button_OnEnter")
			self:HookScript(bar.buttons[i], "OnLeave", "Button_OnLeave")
		end

		if i <= numButtons then
			bar.buttons[i]:Show()
			bar.LastButton = i
		else
			bar.buttons[i]:Hide()
		end
	end

	self:PositionAndSizeBarShapeShift()

	-- sometimes after combat lock down `event` may be true because of passing it back with `AB.NeedsAdjustMaxStanceButtons`
	if event == "UPDATE_SHAPESHIFT_FORMS" then
		self:StyleShapeShift()
	end

	RegisterStateDriver(bar, "visibility", (numButtons == 0 and "hide") or visibility)
end

function AB:UpdateStanceBindings()
	local color = self.db.fontColor

	for i = 1, NUM_SHAPESHIFT_SLOTS do
		if self.db.hotkeytext then
			local key = GetBindingKey("SHAPESHIFTBUTTON"..i)
			local hotkey = _G["ElvUI_StanceBarButton"..i.."HotKey"]
			hotkey:Show()
			hotkey:SetText(key)
			hotkey:SetTextColor(color.r, color.g, color.b)
			self:FixKeybindText(_G["ElvUI_StanceBarButton"..i])
		else
			_G["ElvUI_StanceBarButton"..i.."HotKey"]:Hide()
		end
	end
end

function AB:CreateBarShapeShift()
	bar:CreateBackdrop(self.db.transparentBackdrops and "Transparent")
	bar.backdrop:SetAllPoints()
	bar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -4)
	bar.buttons = {}

	self:HookScript(bar, "OnEnter", "Bar_OnEnter")
	self:HookScript(bar, "OnLeave", "Bar_OnLeave")

	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", "AdjustMaxStanceButtons")
	self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
	self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", "StyleShapeShift")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "StyleShapeShift")
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", "StyleShapeShift")
	E:ShapeshiftDelayedUpdate(AB.StyleShapeShift, self)

	E:CreateMover(bar, "ShiftAB", L["Stance Bar"], nil, -3, nil, "ALL,ACTIONBARS", nil, "actionbar,stanceBar")
	self:AdjustMaxStanceButtons()
	self:PositionAndSizeBarShapeShift()
	self:StyleShapeShift()
	self:UpdateStanceBindings()
end