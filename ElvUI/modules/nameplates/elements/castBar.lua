local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");
local LSM = LibStub("LibSharedMedia-3.0");

local unpack = unpack;

local CreateFrame = CreateFrame;

local green = {r = 0, g = 1, b = 0};
function mod:UpdateElement_CastBarOnValueChanged(value)
	local frame = self:GetParent();
	local min, max = self:GetMinMaxValues();
	local isChannel = value < frame.CastBar:GetValue();
	frame.CastBar:SetMinMaxValues(min, max);
	frame.CastBar:SetValue(value);

	if(isChannel) then
		if(frame.CastBar.channelTimeFormat == "CURRENT") then
			frame.CastBar.Time:SetFormattedText("%.1f", (max - value));
		elseif(frame.CastBar.channelTimeFormat == "CURRENT_MAX") then
			frame.CastBar.Time:SetFormattedText("%.1f / %.1f", (max - value), max);
		else
			frame.CastBar.Time:SetFormattedText("%.1f", value);
		end
	else
		if(frame.CastBar.castTimeFormat == "CURRENT") then
			frame.CastBar.Time:SetFormattedText("%.1f", value);
		elseif(frame.CastBar.castTimeFormat == "CURRENT_MAX") then
			frame.CastBar.Time:SetFormattedText("%.1f / %.1f", value, max);
		else
			frame.CastBar.Time:SetFormattedText("%.1f", (max - value));
		end
	end

	if(frame.CastBar.Spark) then
		local sparkPosition = (value / max) * frame.CastBar:GetWidth();
		frame.CastBar.Spark:SetPoint("CENTER", frame.CastBar, "LEFT", sparkPosition, 0);
	end

	local color;
	if(self.Shield and self.Shield:IsShown()) then
		color = mod.db.castNoInterruptColor;
	else
		if(value > 0 and (isChannel and (value/max) <= 0.02 or (value/max) >= 0.98)) then
			color = green;
		else
			color = mod.db.castColor;
		end
	end

	local spell, _, spellName = UnitCastingInfo("target");
	if(not spell) then
		spell, _, spellName = UnitChannelInfo("target");
	end

	frame.CastBar.Name:SetText(spellName)
	frame.CastBar.Icon.texture:SetTexture(self.Icon:GetTexture());
	frame.CastBar:SetStatusBarColor(color.r, color.g, color.b);
end

function mod:UpdateElement_CastBarOnShow()
	self:GetParent().CastBar:Show();
end

function mod:UpdateElement_CastBarOnHide()
	self:GetParent().CastBar:Hide();
end

function mod:ConfigureElement_CastBar(frame)
	local castBar = frame.CastBar;

	castBar:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, -self.db.castBar.offset);
	castBar:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, -self.db.castBar.offset);
	castBar:SetHeight(self.db.castBar.height);

	castBar.Icon:SetPoint("TOPLEFT", frame.HealthBar, "TOPRIGHT", self.db.castBar.offset, 0);
	castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", self.db.castBar.offset, 0);
	castBar.Icon:SetWidth(self.db.castBar.height + self.db.healthBar.height + E.Border + E.Spacing*3);

	castBar.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
	castBar.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);

	if (self.db.castBar.hideSpellName) then
		castBar.Name:Hide()
	else
		castBar.Name:Show()
	end
	if (self.db.castBar.hideTime) then
		castBar.Time:Hide()
	else
		castBar.Time:Show()
	end

	castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar));

	castBar.castTimeFormat = self.db.castBar.castTimeFormat;
	castBar.channelTimeFormat = self.db.castBar.channelTimeFormat;
end

function mod:ConstructElement_CastBar(parent)
	local frame = CreateFrame("StatusBar", nil, parent);
	frame:SetFrameStrata("BACKGROUND");
	self:StyleFrame(frame);

	frame.Icon = CreateFrame("Frame", nil, frame);
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER");
	frame.Icon.texture:SetAllPoints();
	frame.Icon.texture:SetTexCoord(unpack(E.TexCoords));
	self:StyleFrame(frame.Icon, true);

	frame.Time = frame:CreateFontString(nil, "OVERLAY");
	frame.Time:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -E.Border*3);
	frame.Time:SetJustifyH("RIGHT");
	frame.Time:SetJustifyV("TOP");
	frame.Time:SetWordWrap(false);

	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Name:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -E.Border*3)
	frame.Name:SetPoint("TOPRIGHT", frame.Time, "TOPLEFT")
	frame.Name:SetJustifyH("LEFT")
	frame.Name:SetJustifyV("TOP")
	frame.Name:SetWordWrap(false)

	frame.Spark = frame:CreateTexture(nil, "OVERLAY");
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]);
	frame.Spark:SetBlendMode("ADD");
	frame.Spark:SetSize(15, 15);
	frame:Hide();
	return frame;
end
