local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");
local LSM = LibStub("LibSharedMedia-3.0");

function mod:UpdateElement_HealthOnValueChanged(value)
	local myPlate = mod.CreatedPlates[self:GetParent()];
	local min, max = self:GetMinMaxValues();
	myPlate.HealthBar:SetMinMaxValues(min, max);
	--myPlate.HealthBar:SetValue(value);

	if(myPlate.HealthBar.currentValue ~= value) then
		if(myPlate.HealthBar.anim.progress:IsPlaying()) then
			myPlate.HealthBar.anim.progress:Stop()
		end
		myPlate.HealthBar.anim.progress:SetChange(value);
		myPlate.HealthBar.anim.progress:Play();
		myPlate.HealthBar.currentValue = value;
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
		myPlate.Glow:Show();
		if((r ~= myPlate.Glow.r or g ~= myPlate.Glow.g or b ~= myPlate.Glow.b)) then
			myPlate.Glow:SetBackdropBorderColor(r, g, b);
			myPlate.Glow.r, myPlate.Glow.g, myPlate.Glow.b = r, g, b;
		end
	elseif(myPlate.Glow:IsShown()) then
		myPlate.Glow:Hide();
	end

	if(mod.db.healthBar.text.enable and value and max and max > 1 and self:GetScale() == 1) then
		myPlate.HealthBar.text:SetText(E:GetFormattedText(mod.db.healthBar.text.format, value, max));
	else
		myPlate.HealthBar.text:SetText("");
	end

	if(mod.db.colorNameByValue) then
		myPlate.Name:SetTextColor(E:ColorGradient(perc, 1,0,0, 1,1,0, 1,1,1));
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
end

function mod:ConstructElement_HealthBar(parent)
	local frame = CreateFrame("StatusBar", nil, parent);
	self:CreateBackdrop(frame);
	frame:SetFrameStrata("BACKGROUND");
	frame:SetFrameLevel(0);
	frame.anim = CreateAnimationGroup(frame);
	frame.anim.progress = frame.anim:CreateAnimation("Progress");
	frame.anim.progress:SetSmoothing("Out");
	frame.anim.progress:SetDuration(.3);
	frame.text = frame:CreateFontString(nil, "OVERLAY");
	frame.text:SetAllPoints(frame);
	frame.text:SetWordWrap(false);
	return frame;
end