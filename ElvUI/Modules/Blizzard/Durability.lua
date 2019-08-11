local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

--Lua functions
--WoW API / Variables

local function SetPosition(self, _, parent)
	if parent == "MinimapCluster" or parent == MinimapCluster then
		self:ClearAllPoints()
		self:Point("RIGHT", Minimap, "RIGHT")
		self:SetScale(0.6)
	end
end

function B:PositionDurabilityFrame()
	DurabilityFrame:SetFrameStrata("HIGH")

	hooksecurefunc(DurabilityFrame, "SetPoint", SetPosition)
end