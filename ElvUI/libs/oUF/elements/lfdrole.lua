local parent, ns = ...;
local oUF = ns.oUF;

local Update = function(self, event)
	local lfdrole = self.LFDRole;
	if(lfdrole.PreUpdate) then
		lfdrole:PreUpdate();
	end
	
	local isTank, isHealer, isDamage = UnitGroupRolesAssigned(self.unit);
	if(isTank) then
		lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\tank.tga]]);
		lfdrole:Show();
	elseif(isHealer) then
		lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer.tga]]);
		lfdrole:Show();
	elseif(isDamage) then
		lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\dps.tga]]);
		lfdrole:Show();
	else
		lfdrole:Hide();
	end
	
	if(lfdrole.PostUpdate) then
		return lfdrole:PostUpdate(isTank, isHealer, isDamage);
	end
end

local Path = function(self, ...)
	return (self.LFDRole.Override or Update) (self, ...);
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate");
end

local Enable = function(self)
	local lfdrole = self.LFDRole;
	if(lfdrole) then
		lfdrole.__owner = self;
		lfdrole.ForceUpdate = ForceUpdate;
		
		if(self.unit == "player") then
			self:RegisterEvent("PLAYER_ROLES_ASSIGNED", Path, true);
		else
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", Path, true);
		end
		
		if(lfdrole:IsObjectType"Texture" and not lfdrole:GetTexture()) then
			lfdrole:SetTexture[[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]];
		end
		
		return true;
	end
end

local Disable = function(self)
	local lfdrole = self.LFDRole;
	if(lfdrole) then
		self:UnregisterEvent("PLAYER_ROLES_ASSIGNED", Path);
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED", Path);
	end
end

oUF:AddElement("LFDRole", Path, Enable, Disable);