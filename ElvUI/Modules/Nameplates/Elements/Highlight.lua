local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
--WoW API / Variables

function NP:Update_Highlight(frame)
	if not NP.db.highlight then return end

	if frame.isMouseover and ((frame.IconOnlyChanged or frame.NameOnlyChanged) or (not self.db.units[frame.UnitType].health.enable and self.db.units[frame.UnitType].name.enable)) and not frame.isTarget then
		frame.Name.NameOnlyGlow:Show()
		frame.Health.Highlight:Show()
	elseif frame.isMouseover and (not frame.NameOnlyChanged or self.db.units[frame.UnitType].health.enable) and not frame.isTarget then
		frame.Health.Highlight:Show()
	else
		frame.Name.NameOnlyGlow:Hide()
		frame.Health.Highlight:Hide()
	end
end

function NP:Configure_Highlight(frame)
	frame.Health.Highlight:ClearAllPoints()
	frame.Health.Highlight:SetPoint("TOPLEFT", frame.Health, "TOPLEFT")
	frame.Health.Highlight:SetPoint("BOTTOMRIGHT", frame.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
	frame.Health.Highlight:SetTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function NP:Construct_Highlight(frame)
	local highlight = frame.Health:CreateTexture("$parentHighlight", "OVERLAY")
	highlight:SetVertexColor(1, 1, 1, 0.3)
	highlight:Hide()
	return highlight
end