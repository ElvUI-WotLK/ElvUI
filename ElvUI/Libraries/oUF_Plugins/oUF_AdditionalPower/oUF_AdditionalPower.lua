if(select(2, UnitClass("player")) ~= "DRUID") then return; end

local _, ns = ...
local oUF = ns.oUF or oUF

local function UpdateColor(element, cur, max)
	local parent = element.__owner

	local r, g, b, t
	if(element.colorClass) then
		t = self.colors.class['DRUID']
	elseif(element.colorSmooth) then
		r, g, b = parent.ColorGradient(cur, max, unpack(element.smoothGradient or parent.colors.smooth))
	elseif(element.colorPower) then
		t = parent.colors.power['MANA']
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

local function Update(self, event, unit)
	if(unit ~= 'player') then return end

	local element = self.AdditionalPower
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local cur = UnitPower('player', 0)
	local max = UnitPowerMax('player', 0)
	element:SetMinMaxValues(0, max)
	element:SetValue(cur)

	element:UpdateColor(cur, max)

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, event)
	end
end

local function Path(self, ...)
	return (self.AdditionalPower.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent("UNIT_MANA", Path)
	self:RegisterEvent("UNIT_MAXMANA", Path)

	self.AdditionalPower:Show()

	if self.AdditionalPower.PostUpdateVisibility then
		self.AdditionalPower:PostUpdateVisibility(true, not self.AdditionalPower.isEnabled)
	end

	self.AdditionalPower.isEnabled = true

	Path(self, 'ElementEnable', 'player', SPELL_POWER_MANA)
end

local function ElementDisable(self)
	self:UnregisterEvent("UNIT_MANA", Path)
	self:UnregisterEvent("UNIT_MAXMANA", Path)

	self.AdditionalPower:Hide()

	if self.AdditionalPower.PostUpdateVisibility then
		self.AdditionalPower:PostUpdateVisibility(false, self.AdditionalPower.isEnabled)
	end

	self.AdditionalPower.isEnabled = nil

	Path(self, 'ElementDisable', 'player', SPELL_POWER_MANA)
end

local function Visibility(self, event, unit)
	local shouldEnable

	if(UnitPowerType('player') ~= SPELL_POWER_MANA) then
		shouldEnable = true
	end

	if(shouldEnable) then
		ElementEnable(self)
	else
		ElementDisable(self)
	end
end

local function VisibilityPath(self, ...)
	return (self.AdditionalPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.AdditionalPower
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', VisibilityPath)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(not element.UpdateColor) then
			element.UpdateColor = UpdateColor
		end

		return true
	end
end

local function Disable(self)
	local element = self.AdditionalPower
	if(element) then
		ElementDisable(self)

		self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', VisibilityPath)
	end
end

oUF:AddElement('AdditionalPower', VisibilityPath, Enable, Disable)