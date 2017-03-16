local parent, ns = ...
local oUF = ns.oUF

local unpack = unpack

local GetPetHappiness = GetPetHappiness
local UnitClass = UnitClass
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByAllThreatList = UnitIsTappedByAllThreatList
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsUnit = UnitIsUnit
local UnitPlayerControlled = UnitPlayerControlled
local UnitReaction = UnitReaction

oUF.colors.health = {49/255, 207/255, 37/255}

local Update = function(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	local health = self.Health

	if(health.PreUpdate) then health:PreUpdate(unit) end

	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local disconnected = not UnitIsConnected(unit)
	health:SetMinMaxValues(0, max)

	if(disconnected) then
		health:SetValue(max)
	else
		health:SetValue(min)
	end

	health.disconnected = disconnected

	local r, g, b, t
	if(health.colorTapping and not UnitPlayerControlled(unit) and (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit))) then
		t = self.colors.tapped
	elseif(health.colorDisconnected and not UnitIsConnected(unit)) then
		t = self.colors.disconnected
	elseif(health.colorHappiness and UnitIsUnit(unit, "pet") and GetPetHappiness()) then
		t = self.colors.happiness[GetPetHappiness()]
	elseif(health.colorClass and UnitIsPlayer(unit)) or
		(health.colorClassNPC and not UnitIsPlayer(unit)) or
		(health.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(health.colorReaction and UnitReaction(unit, "player")) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif(health.colorSmooth) then
		r, g, b = self.ColorGradient(min, max, unpack(health.smoothGradient or self.colors.smooth))
	elseif(health.colorHealth) then
		t = self.colors.health
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		health:SetStatusBarColor(r, g, b)

		local bg = health.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(health.PostUpdate) then
		return health:PostUpdate(unit, min, max)
	end
end

local Path = function(self, ...)
	return (self.Health.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local OnHealthUpdate = function(self)
	if(self.disconnected) then return end
	local unit = self.__owner.unit
	local health = UnitHealth(unit)

	if(health ~= self.min) then
		self.min = health

		return Path(self.__owner, "OnHealthUpdate", unit)
	end
end

local Enable = function(self, unit)
	local health = self.Health
	if(health) then
		health.__owner = self
		health.ForceUpdate = ForceUpdate

		if(health.frequentUpdates and (unit and not unit:match"%w+target$")) then
			health:SetScript("OnUpdate", OnHealthUpdate)

			-- The party frames need this to handle disconnect states correctly.
			if(unit == "party") then
				self:RegisterEvent("UNIT_HEALTH", Path)
			end
		else
			self:RegisterEvent("UNIT_HEALTH", Path)
		end

		self:RegisterEvent("UNIT_MAXHEALTH", Path)
		self:RegisterEvent("UNIT_CONNECTION", Path)
		self:RegisterEvent("UNIT_HAPPINESS", Path)

		-- For tapping.
		self:RegisterEvent("UNIT_FACTION", Path)

		if(health:IsObjectType("StatusBar") and not health:GetStatusBarTexture()) then
			health:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local health = self.Health
	if(health) then
		if(health:GetScript("OnUpdate")) then
			health:SetScript("OnUpdate", nil)
		end

		health:Hide()
		self:UnregisterEvent("UNIT_HEALTH", Path)
		self:UnregisterEvent("UNIT_MAXHEALTH", Path)
		self:UnregisterEvent("UNIT_CONNECTION", Path)
		self:UnregisterEvent("UNIT_HAPPINESS", Path)

		self:UnregisterEvent("UNIT_FACTION", Path)
	end
end

oUF:AddElement("Health", Path, Enable, Disable)