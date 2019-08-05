local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local unpack = unpack

local GetComboPoints = GetComboPoints
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function NP:UpdateElement_CPoints(frame)
	if not frame.UnitType then return end
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end
	if self.db.units[frame.UnitType].comboPoints.enable ~= true then return end

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

function NP:ConfigureElement_CPoints(frame)
	if not frame.UnitType then return end
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end

	local comboPoints = frame.CPoints
	local healthShown = self.db.units[frame.UnitType].healthbar.enable or (frame.isTarget and self.db.alwaysShowTargetHealth)

	comboPoints:ClearAllPoints()
	if healthShown then
		comboPoints:Point("CENTER", frame.HealthBar, "BOTTOM", self.db.units[frame.UnitType].comboPoints.xOffset, self.db.units[frame.UnitType].comboPoints.yOffset)
	else
		comboPoints:Point("CENTER", frame, "TOP", self.db.units[frame.UnitType].comboPoints.xOffset, self.db.units[frame.UnitType].comboPoints.yOffset)
	end

	local width, height
	for i = 1, MAX_COMBO_POINTS do
		comboPoints[i]:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
		comboPoints[i]:SetStatusBarColor(unpack(E:GetColorTable(self.db.comboBar.colors[i])))

		if i == 3 then
			comboPoints[i]:Point("CENTER", comboPoints, "CENTER")
		elseif i == 1 or i == 2 then
			comboPoints[i]:Point("RIGHT", comboPoints[i + 1], "LEFT", -self.db.units[frame.UnitType].comboPoints.spacing, 0)
		else
			comboPoints[i]:Point("LEFT", comboPoints[i - 1], "RIGHT", self.db.units[frame.UnitType].comboPoints.spacing, 0)
		end

		width = self.db.units[frame.UnitType].comboPoints.width
		height = self.db.units[frame.UnitType].comboPoints.height

		comboPoints[i]:Width(healthShown and width * (frame.ThreatScale or 1) * (self.db.useTargetScale and self.db.targetScale or 1) or width)
		comboPoints[i]:Height(healthShown and height * (frame.ThreatScale or 1) * (self.db.useTargetScale and self.db.targetScale or 1) or height)
	end
end

function NP:ConstructElement_CPoints(parent)
	local comboBar = CreateFrame("Frame", "$parentComboPoints", parent)
	comboBar:SetSize(68, 1)
	comboBar:Hide()

	for i = 1, MAX_COMBO_POINTS do
		comboBar[i] = CreateFrame("StatusBar", comboBar:GetName().."ComboPoint"..i, comboBar)

		self:StyleFrame(comboBar[i])
	end

	return comboBar
end