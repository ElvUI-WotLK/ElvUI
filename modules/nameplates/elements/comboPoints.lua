local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")

local ComboColors = {
	[1] = {0.69, 0.31, 0.31},
	[2] = {0.69, 0.31, 0.31},
	[3] = {0.65, 0.63, 0.35},
	[4] = {0.65, 0.63, 0.35},
	[5] = {0.33, 0.59, 0.33}
}

local GetComboPoints = GetComboPoints
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function mod:UpdateElement_CPoints(frame)
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end

	local numPoints
	if UnitExists("target") and frame.isTarget then
		numPoints = GetComboPoints("player", "target")
	end

	if numPoints and numPoints > 0 then
		frame.CPoints:Show()
		for i = 1, MAX_COMBO_POINTS do
			if i <= numPoints then
				frame.CPoints[i]:Show()
			else
				frame.CPoints[i]:Hide()
			end
		end
	else
		frame.CPoints:Hide()
	end
end

function mod:ConfigureElement_CPoints(frame)
	if self.db.comboPoints and not frame.CPoints:IsShown() then
		frame.CPoints:Show()
	elseif frame.CPoints:IsShown() then
		frame.CPoints:Hide()
	end
end

function mod:ConstructElement_CPoints(parent)
	local frame = CreateFrame("Frame", nil, parent.HealthBar)
	frame:Point("CENTER", parent.HealthBar, "BOTTOM")
	frame:SetSize(68, 1)
	frame:Hide()

	for i = 1, MAX_COMBO_POINTS do
		frame[i] = frame:CreateTexture(nil, "OVERLAY")
		frame[i]:SetTexture([[Interface\AddOns\ElvUI\media\textures\bubbleTex.tga]])
		frame[i]:SetSize(12, 12)
		frame[i]:SetVertexColor(unpack(ComboColors[i]))

		if i == 1 then
			frame[i]:SetPoint("LEFT", frame, "TOPLEFT")
		else
			frame[i]:SetPoint("LEFT", frame[i-1], "RIGHT", 2, 0)
		end
	end
	return frame
end