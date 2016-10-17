local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule('UnitFrames');

function UF:Construct_PvPIcon(frame)
	local PvP = frame.RaisedElementParent:CreateTexture(nil, 'ARTWORK')
	PvP:SetSize(30, 30)
	PvP:SetPoint('CENTER', frame, 'CENTER')

	return PvP
end

function UF:Configure_PVPIcon(frame)
	local PvP = frame.PvP
	PvP:ClearAllPoints()
	PvP:Point(frame.db.pvpIcon.anchorPoint, frame.Health, frame.db.pvpIcon.anchorPoint, frame.db.pvpIcon.xOffset, frame.db.pvpIcon.yOffset)

	local scale = frame.db.pvpIcon.scale or 1
	PvP:Size(30 * scale)
	
	if frame.db.pvpIcon.enable and not frame:IsElementEnabled('PvP') then
		frame:EnableElement('PvP')
	elseif not frame.db.pvpIcon.enable and frame:IsElementEnabled('PvP') then
		frame:DisableElement('PvP')
		PvP:Hide();
	end
end