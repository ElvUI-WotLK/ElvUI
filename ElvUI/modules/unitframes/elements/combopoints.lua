local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local CreateFrame = CreateFrame;
local UnitHasVehicleUI = UnitHasVehicleUI;
local GetComboPoints = GetComboPoints;
local MAX_COMBO_POINTS = MAX_COMBO_POINTS;

function UF:Construct_Combobar(frame)
	local CPoints = CreateFrame("Frame", nil, frame);
	CPoints:CreateBackdrop("Default", nil, nil, UF.thinBorders);
	CPoints.Override = UF.UpdateComboDisplay;
	CPoints.origParent = frame;
	
	for i = 1, MAX_COMBO_POINTS do
		CPoints[i] = CreateFrame("StatusBar", frame:GetName() .. "ComboBarButton" .. i, CPoints);
		UF["statusbars"][CPoints[i]] = true;
		CPoints[i]:SetStatusBarTexture(E["media"].blankTex);
		CPoints[i]:GetStatusBarTexture():SetHorizTile(false);
		CPoints[i]:SetAlpha(0.15);
		CPoints[i]:CreateBackdrop("Default", nil, nil, UF.thinBorders);
		CPoints[i].backdrop:SetParent(CPoints);
	end
	
	CPoints:SetScript("OnShow", UF.ToggleResourceBar);
	CPoints:SetScript("OnHide", UF.ToggleResourceBar);
	
	return CPoints;
end

function UF:Configure_ComboPoints(frame)
	local CPoints = frame.CPoints;
	CPoints:ClearAllPoints();
	local db = frame.db;
	if(not frame.CLASSBAR_DETACHED) then
		CPoints:SetParent(frame);
	else
		CPoints:SetParent(E.UIParent);
	end
	
	if((not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7) then
		frame.CLASSBAR_HEIGHT = 7;
		if(db.combobar) then db.combobar.height = 7; end
		UF.ToggleResourceBar(CPoints);
	elseif((self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3) then
		frame.CLASSBAR_HEIGHT = 3;
		if(db.combobar) then db.combobar.height = 3; end
		UF.ToggleResourceBar(CPoints);
	end
	
	if(not frame.USE_CLASSBAR) then
		CPoints:Hide();
	end
	
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH;
	if(frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED) then
		CPoints:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0);
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR;
		CPoints:SetFrameStrata("MEDIUM");
		if(CPoints.Holder and CPoints.Holder.mover) then
			E:DisableMover(CPoints.Holder.mover:GetName());
		end
	elseif(not frame.CLASSBAR_DETACHED) then
		CPoints:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, (frame.SPACING*3));
		CPoints:SetFrameStrata("LOW");
		if(CPoints.Holder and CPoints.Holder.mover) then
			E:DisableMover(CPoints.Holder.mover:GetName());
		end
	else
		CLASSBAR_WIDTH = db.combobar.detachedWidth - ((frame.BORDER+frame.SPACING)*2);
		
		if(not CPoints.Holder or (CPoints.Holder and not CPoints.Holder.mover)) then
			CPoints.Holder = CreateFrame("Frame", nil, CPoints);
			CPoints.Holder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150);
			CPoints.Holder:Size(db.combobar.detachedWidth, db.combobar.height);
 			CPoints:Width(CLASSBAR_WIDTH);
			CPoints:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2));
 			CPoints:ClearAllPoints();
			CPoints:Point("BOTTOMLEFT", CPoints.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING);
			E:CreateMover(CPoints.Holder, "ComboBarMover", L["Combobar"], nil, nil, nil, "ALL,SOLO");
 		else
			CPoints.Holder:Size(db.combobar.detachedWidth, db.combobar.height);
 			CPoints:ClearAllPoints();
			CPoints:Point("BOTTOMLEFT", CPoints.Holder.mover, "BOTTOMLEFT", frame.BORDER+frame.SPACING, frame.BORDER+frame.SPACING);
			E:EnableMover(CPoints.Holder.mover:GetName());
 		end
		
		CPoints:SetFrameStrata("LOW");
	end
	
	CPoints:Width(CLASSBAR_WIDTH);
	CPoints:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2));
	
	for i = 1, frame.MAX_CLASS_BAR do
		CPoints[i]:SetStatusBarColor(unpack(ElvUF.colors.ComboPoints[i]));
		CPoints[i]:Height(CPoints:GetHeight());
		if(frame.USE_MINI_CLASSBAR) then
			CPoints[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR);
		elseif(i ~= MAX_COMBO_POINTS) then
			CPoints[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR-1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR);
		end
		
		CPoints[i]:ClearAllPoints();
		if(i == 1) then
			CPoints[i]:Point("LEFT", CPoints);
		else
			if(frame.USE_MINI_CLASSBAR) then
				CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", (5 + frame.BORDER*2 + frame.SPACING*2), 0);
			elseif(i == frame.MAX_CLASS_BAR) then
				CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0);
				CPoints[i]:Point("RIGHT", CPoints);
			else
				CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0);
			end
		end
		
		if(not frame.USE_MINI_CLASSBAR) then
			CPoints[i].backdrop:Hide();
		else
			CPoints[i].backdrop:Show();
		end
	end
	
	if(not frame.USE_MINI_CLASSBAR) then
		CPoints.backdrop:Show();
	else
		CPoints.backdrop:Hide();
	end
	
	if(frame.USE_CLASSBAR and not frame:IsElementEnabled("CPoints")) then
		frame:EnableElement("CPoints");
	elseif(not frame.USE_CLASSBAR and frame:IsElementEnabled("CPoints")) then
		frame:DisableElement("CPoints");
		CPoints:Hide();
	end
	
	if(not frame:IsShown()) then
		CPoints:ForceUpdate();
	end
end

function UF:UpdateComboDisplay(event, unit)
	if(unit == "pet") then return; end
	local db = self.db;
	if(not db) then return; end
	local cpoints = self.CPoints;
	local cp;
	if (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then
		cp = GetComboPoints("vehicle", "target");
	else
		cp = GetComboPoints("player", "target");
	end
	
	if(cp == 0 and db.combobar.autoHide) then
		cpoints:Hide();
		UF.ToggleResourceBar(cpoints);
	else
		cpoints:Show();
		for i = 1, MAX_COMBO_POINTS do
			if(i <= cp) then
				cpoints[i]:SetAlpha(1);
			else
				cpoints[i]:SetAlpha(.2);
			end
		end
		UF.ToggleResourceBar(cpoints);
	end
end