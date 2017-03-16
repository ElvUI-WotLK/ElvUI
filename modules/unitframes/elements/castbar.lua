local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local unpack = unpack;
local abs = abs;

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

local ticks = {};

function UF:Construct_Castbar(frame, moverName)
	local castbar = CreateFrame("StatusBar", nil, frame);
	castbar:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 30);
	self["statusbars"][castbar] = true;

	castbar.CustomDelayText = self.CustomCastDelayText
	castbar.CustomTimeText = self.CustomTimeText
	castbar.PostCastStart = self.PostCastStart
	castbar.PostChannelStart = self.PostCastStart
	castbar.PostChannelUpdate = self.PostChannelUpdate
	castbar.PostCastInterruptible = self.PostCastInterruptible
	castbar.PostCastNotInterruptible = self.PostCastNotInterruptible

	castbar:SetClampedToScreen(true);
	castbar:CreateBackdrop("Default", nil, nil, self.thinBorders);

	castbar.Time = castbar:CreateFontString(nil, "OVERLAY");
	self:Configure_FontString(castbar.Time);
	castbar.Time:Point("RIGHT", castbar, "RIGHT", -4, 0);
	castbar.Time:SetTextColor(0.84, 0.75, 0.65);
	castbar.Time:SetJustifyH("RIGHT");

	castbar.Text = castbar:CreateFontString(nil, "OVERLAY");
	self:Configure_FontString(castbar.Text);
	castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
	castbar.Text:SetJustifyH("LEFT");
	castbar.Text:SetTextColor(0.84, 0.75, 0.65);
	castbar.Text:SetWordWrap(false)

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
	button:SetTemplate("Default", nil, nil, self.thinBorders);

	castbar.Holder = holder;

	castbar.Holder:Point("TOPLEFT", frame, "BOTTOMLEFT", 0, -(frame.BORDER - frame.SPACING));
	castbar:Point("BOTTOMLEFT", castbar.Holder, "BOTTOMLEFT", frame.BORDER, frame.BORDER);
	button:Point("RIGHT", castbar, "LEFT", -E.Spacing*3, 0);

	if(moverName) then
		E:CreateMover(castbar.Holder, frame:GetName() .. "CastbarMover", moverName, nil, -6, nil, "ALL,SOLO");
	end

	local icon = button:CreateTexture(nil, "ARTWORK");
	local offset = frame.BORDER;
	icon:SetInside(nil, offset, offset);
	icon:SetTexCoord(unpack(E.TexCoords));
	icon.bg = button;

	castbar.ButtonIcon = icon;

	return castbar;
end

function UF:Configure_Castbar(frame)
	if(not frame.VARIABLES_SET) then return; end
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
		if(not db.castbar.iconAttached) then
			castbar.Icon.bg:Size(db.castbar.iconSize);
		else
			if(db.castbar.insideInfoPanel and frame.USE_INFO_PANEL) then
				castbar.Icon.bg:Size(db.infoPanel.height - frame.SPACING*2);
			else
				castbar.Icon.bg:Size(db.castbar.height - frame.SPACING*2);
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
	if(db.castbar.insideInfoPanel and frame.USE_INFO_PANEL) then
		if(not db.castbar.iconAttached) then
			castbar:SetInside(frame.InfoPanel, 0, 0);
		else
			local iconWidth = db.castbar.icon and (castbar.Icon.bg:GetWidth() - frame.BORDER) or 0;
			if(frame.ORIENTATION == "RIGHT") then
				castbar:SetPoint("TOPLEFT", frame.InfoPanel, "TOPLEFT");
				castbar:SetPoint("BOTTOMRIGHT", frame.InfoPanel, "BOTTOMRIGHT", -iconWidth - frame.SPACING*3, 0);
			else
				castbar:SetPoint("TOPLEFT", frame.InfoPanel, "TOPLEFT", iconWidth + frame.SPACING*3, 0);
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

	if(not db.castbar.iconAttached and db.castbar.icon) then
		local attachPoint = db.castbar.iconAttachedTo == "Frame" and frame or frame.Castbar;
		local anchorPoint = db.castbar.iconPosition;
		castbar.Icon.bg:ClearAllPoints();
		castbar.Icon.bg:Point(INVERT_ANCHORPOINT[anchorPoint], attachPoint, anchorPoint, db.castbar.iconXOffset, db.castbar.iconYOffset);
	elseif(db.castbar.icon) then
		castbar.Icon.bg:ClearAllPoints();
		if(frame.ORIENTATION == "RIGHT") then
			castbar.Icon.bg:Point("LEFT", castbar, "RIGHT", frame.SPACING*3, 0);
		else
			castbar.Icon.bg:Point("RIGHT", castbar, "LEFT", -frame.SPACING*3, 0);
		end
	end

	castbar.tickHeight = castbar:GetHeight()

	if(db.castbar.enable and not frame:IsElementEnabled("Castbar")) then
		frame:EnableElement("Castbar");
	elseif(not db.castbar.enable and frame:IsElementEnabled("Castbar")) then
		frame:DisableElement("Castbar");

		if(castbar.Holder.mover) then
			E:DisableMover(castbar.Holder.mover:GetName());
		end
	end
end

function UF:CustomCastDelayText(duration)
	local db = self:GetParent().db
	if not db then return end

	if self.channeling then
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(abs(duration - self.max), self.delay))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f |cffaf5050%.1f|r"):format(duration, self.max, self.delay))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(duration, self.delay))
		end
	else
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(duration, "+", self.delay))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f |cffaf5050%s %.1f|r"):format(duration, self.max, "+", self.delay))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(abs(duration - self.max), "+", self.delay))
		end
	end
end

function UF:CustomTimeText(duration)
	local db = self:GetParent().db
	if not db then return end

	if self.channeling then
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f"):format(abs(duration - self.max)))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f"):format(duration, self.max))
			self.Time:SetText(("%.1f / %.1f"):format(abs(duration - self.max), self.max))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f"):format(duration))
		end
	else
		if db.castbar.format == 'CURRENT' then
			self.Time:SetText(("%.1f"):format(duration))
		elseif db.castbar.format == 'CURRENTMAX' then
			self.Time:SetText(("%.1f / %.1f"):format(duration, self.max))
		elseif db.castbar.format == 'REMAINING' then
			self.Time:SetText(("%.1f"):format(abs(duration - self.max)))
		end
	end
end

function UF:HideTicks()
	for i = 1, #ticks do
		ticks[i]:Hide();
	end
end

function UF:SetCastTicks(frame, numTicks)
	UF:HideTicks();

	if(numTicks and numTicks <= 0) then return end

	local w = frame:GetWidth();
	local d = w / numTicks;

	for i = 1, numTicks do
		if(not ticks[i]) then
			ticks[i] = frame:CreateTexture(nil, "OVERLAY");
			ticks[i]:SetTexture(E["media"].normTex);
			E:RegisterStatusBar(ticks[i])
			ticks[i]:SetVertexColor(0, 0, 0, 0.8);
			ticks[i]:Width(1);
		end

		ticks[i]:Height(frame.tickHeight)
		ticks[i]:ClearAllPoints();
		ticks[i]:SetPoint("RIGHT", frame, "LEFT", d * i, 0);
		ticks[i]:Show();
	end
end

function UF:PostCastStart(unit, name)
	local db = self:GetParent().db;
	if not db or not db.castbar then return; end

	if(unit == "vehicle") then
		unit = "player";
	end

	if(db.castbar.displayTarget and self.curTarget) then
		self.Text:SetText(name.." --> "..self.curTarget);
	else
		self.Text:SetText(name);
	end

	-- Get length of Time, then calculate available length for Text
	local timeWidth = self.Time:GetStringWidth()
	local textWidth = self:GetWidth() - timeWidth - 10
	local textStringWidth = self.Text:GetStringWidth()

	if timeWidth == 0 or textStringWidth == 0 then
		E:Delay(0.05, function() -- Delay may need tweaking
			textWidth = self:GetWidth() - self.Time:GetStringWidth() - 10
			textStringWidth = self.Text:GetStringWidth()
			if textWidth > 0 then self.Text:SetWidth(min(textWidth, textStringWidth)) end
		end)
	else
		self.Text:SetWidth(min(textWidth, textStringWidth))
	end

	self.Spark:Height(self:GetHeight() * 2)

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

	local t;
	if(UF.db.colors.castClassColor and UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit);
		t = ElvUF.colors.class[class];
	elseif(UF.db.colors.castReactionColor and UnitReaction(unit, "player")) then
		t = ElvUF.colors.reaction[UnitReaction(unit, "player")];
	end

	if(t) then
		r, g, b = t[1], t[2], t[3];
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

function UF:PostChannelUpdate(unit, name)
	local db = self:GetParent().db;
	if not db then return; end
	if not (unit == "player" or unit == "vehicle") then return end

	if db.castbar.ticks then
		if(E.global.unitframe.ChannelTicks[name]) then
			UF:SetCastTicks(self, E.global.unitframe.ChannelTicks[name]);
		else
			UF:HideTicks();
		end
	else
		UF:HideTicks();
	end
end

function UF:PostCastInterruptible(unit)
	if(unit == "vehicle" or unit == "player") then return; end

	local colors = ElvUF.colors;
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3];

	local t;
	if(UF.db.colors.castClassColor and UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit);
		t = ElvUF.colors.class[class];
	elseif(UF.db.colors.castReactionColor and UnitReaction(unit, "player")) then
		t = ElvUF.colors.reaction[UnitReaction(unit, "player")];
	end

	if(t) then
		r, g, b = t[1], t[2], t[3];
	end

	if(self.interrupt and UnitCanAttack("player", unit)) then
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

function UF:PostCastNotInterruptible()
	local colors = ElvUF.colors;
	self:SetStatusBarColor(colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]);
end