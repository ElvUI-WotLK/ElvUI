local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables

function NP:UpdateElement_Elite(frame)
	if not self.db.units[frame.UnitType].eliteIcon then return end

	local icon = frame.Elite
	if self.db.units[frame.UnitType].eliteIcon.enable then
		local elite, boss = frame.EliteIcon:IsShown(), frame.BossIcon:IsShown()

		if boss then
			icon:SetTexCoord(0, 0.15, 0.62, 0.94)
			icon:Show()
		elseif elite then
			icon:SetTexCoord(0, 0.15, 0.35, 0.63)
			icon:Show()
		else
			icon:Hide()
		end
	else
		icon:Hide()
	end
end

function NP:ConfigureElement_Elite(frame)
	if not self.db.units[frame.UnitType].eliteIcon then return end

	local icon = frame.Elite
	local size = self.db.units[frame.UnitType].eliteIcon.size
	local position = self.db.units[frame.UnitType].eliteIcon.position

	icon:Size(size)
	icon:ClearAllPoints()

	if frame.HealthBar:IsShown() then
		icon:SetParent(frame.HealthBar)
		icon:Point(position, frame.HealthBar, position, self.db.units[frame.UnitType].eliteIcon.xOffset, self.db.units[frame.UnitType].eliteIcon.yOffset)
	else
		icon:SetParent(frame)
		icon:Point(position, frame, position, self.db.units[frame.UnitType].eliteIcon.xOffset, self.db.units[frame.UnitType].eliteIcon.yOffset)
	end
end

function NP:ConstructElement_Elite(frame)
	local icon = frame.HealthBar:CreateTexture(nil, "OVERLAY")
	icon:SetTexture(E.Media.Textures.Nameplates)
	icon:Hide()

	return icon
end