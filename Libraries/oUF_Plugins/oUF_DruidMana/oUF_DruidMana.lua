if(select(2, UnitClass("player")) ~= "DRUID") then return; end

local _, ns = ...;
local oUF = ns.oUF or oUF;

local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitIsPlayer = UnitIsPlayer
local UnitPlayerControlled = UnitPlayerControlled
local UnitClass = UnitClass
local UnitReaction = UnitReaction

local UPDATE_VISIBILITY = function(self, event)
	local druidmana = self.DruidAltMana;

	local min, max = druidmana.ManaBar:GetMinMaxValues();
	local num, str = UnitPowerType("player");
	if(num ~= 0) then
		if(druidmana.ManaBar:GetValue() == max) then
			druidmana:Hide();
		else
			druidmana:Show();
		end
	else
		druidmana:Hide();
	end

	if(druidmana.PostUpdateVisibility) then
		return druidmana:PostUpdateVisibility(self.unit);
	end
end

local UNIT_MANA = function(self, event, unit, powerType)
	if(self.unit ~= unit) then return; end
	local druidmana = self.DruidAltMana;

	if(not druidmana.ManaBar) then return; end

	if(druidmana.PreUpdate) then
		druidmana:PreUpdate(unit);
	end

	local min, max = UnitPower("player", 0), UnitPowerMax("player", 0);

	druidmana.ManaBar:SetMinMaxValues(0, max);
	druidmana.ManaBar:SetValue(min);

	local r, g, b, t;
	if(druidmana.colorPower) then
		t = self.colors.power["MANA"];
	elseif(druidmana.colorClass and UnitIsPlayer(unit)) or
		(druidmana.colorClassNPC and not UnitIsPlayer(unit)) or
		(druidmana.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit);
		t = self.colors.class[class];
	elseif(druidmana.colorReaction and UnitReaction(unit, "player")) then
		t = self.colors.reaction[UnitReaction(unit, "player")];
	elseif(druidmana.colorSmooth) then
		r, g, b = self.ColorGradient(min / max, unpack(druidmana.smoothGradient or self.colors.smooth));
	end

	if(t) then
		r, g, b = t[1], t[2], t[3];
	end

	if(b) then
		druidmana.ManaBar:SetStatusBarColor(r, g, b);

		local bg = druidmana.bg;
		if(bg) then
			local mu = bg.multiplier or 1;
			bg:SetVertexColor(r * mu, g * mu, b * mu);
		end
	end

	UPDATE_VISIBILITY(self);

	if(druidmana.PostUpdatePower) then
		return druidmana:PostUpdatePower(unit, min, max);
	end
end

local Update = function(self, ...)
	UNIT_MANA(self, ...);
	return UPDATE_VISIBILITY(self, ...);
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate");
end

local Enable = function(self, unit)
	local druidmana = self.DruidAltMana;
	if(druidmana and unit == "player") then
		druidmana.__owner = self;
		druidmana.ForceUpdate = ForceUpdate;

		self:RegisterEvent("UNIT_MANA", UNIT_MANA);
		self:RegisterEvent("UNIT_MAXMANA", UNIT_MANA);
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UPDATE_VISIBILITY);

		return true;
	end
end

local Disable = function(self)
	local druidmana = self.DruidAltMana;
	if(druidmana) then
		self:UnregisterEvent("UNIT_MANA", UNIT_MANA);
		self:UnregisterEvent("UNIT_MAXMANA", UNIT_MANA);
		self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", UPDATE_VISIBILITY);
	end
end

oUF:AddElement("DruidAltMana", Update, Enable, Disable);