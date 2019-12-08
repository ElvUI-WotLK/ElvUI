local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables

function NP:Update_IconFrame(frame)
	local db = self.db.units[frame.UnitType].iconFrame
	if not db then return end

	if db.enable or frame.IconOnlyChanged then
		local icon = G.nameplates.totemList[frame.UnitName]
		if icon then
			local icon2 = NP.TriggerConditions.totems[icon][3]
			if icon2 then
				frame.IconFrame.texture:SetTexture(icon2)
				frame.IconFrame:Show()
			else
				frame.IconFrame:Hide()
			end
		end
	end
end

function NP:Configure_IconFrame(frame)
	local db = self.db.units[frame.UnitType].iconFrame
	if db and db.enable then
		frame.IconFrame:SetSize(db.size, db.size)
		frame.IconFrame:ClearAllPoints()
		frame.IconFrame:SetPoint(E.InversePoints[db.position], db.parent == "Nameplate" and frame or frame[db.parent], db.position, db.xOffset, db.yOffset)
	else
		frame.IconFrame:Hide()
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