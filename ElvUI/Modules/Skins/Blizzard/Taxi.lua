local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.taxi then return end

	TaxiFrame:StripTextures()

	TaxiFrame:CreateBackdrop("Transparent")
	TaxiFrame.backdrop:Point("TOPLEFT", 11, -12)
	TaxiFrame.backdrop:Point("BOTTOMRIGHT", -34, 75)

	TaxiPortrait:Kill()

	S:HandleCloseButton(TaxiCloseButton)

	TaxiRouteMap:CreateBackdrop("Default")
end

S:AddCallback("Skin_Taxi", LoadSkin)