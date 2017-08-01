local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

function UF:Construct_CombatIndicator(frame)
	local combat = frame.RaisedElementParent:CreateTexture(nil, "OVERLAY");
	combat:Size(19);
	combat:Point("CENTER", frame.Health, "CENTER", 0,6);
	combat:SetVertexColor(0.69, 0.31, 0.31);

	return combat;
end

function UF:Configure_CombatIndicator(frame)
	if(frame.db.combatIcon and not frame:IsElementEnabled("CombatIndicator")) then
		frame:EnableElement("CombatIndicator")
	elseif(not frame.db.combatIcon and frame:IsElementEnabled("CombatIndicator")) then
		frame:DisableElement("CombatIndicator");
		frame.CombatIndicator:Hide();
	end
end