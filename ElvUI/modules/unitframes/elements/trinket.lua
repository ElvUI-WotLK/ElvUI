local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local CreateFrame = CreateFrame;

function UF:Construct_Trinket(frame)
	local trinket = CreateFrame("Frame", nil, frame);
	trinket.bg = CreateFrame("Frame", nil, trinket);
	trinket.bg:SetTemplate("Default");
	trinket.bg:SetFrameLevel(trinket:GetFrameLevel() - 1);
	trinket:SetInside(trinket.bg);
	
	return trinket;
end