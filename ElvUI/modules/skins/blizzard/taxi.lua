local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

S:RegisterSkin("ElvUI", function()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true) then return; end

	TaxiFrame:CreateBackdrop("Transparent");
	TaxiFrame.backdrop:Point("TOPLEFT", 11, -12);
	TaxiFrame.backdrop:Point("BOTTOMRIGHT", -34, 75);

	TaxiFrame:StripTextures();

	TaxiPortrait:Kill();

	S:HandleCloseButton(TaxiCloseButton);

	TaxiRouteMap:CreateBackdrop("Default");
end);