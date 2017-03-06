local parent, ns = ...
local oUF = ns.oUF

local GetReadyCheckStatus = GetReadyCheckStatus
local UnitExists = UnitExists

local function OnFinished(self)
	local element = self:GetParent()
	element:Hide()

	if(element.PostUpdateFadeOut) then
		element:PostUpdateFadeOut()
	end
end

local Update = function(self, event)
	local element = self.ReadyCheck

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local unit = self.unit
	local status = GetReadyCheckStatus(unit)
	if(UnitExists(unit) and status) then
		if(status == "ready") then
			element:SetTexture(element.readyTexture or READY_CHECK_READY_TEXTURE)
		elseif(status == "notready") then
			element:SetTexture(element.notReadyTexture or READY_CHECK_NOT_READY_TEXTURE)
		else
			element:SetTexture(element.waitingTexture or READY_CHECK_WAITING_TEXTURE)
		end

		element.status = status
		element:Show()
	elseif(event ~= "READY_CHECK_FINISHED") then
		element.status = nil
		element:Hide()
	end

	if(event == "READY_CHECK_FINISHED") then
		if(element.status == "waiting") then
			element:SetTexture(element.notReadyTexture or READY_CHECK_NOT_READY_TEXTURE)
		end

		element.Animation:Play()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(status)
	end
end

local Path = function(self, ...)
	return (self.ReadyCheck.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate")
end

local Enable = function(self, unit)
	local element = self.ReadyCheck
	if(element and (unit and (unit:sub(1, 5) == "party" or unit:sub(1, 4) == "raid"))) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		local AnimationGroup = element:CreateAnimationGroup()
		AnimationGroup:HookScript("OnFinished", OnFinished)
		element.Animation = AnimationGroup

		local Animation = AnimationGroup:CreateAnimation("Alpha")
		Animation:SetChange(-1)
		Animation:SetDuration(element.fadeTime or 1.5)
		Animation:SetStartDelay(element.finishedTime or 10)

		self:RegisterEvent("READY_CHECK", Path, true)
		self:RegisterEvent("READY_CHECK_CONFIRM", Path, true)
		self:RegisterEvent("READY_CHECK_FINISHED", Path, true)

		return true
	end
end

local Disable = function(self)
	local element = self.ReadyCheck
	if(element) then
		element:Hide()

		self:UnregisterEvent("READY_CHECK", Path)
		self:UnregisterEvent("READY_CHECK_CONFIRM", Path)
		self:UnregisterEvent("READY_CHECK_FINISHED", Path)
	end
end

oUF:AddElement("ReadyCheck", Path, Enable, Disable)