local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables

function NP:Update_RaidIcon(frame)
	local icon = frame.RaidIcon
	icon:ClearAllPoints()
	if frame.Health:IsShown() then
		icon:SetPoint("RIGHT", frame.Health, "LEFT", -6, 0)
	else
		icon:SetPoint("BOTTOM", frame.Name, "TOP", 0, 3)
	end
end