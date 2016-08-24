local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");

function mod:ConstructElement_HealerIcon(frame)
	local texture = frame:CreateTexture(nil, "OVERLAY");
	texture:SetPoint("RIGHT", frame.HealthBar, "LEFT", -6, 0);
	texture:SetSize(40, 40);
	texture:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer.tga]]);
	texture:Hide();

	return texture;
end