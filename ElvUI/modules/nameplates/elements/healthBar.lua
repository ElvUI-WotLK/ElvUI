local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

function mod:ConfigureElement_HealthBar(frame, configuring)
	local healthBar = frame.HealthBar;
	
	healthBar:SetPoint("BOTTOM", frame, "BOTTOM", 0, self.db.castBar.height + 3);
	if(frame.isTarget) then
		healthBar:SetHeight(self.db.healthBar.height * self.db.targetScale);
		healthBar:SetWidth(self.db.healthBar.width * self.db.targetScale);
	else
		healthBar:SetHeight(self.db.healthBar.height);
		healthBar:SetWidth(self.db.healthBar.width);
	end
end

function mod:ConstructElement_HealthBar(parent)
	local frame = CreateFrame("StatusBar", nil, parent);
	self:CreateBackdrop(frame);

	frame.text = frame:CreateFontString(nil, "OVERLAY");
	frame.text:SetAllPoints(frame);
	frame.text:SetWordWrap(false);
	frame.scale = CreateAnimationGroup(frame);
	
	frame.scale.width = frame.scale:CreateAnimation("Width");
	frame.scale.width:SetDuration(0.2);
	frame.scale.height = frame.scale:CreateAnimation("Height");
	frame.scale.height:SetDuration(0.2);
	return frame;
end