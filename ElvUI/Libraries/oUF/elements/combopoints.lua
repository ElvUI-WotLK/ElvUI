--[[
# Element: ComboPoints

Handles the visibility and updating of the player's combo points.

## Widget

ComboPoints - An `table` consisting of as many Textures as the theoretical maximum return of [GetComboPoints](http://wowprogramming.com/docs/api/GetComboPoints).

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    local ComboPoints = {}
    for index = 1, 10 do
        local Bar = CreateFrame('StatusBar', nil, self)

        -- Position and size.
        Bar:SetSize(16, 16)
        Bar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', (index - 1) * Bar:GetWidth(), 0)

        ComboPoints[index] = Bar
    end

    -- Register with oUF
    self.ComboPoints = ComboPoints
--]]

local _, ns = ...
local oUF = ns.oUF

local GetComboPoints = GetComboPoints
local UnitHasVehicleUI = UnitHasVehicleUI

local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local function Update(self, event, unit)
	if(unit == 'pet') then return end

	local element = self.ComboPoints

	--[[ Callback: ComboPoints:PreUpdate()
	Called before the element has been updated.

	* self - the ComboPoints element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local cp
	if(UnitHasVehicleUI('player')) then
		cp = GetComboPoints('vehicle', 'target')
	else
		cp = GetComboPoints('player', 'target')
	end

	for i = 1, MAX_COMBO_POINTS do
		if(i <= cp) then
			element[i]:Show()
		else
			element[i]:Hide()
		end
	end

	--[[ Callback: ComboPoints:PostUpdate(role)
	Called after the element has been updated.

	* self   - the ComboPoints element
	* cpoint - the current amount of combo points (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(cp)
	end
end

local function Path(self, ...)
	--[[ Override: ComboPoints.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ComboPoints.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.ComboPoints
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_COMBO_POINTS', Path, true)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path, true)

		for index = 1, MAX_COMBO_POINTS do
			local cp = element[index]
			if(cp:IsObjectType('Texture') and not cp:GetTexture()) then
				cp:SetTexture([[Interface\ComboFrame\ComboPoint]])
				cp:SetTexCoord(0, 0.375, 0, 1)
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.ComboPoints
	if(element) then
		for index = 1, MAX_COMBO_POINTS do
			element[index]:Hide()
		end

		self:UnregisterEvent('UNIT_COMBO_POINTS', Path)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
	end
end

oUF:AddElement('ComboPoints', Path, Enable, Disable)