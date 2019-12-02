local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local GetComboPoints = GetComboPoints
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function NP:Update_CPoints(frame)
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end
	if not self.db.units.TARGET.comboPoints.enable then return end

	local numPoints
	if frame.isTarget then
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

function NP:Configure_CPointsScale(frame, scale, noPlayAnimation)
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end
	local db = self.db.units.TARGET.comboPoints
	if not db.enable then return end

	if noPlayAnimation then
		frame.CPoints:SetWidth(((db.width * 5) + (db.spacing * 4)) * scale)
		frame.CPoints:SetHeight(db.height * scale)
	else
		if frame.CPoints.scale:IsPlaying() then
			frame.CPoints.scale:Stop()
		end

		frame.CPoints.scale.width:SetChange(((db.width * 5) + (db.spacing * 4)) * scale)
		frame.CPoints.scale.height:SetChange(db.height * scale)
		frame.CPoints.scale:Play()
	end
end

function NP:Configure_CPoints(frame, configuring)
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end
	local db = self.db.units.TARGET.comboPoints
	if not db.enable then return end

	local comboBar = frame.CPoints
	local healthShown = self.db.units[frame.UnitType].health.enable or (frame.isTarget and self.db.alwaysShowTargetHealth)

	comboBar:ClearAllPoints()
	if healthShown then
		comboBar:Point("CENTER", frame.Health, "BOTTOM", db.xOffset, db.yOffset)
	else
		comboBar:Point("CENTER", frame, "TOP", db.xOffset, db.yOffset)
	end

	for i = 1, MAX_COMBO_POINTS do
		local comboPoint = comboBar[i]
		comboPoint.backdrop:SetTexture(LSM:Fetch("statusbar", self.db.statusbar))
		local color = self.db.colors.comboPoints[i]
		comboPoint.backdrop:SetVertexColor(color.r, color.g, color.b)

		comboPoint:SetWidth(db.width)

		comboPoint:ClearAllPoints()
		if i == 1 then
			comboPoint:SetPoint("TOPLEFT")
			comboPoint:SetPoint("BOTTOMLEFT")
		else
			comboPoint:SetPoint("TOPLEFT", comboBar[i - 1], "TOPRIGHT", db.spacing, 0)
			comboPoint:SetPoint("BOTTOMLEFT", comboBar[i - 1], "BOTTOMRIGHT")
		end
	end

	comboBar.spacing = db.spacing * (MAX_COMBO_POINTS - 1)

	if configuring then
		self:Configure_CPointsScale(frame, frame.currentScale or 1, configuring)
	end
end

local function CPoints_OnSizeChanged(self, width)
	width = width - self.spacing
	for i = 1, MAX_COMBO_POINTS do
		self[i]:SetWidth(width * 0.2)
	end
end

function NP:Construct_CPoints(parent)
	local comboBar = CreateFrame("Frame", "$parentComboPoints", parent)
	comboBar:Hide()

	comboBar.scale = CreateAnimationGroup(comboBar)
	comboBar.scale.width = comboBar.scale:CreateAnimation("Width")
	comboBar.scale.width:SetDuration(0.2)
	comboBar.scale.height = comboBar.scale:CreateAnimation("Height")
	comboBar.scale.height:SetDuration(0.2)

	comboBar:SetScript("OnSizeChanged", CPoints_OnSizeChanged)

	for i = 1, MAX_COMBO_POINTS do
		comboBar[i] = CreateFrame("Frame", "$parentComboPoint"..i, comboBar)
		self:StyleFrame(comboBar[i])
	end

	return comboBar
end