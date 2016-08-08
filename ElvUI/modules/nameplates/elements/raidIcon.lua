local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");

function mod:UpdateElement_RaidIcon(frame)
	local icon = frame.raidIcon;
	icon:ClearAllPoints();
	icon:SetPoint(E.InversePoints[mod.db.raidIcon.attachTo], frame.healthBar, mod.db.raidIcon.attachTo, mod.db.raidIcon.xOffset, mod.db.raidIcon.yOffset);
	icon:SetSize(mod.db.raidIcon.size, mod.db.raidIcon.size);
end

function mod:ConstructElement_RaidIcon(frame)
	local texture = frame:CreateTexture(nil, "OVERLAY");
	texture:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]]);
	texture:Hide();

	return texture;
end