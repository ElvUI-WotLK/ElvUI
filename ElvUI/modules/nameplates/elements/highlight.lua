local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

function mod:UpdateElement_Highlight(frame)
	if frame:IsShown() and frame.isMouseover and (frame.NameOnlyChanged or (not self.db.units[frame.UnitType].healthbar.enable and self.db.units[frame.UnitType].showName)) and not frame.isTarget then
		frame.Name.NameOnlyGlow:Show()
		frame.Highlight:Show()
	elseif frame:IsShown() and frame.isMouseover and (not frame.NameOnlyChanged or self.db.units[frame.UnitType].healthbar.enable) and not frame.isTarget then
		frame.Highlight.texture:ClearAllPoints()
		frame.Highlight.texture:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT")
		frame.Highlight.texture:SetPoint("BOTTOMRIGHT", frame.HealthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
		frame.Highlight.texture:Show()
		frame.Highlight:Show()
	else
		frame.Name.NameOnlyGlow:Hide()
		frame.Highlight.texture:Hide()
		frame.Highlight:Hide()
	end
end

function mod:ConfigureElement_Highlight(frame)
	if not self.db.units[frame.UnitType].healthbar.enable then return end
	frame.Highlight.texture:SetTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function mod:ConstructElement_Highlight(frame)
	local f = CreateFrame("Frame", nil, frame)
	f.texture = frame.HealthBar:CreateTexture(nil, "ARTWORK")
	f.texture:SetVertexColor(1, 1, 1, 0.3)
	f.texture:Hide()

	f:HookScript("OnHide", function()
		frame.Name.NameOnlyGlow:Hide()
		frame.Highlight.texture:Hide()
	end)

	return f
end