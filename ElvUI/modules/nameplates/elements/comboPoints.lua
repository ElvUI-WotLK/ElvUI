local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");

local GetComboPoints = GetComboPoints;
local UnitHasVehicleUI = UnitHasVehicleUI;
local MAX_COMBO_POINTS = MAX_COMBO_POINTS;

function mod:ToggleComboPoints()
	if(self.db.comboPoints) then
		self:RegisterEvent("UNIT_COMBO_POINTS");
	else
		self:ForEachPlate("HideComboPoints");
		self:UnregisterEvent("UNIT_COMBO_POINTS");
	end
end

function mod:HideComboPoints()
	for i = 1, MAX_COMBO_POINTS do
		self.CPoints[i]:Hide();
	end
end

function mod:UpdateElement_CPoints(frame)
	if(not self.db.comboPoints) then return; end

	local numPoints = mod.ComboPoints[frame.guid];
	if(not numPoints) then
		for i = 1, MAX_COMBO_POINTS do
			frame.CPoints[i]:Hide();
		end
		return;
	end

	for i = 1, MAX_COMBO_POINTS do
		if(i <= numPoints) then
			frame.CPoints[i]:Show();
		else
			frame.CPoints[i]:Hide();
		end
	end
end

function mod:UpdateElement_CPointsByUnitID(unitID)
	local guid = UnitGUID(unitID);
	if(not guid) then return; end
	self.ComboPoints[guid] = GetComboPoints(UnitHasVehicleUI("player") and "vehicle" or "player", unitID);

	local frame = self:SearchForFrame(guid);
	if(frame) then
		self:UpdateElement_CPoints(frame);
	end
end

function mod:ConfigureElement_CPoints(frame)
	if(self.db.comboPoints and not frame.CPoints:IsShown()) then
		frame.CPoints:Show();
	elseif(frame.CPoints:IsShown()) then
		frame.CPoints:Hide();
	end
end

function mod:ConstructElement_CPoints(parent)
	local frame = CreateFrame("Frame", nil, parent.HealthBar);
	frame:Point("CENTER", parent.HealthBar, "BOTTOM");
	frame:SetSize(68, 1);
	frame:Hide();

	for i = 1, MAX_COMBO_POINTS do
		frame[i] = frame:CreateTexture(nil, "OVERLAY");
		frame[i]:SetTexture([[Interface\AddOns\ElvUI\media\textures\bubbleTex.tga]]);
		frame[i]:SetSize(12, 12);
		frame[i]:SetVertexColor(unpack(self.ComboColors[i]));

		if(i == 1) then
			frame[i]:SetPoint("LEFT", frame, "TOPLEFT")
		else
			frame[i]:SetPoint("LEFT", frame[i-1], "RIGHT", 2, 0)
		end

		frame[i]:Hide();
	end
	return frame;
end