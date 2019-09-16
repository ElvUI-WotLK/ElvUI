--[[
# Element: Power Bar

Handles the updating of a status bar that displays the unit's power.

## Widget

Power - A `StatusBar` used to represent the unit's power.

## Sub-Widgets

.bg - A `Texture` used as a background. It will inherit the color of the main StatusBar.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture or a color set.

## Options

.frequentUpdates - Indicates whether to use OnUpdate script instead of UNIT_POWER to update the bar. Only valid for the
                   player and pet units (boolean)
.smoothGradient  - 9 color values to be used with the .colorSmooth option (table)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorTapping      - Use `self.colors.tapping` to color the bar if the unit isn't tapped by the player (boolean)
.colorDisconnected - Use `self.colors.disconnected` to color the bar if the unit is offline (boolean)
.colorHappiness    - Use `self.colors.happiness` to color the bar if the unit is pet based on pet happiness (boolean)
.colorPower        - Use `self.colors.power[token]` to color the bar based on the unit's power type. This method will
                     fall-back to `:GetAlternativeColor()` if it can't find a color matching the token. If this function
                     isn't defined, then it will attempt to color based upon the alternative power colors returned by
                     [UnitPowerType](http://wowprogramming.com/docs/api/UnitPowerType). Finally, if these aren't
                     defined, then it will attempt to color the bar based upon `self.colors.power[type]` (boolean)
.colorClass        - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                     second return of [UnitClass](http://wowprogramming.com/docs/api/UnitClass) (boolean)
.colorClassNPC     - Use `self.colors.class[class]` to color the bar if the unit is a NPC (boolean)
.colorClassPet     - Use `self.colors.class[class]` to color the bar if the unit is player controlled, but not a player
                     (boolean)
.colorReaction     - Use `self.colors.reaction[reaction]` to color the bar based on the player's reaction towards the
                     unit. `reaction` is defined by the return value of
                     [UnitReaction](http://wowprogramming.com/docs/api/UnitReaction) (boolean)
.colorSmooth       - Use `smoothGradient` if present or `self.colors.smooth` to color the bar with a smooth gradient
                     based on the player's current power percentage (boolean)

## Sub-Widget Options

.multiplier - A multiplier used to tint the background based on the main widgets R, G and B values. Defaults to 1
              (number)[0-1]

## Attributes

.disconnected - Indicates whether the unit is disconnected (boolean)
.tapped       - Indicates whether the unit is tapped by the player (boolean)

## Examples

    -- Position and size
    local Power = CreateFrame('StatusBar', nil, self)
    Power:SetHeight(20)
    Power:SetPoint('BOTTOM')
    Power:SetPoint('LEFT')
    Power:SetPoint('RIGHT')

    -- Add a background
    local Background = Power:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Power)
    Background:SetTexture(1, 1, 1, .5)

    -- Options
    Power.frequentUpdates = true
    Power.colorTapping = true
    Power.colorDisconnected = true
    Power.colorPower = true
    Power.colorClass = true
    Power.colorReaction = true

    -- Make the background darker.
    Background.multiplier = .5

    -- Register it with oUF
	Power.bg = Background
    self.Power = Power
--]]

local _, ns = ...
local oUF = ns.oUF

local unpack = unpack

local GetPetHappiness = GetPetHappiness
local UnitClass = UnitClass
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsUnit = UnitIsUnit
local UnitPlayerControlled = UnitPlayerControlled
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction

local function UpdateColor(self, event, unit)
	if(self.unit ~= unit) then return end
	local element = self.Power

	local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)
	local r, g, b, t
	if(element.colorDisconnected and element.disconnected) then
		t = self.colors.disconnected
	elseif(element.colorTapping and not UnitPlayerControlled(unit) and (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit))) then
		t = self.colors.tapped
	elseif(element.colorThreat and not UnitPlayerControlled(unit) and UnitThreatSituation('player', unit)) then
		t =  self.colors.threat[UnitThreatSituation('player', unit)]
	elseif(element.colorHappiness and UnitIsUnit(unit, 'pet') and GetPetHappiness()) then
		t = self.colors.happiness[GetPetHappiness()]
	elseif(element.colorPower) then
		t = self.colors.power[ptoken or ptype]
		if(not t) then
			if(element.GetAlternativeColor) then
				r, g, b = element:GetAlternativeColor(unit, ptype, ptoken, altR, altG, altB)
			elseif(altR) then
				r, g, b = altR, altG, altB
			end
		end
	elseif(element.colorClass and UnitIsPlayer(unit)) or
		(element.colorClassNPC and not UnitIsPlayer(unit)) or
		(element.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, 'player')]
	elseif(element.colorSmooth) then
		r, g, b = self:ColorGradient(element.cur or 1, element.max or 1, unpack(element.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	element:SetStatusBarTexture(element.texture)

	if(b) then
		element:SetStatusBarColor(r, g, b)
	end

	local bg = element.bg
	if(bg and b) then
		local mu = bg.multiplier or 1
		bg:SetVertexColor(r * mu, g * mu, b * mu)
	end

	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, r, g, b)
	end
end

local function ColorPath(self, ...)
	--[[ Override: Power.UpdateColor(self, event, unit)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.Power.UpdateColor or UpdateColor) (self, ...)
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end
	local element = self.Power

	--[[ Callback: Power:PreUpdate(unit)
	Called before the element has been updated.

	* self - the Power element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	local disconnected = not UnitIsConnected(unit)
	if max == 0 then
		max = 1
	end

	element:SetMinMaxValues(0, max)

	if(disconnected) then
		element:SetValue(max)
	else
		element:SetValue(cur)
	end

	element.cur = cur
	element.max = max
	element.disconnected = disconnected

	--[[ Callback: Power:PostUpdate(unit, cur, max)
	Called after the element has been updated.

	* self - the Power element
	* unit - the unit for which the update has been triggered (string)
	* cur  - the unit's current power value (number)
	* max  - the unit's maximum possible power value (number)
	--]]
	if(element.PostUpdate) then
		element:PostUpdate(unit, cur, max)
	end
end

local function Path(self, ...)
	--[[ Override: Power.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.Power.Override or Update) (self, ...);

	ColorPath(self, ...)
end

local function ForceUpdate(element)
	Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

--[[ Power:SetColorDisconnected(state)
Used to toggle coloring if the unit is offline.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetColorDisconnected(element, state)
	if(element.colorDisconnected ~= state) then
		element.colorDisconnected = state
		if(element.colorDisconnected) then
			element.__owner:RegisterEvent('UNIT_CONNECTION', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_CONNECTION', ColorPath)
		end
	end
end

--[[ Power:SetColorTapping(state)
Used to toggle coloring if the unit isn't tapped by the player.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetColorTapping(element, state)
	if(element.colorTapping ~= state) then
		element.colorTapping = state
		if(element.colorTapping) then
			element.__owner:RegisterEvent('UNIT_FACTION', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_FACTION', ColorPath)
		end
	end
end

--[[ Power:SetColorThreat(state)
Used to toggle coloring by the unit's threat status.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetColorThreat(element, state)
	if(element.colorThreat ~= state) then
		element.colorThreat = state
		if(element.colorThreat) then
			element.__owner:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		end
	end
end

--[[ Power:SetColorHappiness(state)
Used to toggle coloring by the unit's happiness status.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetColorHappiness(element, state)
	if(element.colorHappiness ~= state) then
		element.colorHappiness = state
		if(element.colorHappiness) then
			element.__owner:RegisterEvent('UNIT_HAPPINESS', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_HAPPINESS', ColorPath)
		end
	end
end


local function onPowerUpdate(self)
	if(self.disconnected) then return end

	local unit = self.__owner.unit
	local power = UnitPower(unit)

	if(power ~= self.power) then
		self.power = power

		return Path(self.__owner, 'OnPowerUpdate', unit)
	end
end

--[[ Power:SetFrequentUpdates(state)
Used to toggle frequent updates.

* self  - the Power element
* state - the desired state (boolean)
--]]
local function SetFrequentUpdates(element, state)
	--if(not unit or (unit ~= 'player' and unit ~= 'pet')) then return end

	if(element.frequentUpdates ~= state) then
		element.frequentUpdates = state
		if(element.frequentUpdates and not element:GetScript('OnUpdate')) then
			element:SetScript('OnUpdate', onPowerUpdate)

			element.__owner:UnregisterEvent('UNIT_MANA', Path)
			element.__owner:UnregisterEvent('UNIT_RAGE', Path)
			element.__owner:UnregisterEvent('UNIT_FOCUS', Path)
			element.__owner:UnregisterEvent('UNIT_ENERGY', Path)
			element.__owner:UnregisterEvent('UNIT_RUNIC_POWER', Path)
		elseif(not element.frequentUpdates and element:GetScript('OnUpdate')) then
			element:SetScript('OnUpdate', nil)

			element.__owner:RegisterEvent('UNIT_MANA', Path)
			element.__owner:RegisterEvent('UNIT_RAGE', Path)
			element.__owner:RegisterEvent('UNIT_FOCUS', Path)
			element.__owner:RegisterEvent('UNIT_ENERGY', Path)
			element.__owner:RegisterEvent('UNIT_RUNIC_POWER', Path)
		end
	end
end

local function Enable(self, unit)
	local element = self.Power
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.SetColorDisconnected = SetColorDisconnected
		element.SetColorTapping = SetColorTapping
		element.SetColorThreat = SetColorThreat
		element.SetColorHappiness = SetColorHappiness
		element.SetFrequentUpdates = SetFrequentUpdates

		if(element.colorDisconnected) then
			self:RegisterEvent('UNIT_CONNECTION', ColorPath)
		end

		if(element.colorTapping) then
			self:RegisterEvent('UNIT_FACTION', ColorPath)
		end

		if(element.colorThreat) then
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		end

		if(element.colorHappiness) then
			self:RegisterEvent('UNIT_HAPPINESS', ColorPath)
		end

		if(element.frequentUpdates and (unit == 'player' or unit == 'pet')) then
			element:SetScript('OnUpdate', onPowerUpdate)
		else
			self:RegisterEvent('UNIT_MANA', Path)
			self:RegisterEvent('UNIT_RAGE', Path)
			self:RegisterEvent('UNIT_FOCUS', Path)
			self:RegisterEvent('UNIT_ENERGY', Path)
			self:RegisterEvent('UNIT_RUNIC_POWER', Path)
		end

		self:RegisterEvent('UNIT_MAXMANA', Path)
		self:RegisterEvent('UNIT_MAXRAGE', Path)
		self:RegisterEvent('UNIT_MAXFOCUS', Path)
		self:RegisterEvent('UNIT_MAXENERGY', Path)
		self:RegisterEvent('UNIT_MAXRUNIC_POWER', Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)

		if(element:IsObjectType('StatusBar')) then
			element.texture = element:GetStatusBarTexture() and element:GetStatusBarTexture():GetTexture() or [[Interface\TargetingFrame\UI-StatusBar]]
			element:SetStatusBarTexture(element.texture)
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Power
	if(element) then
		element:Hide()

		if(element:GetScript('OnUpdate')) then
			element:SetScript('OnUpdate', nil)
		else
			self:UnregisterEvent('UNIT_MANA', Path)
			self:UnregisterEvent('UNIT_RAGE', Path)
			self:UnregisterEvent('UNIT_FOCUS', Path)
			self:UnregisterEvent('UNIT_ENERGY', Path)
			self:UnregisterEvent('UNIT_RUNIC_POWER', Path)
		end

		self:UnregisterEvent('UNIT_MAXMANA', Path)
		self:UnregisterEvent('UNIT_MAXRAGE', Path)
		self:UnregisterEvent('UNIT_MAXFOCUS', Path)
		self:UnregisterEvent('UNIT_MAXENERGY', Path)
		self:UnregisterEvent('UNIT_MAXRUNIC_POWER', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)

		self:UnregisterEvent('UNIT_CONNECTION', ColorPath)
		self:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		self:UnregisterEvent('UNIT_FACTION', ColorPath)
		self:UnregisterEvent('UNIT_HAPPINESS', ColorPath)
	end
end

oUF:AddElement('Power', Path, Enable, Disable)