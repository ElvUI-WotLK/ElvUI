local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");

function mod:ConfigureElement_RaidIcon(frame)
	frame.RaidIcon:ClearAllPoints();
	frame.RaidIcon:SetPoint(E.InversePoints[self.db.raidIcon.attachTo], frame.HealthBar, self.db.raidIcon.attachTo, self.db.raidIcon.xOffset, self.db.raidIcon.yOffset);
	frame.RaidIcon:SetSize(self.db.raidIcon.size, self.db.raidIcon.size);
end

function mod:ConstructElement_RaidIcon(frame)
	local texture = frame:CreateTexture(nil, "OVERLAY");
	texture:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]]);
	texture:Hide();
	return texture;
end