--[[
# Element: Resurrect Indicator

Handles the visibility and updating of an indicator based on the unit's incoming resurrect status.

## Widget

ResurrectIndicator - A `Texture` used to display if the unit has an incoming resurrect.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local ResurrectIndicator = self:CreateTexture(nil, 'OVERLAY')
    ResurrectIndicator:SetSize(16, 16)
    ResurrectIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.ResurrectIndicator = ResurrectIndicator
--]]

local _, ns = ...
local oUF = ns.oUF
assert(oUF, "oUF_ResComm was unable to locate oUF install")

local LRC = LibStub("LibResComm-1.0")

local tremove = table.remove

local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitName = UnitName

local enabledUF, enabled = {}

local function Update(self, event, unit, succeeded)
	if not unit or self.unit ~= unit then return end

	local element = self.ResurrectIndicator

	--[[ Callback: ResurrectIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the ResurrectIndicator element
	--]]
	if element.PreUpdate then
		element:PreUpdate()
	end

	local incomingResurrect
	if UnitIsDead(unit) or UnitIsGhost(unit) then
		if event == "ResComm_ResStart" or event == "ResComm_CanRes" or event == "ResComm_Ressed" or (event == "ResComm_ResEnd" and succeeded) then
			if event ~= "ResComm_ResStart" then
				element.ressed = true
			end

			element:Show()
			incomingResurrect = true
		elseif (event == "ResComm_ResEnd" and not succeeded and not element.ressed) or event == "ResComm_ResExpired" then
			element:Hide()
			element.ressed = nil
		end
	else
		element:Hide()
	end

	--[[ Callback: ResurrectIndicator:PostUpdate(incomingResurrect)
	Called after the element has been updated.

	* self              - the ResurrectIndicator element
	* incomingResurrect - indicates if the unit has an incoming resurrection (boolean)
	--]]
	if element.PostUpdate then
		return element:PostUpdate(incomingResurrect)
	end
end

local function Path(self, ...)
	--[[ Override: ResurrectIndicator.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.ResurrectIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function ResComm_Update(event, ...)
	local sender, endTime, target, succeeded

	if event == "ResComm_ResStart" then
		sender, endTime, target = ...
	elseif event == "ResComm_ResEnd" then
		sender, target, succeeded = ...
	else
		target = ...
	end

	for i = 1, #enabledUF do
		local frame = enabledUF[i]

		if frame.unit and UnitName(frame.unit) == target then
			Path(frame, event, frame.unit, succeeded)
		end
	end
end

local function ToggleCallbacks(toggle)
	if toggle and not enabled and #enabledUF > 0 then
		LRC.RegisterCallback("oUF_ResComm", "ResComm_CanRes", ResComm_Update)
		LRC.RegisterCallback("oUF_ResComm", "ResComm_Ressed", ResComm_Update)
		LRC.RegisterCallback("oUF_ResComm", "ResComm_ResExpired", ResComm_Update)
		LRC.RegisterCallback("oUF_ResComm", "ResComm_ResStart", ResComm_Update)
		LRC.RegisterCallback("oUF_ResComm", "ResComm_ResEnd", ResComm_Update)

		enabled = true
	elseif not toggle and enabled and #enabledUF == 0 then
		LRC.UnregisterCallback("oUF_ResComm", "ResComm_CanRes")
		LRC.UnregisterCallback("oUF_ResComm", "ResComm_Ressed")
		LRC.UnregisterCallback("oUF_ResComm", "ResComm_ResExpired")
		LRC.UnregisterCallback("oUF_ResComm", "ResComm_ResStart")
		LRC.UnregisterCallback("oUF_ResComm", "ResComm_ResEnd")

		enabled = nil
	end
end

local function Enable(self)
	local element = self.ResurrectIndicator

	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_HEALTH", Path)

		if element:IsObjectType("Texture") and not element:GetTexture() then
			element:SetTexture([[Interface\Icons\Spell_Holy_Resurrection]])
		end

		enabledUF[#enabledUF + 1] = self
		ToggleCallbacks(true)

		return true
	end
end

local function Disable(self)
	local element = self.ResurrectIndicator

	if element then
		element:Hide()

		self:UnregisterEvent("UNIT_HEALTH", Path)

		for i = 1, #enabledUF do
			if enabledUF[i] == self then
				tremove(enabledUF, i)
				break
			end
		end

		ToggleCallbacks(false)
	end
end

oUF:AddElement("ResurrectIndicator", Path, Enable, Disable)