local _, ns = ...;
local oUF = ns.oUF or oUF;
assert(oUF, "oUF_HealComm4 was unable to locate oUF install");

local healcomm = LibStub("LibHealComm-4.0");
local format = string.format;
local min = math.min;

local function Hide(self)
	if(self.HealCommBar) then self.HealCommBar:Hide(); end
end

local function Update(self, event, unit)
	if(not self.unit or UnitIsDeadOrGhost(self.unit) or not UnitIsConnected(self.unit)) then return Hide(self); end
	
	local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit);
	if(maxHealth == 0 or maxHealth == 100) then return Hide(self); end

	local guid = UnitGUID(self.unit);
	local timeFrame = self.HealCommTimeframe and GetTime() + self.HealCommTimeframe or nil;
	local incHeals = self.HealCommOthersOnly and healcomm:GetOthersHealAmount(guid, healcomm.ALL_HEALS, timeFrame) or not self.HealCommOthersOnly and healcomm:GetHealAmount(guid, healcomm.ALL_HEALS, timeFrame) or 0;
	if(incHeals == 0) then return Hide(self); end
	
	incHeals = incHeals * healcomm:GetHealModifier(guid);
	
	local healCommBar = self.HealCommBar;
	if(healCommBar) then
		local curHealth = UnitHealth(self.unit);
		local inc = self.allowHealCommOverflow and incHeals or min(incHeals, maxHealth - health);
		if(inc == 0) then return healCommBar:Hide(); end
		
		local orientation = self.Health:GetOrientation();
		healCommBar:ClearAllPoints();
		if(orientation == "HORIZONTAL") then
			healCommBar:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT");
			healCommBar:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT");
		else
			healCommBar:SetPoint("BOTTOMRIGHT", self.Health:GetStatusBarTexture(), "TOPRIGHT");
			healCommBar:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "TOPLEFT");
		end
		
		local totalWidth, totalHeight = self.Health:GetSize();
		if(orientation == "HORIZONTAL") then
			healCommBar:SetWidth(totalWidth);
		else
			healCommBar:SetHeight(totalHeight);
		end
		
		healCommBar:SetMinMaxValues(0, maxHealth);
		healCommBar:SetValue(inc);
		healCommBar:Show();
		
		if(healCommBar.PostUpdate) then
			return healCommBar:PostUpdate(inc);
		end
	end
end

local function Path(self, ...)
	return (self.HealCommBar.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function MultiUpdate(...)
	for i = 1, select("#", ...) do
		for _, frame in ipairs(oUF.objects) do
			if frame.unit and (frame.HealCommBar and frame:IsElementEnabled("HealComm4")) and UnitGUID(frame.unit) == select(i, ...) and frame:IsVisible() then
				Update(frame)
			end
		end
	end
end

local function HealComm_Heal_Update(event, casterGUID, spellID, healType, _, ...)
	MultiUpdate(...);
end

local function HealComm_Modified(event, guid)
	MultiUpdate(guid);
end

local function Enable(self)
	local healCommBar = self.HealCommBar;
	if(healCommBar) then
		healCommBar.__owner = self;
		healCommBar.ForceUpdate = ForceUpdate;
		
		self:RegisterEvent("UNIT_HEALTH", Path);
		self:RegisterEvent("UNIT_MAXHEALTH", Path);
		
		if(not healCommBar:GetStatusBarTexture()) then healCommBar:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=]); end
		
		return true;
	end
end

local function Disable(self)
	local healCommBar = self.HealCommBar;
	if(healCommBar) then
		self:UnregisterEvent("UNIT_HEALTH", Path);
		self:UnregisterEvent("UNIT_MAXHEALTH", Path);
		
		healCommBar:Hide();
	end
end

oUF:AddElement("HealComm4", Path, Enable, Disable);

healcomm.RegisterCallback("HealComm4", "HealComm_HealStarted", HealComm_Heal_Update);
healcomm.RegisterCallback("HealComm4", "HealComm_HealUpdated", HealComm_Heal_Update);
healcomm.RegisterCallback("HealComm4", "HealComm_HealDelayed", HealComm_Heal_Update);
healcomm.RegisterCallback("HealComm4", "HealComm_HealStopped", HealComm_Heal_Update);
healcomm.RegisterCallback("HealComm4", "HealComm_ModifierChanged", HealComm_Modified);
healcomm.RegisterCallback("HealComm4", "HealComm_GUIDDisappeared", HealComm_Modified);