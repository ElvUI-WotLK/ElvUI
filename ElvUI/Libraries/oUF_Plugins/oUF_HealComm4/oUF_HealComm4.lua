--[[
# Element: Health Prediction Bars

Handles the visibility and updating of incoming heals and heal/damage absorbs.

## Widget

HealthPrediction - A `table` containing references to sub-widgets and options.

## Sub-Widgets

myBar          - A `StatusBar` used to represent incoming heals from the player.
otherBar       - A `StatusBar` used to represent incoming heals from others.

## Notes

A default texture will be applied to the StatusBar widgets if they don't have a texture set.
A default texture will be applied to the Texture widgets if they don't have a texture or a color set.

## Options

.maxOverflow     - The maximum amount of overflow past the end of the health bar. Set this to 1 to disable the overflow.
                   Defaults to 1.05 (number)

## Examples

    -- Position and size
    local myBar = CreateFrame('StatusBar', nil, self.Health)
    myBar:SetPoint('TOP')
    myBar:SetPoint('BOTTOM')
    myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    myBar:SetWidth(200)

    local otherBar = CreateFrame('StatusBar', nil, self.Health)
    otherBar:SetPoint('TOP')
    otherBar:SetPoint('BOTTOM')
    otherBar:SetPoint('LEFT', myBar:GetStatusBarTexture(), 'RIGHT')
    otherBar:SetWidth(200)

    -- Register with oUF
    self.HealthPrediction = {
        myBar = myBar,
        otherBar = otherBar,
        maxOverflow = 1.05
    }
--]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_HealComm4 was unable to locate oUF install")

local select = select
local tremove = table.remove

local GetTime = GetTime
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

local HealComm = LibStub("LibHealComm-4.0")

local enabledUF, enabled = {}

local function Update(self)
	local unit = self.unit
	local element = self.HealCommBar

	--[[ Callback: HealthPrediction:PreUpdate(unit)
	Called before the element has been updated.

	* self - the HealthPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if element.PreUpdate then
		element:PreUpdate(unit)
	end

	local guid = UnitGUID(unit)
	local timeFrame = self.HealCommTimeframe and GetTime() + self.HealCommTimeframe or nil
	local myIncomingHeal = HealComm:GetHealAmount(guid, HealComm.ALL_HEALS, timeFrame, UnitGUID("player")) or 0
	local allIncomingHeal = HealComm:GetHealAmount(guid, HealComm.ALL_HEALS, timeFrame) or 0
	local health = UnitHealth(unit)
	local maxHealth = UnitHealthMax(unit)
	local maxOverflowHP = maxHealth * element.maxOverflow
	local otherIncomingHeal = 0

	if health + allIncomingHeal > maxOverflowHP then
		allIncomingHeal = maxOverflowHP - health
	end

	if allIncomingHeal < myIncomingHeal then
		myIncomingHeal = allIncomingHeal
	else
		otherIncomingHeal = allIncomingHeal - myIncomingHeal
	end

	if element.myBar then
		element.myBar:SetMinMaxValues(0, maxHealth)
		element.myBar:SetValue(myIncomingHeal)
		element.myBar:Show()
	end

	if element.otherBar then
		element.otherBar:SetMinMaxValues(0, maxHealth)
		element.otherBar:SetValue(otherIncomingHeal)
		element.otherBar:Show()
	end

	--[[ Callback: HealthPrediction:PostUpdate(unit, myIncomingHeal, otherIncomingHeal)
	Called after the element has been updated.

	* self              - the HealthPrediction element
	* unit              - the unit for which the update has been triggered (string)
	* myIncomingHeal    - the amount of incoming healing done by the player (number)
	* otherIncomingHeal - the amount of incoming healing done by others (number)
	--]]
	if element.PostUpdate then
		return element:PostUpdate(unit, myIncomingHeal, otherIncomingHeal)
	end
end

local function Path(self, ...)
	--[[ Override: HealthPrediction.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event
	--]]
	return (self.HealCommBar.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function MultiUpdate(...)
	for i = 1, select("#", ...) do
		for j = 1, #enabledUF do
			local frame = enabledUF[j]

			if frame.unit and frame:IsVisible() and UnitGUID(frame.unit) == select(i, ...) then
				Path(frame)
			end
		end
	end
end

local function HealComm_Heal_Update(event, casterGUID, spellID, healType, _, ...)
	MultiUpdate(...)
end

local function HealComm_Modified(event, guid)
	MultiUpdate(guid)
end

local function ToggleCallbacks(toggle)
	if toggle and not enabled and #enabledUF > 0 then
		HealComm.RegisterCallback("oUF_HealComm", "HealComm_HealStarted", HealComm_Heal_Update)
		HealComm.RegisterCallback("oUF_HealComm", "HealComm_HealUpdated", HealComm_Heal_Update)
		HealComm.RegisterCallback("oUF_HealComm", "HealComm_HealDelayed", HealComm_Heal_Update)
		HealComm.RegisterCallback("oUF_HealComm", "HealComm_HealStopped", HealComm_Heal_Update)
		HealComm.RegisterCallback("oUF_HealComm", "HealComm_ModifierChanged", HealComm_Modified)
		HealComm.RegisterCallback("oUF_HealComm", "HealComm_GUIDDisappeared", HealComm_Modified)

		enabled = true
	elseif not toggle and enabled and #enabledUF == 0 then
		HealComm.UnregisterCallback("oUF_HealComm", "HealComm_HealStarted")
		HealComm.UnregisterCallback("oUF_HealComm", "HealComm_HealUpdated")
		HealComm.UnregisterCallback("oUF_HealComm", "HealComm_HealDelayed")
		HealComm.UnregisterCallback("oUF_HealComm", "HealComm_HealStopped")
		HealComm.UnregisterCallback("oUF_HealComm", "HealComm_ModifierChanged")
		HealComm.UnregisterCallback("oUF_HealComm", "HealComm_GUIDDisappeared")

		enabled = nil
	end
end

local function Enable(self)
	local element = self.HealCommBar

	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_HEALTH", Path)
		self:RegisterEvent("UNIT_MAXHEALTH", Path)

		if not element.maxOverflow then
			element.maxOverflow = 1.05
		end

		if element.myBar and element.myBar:IsObjectType("StatusBar") and not element.myBar:GetStatusBarTexture() then
			element.myBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if element.otherBar and element.otherBar:IsObjectType("StatusBar") and not element.otherBar:GetStatusBarTexture() then
			element.otherBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		enabledUF[#enabledUF + 1] = self
		ToggleCallbacks(true)

		return true
	end
end

local function Disable(self)
	local element = self.HealCommBar

	if element then
		if element.myBar then
			element.myBar:Hide()
		end

		if element.otherBar then
			element.otherBar:Hide()
		end

		self:UnregisterEvent("UNIT_HEALTH", Path)
		self:UnregisterEvent("UNIT_MAXHEALTH", Path)

		for i = 1, #enabledUF do
			if enabledUF[i] == self then
				tremove(enabledUF, i)
				break
			end
		end

		ToggleCallbacks(false)
	end
end

oUF:AddElement("HealComm4", Path, Enable, Disable)