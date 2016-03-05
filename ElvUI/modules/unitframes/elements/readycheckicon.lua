local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local CreateFrame = CreateFrame;

function UF:Construct_ReadyCheckIcon(frame)
	local f = CreateFrame("FRAME", nil, frame);
	f:SetFrameStrata("HIGH");
	f:SetFrameLevel(100);
	
	local tex = f:CreateTexture(nil, "OVERLAY");
	tex:Size(12);
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2);
	
	return tex;
end

function UF:Configure_ReadyCheckIcon(frame)
	if(not frame:IsElementEnabled("ReadyCheck")) then
		frame:EnableElement("ReadyCheck");
	end
end