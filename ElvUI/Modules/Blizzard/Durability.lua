local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

--Lua functions
--WoW API / Variables

function B:PositionDurabilityFrame()
	DurabilityFrame:SetFrameStrata("HIGH")
	DurabilityFrame:SetScale(0.6)

	DurabilityWeapon:Point("RIGHT", DurabilityWrists, "LEFT", 6, 0)
	DurabilityShield:Point("LEFT", DurabilityWrists, "RIGHT", -6, 10)
	DurabilityOffWeapon:Point("LEFT", DurabilityWrists, "RIGHT", -6, 0)
	DurabilityRanged:Point("TOP", DurabilityShield, "BOTTOM", -1, 0)

	hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, point)
		if point ~= Minimap then
			self:ClearAllPoints()

			if DurabilityShield:IsShown() or DurabilityOffWeapon:IsShown() or DurabilityRanged:IsShown() then
				self:Point("RIGHT", Minimap, "RIGHT", -7, 0)
			else
				self:Point("RIGHT", Minimap, "RIGHT", 8, 0)
			end
		end
	end)
end