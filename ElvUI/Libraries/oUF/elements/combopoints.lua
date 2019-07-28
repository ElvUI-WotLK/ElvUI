--[[
# Element: ClassPower

Handles the visibility and updating of the player's class resources (like Chi Orbs or Holy Power) and combo points.

## Widget

ClassPower - An `table` consisting of as many StatusBars as the theoretical maximum return of [UnitPowerMax](http://wowprogramming.com/docs/api/UnitPowerMax.html).

## Sub-Widgets

.bg - A `Texture` used as a background. It will inherit the color of the main StatusBar.

## Sub-Widget Options

.multiplier - Used to tint the background based on the widget's R, G and B values. Defaults to 1 (number)[0-1]

## Notes

A default texture will be applied if the sub-widgets are StatusBars and don't have a texture set.
If the sub-widgets are StatusBars, their minimum and maximum values will be set to 0 and 1 respectively.

Supported class powers:
  - All     - Combo Points
  - Mage    - Arcane Charges
  - Monk    - Chi Orbs
  - Paladin - Holy Power
  - Warlock - Soul Shards

## Examples

    local ClassPower = {}
    for index = 1, 10 do
        local Bar = CreateFrame('StatusBar', nil, self)

        -- Position and size.
        Bar:SetSize(16, 16)
        Bar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', (index - 1) * Bar:GetWidth(), 0)

        ClassPower[index] = Bar
    end

    -- Register with oUF
    self.ClassPower = ClassPower
--]]

local _, ns = ...
local oUF = ns.oUF

local _, PlayerClass = UnitClass('player')

-- Holds the class specific stuff.
local ClassPowerID, ClassPowerType
local ClassPowerEnable, ClassPowerDisable

local function UpdateColor(element, powerType)
	local color = element.__owner.colors.power[powerType]
	local r, g, b = color[1], color[2], color[3]
	for i = 1, #element do
		local bar = element[i]
		bar:SetStatusBarColor(r, g, b)

		local bg = bar.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

local function Update(self, event, unit, powerType)
	if(unit == 'pet') then return end

	local element = self.ClassPower

	--[[ Callback: ClassPower:PreUpdate(event)
	Called before the element has been updated.

	* self  - the ClassPower element
	]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local cur, max, oldMax
	if(event ~= 'ClassPowerDisable') then
		if(UnitHasVehicleUI('player')) then
			cur = GetComboPoints('vehicle', 'target')
		else
			cur = GetComboPoints('player', 'target')
		end
		max = MAX_COMBO_POINTS

		local numActive = cur + 0.9
		for i = 1, max do
			if(i > numActive) then
				element[i]:Hide()
				element[i]:SetValue(0)
			else
				element[i]:Show()
				element[i]:SetValue(cur - i + 1)
			end
		end

		oldMax = element.__max
		if(max ~= oldMax) then
			if(max < oldMax) then
				for i = max + 1, oldMax do
					element[i]:Hide()
					element[i]:SetValue(0)
				end
			end

			element.__max = max
		end
	end
	--[[ Callback: ClassPower:PostUpdate(cur, max, hasMaxChanged, powerType)
	Called after the element has been updated.

	* self          - the ClassPower element
	* cur           - the current amount of power (number)
	* max           - the maximum amount of power (number)
	* hasMaxChanged - indicates whether the maximum amount has changed since the last update (boolean)
	* powerType     - the active power type (string)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(cur, max, oldMax ~= max, powerType)
	end
end

local function Path(self, ...)
	--[[ Override: ClassPower.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ClassPower.Override or Update) (self, ...)
end

local function Visibility(self, event, unit)
	local element = self.ClassPower
	local shouldEnable

	if(UnitHasVehicleUI('player')) then
		shouldEnable = true
		unit = 'vehicle'
	elseif UnitExists("target") then
		shouldEnable = true
	end

	local isEnabled = element.isEnabled
	local powerType = unit == 'vehicle' and 'COMBO_POINTS' or ClassPowerType

	if(shouldEnable) then
		--[[ Override: ClassPower:UpdateColor(powerType)
		Used to completely override the internal function for updating the widgets' colors.

		* self      - the ClassPower element
		* powerType - the active power type (string)
		--]]
		(element.UpdateColor or UpdateColor) (element, powerType)
	end

	if(shouldEnable and not isEnabled) then
		ClassPowerEnable(self)
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		ClassPowerDisable(self)
	elseif(shouldEnable and isEnabled) then
		Path(self, event, unit, powerType)
	end
end

local function VisibilityPath(self, ...)
	--[[ Override: ClassPower.OverrideVisibility(self, event, unit)
	Used to completely override the internal visibility function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.ClassPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

do
	function ClassPowerEnable(self)
		self.ClassPower.isEnabled = true

		if(UnitHasVehicleUI('player')) then
			Path(self, 'ClassPowerEnable', 'vehicle', 'COMBO_POINTS')
		else
			Path(self, 'ClassPowerEnable', 'player', ClassPowerType)
		end
	end

	function ClassPowerDisable(self)
		local element = self.ClassPower
		for i = 1, #element do
			element[i]:Hide()
		end

		self.ClassPower.isEnabled = false
		Path(self, 'ClassPowerDisable', 'player', ClassPowerType)
	end

	if(PlayerClass == 'ROGUE' or PlayerClass == 'DRUID') then
		ClassPowerType = 'COMBO_POINTS'
	end
end

local function Enable(self, unit)
	local element = self.ClassPower
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_COMBO_POINTS', Path)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path)

		element.ClassPowerEnable = ClassPowerEnable
		element.ClassPowerDisable = ClassPowerDisable

		for i = 1, #element do
			local bar = element[i]
			if(bar:IsObjectType('StatusBar')) then
				if(not bar:GetStatusBarTexture()) then
					bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end

				bar:SetMinMaxValues(0, 1)
			end
		end

		return true
	end
end

local function Disable(self)
	if(self.ClassPower) then
		ClassPowerDisable(self)

		self:UnregisterEvent('UNIT_COMBO_POINTS', Path)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
	end
end

oUF:AddElement('ClassPower', VisibilityPath, Enable, Disable)
