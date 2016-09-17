local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");
local LSM = LibStub("LibSharedMedia-3.0");

function mod:UpdateElement_HealthOnValueChanged(value)
	local frame = self:GetParent();
	local min, max = self:GetMinMaxValues();
	frame.HealthBar:SetMinMaxValues(min, max);
	--frame.HealthBar:SetValue(value);

	if(frame.HealthBar.currentValue ~= value) then
		if(frame.HealthBar.anim.progress:IsPlaying()) then
			frame.HealthBar.anim.progress:Stop()
		end
		frame.HealthBar.anim.progress:SetChange(value);
		frame.HealthBar.anim.progress:Play();
		frame.HealthBar.currentValue = value;
	end

	local r, g, b, shouldShow;
	local perc = value/max;
	if(perc <= mod.db.lowHealthThreshold) then
		if(perc <= mod.db.lowHealthThreshold / 2) then
			r, g, b = 1, 0, 0;
		else
			r, g, b = 1, 1, 0;
		end
		shouldShow = true;
	end

	if(shouldShow) then
		frame.Glow:Show();
		if((r ~= frame.Glow.r or g ~= frame.Glow.g or b ~= frame.Glow.b)) then
			frame.Glow:SetBackdropBorderColor(r, g, b);
			frame.Glow.r, frame.Glow.g, frame.Glow.b = r, g, b;
		end
	elseif(frame.Glow:IsShown()) then
		frame.Glow:Hide();
	end

	if(mod.db.healthBar.text.enable and value and max and max > 1 and self:GetScale() == 1) then
		frame.HealthBar.text:SetText(E:GetFormattedText(mod.db.healthBar.text.format, value, max));
	else
		frame.HealthBar.text:SetText("");
	end

	if(mod.db.colorNameByValue) then
		frame.Name:SetTextColor(E:ColorGradient(perc, 1,0,0, 1,1,0, 1,1,1));
	end
end

function mod:ConfigureElement_HealthBar(frame, customScale)
	local healthBar = frame.HealthBar;

	healthBar:SetPoint("BOTTOM", frame, "BOTTOM", 0, self.db.castBar.height + 3);
	if(not customScale) then
		healthBar:SetHeight(self.db.healthBar.height);
		healthBar:SetWidth(self.db.healthBar.width);
	end

	healthBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar));
	healthBar.text:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
	healthBar.anim.progress:SetDuration(self.db.healthAnimationSpeed);
end

function mod:ConstructElement_HealthBar(parent)
	local frame = CreateFrame("StatusBar", nil, parent);
	frame:SetFrameStrata("BACKGROUND");
	self:StyleFrame(frame);
	frame.anim = CreateAnimationGroup(frame);
	frame.anim.progress = frame.anim:CreateAnimation("Progress");
	frame.anim.progress:SetSmoothing("Out");
	frame.text = frame:CreateFontString(nil, "OVERLAY");
	frame.text:SetAllPoints(frame);
	frame.text:SetWordWrap(false);
	return frame;
end