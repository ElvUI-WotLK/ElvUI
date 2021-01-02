local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables

function NP:Update_IconFrame(frame, triggered)
	local db = self.db.units[frame.UnitType].iconFrame
	if not db then return end

	if (db and db.enable) or (frame.IconOnlyChanged or frame.IconChanged) then
		local totem, unit, icon = self.Totems[frame.UnitName], self.UniqueUnits[frame.UnitName]
		if totem then
			icon = NP.TriggerConditions.totems[totem][3]
		elseif unit then
			icon = NP.TriggerConditions.uniqueUnits[unit][3]
		end

		if icon then
			frame.IconFrame.texture:SetTexture(icon)
			frame.IconFrame:Show()

			self:StyleFrameColor(frame.IconFrame, frame.oldHealthBar:GetStatusBarColor())

			if triggered then
				frame.IconFrame:ClearAllPoints()
				frame.IconFrame:SetPoint("TOP", frame)
			end
		else
			frame.IconFrame:Hide()
		end
	else
		frame.IconFrame:Hide()
	end
end

function NP:Configure_IconFrame(frame)
	local db = self.db.units[frame.UnitType].iconFrame

	if db then
		if db.enable or frame.IconChanged then
			frame.IconFrame:SetSize(db.size, db.size)
			frame.IconFrame:ClearAllPoints()
			frame.IconFrame:SetPoint(E.InversePoints[db.position], db.parent == "Nameplate" and frame or frame[db.parent], db.position, db.xOffset, db.yOffset)
		else
			frame.IconFrame:Hide()
		end
	end
end

function NP:Construct_IconFrame(frame)
	local iconFrame = CreateFrame("Frame", nil, frame)
	iconFrame:Hide()

	iconFrame:SetSize(24, 24)
	iconFrame:SetPoint("CENTER")
	NP:StyleFrame(iconFrame, true)

	iconFrame.texture = iconFrame:CreateTexture()
	iconFrame.texture:SetAllPoints()
	iconFrame.texture:SetTexCoord(unpack(E.TexCoords))

	return iconFrame
end