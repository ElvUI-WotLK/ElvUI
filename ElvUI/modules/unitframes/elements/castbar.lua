local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");
local LSM = LibStub("LibSharedMedia-3.0");

local unpack, tonumber = unpack, tonumber;
local floor, abs = math.floor, abs;

local CreateFrame = CreateFrame;
local UnitIsPlayer = UnitIsPlayer;
local UnitClass = UnitClass;
local UnitReaction = UnitReaction;
local UnitCanAttack = UnitCanAttack;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

local INVERT_ANCHORPOINT = {
	TOPLEFT = "BOTTOMRIGHT",
	LEFT = "RIGHT",
	BOTTOMLEFT = "TOPRIGHT",
	RIGHT = "LEFT",
	TOPRIGHT = "BOTTOMLEFT",
	BOTTOMRIGHT = "TOPLEFT",
	CENTER = "CENTER",
	TOP = "BOTTOM",
	BOTTOM = "TOP"
};

function UF:Construct_Castbar(frame, direction, moverName)
	local castbar = CreateFrame("StatusBar", nil, frame);
	castbar:SetFrameStrata("HIGH");
	self["statusbars"][castbar] = true;
	
	castbar.OnUpdate = self.OnCastUpdate;
	castbar.PostCastStart = self.PostCastStart;
	castbar.PostChannelStart = self.PostCastStart;
	castbar.PostCastStop = self.PostCastStop;
	castbar.PostChannelUpdate = self.PostChannelUpdate;
	castbar.PostCastFailed = self.PostCastFailed;
	castbar.PostCastInterrupted = self.PostCastFailed;
	castbar.PostCastInterruptible = self.PostCastInterruptible;
	castbar.PostCastNotInterruptible = self.PostCastNotInterruptible;
	castbar.PostChannelStop = self.PostChannelStop;
	
	castbar:SetClampedToScreen(true);
	castbar:CreateBackdrop("Default", nil, nil, self.thinBorders);
	
	castbar.Time = castbar:CreateFontString(nil, "OVERLAY");
	self:Configure_FontString(castbar.Time);
	castbar.Time:Point("RIGHT", castbar, "RIGHT", -4, 0);
	castbar.Time:SetTextColor(0.84, 0.75, 0.65);
	castbar.Time:SetJustifyH("RIGHT");
	
	castbar.Text = castbar:CreateFontString(nil, "OVERLAY");
	self:Configure_FontString(castbar.Text);
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
	button:SetTemplate("Default", nil, nil, self.thinBorders and not E.global.tukuiMode);
	
	castbar.Holder = holder;
	
	castbar.Holder:Point("TOPLEFT", frame, "BOTTOMLEFT", 0, -(frame.BORDER - frame.SPACING));
	castbar:Point("BOTTOMLEFT", castbar.Holder, "BOTTOMLEFT", frame.BORDER, frame.BORDER);
	button:Point("RIGHT", castbar, "LEFT", -E.Spacing*3, 0);
	
	if(moverName) then
		E:CreateMover(castbar.Holder, frame:GetName() .. "CastbarMover", moverName, nil, -6, nil, "ALL,SOLO");
	end
	
	local icon = button:CreateTexture(nil, "ARTWORK");
	local offset = (not E.global.tukuiMode and frame.BORDER or E.Border);
	icon:SetInside(nil, offset, offset);
	icon:SetTexCoord(unpack(E.TexCoords));
	icon.bg = button;
	
	castbar.ButtonIcon = icon;
	castbar.Icon = castbar.ButtonIcon
	
	return castbar;
end

function UF:Configure_Castbar(frame)
	local castbar = frame.Castbar;
	local db = frame.db;
	castbar:Width(db.castbar.width - ((frame.BORDER+frame.SPACING)*2));
	castbar:Height(db.castbar.height - ((frame.BORDER+frame.SPACING)*2));
	castbar.Holder:Width(db.castbar.width);
	castbar.Holder:Height(db.castbar.height);
	if(castbar.Holder:GetScript("OnSizeChanged")) then
		castbar.Holder:GetScript("OnSizeChanged")(castbar.Holder);
	end
	
	if(db.castbar.latency) then
		castbar.SafeZone = castbar.LatencyTexture;
		castbar.LatencyTexture:Show();
	else
		castbar.SafeZone = nil;
		castbar.LatencyTexture:Hide();
	end
	
	if(db.castbar.icon) then
		castbar.Icon = castbar.ButtonIcon;
		if((not db.castbar.iconAttached) or E.global.tukuiMode) then
			castbar.Icon.bg:Size(db.castbar.iconSize);
		else
			if(db.castbar.insideInfoPanel and frame.USE_INFO_PANEL) then
				castbar.Icon.bg:Size(db.infoPanel.height - frame.SPACING*2);
			else
				castbar.Icon.bg:Size(db.castbar.height-frame.SPACING*2);
			end
			castbar:Width(db.castbar.width - castbar.Icon.bg:GetWidth() - (frame.BORDER + frame.SPACING*5));
		end
		
		castbar.Icon.bg:Show();
	else
		castbar.ButtonIcon.bg:Hide();
		castbar.Icon = nil;
	end
	
	if(db.castbar.spark) then
		castbar.Spark:Show();
	else
		castbar.Spark:Hide();
	end
	
	castbar:ClearAllPoints();
	if((db.castbar.insideInfoPanel and frame.USE_INFO_PANEL) or E.global.tukuiMode) then
		castbar:Size(frame.InfoPanel:GetSize());
		if((not db.castbar.iconAttached) or E.global.tukuiMode) then
			castbar:SetInside(frame.InfoPanel, 0, 0);
		else
			local iconWidth = db.castbar.icon and (castbar.Icon.bg:GetWidth() - frame.BORDER) or 0;
 			if(frame.ORIENTATION == "RIGHT") then
				castbar:SetPoint("TOPLEFT", frame.InfoPanel, "TOPLEFT");
				castbar:SetPoint("BOTTOMRIGHT", frame.InfoPanel, "BOTTOMRIGHT", -iconWidth - frame.SPACING*3, 0);
			else
				castbar:SetPoint("TOPLEFT", frame.InfoPanel, "TOPLEFT",  iconWidth + frame.SPACING*3, 0);
				castbar:SetPoint("BOTTOMRIGHT", frame.InfoPanel, "BOTTOMRIGHT");
			end
		end
		if(castbar.Holder.mover) then
			E:DisableMover(castbar.Holder.mover:GetName());
		end
	else
		local isMoved = E:HasMoverBeenMoved(frame:GetName() .. "CastbarMover") or not castbar.Holder.mover;
		if(not isMoved) then	
			castbar.Holder.mover:ClearAllPoints();
		end
		
		castbar:ClearAllPoints();
		if(frame.ORIENTATION ~= "RIGHT") then
			castbar:Point("BOTTOMRIGHT", castbar.Holder, "BOTTOMRIGHT", -(frame.BORDER+frame.SPACING), frame.BORDER+frame.SPACING);
			if(not isMoved) then
				castbar.Holder.mover:Point("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -(frame.BORDER - frame.SPACING));
			end
		else
			castbar:Point("BOTTOMLEFT", castbar.Holder, "BOTTOMLEFT", frame.BORDER+frame.SPACING, frame.BORDER+frame.SPACING);
			if(not isMoved) then
				castbar.Holder.mover:Point("TOPLEFT", frame, "BOTTOMLEFT", 0, -(frame.BORDER - frame.SPACING));
			end
		end
		
		if(castbar.Holder.mover) then
			E:EnableMover(castbar.Holder.mover:GetName());
		end
	end
	
	if(E.global.tukuiMode and db.castbar.icon) then
		castbar.Icon.bg:ClearAllPoints();
		if(frame.ORIENTATION == "LEFT") then
			castbar.Icon.bg:Point("RIGHT", frame, "LEFT", -10, 0);
		else
			castbar.Icon.bg:Point("LEFT", frame, "RIGHT", 10, 0);
		end
	elseif(not db.castbar.iconAttached and db.castbar.icon) then
		local attachPoint = db.castbar.iconAttachedTo == "Frame" and frame or frame.Castbar;
		local anchorPoint = db.castbar.iconPosition;
		castbar.Icon.bg:ClearAllPoints();
		castbar.Icon.bg:Point(INVERT_ANCHORPOINT[anchorPoint], attachPoint, anchorPoint, db.castbar.iconXOffset, db.castbar.iconYOffset);
		castbar.Icon.bg:SetFrameStrata("HIGH");
	elseif(db.castbar.icon) then
		castbar.Icon.bg:ClearAllPoints();
		if(frame.ORIENTATION == "RIGHT") then
 			castbar.Icon.bg:Point("LEFT", castbar, "RIGHT", frame.SPACING*3, 0);
		else
			castbar.Icon.bg:Point("RIGHT", castbar, "LEFT", -frame.SPACING*3, 0);
		end
	end
	
	if(db.castbar.enable and not frame:IsElementEnabled("Castbar")) then
		frame:EnableElement("Castbar");
	elseif(not db.castbar.enable and frame:IsElementEnabled("Castbar")) then
		frame:DisableElement("Castbar");
		if(castbar.Holder.mover) then
			E:DisableMover(castbar.Holder.mover:GetName());
		end
	end
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
			
			if(self.Spark and db.castbar.spark) then
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
		
		if(self.Spark and db.castbar.spark) then
			self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0);
		end
	elseif(self.channeling) then
		local duration = self.duration - elapsed;
		if(duration <= 0) then
			if(self.Spark and db.castbar.spark) then
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
		
		if(self.Spark and db.castbar.spark) then
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
			if(self.Spark and db.castbar.spark) then self.Spark:Hide(); end
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
	local db = self:GetParent().db;
	if(not db) then
		return;
	end
	
	local colors = ElvUF.colors;
	local r, g, b = colors.castCompleteColor[1], colors.castCompleteColor[2], colors.castCompleteColor[3];
	
	if(UF.db.colors.transparentCastbar and self.bg:IsShown()) then
		local _, _, _, alpha = self.backdrop:GetBackdropColor();
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha);
	else
		self:SetStatusBarColor(r, g, b);
	end
	
	if(self.Spark and db.castbar.spark) then
		self.Spark:Hide();
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
	local db = self:GetParent().db;
	if(not db) then
		return;
	end
	
	local colors = ElvUF.colors;
	local r, g, b = colors.castFailColor[1], colors.castFailColor[2], colors.castFailColor[3];
	if(UF.db.colors.transparentCastbar and self.bg:IsShown()) then
		local _, _, _, alpha = self.backdrop:GetBackdropColor();
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha);
	else
		self:SetStatusBarColor(r, g, b);
	end
	
	if(self.Spark and db.castbar.spark) then
		self.Spark:Hide();
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

function UF:PostChannelStop(unit, spellname)
	local db = self:GetParent().db;
	if(not db) then
		return;
	end
	
	if(self.Spark and db.castbar.spark) then
		self.Spark:Hide();
	end
end