local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables

function NP:Update_Elite(frame)
	local db = self.db.units[frame.UnitType].eliteIcon
	if not db then return end

	local icon = frame.Elite
	if db.enable then
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

function NP:Configure_Elite(frame)
	local db = self.db.units[frame.UnitType].eliteIcon
	if not db then return end

	local icon = frame.Elite

	icon:Size(db.size)
	icon:ClearAllPoints()

	if frame.Health:IsShown() then
		icon:SetParent(frame.Health)
		icon:Point(db.position, frame.Health, db.position, db.xOffset, db.yOffset)
	else
		icon:SetParent(frame)
		icon:Point(db.position, frame, db.position, db.xOffset, db.yOffset)
	end
end

function NP:Construct_Elite(frame)
	local icon = frame.Health:CreateTexture(nil, "OVERLAY")
	icon:SetTexture(E.Media.Textures.Nameplates)
	icon:Hide()

	return icon
end