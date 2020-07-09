local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars")
local Skins = E:GetModule("Skins")

--Lua functions
local _G = _G
local select, tonumber, pairs = select, tonumber, pairs
local floor = math.floor
local find, format, upper = string.find, string.format, string.upper
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local LoadBindings, SaveBindings = LoadBindings, SaveBindings
local GetCurrentBindingSet = GetCurrentBindingSet
local SetBinding = SetBinding
local GetBindingKey = GetBindingKey
local IsAltKeyDown, IsControlKeyDown = IsAltKeyDown, IsControlKeyDown
local IsShiftKeyDown, IsModifiedClick = IsShiftKeyDown, IsModifiedClick
local InCombatLockdown = InCombatLockdown
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local GetMacroInfo = GetMacroInfo
local SecureActionButton_OnClick = SecureActionButton_OnClick
local GameTooltip_Hide = GameTooltip_Hide
local CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP = CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP
local CHARACTER_SPECIFIC_KEYBINDINGS = CHARACTER_SPECIFIC_KEYBINDINGS

local bind = CreateFrame("Frame", "ElvUI_KeyBinder", E.UIParent)

function AB:ActivateBindMode()
	if InCombatLockdown() then
		return
	end

	bind.active = true
	E:StaticPopupSpecial_Show(ElvUIBindPopupWindow)
	AB:RegisterEvent("PLAYER_REGEN_DISABLED", "DeactivateBindMode", false)
end

function AB:DeactivateBindMode(save)
	if save then
		SaveBindings(GetCurrentBindingSet())
		E:Print(L["Binds Saved"])
	else
		LoadBindings(GetCurrentBindingSet())
		E:Print(L["Binds Discarded"])
	end

	bind.active = false
	self:BindHide()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	E:StaticPopupSpecial_Hide(ElvUIBindPopupWindow)
	AB.bindingsChanged = false
end

function AB:BindHide()
	bind:ClearAllPoints()
	bind:Hide()
	GameTooltip:Hide()
end

function AB:BindListener(key)
	AB.bindingsChanged = true
	if key == "ESCAPE" or key == "RightButton" then
		if bind.button.bindings then
			for i = 1, #bind.button.bindings do
				SetBinding(bind.button.bindings[i])
			end
		end
		E:Print(format(L["All keybindings cleared for |cff00ff00%s|r."], bind.button.name))
		self:BindUpdate(bind.button, bind.spellmacro)
		if bind.spellmacro ~= "MACRO" then
			GameTooltip:Hide()
		end
		return
	end

	if key == "LSHIFT"
	or key == "RSHIFT"
	or key == "LCTRL"
	or key == "RCTRL"
	or key == "LALT"
	or key == "RALT"
	or key == "UNKNOWN"
	or key == "LeftButton"
	then return end

	if key == "MiddleButton" then key = "BUTTON3" end
	if find(key, "Button%d") then
		key = upper(key)
	end

	local alt = IsAltKeyDown() and "ALT-" or ""
	local ctrl = IsControlKeyDown() and "CTRL-" or ""
	local shift = IsShiftKeyDown() and "SHIFT-" or ""
	local keybind = format("%s%s%s%s", alt, ctrl, shift, key)

	if not bind.spellmacro or bind.spellmacro == "PET" or bind.spellmacro == "SHAPESHIFT" then
		SetBinding(keybind, bind.button.bindstring)
	else
		SetBinding(keybind, bind.spellmacro.." "..bind.button.name)
	end

	E:Print(format("%s%s%s.", keybind, L[" |cff00ff00bound to |r"], bind.button.name))
	self:BindUpdate(bind.button, bind.spellmacro)

	if bind.spellmacro ~= "MACRO" then
		GameTooltip:Hide()
	end
end

function AB:BindUpdate(button, spellmacro)
	if not bind.active or InCombatLockdown() then return end

	bind.button = button
	bind.spellmacro = spellmacro

	bind:ClearAllPoints()
	bind:SetAllPoints(button)
	bind:Show()

	ShoppingTooltip1:Hide()

	if not bind:IsMouseEnabled() then
		bind:EnableMouse(true)
	end

	if spellmacro == "MACRO" then
		bind.button.id = bind.button:GetID()

		if floor(.5 + select(2, MacroFrameTab1Text:GetTextColor()) * 10) / 10 == .8 then bind.button.id = bind.button.id + MAX_ACCOUNT_MACROS end

		bind.button.name = GetMacroInfo(bind.button.id)

		GameTooltip:SetOwner(bind, "ANCHOR_TOP")
		GameTooltip:SetPoint("BOTTOM", bind, "TOP", 0, 1)
		GameTooltip:AddLine(bind.button.name, 1, 1, 1)

		bind.button.bindings = {GetBindingKey(spellmacro.." "..bind.button.name)}

		if #bind.button.bindings == 0 then
			GameTooltip:AddLine(L["No bindings set."], .6, .6, .6)
		else
			GameTooltip:AddDoubleLine(L["Binding"], L["Key"], .6, .6, .6, .6, .6, .6)
			for i = 1, #bind.button.bindings do
				GameTooltip:AddDoubleLine(L["Binding"]..i, bind.button.bindings[i], 1, 1, 1)
			end
		end

		GameTooltip:Show()
	elseif spellmacro == "SHAPESHIFT" or spellmacro == "PET" then
		bind.button.id = tonumber(button:GetID())
		bind.button.name = button:GetName()

		if not bind.button.name then return end

		if not bind.button.id or bind.button.id < 1 or bind.button.id > (spellmacro=="SHAPESHIFT" and 10 or 12) then
			bind.button.bindstring = "CLICK "..bind.button.name..":LeftButton"
		else
			bind.button.bindstring = (spellmacro=="SHAPESHIFT" and "SHAPESHIFTBUTTON" or "BONUSACTIONBUTTON")..bind.button.id
		end

		GameTooltip:AddLine(L["Trigger"])
		GameTooltip:Show()
		GameTooltip:SetScript("OnHide", function(tt)
			tt:SetOwner(bind, "ANCHOR_NONE")
			tt:SetPoint("BOTTOM", bind, "TOP", 0, 1)
			tt:AddLine(bind.button.name, 1, 1, 1)
			bind.button.bindings = {GetBindingKey(bind.button.bindstring)}
			if #bind.button.bindings == 0 then
				tt:AddLine(L["No bindings set."], .6, .6, .6)
			else
				tt:AddDoubleLine(L["Binding"], L["Key"], .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					tt:AddDoubleLine(i, bind.button.bindings[i])
				end
			end
			tt:Show()
			tt:SetScript("OnHide", nil)
		end)
	else
		bind.button.action = tonumber(button.action)
		bind.button.name = button:GetName()

		if not bind.button.name then return end
		if (not bind.button.action or bind.button.action < 1 or bind.button.action > 132) and not (bind.button.keyBoundTarget) then
			bind.button.bindstring = "CLICK "..bind.button.name..":LeftButton"
		elseif bind.button.keyBoundTarget then
			bind.button.bindstring = bind.button.keyBoundTarget
		else
			local modact = 1 + (bind.button.action-1) % 12
			if bind.button.action < 25 or bind.button.action > 72 then
				bind.button.bindstring = "ACTIONBUTTON"..modact
			elseif bind.button.action < 73 and bind.button.action > 60 then
				bind.button.bindstring = "MULTIACTIONBAR1BUTTON"..modact
			elseif bind.button.action < 61 and bind.button.action > 48 then
				bind.button.bindstring = "MULTIACTIONBAR2BUTTON"..modact
			elseif bind.button.action < 49 and bind.button.action > 36 then
				bind.button.bindstring = "MULTIACTIONBAR4BUTTON"..modact
			elseif bind.button.action < 37 and bind.button.action > 24 then
				bind.button.bindstring = "MULTIACTIONBAR3BUTTON"..modact
			end
		end

		GameTooltip:AddLine(L["Trigger"])
		GameTooltip:Show()
		GameTooltip:SetScript("OnHide", function(tt)
			tt:SetOwner(bind, "ANCHOR_TOP")
			tt:SetPoint("BOTTOM", bind, "TOP", 0, 4)
			tt:AddLine(bind.button.name, 1, 1, 1)
			bind.button.bindings = {GetBindingKey(bind.button.bindstring)}
			if #bind.button.bindings == 0 then
				tt:AddLine(L["No bindings set."], .6, .6, .6)
			else
				tt:AddDoubleLine(L["Binding"], L["Key"], .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					tt:AddDoubleLine(i, bind.button.bindings[i])
				end
			end
			tt:Show()
			tt:SetScript("OnHide", nil)
		end)
	end
end

function AB:RegisterButton(button, override)
	local shapeshift = ShapeshiftButton1:GetScript("OnClick")
	local pet = PetActionButton1:GetScript("OnClick")
	local secureOnClick = SecureActionButton_OnClick

	if button.IsProtected and button.GetObjectType and button.GetScript and button:GetObjectType() == "CheckButton" and button:IsProtected() then
		local script = button:GetScript("OnClick")

		if script == secureOnClick or override then
			button:HookScript("OnEnter", function(b) self:BindUpdate(b) end)

			if script == shapeshift then
				button:HookScript("OnEnter", function(b) self:BindUpdate(b, "SHAPESHIFT") end)
			elseif script == pet then
				button:HookScript("OnEnter", function(b) self:BindUpdate(b, "PET") end)
			end
		end
	end
end

local elapsed = 0
function AB:Tooltip_OnUpdate(tooltip, e)
	elapsed = elapsed + e
	if elapsed < .2 then return else elapsed = 0 end

	local compareItems = IsModifiedClick("COMPAREITEMS")
	if not tooltip.comparing and compareItems and tooltip:GetItem() then
		GameTooltip_ShowCompareItem(tooltip)
		tooltip.comparing = true
	elseif tooltip.comparing and not compareItems then
		for _, frame in pairs(tooltip.shoppingTooltips) do frame:Hide() end
		tooltip.comparing = false
	end
end

function AB:RegisterMacro(addon)
	if addon == "Blizzard_MacroUI" then
		for i = 1, MAX_ACCOUNT_MACROS do
			local button = _G["MacroButton"..i]
			button:HookScript("OnEnter", function(b) AB:BindUpdate(b, "MACRO") end)
		end
	end
end

function AB:ChangeBindingProfile()
	if ElvUIBindPopupWindowCheckButton:GetChecked() then
		LoadBindings(2)
		SaveBindings(2)
	else
		LoadBindings(1)
		SaveBindings(1)
	end
end

function AB:LoadKeyBinder()
	bind:SetFrameStrata("DIALOG")
	bind:SetFrameLevel(99)
	bind:EnableMouse(true)
	bind:EnableKeyboard(true)
	bind:EnableMouseWheel(true)
	bind.texture = bind:CreateTexture()
	bind.texture:SetAllPoints(bind)
	bind.texture:SetTexture(0, 0, 0, .25)
	bind:Hide()

	self:HookScript(GameTooltip, "OnUpdate", "Tooltip_OnUpdate")
	hooksecurefunc(GameTooltip, "Hide", function(tooltip) for _, tt in pairs(tooltip.shoppingTooltips) do tt:Hide() end end)

	bind:SetScript("OnEnter", function(self) local db = self.button:GetParent().db if db and db.mouseover then AB:Button_OnEnter(self.button) end end)
	bind:SetScript("OnLeave", function(self) AB:BindHide() local db = self.button:GetParent().db if db and db.mouseover then AB:Button_OnLeave(self.button) end end)
	bind:SetScript("OnKeyUp", function(_, key) self:BindListener(key) end)
	bind:SetScript("OnMouseUp", function(_, key) self:BindListener(key) end)
	bind:SetScript("OnMouseWheel", function(_, delta) if delta > 0 then self:BindListener("MOUSEWHEELUP") else self:BindListener("MOUSEWHEELDOWN") end end)

	for b, _ in pairs(self.handledbuttons) do
		self:RegisterButton(b, true)
	end

	if not IsAddOnLoaded("Blizzard_MacroUI") then
		self:SecureHook("LoadAddOn", "RegisterMacro")
	else
		self:RegisterMacro("Blizzard_MacroUI")
	end

	--Special Popup
	local f = CreateFrame("Frame", "ElvUIBindPopupWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetFrameLevel(99)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(130)
	f:SetTemplate("Transparent")
	f:Hide()

	local header = CreateFrame("Button", nil, f)
	header:SetTemplate(nil, true)
	header:Width(100)
	header:Height(25)
	header:Point("CENTER", f, "TOP")
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:EnableMouse(true)
	header:RegisterForClicks("AnyUp", "AnyDown")
	header:SetScript("OnMouseDown", function() f:StartMoving() end)
	header:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:Point("CENTER", header, "CENTER")
	title:SetText("Key Binds")

	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:Point("TOPLEFT", 18, -32)
	desc:Point("BOTTOMRIGHT", -18, 48)
	desc:SetText(L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the ESC key to clear the current actionbutton's keybinding."])

	local perCharCheck = CreateFrame("CheckButton", f:GetName().."CheckButton", f, "OptionsCheckButtonTemplate")
	_G[perCharCheck:GetName().."Text"]:SetText(CHARACTER_SPECIFIC_KEYBINDINGS)

	perCharCheck:SetScript("OnShow", function(self)
		self:SetChecked(GetCurrentBindingSet() == 2)
	end)

	perCharCheck:SetScript("OnClick", function()
		if ( AB.bindingsChanged ) then
			E:StaticPopup_Show("CONFIRM_LOSE_BINDING_CHANGES")
		else
			AB:ChangeBindingProfile()
		end
	end)

	perCharCheck:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP, nil, nil, nil, nil, 1)
	end)

	perCharCheck:SetScript("OnLeave", GameTooltip_Hide)

	local save = CreateFrame("Button", f:GetName().."SaveButton", f, "OptionsButtonTemplate")
	_G[save:GetName().."Text"]:SetText(L["Save"])
	save:Width(150)
	save:SetScript("OnClick", function()
		AB:DeactivateBindMode(true)
	end)

	local discard = CreateFrame("Button", f:GetName().."DiscardButton", f, "OptionsButtonTemplate")
	discard:Width(150)
	_G[discard:GetName().."Text"]:SetText(L["Discard"])

	discard:SetScript("OnClick", function()
		AB:DeactivateBindMode(false)
	end)

	--position buttons
	perCharCheck:Point("BOTTOMLEFT", discard, "TOPLEFT", 0, 2)
	save:Point("BOTTOMRIGHT", -14, 10)
	discard:Point("BOTTOMLEFT", 14, 10)

	Skins:HandleCheckBox(perCharCheck)
	Skins:HandleButton(save)
	Skins:HandleButton(discard)
end