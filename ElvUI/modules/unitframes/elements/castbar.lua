local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local floor = math.floor;
local LSM = LibStub("LibSharedMedia-3.0");

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

function UF:Construct_Castbar(self, direction, moverName)
	local castbar = CreateFrame("StatusBar", nil, self);
	UF["statusbars"][castbar] = true;
	
	castbar.OnUpdate = UF.OnCastUpdate;
	castbar.PostCastStart = UF.PostCastStart
	castbar.PostChannelStart = UF.PostCastStart
	castbar.PostCastStop = UF.PostCastStop;
	castbar.PostChannelUpdate = UF.PostChannelUpdate;
	castbar.PostCastFailed = UF.PostCastFailed;
	castbar.PostCastInterrupted = UF.PostCastFailed;
	castbar.PostCastInterruptible = UF.PostCastInterruptible;
	castbar.PostCastNotInterruptible = UF.PostCastNotInterruptible;
	
	castbar:SetClampedToScreen(true);
	castbar:CreateBackdrop("Default");
	
	castbar.Time = castbar:CreateFontString(nil, "OVERLAY");
	UF:Configure_FontString(castbar.Time);
	castbar.Time:Point("RIGHT", castbar, "RIGHT", -4, 0);
	castbar.Time:SetTextColor(0.84, 0.75, 0.65);
	castbar.Time:SetJustifyH("RIGHT");
	
	castbar.Text = castbar:CreateFontString(nil, "OVERLAY");
	UF:Configure_FontString(castbar.Text);
	castbar.Text:SetPoint("LEFT", 4, 0);
	castbar.Text:SetPoint("RIGHT", castbar.Time, "LEFT", -5, 0);
	castbar.Text:SetTextColor(0.84, 0.75, 0.65);
	castbar.Text:SetJustifyH("LEFT");
	
	castbar.Spark = castbar:CreateTexture(nil, "OVERLAY");
	castbar.Spark:SetBlendMode("ADD");
	castbar.Spark:SetVertexColor(1, 1, 1);
	
	castbar.LatencyTexture = castbar:CreateTexture(nil, "OVERLAY");
	castbar.LatencyTexture:SetTexture(E["media"].blankTex);
	castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75);
	
	castbar.bg = castbar:CreateTexture(nil, "BORDER");
	castbar.bg:Hide();
	
	local button = CreateFrame("Frame", nil, castbar);
	local holder = CreateFrame("Frame", nil, castbar);
	button:SetTemplate("Default");
	
	if(direction == "LEFT" ) then
		holder:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -(E.Border * 3));
		castbar:Point("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -E.Border, E.Border);
		button:Point("RIGHT", castbar, "LEFT", E.PixelMode and 0 or -3, 0);
	else
		holder:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -(E.Border * 3));
		castbar:Point("BOTTOMLEFT", holder, "BOTTOMLEFT", E.Border, E.Border);
		button:Point("LEFT", castbar, "RIGHT", E.PixelMode and 0 or 3, 0);
	end
	
	castbar.Holder = holder;
	
	if(moverName ) then
		E:CreateMover(castbar.Holder, self:GetName().."CastbarMover", moverName, nil, -6, nil, "ALL,SOLO");
	end
	
	local icon = button:CreateTexture(nil, "ARTWORK");
	icon:SetInside();
	icon:SetTexCoord(unpack(E.TexCoords));
	icon.bg = button;
	
	castbar.ButtonIcon = icon;
	
	return castbar;
end

function UF:OnCastUpdate(elapsed)
	local db = self:GetParent().db;
	if(not db) then
		return;
	end
	
	if(self.casting) then
		local duration = self.duration + elapsed;
		if(duration >= self.max) then
			self:SetValue(self.max);
			
			local colors = ElvUF.colors;
			local r, g, b = colors.castCompleteColor[1], colors.castCompleteColor[2], colors.castCompleteColor[3];
			
			if(UF.db.colors.transparentCastbar and self.bg:IsShown()) then
				local _, _, _, alpha = self.backdrop:GetBackdropColor();
				self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha);
			else
				self:SetStatusBarColor(r, g, b);
			end
			
			if(self.Spark) then
				self.Spark:Hide();
			end
			
			self.fadeOut = 1;
			self.casting = nil;
			self.channeling = nil;
			
			return;
		end
		
		if(self.Time) then
			if(self.delay ~= 0) then
				if(db.castbar.format == "CURRENT") then
					self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(duration, "+", self.delay));
				elseif(db.castbar.format == "CURRENTMAX") then
					self.Time:SetText(("%.1f / %.1f |cffaf5050%s %.1f|r"):format(duration, self.max, "+", self.delay));
				elseif (db.castbar.format == "REMAINING") then
					self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(abs(duration - self.max), "+", self.delay));
				end
			else
				if(db.castbar.format == "CURRENT") then
					self.Time:SetText(("%.1f"):format(duration));
				elseif(db.castbar.format == "CURRENTMAX") then
					self.Time:SetText(("%.1f / %.1f"):format(duration, self.max));
				elseif(db.castbar.format == "REMAINING") then
					self.Time:SetText(("%.1f"):format(abs(duration - self.max)));
				end
			end
		end
		
		self.duration = duration;
		self:SetValue(duration);
		
		if(self.Spark) then
			self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0);
		end
	elseif(self.channeling) then
		local duration = self.duration - elapsed;
		if(duration <= 0) then
			if(self.Spark) then
				self.Spark:Hide();
			end
			
			self.fadeOut = 1;
			self.casting = nil;
			self.channeling = nil;
			
			return;
		end
		
		if(self.Time) then
			if(self.delay ~= 0) then
				if(db.castbar.format == "CURRENT") then
					self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(abs(duration - self.max), self.delay));
				elseif(db.castbar.format == "CURRENTMAX") then
					self.Time:SetText(("%.1f / %.1f |cffaf5050%.1f|r"):format(duration, self.max, self.delay));
				elseif(db.castbar.format == "REMAINING") then
					self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(duration, self.delay));
				end
			else
				if(db.castbar.format == "CURRENT") then
					self.Time:SetText(("%.1f"):format(abs(duration - self.max)));
				elseif(db.castbar.format == "CURRENTMAX") then
					self.Time:SetText(("%.1f / %.1f"):format(duration, self.max));
					self.Time:SetText(("%.1f / %.1f"):format(abs(duration - self.max), self.max));
				elseif(db.castbar.format == "REMAINING") then
					self.Time:SetText(("%.1f"):format(duration));
				end
			end
		end
		
		self.duration = duration;
		self:SetValue(duration);
		
		if(self.Spark) then
			self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0);
		end
	elseif(GetTime() < self.holdTime) then
		return;
	elseif(self.fadeOut) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if(alpha > 0) then
			self:SetAlpha(alpha);
		else
			self.fadeOut = nil;
			self:Hide();
		end
	end
end

local ticks = {};
function UF:HideTicks()
	for i = 1, #ticks do
		ticks[i]:Hide();
	end
end

function UF:SetCastTicks(frame, numTicks)
	UF:HideTicks();
	
	if(numTicks and numTicks <= 0) then
		return
	end;
	
	local w = frame:GetWidth();
	local d = w / numTicks;
	
	for i = 1, numTicks do
		if(not ticks[i]) then
			ticks[i] = frame:CreateTexture(nil, "OVERLAY");
			ticks[i]:SetTexture(E["media"].normTex);
			ticks[i]:SetVertexColor(0, 0, 0, 0.8);
			ticks[i]:Width(1);
			ticks[i]:SetHeight(frame:GetHeight());
		end
		
		ticks[i]:ClearAllPoints();
		ticks[i]:SetPoint("RIGHT", frame, "LEFT", d * i, 0);
		ticks[i]:Show();
	end
end

function UF:PostCastStart(unit, name, rank, castid)
	local db = self:GetParent().db;
	if(not db or not db.castbar) then
		return;
	end
	
	if(unit == "vehicle") then
		unit = "player";
	end
	
	if(self.Spark and db.castbar.spark) then
		self.Spark:Show();
		self.Spark:Height(self:GetHeight() * 2);
	end
	
	if(db.castbar.displayTarget and self.curTarget) then
		self.Text:SetText(name.." --> "..self.curTarget);
	else
		self.Text:SetText(name);
	end
	
	self.unit = unit;

	if(db.castbar.ticks and unit == "player") then
		if(E.global.unitframe.ChannelTicks[name]) then
			UF:SetCastTicks(self, E.global.unitframe.ChannelTicks[name])
		else
			UF:HideTicks();
		end
	elseif(unit == "player") then
		UF:HideTicks();
	end
	
	local colors = ElvUF.colors;
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3];
	if(UF.db.colors.castClassColor) then
		local t;
		if(UnitIsPlayer(unit)) then
			local _, Class = UnitClass(unit);
			t = ElvUF.colors.class[Class];
		elseif(UnitReaction(unit, "player")) then
			t = ElvUF.colors.reaction[UnitReaction(unit, "player")];
		end
		
		if(t) then
			r, g, b = t[1], t[2], t[3];
		end
	end
	
	if(self.interrupt and unit ~= "player" and UnitCanAttack("player", unit)) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3];
	end
	self:SetStatusBarColor(r, g, b);
	
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentCastbar, self, self.bg, nil, true);
	if(self.bg:IsShown() ) then
		self.bg:SetTexture(r * 0.25, g * 0.25, b * 0.25);
		
		local _, _, _, alpha = self.backdrop:GetBackdropColor();
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha);
	end
end

function UF:PostCastStop(unit, name, rank, castid)
	local colors = ElvUF.colors;
	local r, g, b = colors.castCompleteColor[1], colors.castCompleteColor[2], colors.castCompleteColor[3];
	
	if(UF.db.colors.transparentCastbar and self.bg:IsShown()) then
		local _, _, _, alpha = self.backdrop:GetBackdropColor();
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha);
	else
		self:SetStatusBarColor(r, g, b);
	end
end

function UF:PostChannelUpdate(unit, name)
	local db = self:GetParent().db;
	if(not db) then
		return;
	end
	
    if not(unit == "player" or unit == "vehicle") then
		return;
	end
	
	if(db.castbar.ticks and unit == "player") then
		if(E.global.unitframe.ChannelTicks[name]) then
			UF:SetCastTicks(self, E.global.unitframe.ChannelTicks[name]);
		else
			UF:HideTicks();
		end
	elseif(unit == "player") then
		UF:HideTicks();
	end
end

function UF:PostCastFailed(event, unit, name, rank, castid)
	local colors = ElvUF.colors;
	local r, g, b = colors.castFailColor[1], colors.castFailColor[2], colors.castFailColor[3];
	if(UF.db.colors.transparentCastbar and self.bg:IsShown()) then
		local _, _, _, alpha = self.backdrop:GetBackdropColor();
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha);
	else
		self:SetStatusBarColor(r, g, b);
	end
end

function UF:PostCastNotInterruptible(unit)
	local colors = ElvUF.colors;
	
	self:SetStatusBarColor(colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]);
end

function UF:PostCastInterruptible(unit)
	if(unit == "vehicle" or unit == "player") then
		return;
	end
	
	local colors = ElvUF.colors;
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3];
	
	if(UF.db.colors.castClassColor) then
		local t;
		if(UnitIsPlayer(unit)) then
			local _, class = UnitClass(unit)
			t = ElvUF.colors.class[class]
		elseif(UnitReaction(unit, "player")) then
			t = ElvUF.colors.reaction[UnitReaction(unit, "player")];
		end
		
		if(t) then
			r, g, b = t[1], t[2], t[3];
		end
	end
	
	if(UnitCanAttack("player", unit)) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3];
	end
	
	self:SetStatusBarColor(r, g, b);
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentCastbar, self, self.bg, nil, true);
	if(self.bg:IsShown()) then
		self.bg:SetTexture(r * 0.25, g * 0.25, b * 0.25);
		
		local _, _, _, alpha = self.backdrop:GetBackdropColor();
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha);
	end
end