local parent, ns = ...
local oUF = ns.oUF

local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor

local Update = function(self, event, unit)
	if(not unit or self.unit ~= unit) then return end

	local threat = self.Threat
	if(threat.PreUpdate) then threat:PreUpdate(unit) end

	unit = unit or self.unit
	local status = UnitThreatSituation(unit)

	local r, g, b
	if(status and status > 0) then
		r, g, b = GetThreatStatusColor(status)

		if threat:IsObjectType("Texture") then
			threat:SetVertexColor(r, g, b)
		end

		threat:Show()
	else
		threat:Hide()
	end

	if(threat.PostUpdate) then
		return threat:PostUpdate(unit, status, r, g, b)
	end
end

local Path = function(self, ...)
	return (self.Threat.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	local threat = self.Threat
	if(threat) then
		threat.__owner = self
		threat.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)
		self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", Path)

		if(threat:IsObjectType("Texture") and not threat:GetTexture()) then
			threat:SetTexture([[Interface\Minimap\ObjectIcons]])
			threat:SetTexCoord(6/8, 7/8, 1/8, 2/8)
		end

		return true
	end
end

local Disable = function(self)
	local threat = self.Threat
	if(threat) then
		threat:Hide()
		self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)
		self:UnregisterEvent("UNIT_THREAT_LIST_UPDATE", Path)
	end
end

oUF:AddElement("Threat", Path, Enable, Disable)