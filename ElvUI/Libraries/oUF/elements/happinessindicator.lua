--[[
# Element: HappinessIndicator

Handles the visibility and updating of player pet happiness.

## Widget

HappinessIndicator - A `Texture` used to display the current happiness level.
The element works by changing the texture's vertex color.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local HappinessIndicator = self:CreateTexture(nil, 'OVERLAY')
    HappinessIndicator:SetSize(16, 16)
    HappinessIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.HappinessIndicator = HappinessIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local GetPetHappiness = GetPetHappiness
local HasPetUI = HasPetUI

local function Update(self, event, unit)
	if(not unit or self.unit ~= unit) then return end

	local element = self.HappinessIndicator

	--[[ Callback: HappinessIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the ComboPoints element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local _, hunterPet = HasPetUI()
	local happiness, damagePercentage = GetPetHappiness()

	if(hunterPet and happiness) then
		if(happiness == 1) then
			element:SetTexCoord(0.375, 0.5625, 0, 0.359375)
		elseif(happiness == 2) then
			element:SetTexCoord(0.1875, 0.375, 0, 0.359375)
		elseif(happiness == 3) then
			element:SetTexCoord(0, 0.1875, 0, 0.359375)
		end

		element:Show()
	else
		return element:Hide()
	end

	--[[ Callback: HappinessIndicator:PostUpdate(role)
	Called after the element has been updated.

	* self      - the ComboPoints element
	* unit      - the unit for which the update has been triggered (string)
	* happiness        - the numerical happiness value of the pet (1 = unhappy, 2 = content, 3 = happy) (number)
	* damagePercentage - damage modifier, happiness affects this (unhappy = 75%, content = 100%, happy = 125%) (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, happiness, damagePercentage)
	end
end

local function Path(self, ...)
	--[[ Override: HappinessIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.HappinessIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.HappinessIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_HAPPINESS', Path)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\PetPaperDollFrame\UI-PetHappiness]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.HappinessIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_HAPPINESS', Path)
	end
end

oUF:AddElement('HappinessIndicator', Path, Enable, Disable)