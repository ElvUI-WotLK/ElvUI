local _, ns = ...;
local oUF = ns.oUF or oUF;
assert(oUF, "oUF_HealComm4 was unable to locate oUF install");

local UnitGUID = UnitGUID
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax

local healComm = LibStub("LibHealComm-4.0");

local function Update(self, ...)
	if(self.db and not self.db.healPrediction) then return; end
	local unit = self.unit;
	local healCommBar = self.HealCommBar;
	healCommBar.parent = self;

	if(not unit or UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit)) then
		if(healCommBar.myBar) then
			healCommBar.myBar:Hide();
		end

		if(healCommBar.otherBar) then
			healCommBar.otherBar:Hide();
		end
		return;
	end

	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit);
	local guid = UnitGUID(unit);
	local timeFrame = self.HealCommTimeframe and GetTime() + self.HealCommTimeframe or nil;

	local myIncomingHeal = healComm:GetHealAmount(guid, healComm.ALL_HEALS, timeFrame, UnitGUID("player")) or 0;
	local allIncomingHeal = healComm:GetHealAmount(guid, healComm.ALL_HEALS, timeFrame) or 0;

	if(health + allIncomingHeal > maxHealth * healCommBar.maxOverflow) then
		allIncomingHeal = maxHealth * healCommBar.maxOverflow - health;
	end

	if(allIncomingHeal < myIncomingHeal) then
		myIncomingHeal = allIncomingHeal;
		allIncomingHeal = 0;
	else
		allIncomingHeal = allIncomingHeal - myIncomingHeal;
	end

	if(healCommBar.myBar) then
		healCommBar.myBar:SetMinMaxValues(0, maxHealth);
		healCommBar.myBar:SetValue(myIncomingHeal);
		healCommBar.myBar:Show();
	end

	if(healCommBar.otherBar) then
		healCommBar.otherBar:SetMinMaxValues(0, maxHealth);
		healCommBar.otherBar:SetValue(allIncomingHeal);
		healCommBar.otherBar:Show();
	end

	if(healCommBar.PostUpdate) then
		return healCommBar:PostUpdate(unit, myIncomingHeal, allIncomingHeal);
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
			if(frame.unit and frame.HealCommBar and UnitGUID(frame.unit) == select(i, ...)) then
				Path(frame);
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

		if(not healCommBar.maxOverflow) then
			healCommBar.maxOverflow = 1.05;
		end

		self:RegisterEvent("UNIT_HEALTH", Path);
		self:RegisterEvent("UNIT_MAXHEALTH", Path);

		return true;
	end
end

local function Disable(self)
	local healCommBar = self.HealCommBar;
	if(healCommBar) then
		self:UnregisterEvent("UNIT_HEALTH", Path);
		self:UnregisterEvent("UNIT_MAXHEALTH", Path);

		if(healCommBar.myBar) then
			healCommBar.myBar:Hide();
		end

		if(healCommBar.otherBar) then
			healCommBar.otherBar:Hide();
		end
	end
end

oUF:AddElement("HealComm4", Path, Enable, Disable);

healComm.RegisterCallback("HealComm4", "HealComm_HealStarted", HealComm_Heal_Update);
healComm.RegisterCallback("HealComm4", "HealComm_HealUpdated", HealComm_Heal_Update);
healComm.RegisterCallback("HealComm4", "HealComm_HealDelayed", HealComm_Heal_Update);
healComm.RegisterCallback("HealComm4", "HealComm_HealStopped", HealComm_Heal_Update);
healComm.RegisterCallback("HealComm4", "HealComm_ModifierChanged", HealComm_Modified);
healComm.RegisterCallback("HealComm4", "HealComm_GUIDDisappeared", HealComm_Modified);