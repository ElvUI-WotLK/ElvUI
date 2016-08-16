local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");
local LSM = LibStub("LibSharedMedia-3.0");

local CreateFrame = CreateFrame;

function mod:ConstructElement_Glow(frame)
	local f = CreateFrame("Frame", nil, frame);
	f:SetFrameLevel(0);
	f:SetFrameStrata("BACKGROUND");
	f:SetOutside(frame.HealthBar, 3, 3);
	f:SetBackdrop({
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(3),
		insets = {left = E:Scale(5), right = E:Scale(5), top = E:Scale(5), bottom = E:Scale(5)}
	});

	f:SetScale(E.PixelMode and 1.5 or 2);
	f:Hide();
	return f;
end