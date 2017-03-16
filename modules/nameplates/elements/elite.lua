local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")

function mod:UpdateElement_Elite(frame)
	if not self.db.units[frame.UnitType].eliteIcon then return end

	local icon = frame.Elite
	if self.db.units[frame.UnitType].eliteIcon.enable then
		local elite, boss = frame.EliteIcon:IsShown(), frame.BossIcon:IsShown()
		if boss or elite then
			icon:SetTexCoord(0, 0.15, 0.35, 0.63)
			icon:Show()
		else
			icon:Hide()
		end
	else
		icon:Hide()
	end
end

function mod:ConfigureElement_Elite(frame)
	if not self.db.units[frame.UnitType].eliteIcon then return end

	local icon = frame.Elite
	local position = self.db.units[frame.UnitType].eliteIcon.position

	icon:Size(self.db.units[frame.UnitType].eliteIcon.size)
	icon:ClearAllPoints()

	if frame.HealthBar:IsShown() then
		icon:SetParent(frame.HealthBar)
		icon:Point(position, frame.HealthBar, position, self.db.units[frame.UnitType].eliteIcon.xOffset, self.db.units[frame.UnitType].eliteIcon.yOffset)
	else
		icon:SetParent(frame)
		icon:Point(position, frame, position, self.db.units[frame.UnitType].eliteIcon.xOffset, self.db.units[frame.UnitType].eliteIcon.yOffset)
	end
end

function mod:ConstructElement_Elite(frame)
	local icon = frame.HealthBar:CreateTexture(nil, "OVERLAY")
	icon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\nameplates")
	icon:Hide()

	return icon
end