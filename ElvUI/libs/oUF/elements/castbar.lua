--[[
	Original codebase:
		oUF_Castbar by starlon.
		http://svn.wowace.com/wowace/trunk/oUF_Castbar/
--]]
local parent, ns = ...
local oUF = ns.oUF
local tradeskillCurrent, tradeskillTotal, mergeTradeskill = 0, 0, false;

local GetTime = GetTime;
local UnitCastingInfo = UnitCastingInfo;
local UnitChannelInfo = UnitChannelInfo;

local updateSafeZone = function(self)
	local sz = self.SafeZone;
	local width = self:GetWidth();
	local _, _, ms = GetNetStats();
	
	if(ms ~= 0) then
		local safeZonePercent = (width / self.max) * (ms / 1e5);
		if(safeZonePercent > 1) then
			safeZonePercent = 1;
		end
		sz:SetWidth(width * safeZonePercent);
		sz:Show();
	else
		sz:Hide();
	end
end

local UNIT_SPELLCAST_SENT = function (self, event, unit, spell, rank, target)
	local castbar = self.Castbar;
	castbar.curTarget = (target and target ~= "") and target or nil;
end

local UNIT_SPELLCAST_START = function(self, event, unit, spell)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	local name, _, text, texture, startTime, endTime, isTradeSkill, castid, interrupt = UnitCastingInfo(unit)
	if(not name) then
		castbar:Hide();
		return
	end
	
	castbar.duration = GetTime() - (startTime/1000);
	castbar.max = (endTime - startTime) / 1000;
	
	if(mergeTradeskill and isTradeSkill and UnitIsUnit(unit, "player")) then
		castbar.duration = castbar.duration + (castbar.max * tradeskillCurrent);
		castbar.max = castbar.max * tradeskillTotal;
		
		if(unit == "player") then
			tradeskillCurrent = tradeskillCurrent + 1;
		end
		castbar:SetValue(castbar.duration);
	else
		castbar:SetValue(0);
	end
	
	castbar:SetMinMaxValues(0, castbar.max);
	
	castbar:SetAlpha(1.0);
	castbar.holdTime = 0;
	castbar.casting = 1;
	castbar.castid = castid;
	castbar.delay = 0;
	castbar.channeling = nil;
	castbar.fadeOut = nil;
	castbar.interrupt = interrupt;
	castbar.isTradeSkill = isTradeSkill;
	
	if(castbar.Text) then
		castbar.Text:SetText(text);
	end
	if(castbar.Icon) then
		castbar.Icon:SetTexture(texture);
	end
	if(castbar.Time) then
		castbar.Time:SetText();
	end
	
	local sf = castbar.SafeZone;
	if(sf) then
		sf:ClearAllPoints();
		sf:SetPoint'RIGHT';
		sf:SetPoint'TOP';
		sf:SetPoint'BOTTOM';
		updateSafeZone(castbar);
	end
	
	castbar:Show();
	
	if(castbar.PostCastStart) then
		castbar:PostCastStart(unit, name, castid)
	end
end

local UNIT_SPELLCAST_FAILED = function(self, event, unit, spellname, _, castid)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	if(castbar.castid ~= castid) then
		return;
	end
	castbar:SetValue(castbar.max);
	
	castbar.casting = nil;
	castbar.channeling = nil;
	castbar.interrupt = nil;
	castbar.fadeOut = 1;
	castbar.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
	
	if(castbar.PostCastFailed) then
		return castbar:PostCastFailed(unit, spellname, castid);
	end
end

local UNIT_SPELLCAST_INTERRUPTED = function(self, event, unit, spellname, _, castid)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	if(castbar.castid ~= castid) then
		return;
	end
	castbar:SetValue(castbar.max);
	
	castbar.casting = nil;
	castbar.channeling = nil;
	castbar.fadeOut = 1;
	castbar.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
	
	if(castbar.PostCastInterrupted) then
		return castbar:PostCastInterrupted(unit, spellname, castid);
	end
end

local UNIT_SPELLCAST_INTERRUPTIBLE = function(self, event, unit)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	if(castbar.PostCastInterruptible) then
		return castbar:PostCastInterruptible(unit);
	end
end

local UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function(self, event, unit)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	if(castbar.PostCastNotInterruptible) then
		return castbar:PostCastNotInterruptible(unit);
	end
end

local UNIT_SPELLCAST_DELAYED = function(self, event, unit, spellname, _, castid)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	if(castbar:IsShown()) then
		local name, _, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
		if(not name) then
			return;
		end
		
		local duration = GetTime() - (startTime / 1000);
		if(duration < 0) then duration = 0; end
		
		castbar.delay = castbar.delay + castbar.duration - duration;
		castbar.duration = duration;
		
		castbar:SetValue(duration);
		
		if(not castbar.casting) then
			castbar.casting = 1;
			castbar.channeling = nil;
			castbar.fadeOut = 0;
		end
	end
	
	if(castbar.PostCastDelayed) then
		return castbar:PostCastDelayed(unit, name, castid);
	end
end

local UNIT_SPELLCAST_STOP = function(self, event, unit, spellname, _, castid)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	if(castbar.castid == castid and castbar.casting and (not castbar.fadeOut)) then
		if(mergeTradeskill and UnitIsUnit(unit, "player")) then
			if(tradeskillCurrent == tradeskillTotal) then
				mergeTradeskill = false;
			end
		else
			castbar:SetValue(castbar.max);
			
			castbar.casting = nil;
			castbar.interrupt = nil;
			castbar.fadeOut = 1;
			castbar.holdTime = 0;
		end
		
		if(castbar.PostCastStop) then
			return castbar:PostCastStop(unit, spellname, castid);
		end
	end
end

local UNIT_SPELLCAST_CHANNEL_START = function(self, event, unit, spellname)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	local name, _, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit);
	if(not name) then
		return;
	end
	
	castbar.duration = ((endTime / 1000) - GetTime());
	castbar.max = (endTime - startTime) / 1000;
	castbar.delay = 0;
	castbar:SetMinMaxValues(0, castbar.max);
	castbar:SetValue(castbar.duration);
	
	if(castbar.Text) then
		castbar.Text:SetText(name);
	end
	if(castbar.Icon) then
		castbar.Icon:SetTexture(texture);
	end
	if(castbar.Time) then
		castbar.Time:SetText();
	end
	
	castbar:SetAlpha(1.0);
	castbar.holdTime = 0;
	castbar.casting = nil;
	castbar.channeling = 1;
	castbar.interrupt = notInterruptible;
	castbar.fadeOut = nil;
	
	local sf = castbar.SafeZone;
	if(sf) then
		sf:ClearAllPoints();
		sf:SetPoint'LEFT';
		sf:SetPoint'TOP';
		sf:SetPoint'BOTTOM';
		updateSafeZone(castbar);
	end
	
	castbar:Show();
	
	if(castbar.PostChannelStart) then
		castbar:PostChannelStart(unit, name);
	end
end

local UNIT_SPELLCAST_CHANNEL_UPDATE = function(self, event, unit, spellname)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	if(castbar:IsShown()) then
		local name, _, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);
		if(not name) then
			return;
		end
		local duration = ((endTime / 1000) - GetTime());
		castbar.delay = castbar.delay + castbar.duration - duration;
		castbar.duration = duration;
		castbar.max = (endTime - startTime) / 1000;
		
		castbar:SetMinMaxValues(0, castbar.max);
		castbar:SetValue(duration);
	end
	
	if(castbar.PostChannelUpdate) then
		return castbar:PostChannelUpdate(unit, name);
	end
end

local UNIT_SPELLCAST_CHANNEL_STOP = function(self, event, unit, spellname)
	if((self.unit ~= unit) or not unit) then
		return;
	end
	
	local castbar = self.Castbar;
	if(castbar:IsShown() or castbar.channeling) then
		castbar:SetValue(castbar.max);
		
		castbar.channeling = nil;
		castbar.interrupt = nil;
		castbar.fadeOut = 1;
		castbar.holdTime = 0;
		
		if(castbar.PostChannelStop) then
			return castbar:PostChannelStop(unit, spellname);
		end
	end
end

local UpdateCastingTimeInfo = function(self, duration)
	if(self.Time) then
		if(self.delay ~= 0) then
			if(self.CustomDelayText) then
				self:CustomDelayText(duration)
			else
				self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
			end
		else
			if(self.CustomTimeText) then
				self:CustomTimeText(duration)
			else
				self.Time:SetFormattedText("%.1f", duration)
			end
		end
	end
	if(self.Spark) then
		self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
	end
end

local onUpdate = function(self, elapsed)
	if(self.casting) then
		local duration = self.duration + elapsed;
		if(duration >= self.max) then
			self:SetValue(self.max)
			
			self.holdTime = 0
			self.fadeOut = 1
			self.casting = nil
			
			if(self.PostCastStop) then self:PostCastStop(self.__owner.unit) end
			return
		end

		UpdateCastingTimeInfo(self, duration)

		self.duration = duration
		self:SetValue(duration)
	elseif(self.channeling) then
		local duration = self.duration - elapsed;
		if(duration <= 0) then
			self.fadeOut = 1
			self.channeling = nil
			self.holdTime = 0

			if(self.PostChannelStop) then self:PostChannelStop(self.__owner.unit) end
			return
		end

		UpdateCastingTimeInfo(self, duration)

		self.duration = duration
		self:SetValue(duration)
	elseif(GetTime() < self.holdTime) then
		return
	elseif(self.fadeOut) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if (alpha > 0.05) then
			self:SetAlpha(alpha);
		else
			self.fadeOut = nil;
			self:Hide();
		end
	end
end

local Update = function(self, ...)
	UNIT_SPELLCAST_START(self, ...)
	return UNIT_SPELLCAST_CHANNEL_START(self, ...)
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(object, unit)
	local castbar = object.Castbar;
	if(castbar) then
		castbar.__owner = object
		castbar.ForceUpdate = ForceUpdate

		if(not (unit and unit:match'%wtarget$')) then
			object:RegisterEvent("UNIT_SPELLCAST_SENT", UNIT_SPELLCAST_SENT)
			object:RegisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
			object:RegisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
			object:RegisterEvent("UNIT_SPELLCAST_STOP", UNIT_SPELLCAST_STOP)
			object:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", UNIT_SPELLCAST_INTERRUPTED)
			object:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", UNIT_SPELLCAST_INTERRUPTIBLE)
			object:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
			object:RegisterEvent("UNIT_SPELLCAST_DELAYED", UNIT_SPELLCAST_DELAYED)
			object:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", UNIT_SPELLCAST_CHANNEL_START)
			object:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", UNIT_SPELLCAST_CHANNEL_UPDATE)
			object:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", UNIT_SPELLCAST_CHANNEL_STOP)
		end

		castbar:SetScript("OnUpdate", castbar.OnUpdate or onUpdate)
		
		castbar.casting = nil;
		castbar.channeling = nil;
		castbar.holdTime = 0;
		
		if(object.unit == "player") then
			CastingBarFrame:UnregisterAllEvents()
			CastingBarFrame.Show = CastingBarFrame.Hide
			CastingBarFrame:Hide()
		elseif(object.unit == 'pet') then
			PetCastingBarFrame:UnregisterAllEvents()
			PetCastingBarFrame.Show = PetCastingBarFrame.Hide
			PetCastingBarFrame:Hide()
		end

		if(castbar:IsObjectType'StatusBar' and not castbar:GetStatusBarTexture()) then
			castbar:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		local spark = castbar.Spark
		if(spark and spark:IsObjectType'Texture' and not spark:GetTexture()) then
			spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
		end

		local sz = castbar.SafeZone
		if(sz and sz:IsObjectType'Texture' and not sz:GetTexture()) then
			sz:SetTexture(1, 0, 0)
		end

		castbar:Hide()

		return true
	end
end

local Disable = function(object, unit)
	local castbar = object.Castbar;
	if(castbar) then
		object:UnregisterEvent("UNIT_SPELLCAST_SENT", UNIT_SPELLCAST_SENT)
		object:UnregisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
		object:UnregisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
		object:UnregisterEvent("UNIT_SPELLCAST_STOP", UNIT_SPELLCAST_STOP)
		object:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED", UNIT_SPELLCAST_INTERRUPTED)
		object:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", UNIT_SPELLCAST_INTERRUPTIBLE)
		object:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
		object:UnregisterEvent("UNIT_SPELLCAST_DELAYED", UNIT_SPELLCAST_DELAYED)
		object:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", UNIT_SPELLCAST_CHANNEL_START)
		object:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", UNIT_SPELLCAST_CHANNEL_UPDATE)
		object:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", UNIT_SPELLCAST_CHANNEL_STOP)

		castbar:SetScript("OnUpdate", nil)
	end
end

hooksecurefunc("DoTradeSkill", function(index, num, ...)
	tradeskillCurrent = 0
	tradeskillTotal = tonumber(num) or 1
	mergeTradeskill = true
end)

oUF:AddElement('Castbar', Update, Enable, Disable)