local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

S:RegisterSkin('Blizzard_GlyphUI', function()
	if(E.private.skins.blizzard.enable ~= true
		or E.private.skins.blizzard.talent ~= true)
	then
		return;
	end
	
	GlyphFrame:CreateBackdrop('Default');
	GlyphFrame.backdrop:Point('TOPLEFT', 13, -12);
	GlyphFrame.backdrop:Point('BOTTOMRIGHT', -31, 76);
	
	GlyphFrame:StripTextures();
end);