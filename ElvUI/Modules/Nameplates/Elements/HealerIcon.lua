local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables

function NP:Update_HealerIcon(frame)
	local icon = frame.HealerIcon
	if frame.UnitType == "ENEMY_PLAYER" and self.Healers[frame.UnitName] then
		icon:ClearAllPoints()
		if frame.Health:IsShown() then
			icon:SetPoint("RIGHT", frame.Health, "LEFT", -6, 0)
		else
			icon:SetPoint("BOTTOM", frame.Name, "TOP", 0, 3)
		end

		icon:Show()
	else
		icon:Hide()
	end
end

function NP:Construct_HealerIcon(frame)
	local texture = frame:CreateTexture(nil, "OVERLAY")
	texture:SetPoint("RIGHT", frame.Health, "LEFT", -6, 0)
	texture:SetSize(40, 40)
	texture:SetTexture(E.Media.Textures.Healer)
	texture:Hide()

	return texture
end