local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
--WoW API / Variables

function NP:UpdateElement_Highlight(frame)
	if frame.isMouseover and (frame.NameOnlyChanged or (not self.db.units[frame.UnitType].healthbar.enable and self.db.units[frame.UnitType].showName)) and not frame.isTarget then
		frame.Name.NameOnlyGlow:Show()
		frame.HealthBar.Highlight:Show()
	elseif frame.isMouseover and (not frame.NameOnlyChanged or self.db.units[frame.UnitType].healthbar.enable) and not frame.isTarget then
		frame.HealthBar.Highlight:ClearAllPoints()
		frame.HealthBar.Highlight:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT")
		frame.HealthBar.Highlight:SetPoint("BOTTOMRIGHT", frame.HealthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
		frame.HealthBar.Highlight:Show()
	else
		frame.Name.NameOnlyGlow:Hide()
		frame.HealthBar.Highlight:Hide()
	end
end

function NP:ConfigureElement_Highlight(frame)
	if not self.db.units[frame.UnitType].healthbar.enable then return end
	frame.HealthBar.Highlight:SetTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function NP:ConstructElement_Highlight(frame)
	frame.HealthBar.Highlight = frame.HealthBar:CreateTexture("$parentHighlight", "OVERLAY")
	frame.HealthBar.Highlight:SetVertexColor(1, 1, 1, 0.3)
	frame.HealthBar.Highlight:Hide()
end