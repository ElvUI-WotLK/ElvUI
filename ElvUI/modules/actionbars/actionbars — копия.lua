local UI, C, M = select(2, ...):unpack();

local GUI = UI:GetModule("GUI")
local Bartender4 = UI:NewModule("ActionBars")

local specialButtons = {
	[132] = { icon = "Interface\\Icons\\Spell_Shadow_SacrificialShield", tooltip = LEAVE_VEHICLE}, -- Vehicle Leave Button
}

local Button = CreateFrame("CheckButton")
local Button_MT = {__index = Button}

local onEnter, onLeave, onUpdate, onDragUpdate

-- upvalues
local _G = _G
local format = string.format
local IsUsableAction, IsActionInRange, GetActionTexture, ActionHasRange = IsUsableAction, IsActionInRange, GetActionTexture, ActionHasRange
local ATTACK_BUTTON_FLASH_TIME, RANGE_INDICATOR, TOOLTIP_UPDATE_TIME = ATTACK_BUTTON_FLASH_TIME, RANGE_INDICATOR, TOOLTIP_UPDATE_TIME

local LBF = false
-- local KeyBound = LibStub("LibKeyBound-1.0")

Bartender4.Button = {}
Bartender4.Button.prototype = Button
Button.BT4init = true
function Bartender4.Button:Create(id, parent)
	local absid = (parent.id - 1) * 12 + id
	local name =  ("BT4Button%d"):format(absid)
	local button = setmetatable(CreateFrame("CheckButton", name, parent, "ActionBarButtonTemplate"), Button_MT)
	-- work around for "blocked" message when using /click macros
	GetClickFrame(name)

	-- Backwards Compat to pre-4.2.0 button names/layout
	_G[name .. "Secure"] = button
	button.Secure = button

	button.rid = id
	button.id = absid
	button.parent = parent
	button.stateactions = {}

	button:SetRealNormalTexture("")
	local oldNT = _G[("%sNormalTexture"):format(name)]
	oldNT:Hide()

	button.normalTexture = button:CreateTexture(("%sBTNT"):format(name))
	button.normalTexture:SetWidth(66)
	button.normalTexture:SetHeight(66)
	button.normalTexture:ClearAllPoints()
	button.normalTexture:SetPoint("CENTER", 0, -1)
	button.normalTexture:Show()


	--button:SetFrameStrata("MEDIUM")

	-- overwrite some scripts with out customized versions
	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnUpdate", onUpdate)
	button:SetScript("OnDragStart", onDragUpdate)
	--button:SetScript("OnReceiveDrag", nil)

	button.icon = _G[("%sIcon"):format(name)]
	button.border = _G[("%sBorder"):format(name)]
	button.cooldown = _G[("%sCooldown"):format(name)]
	button.macroName = _G[("%sName"):format(name)]
	button.hotkey = _G[("%sHotKey"):format(name)]
	button.count = _G[("%sCount"):format(name)]
	button.flash = _G[("%sFlash"):format(name)]
	button.flash:Hide()

	button:SetAttribute("type", "action")
	button:SetAttribute("action", absid)
	button:SetAttribute("useparent-unit", nil);
	button:SetAttribute("useparent-actionpage", nil);
	-- button:SetAttribute("buttonlock", Bartender4.db.profile.buttonlock)

	button:UpdateSelfCast()

	parent:WrapScript(button, "OnDragStart", [[
		local action = self:GetAttribute("action")
		if action and (not self:GetAttribute("buttonlock") or IsModifiedClick("PICKUPACTION")) then
			return "action", action
		end
	]], [[
		control:RunFor(self, self:GetAttribute("UpdateAutoAssist"))
	]])

	parent:WrapScript(button, "OnReceiveDrag", [[]], [[
		control:RunFor(self, self:GetAttribute("UpdateAutoAssist"))
	]])

	button:SetAttribute("UpdateAutoAssist", [[
		self:SetAttribute("assisttype", nil)
		self:SetAttribute("unit", nil)
		if self:GetAttribute("autoassist") then
			local action = self:GetAttribute("action")
			local type, id, subtype = GetActionInfo(action)
			if type == "spell" and id > 0 then
				if IsHelpfulSpell(id, subtype) then
					self:SetAttribute("assisttype", 1)
					self:SetAttribute("unit", G_assist_help)
				elseif IsHarmfulSpell(id, subtype) then
					self:SetAttribute("assisttype", 2)
					self:SetAttribute("unit", G_assist_harm)
				end
			end
		end
	]])

	button:SetAttribute('_childupdate-init', [[
		control:RunFor(self, self:GetAttribute("UpdateAutoAssist"))
	]])

	button:SetAttribute('_childupdate-state', [[
		self:SetAttribute("state", message)
		local action = self:GetAttribute("action-" .. message)
		if not action then return end
		if action == 132 then
			self:SetAttribute("type", "click")
			if not self:GetAttribute("isSpecial") then
				self:SetAttribute("showgrid", self:GetAttribute("showgrid") + 1)
				self:SetAttribute("isSpecial", true)
			end
		else
			if action > 120 and action <= 126 then
				self:SetAttribute("type", "click")
			else
				self:SetAttribute("type", "action")
			end
			if self:GetAttribute("isSpecial") then
				self:SetAttribute("isSpecial", nil)
				self:SetAttribute("showgrid", max(0, self:GetAttribute("showgrid") - 1))
			end
		end
		self:SetAttribute("action", action)

		-- fix unit on state change
		if action <= 120 and self:GetAttribute("autoassist") then
			control:RunFor(self, self:GetAttribute("UpdateAutoAssist"))
		else
			self:SetAttribute("unit", nil)
		end
		G_state = message
	]])

	button:SetAttribute('_childupdate-assist-help', [[
		G_assist_help = message
		if self:GetAttribute("assisttype") == 1 then
			self:SetAttribute("unit", message)
		end
	]])

	button:SetAttribute('_childupdate-assist-harm', [[
		G_assist_harm = message
		if self:GetAttribute("assisttype") == 2 then
			self:SetAttribute("unit", message)
		end
	]])

	button.SecureInit = true

	-- if LBF and parent.LBFGroup then
		-- local group = parent.LBFGroup
		-- group:AddButton(button)
	-- end

	-- if button.parent.config.showgrid then
		button:ShowGrid()
	-- end

	--self:UpdateAction(true)
	button:UpdateHotkeys()
	button:UpdateUsable()
	button:UpdateGrid()
	button:ToggleButtonElements()

	for page = 0,11,1 do
		local action = (page == 0) and button.id or (button.rid + (page - 1) * 12)
		button:SetStateAction(page, action)
	end

	return button
end

function onDragUpdate(self)
	ActionButton_UpdateState(self)
	ActionButton_UpdateFlash(self)
end

function onEnter(self)
	if not (InCombatLockdown()) then
		self:SetTooltip(self)
	end
	-- KeyBound:Set(self)
end

function onUpdate(self, elapsed)
	if self.flashing == 1 then
		self.flashtime = self.flashtime - elapsed
		if self.flashtime <= 0 then
			local overtime = -self.flashtime
			if overtime >= ATTACK_BUTTON_FLASH_TIME then
				overtime = 0
			end
			self.flashtime = ATTACK_BUTTON_FLASH_TIME - overtime

			local flashTexture = self.flash
			if flashTexture:IsShown() then
				flashTexture:Hide()
			else
				flashTexture:Show()
			end
		end
	end

	if self.rangeTimer then
		self.rangeTimer = self.rangeTimer - elapsed
		if self.rangeTimer <= 0 then
			local valid = IsActionInRange(self.action)
			self.outOfRange = (valid == 0)

			local oor = "hotkey"
			if oor == "hotkey" then
				local hotkey = self.hotkey
				local hkshown = hotkey:GetText() == RANGE_INDICATOR
				if valid and hkshown then
					hotkey:Show()
				elseif hkshown then
					hotkey:Hide()
				end

				if self.outOfRange then
					local oorc = Bartender4.db.profile.colors.range
					hotkey:SetVertexColor(oorc.r, oorc.g, oorc.b)
				else
					hotkey:SetVertexColor(1.0, 1.0, 1.0)
				end
			elseif oor == "button" then
				self:UpdateUsable()
			end
			self.rangeTimer = TOOLTIP_UPDATE_TIME
		end
	end
end
Bartender4.Button.onUpdate = onUpdate

local function updateIcon(self)
	if self.action then
		if specialButtons[self.action] then
			if not LBF then
				self.normalTexture:SetTexCoord(0, 0, 0, 0)
			end
			self.icon:SetTexture(specialButtons[self.action].icon)
			self.icon:Show()
			self:UpdateUsable()
		elseif not LBF then
			if GetActionTexture(self.action) then
				self.normalTexture:SetTexCoord(0, 0, 0, 0)
			else
				self.normalTexture:SetTexCoord(-0.15, 1.15, -0.15, 1.17)
			end
		end
	end
end

local function updateFunc(self)
	local parent = self:GetParent()
	if not self.BT4init or not parent.BT4BarType then return end
	self:UpdateRange()
	updateIcon(self)

	if self.SecureInit and not InCombatLockdown() then
		local parent = self:GetParent()
		parent:SetFrameRef("upd", self)
		parent:Execute([[
			local frame = self:GetFrameRef("upd")
			control:RunFor(frame, frame:GetAttribute("UpdateAutoAssist"))
		]])
	end
end

hooksecurefunc("ActionButton_Update", updateFunc)

Button.SetRealNormalTexture = Button.SetNormalTexture
function Button:SetNormalTexture(...)
	self.normalTexture:SetTexture(...)
end

Button.GetRealNormalTexture = Button.GetNormalTexture
function Button:GetNormalTexture()
	return self.normalTexture
end

function Button:UpdateStates()
	self:SetAttribute("autoassist", self.parent.config.autoassist)
end

function Button:SetStateAction(state, action)
	self.stateactions[state] = action
	self:RefreshStateAction(state)
end

function Button:RefreshStateAction(state)
	local state = tonumber(state or self:GetAttribute("state")) or 0
	local action = self.stateactions[state]
	assert(action, ("No valid action for state %d on button %d of Bar %d"):format(state, self.rid, self.parent.id))
	self:SetAttribute("action-"..state, action)

	if action > 120 and action <= 126 then
		self:SetAttribute("clickbutton", _G["VehicleMenuBarActionButton"..tostring(action-120)])
	elseif action == 132 then
		self:SetAttribute("clickbutton", PossessButton2)
	end
end

function Button:UpdateSelfCast()
	-- self:SetAttribute("checkselfcast", Bartender4.db.profile.selfcastmodifier and true or nil)
	-- self:SetAttribute("checkfocuscast", Bartender4.db.profile.focuscastmodifier and true or nil)
	-- self:SetAttribute("unit2", Bartender4.db.profile.selfcastrightclick and "player" or nil)
end

function Button:GetActionID()
	return self.action
end

function Button:Update()
	self:UpdateAction(true)
	self:UpdateHotkeys()
	self:ToggleButtonElements()
	self:UpdateRange()
end

function Button:UpdateAction(force)
	ActionButton_UpdateAction(self)
end

function Button:ToggleButtonElements()
	-- if self.parent.config.hidemacrotext then
		-- self.macroName:Hide()
	-- else
		self.macroName:Show()
	-- end
end

hooksecurefunc("ActionButton_UpdateHotkeys", function(self, ...)
	local parent = self:GetParent()
	if not self.BT4init or not parent.BT4BarType then return end

	self:UpdateHotkeys()
end)

function Button:UpdateHotkeys()
	local key = self:GetHotkey() or ""
	local hotkey = self.hotkey

	if key == "" or self.parent.config.hidehotkey then
		hotkey:SetText(RANGE_INDICATOR)
		if not LBF then
			hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -2)
		end
		hotkey:Hide()
	else
		hotkey:SetText(key)
		if not LBF then
			hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", -2, -2)
		end
		hotkey:Show()
	end
end

function Button:GetHotkey()
	-- local key = ((self.id <= 12) and GetBindingKey(format("ACTIONBUTTON%d", self.id))) or GetBindingKey("CLICK "..self:GetName()..":LeftButton")
	-- return key and KeyBound:ToShortKey(key)
end

function Button:GetBindings()
	local keys, binding = ""

	if self.id <= 12 then
		binding = format("ACTIONBUTTON%d", self.id)
		for i = 1, select('#', GetBindingKey(binding)) do
			local hotKey = select(i, GetBindingKey(binding))
			if keys ~= "" then
				keys = keys .. ', '
			end
			keys = keys .. GetBindingText(hotKey,'KEY_')
		end
	end

	binding = "CLICK "..self:GetName()..":LeftButton"
	for i = 1, select('#', GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding))
		if keys ~= "" then
			keys = keys .. ', '
		end
		keys = keys .. GetBindingText(hotKey,'KEY_')
	end

	return keys
end

function Button:SetKey(key)
	if self.id <= 12 then
		SetBinding(key, format("ACTIONBUTTON%d", self.id))
	else
		SetBindingClick(key, self:GetName(), 'LeftButton')
	end
end

function Button:ClearBindings()
	if self.id <= 12 then
		local binding = format("ACTIONBUTTON%d", self.id)
		while GetBindingKey(binding) do
			SetBinding(GetBindingKey(binding), nil)
		end
	end
	local binding = "CLICK "..self:GetName()..":LeftButton"
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end
end

local actionTmpl = "BT4 Bar %d Button %d"
function Button:GetActionName()
	return format(actionTmpl, self.parent.id, self.rid)
end

hooksecurefunc("ActionButton_UpdateUsable", function(self)
	if self.BT4init then
		self:UpdateUsable()
	end
end)

function Button:UpdateUsable()
	local isUsable, notEnoughMana = IsUsableAction(self.action)
	local icon = self.icon

	-- if Bartender4.db.profile.outofrange == "button" and self.outOfRange then
		-- local oorc = Bartender4.db.profile.colors.range
		-- icon:SetVertexColor(oorc.r, oorc.g, oorc.b)
	-- else
		-- if isUsable or specialButtons[self.action] then
			-- icon:SetVertexColor(1.0, 1.0, 1.0)
		-- elseif notEnoughMana then
			-- local oomc = Bartender4.db.profile.colors.mana
			-- icon:SetVertexColor(oomc.r, oomc.g, oomc.b)
		-- else
			-- icon:SetVertexColor(0.4, 0.4, 0.4)
		-- end
	-- end
end

function Button:UpdateRange()
	if Bartender4.db.profile.outofrange == "none" or not ActionHasRange(self.action) then
		self.rangeTimer = nil
		self.outOfRange = nil
	end
	self.hotkey:SetVertexColor(1.0, 1.0, 1.0)
	self:UpdateUsable()
	onUpdate(self, 10)
end

function Button:SetTooltip()
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	end

	if specialButtons[self.action] then
		GameTooltip:SetText(specialButtons[self.action].tooltip)
		self.UpdateTooltip = self.SetTooltip
	else
		if ( GameTooltip:SetAction(self.action) ) then
			self.UpdateTooltip = self.SetTooltip
		else
			self.UpdateTooltip = nil
		end
	end
end

function Button:UpdateGrid()
	if self:GetAttribute("showgrid") > 0 then
		ActionButton_ShowGrid(self)
	else
		ActionButton_HideGrid(self)
	end
end

function Button:ShowGrid()
	if not self.gridShown then
		self.gridShown = true
		self:SetAttribute("showgrid", self:GetAttribute("showgrid") + 1)
		self:UpdateGrid()
	end
end

function Button:HideGrid()
	if self.gridShown then
		self.gridShown = nil
		self:SetAttribute("showgrid", max(0, self:GetAttribute("showgrid") - 1))
		self:UpdateGrid()
	end
end

-- function Button:ClearSetPoint(...)
	-- self:ClearAllPoints()
	-- self:SetPoint(...)
-- end


	local actionbars = {}
	local buttons = {}
	
local bar1 = CreateFrame("Frame", "Bar1test", UIParent, "SecureHandlerStateTemplate")
bar1.id =1
bar1:SetSize(100, 100)
bar1:SetPoint("CENTER", UIParent)
bar1:StyleFrame()
	-- for i = 1, 5 do
		buttons[1] = Bartender4.Button:Create(1, bar1)
		buttons[1]:SetSize(100, 100)
		buttons[1]:SetPoint("CENTER")
	-- end