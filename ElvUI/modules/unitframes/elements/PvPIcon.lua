local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

function UF:Construct_PvPIcon(frame)
	local PvPIndicator = frame.RaisedElementParent:CreateTexture(nil, "ARTWORK")
	PvPIndicator:SetSize(30, 30)
	PvPIndicator:SetPoint("CENTER", frame, "CENTER")

	return PvPIndicator
end

function UF:Configure_PVPIcon(frame)
	local PvPIndicator = frame.PvPIndicator
	PvPIndicator:ClearAllPoints()
	PvPIndicator:Point(frame.db.pvpIcon.anchorPoint, frame.Health, frame.db.pvpIcon.anchorPoint, frame.db.pvpIcon.xOffset, frame.db.pvpIcon.yOffset)

	local scale = frame.db.pvpIcon.scale or 1
	PvPIndicator:Size(30 * scale)

	if frame.db.pvpIcon.enable and not frame:IsElementEnabled("PvPIndicator") then
		frame:EnableElement("PvPIndicator")
	elseif not frame.db.pvpIcon.enable and frame:IsElementEnabled("PvPIndicator") then
		frame:DisableElement("PvPIndicator")
		PvPIndicator:Hide();
	end
end