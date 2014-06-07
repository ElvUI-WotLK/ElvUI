local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	TaxiPortrait:Kill();

	TaxiFrame:StripTextures();
	TaxiFrame:CreateBackdrop('Transparent');
	TaxiFrame.backdrop:Point('TOPLEFT', 10, -12);
	TaxiFrame.backdrop:Point('BOTTOMRIGHT', -33, 76);

	TaxiRouteMap:CreateBackdrop('Default');

	S:HandleCloseButton(TaxiCloseButton);
end

S:RegisterSkin('ElvUI', LoadSkin);