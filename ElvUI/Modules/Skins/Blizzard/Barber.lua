local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallbackForAddon("Blizzard_BarbershopUI", "Skin_Blizzard_BarbershopUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.barber then return end

	BarberShopFrame:CreateBackdrop("Transparent")
	BarberShopFrame.backdrop:Point("TOPLEFT", 44, -70)
	BarberShopFrame.backdrop:Point("BOTTOMRIGHT", -38, 42)

	S:SetBackdropHitRect(BarberShopFrame)

	BarberShopFrameBackground:Kill()

	for i = 1, 4 do
		S:HandleNextPrevButton(_G["BarberShopFrameSelector"..i.."Prev"])
		S:HandleNextPrevButton(_G["BarberShopFrameSelector"..i.."Next"])
	end

	BarberShopFrameMoneyFrame:StripTextures()
	BarberShopFrameMoneyFrame:CreateBackdrop()

	S:HandleButton(BarberShopFrameOkayButton)
	S:HandleButton(BarberShopFrameCancelButton)
	S:HandleButton(BarberShopFrameResetButton)
end)