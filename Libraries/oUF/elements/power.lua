local parent, ns = ...
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

oUF.colors.power = {}
for power, color in next, PowerBarColor do
	if (type(power) == "string") then
		if(type(select(2, next(color))) == "table") then
			oUF.colors.power[power] = {}

			for index, color in next, color do
				oUF.colors.power[power][index] = {color.r, color.g, color.b}
			end
		else
			oUF.colors.power[power] = {color.r, color.g, color.b}
		end
	end
end

-- sourced from FrameXML/Constants.lua
oUF.colors.power[0] = oUF.colors.power.MANA
oUF.colors.power[1] = oUF.colors.power.RAGE
oUF.colors.power[2] = oUF.colors.power.FOCUS
oUF.colors.power[3] = oUF.colors.power.ENERGY
oUF.colors.power[4] = oUF.colors.power.HAPPINESS
oUF.colors.power[5] = oUF.colors.power.RUNES
oUF.colors.power[6] = oUF.colors.power.RUNIC_POWER

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end
	local power = self.Power

	if(power.PreUpdate) then power:PreUpdate(unit) end

	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	local disconnected = not UnitIsConnected(unit)
	local tapped = not UnitPlayerControlled(unit) and (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit))
	power:SetMinMaxValues(0, max)

	if(disconnected) then
		power:SetValue(max)
	else
		power:SetValue(cur)
	end

	power.disconnected = disconnected
	power.tapped = tapped

	local r, g, b, t

	if(power.colorTapping and not UnitPlayerControlled(unit) and (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit))) then
		t = self.colors.tapped
	elseif(power.colorDisconnected and disconnected) then
		t = self.colors.disconnected
	elseif(power.colorHappiness and UnitIsUnit(unit, "pet") and GetPetHappiness()) then
		t = self.colors.happiness[GetPetHappiness()]
	elseif(power.colorPower) then
		local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)

		t = self.colors.power[ptoken]
		if(not t and altR) then
			r, g, b = altR, altG, altB
		end
	elseif(power.colorClass and UnitIsPlayer(unit)) or
		(power.colorClassNPC and not UnitIsPlayer(unit)) or
		(power.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(power.colorReaction and UnitReaction(unit, "player")) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif(power.colorSmooth) then
		r, g, b = self.ColorGradient(cur, max, unpack(power.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		power:SetStatusBarColor(r, g, b)

		local bg = power.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(power.PostUpdate) then
		return power:PostUpdate(unit, cur, max)
	end
end

local Path = function(self, ...)
	return (self.Power.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local OnPowerUpdate = function(self)
	if(self.disconnected) then return end
	local unit = self.__owner.unit
	local power = UnitPower(unit)

	if(power ~= self.min) then
		self.min = power

		return Path(self.__owner, "OnPowerUpdate", unit)
	end
end

local Enable = function(self, unit)
	local power = self.Power
	if(power) then
		power.__owner = self
		power.ForceUpdate = ForceUpdate

		if(power.frequentUpdates and (unit == "player" or unit == "pet")) then
			power:SetScript("OnUpdate", OnPowerUpdate)
		else
			self:RegisterEvent("UNIT_MANA", Path)
			self:RegisterEvent("UNIT_RAGE", Path)
			self:RegisterEvent("UNIT_FOCUS", Path)
			self:RegisterEvent("UNIT_ENERGY", Path)
			self:RegisterEvent("UNIT_RUNIC_POWER", Path)
		end

		self:RegisterEvent("UNIT_MAXMANA", Path)
		self:RegisterEvent("UNIT_MAXRAGE", Path)
		self:RegisterEvent("UNIT_MAXFOCUS", Path)
		self:RegisterEvent("UNIT_MAXENERGY", Path)
		self:RegisterEvent("UNIT_MAXRUNIC_POWER", Path)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Path)

		self:RegisterEvent("UNIT_CONNECTION", Path)
		self:RegisterEvent("UNIT_HAPPINESS", Path)

		-- For tapping.
		self:RegisterEvent("UNIT_FACTION", Path)

		if(power:IsObjectType("StatusBar")) then
			power.texture = power:GetStatusBarTexture() and power:GetStatusBarTexture():GetTexture() or [[Interface\TargetingFrame\UI-StatusBar]]
			power:SetStatusBarTexture(power.texture)
		end

		return true
	end
end

local Disable = function(self)
	local power = self.Power
	if(power) then
		if(power:GetScript("OnUpdate")) then
			power:SetScript("OnUpdate", nil)
		else
			self:UnregisterEvent("UNIT_MANA", Path)
			self:UnregisterEvent("UNIT_RAGE", Path)
			self:UnregisterEvent("UNIT_FOCUS", Path)
			self:UnregisterEvent("UNIT_ENERGY", Path)
			self:UnregisterEvent("UNIT_RUNIC_POWER", Path)
		end

		self:UnregisterEvent("UNIT_MAXMANA", Path)
		self:UnregisterEvent("UNIT_MAXRAGE", Path)
		self:UnregisterEvent("UNIT_MAXFOCUS", Path)
		self:UnregisterEvent("UNIT_MAXENERGY", Path)
		self:UnregisterEvent("UNIT_MAXRUNIC_POWER", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)

		self:UnregisterEvent("UNIT_CONNECTION", Path)
		self:UnregisterEvent("UNIT_HAPPINESS", Path)
		self:UnregisterEvent("UNIT_FACTION", Path)
	end
end

oUF:AddElement("Power", Path, Enable, Disable)