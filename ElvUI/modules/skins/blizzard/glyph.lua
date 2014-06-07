local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end
	
	GlyphFrame:StripTextures();
	
	hooksecurefunc('GlyphFrameGlyph_UpdateSlot', function(self)
		self.glyph:SetTexCoord(unpack(E.TexCoords));
		self.setting:Hide();
		self.highlight:SetTexture('');
		self.background:Hide();
		self.ring:Hide();
		
		if not self.backdrop then
			self:CreateBackdrop('Default', true);
			self.backdrop:SetOutside(self.glyph);
		end
	end);
	
	hooksecurefunc('GlyphFrameGlyph_OnUpdate', function(self)
		local id = self:GetID();
		
		if GlyphMatchesSocket(id) then
			self.backdrop:SetBackdropBorderColor(unpack(E['media'].rgbvaluecolor));
		else
			self.backdrop:SetBackdropBorderColor(0, 0, 0);
		end
	end);
end

S:RegisterSkin("Blizzard_GlyphUI", LoadSkin)