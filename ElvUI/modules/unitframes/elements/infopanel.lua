local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

function UF:Construct_InfoPanel(frame)
	local infoPanel = CreateFrame("Frame", nil, frame);
	infoPanel:SetFrameLevel(7);
	local thinBorders = self.thinBorders;
	infoPanel:CreateBackdrop("Default", true, nil, thinBorders, true);

	return infoPanel;
end

function UF:Configure_InfoPanel(frame)
	if(not frame.VARIABLES_SET) then return; end
	local db = frame.db;

	if(frame.USE_INFO_PANEL) then
		frame.InfoPanel:Show();
		frame.InfoPanel:ClearAllPoints();

		if(frame.ORIENTATION == "RIGHT" and not (frame.unitframeType == "arena")) then
			frame.InfoPanel:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.BORDER - frame.SPACING, frame.BORDER + frame.SPACING);
			if(frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED) then
				frame.InfoPanel:Point("TOPLEFT", frame.Power.backdrop, "BOTTOMLEFT", frame.BORDER, -(frame.SPACING*3));
			else
				frame.InfoPanel:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER, -(frame.SPACING*3));
			end
		else
			frame.InfoPanel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING);
			if(frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED) then
				frame.InfoPanel:Point("TOPRIGHT", frame.Power.backdrop, "BOTTOMRIGHT", -frame.BORDER, -(frame.SPACING*3));
			else
				frame.InfoPanel:Point("TOPRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", -frame.BORDER, -(frame.SPACING*3));
			end
		end

		local thinBorders = self.thinBorders;
		if(db.infoPanel.transparent) then
			frame.InfoPanel.backdrop:SetTemplate("Transparent", nil, nil, thinBorders, true);
		else
			frame.InfoPanel.backdrop:SetTemplate("Default", true, nil, thinBorders, true);
		end
	else
		frame.InfoPanel:Hide();
	end
end