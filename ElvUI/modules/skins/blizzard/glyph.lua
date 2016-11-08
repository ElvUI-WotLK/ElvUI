local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local GetCVarBool = GetCVarBool;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true) then return; end

	GlyphFrame:StripTextures();

	GlyphFrame:CreateBackdrop();
	GlyphFrame.backdrop:Point("TOPLEFT", 21, -60);
	GlyphFrame.backdrop:Point("BOTTOMRIGHT", -38, 100);
	GlyphFrame.backdrop:SetBackdropBorderColor(0, 0, 0, 0);
	GlyphFrame.backdrop:CreateShadow();

	GlyphFrame.texture = GlyphFrame:CreateTexture(nil, "OVERLAY");
	GlyphFrame.texture:SetTexture("Interface\\Spellbook\\UI-GlyphFrame");
	GlyphFrame.texture:SetTexCoord(0.075, 0.630, 0.154, 0.770);
	GlyphFrame.texture:SetInside(GlyphFrame.backdrop);
	GlyphFrame.texture:SetDesaturated(true);

	for i = 1, 6 do
		_G["GlyphFrameGlyph" .. i .. "Shine"]:SetDesaturated(true);
		_G["GlyphFrameGlyph" .. i .. "Ring"]:SetDesaturated(true);
		_G["GlyphFrameGlyph" .. i .. "Setting"]:SetDesaturated(true);
	end

	GlyphFrame:HookScript("OnShow", function()
		PlayerTalentFrameTitleText:Hide();
		PlayerTalentFramePointsBar:Hide();
		PlayerTalentFrameScrollFrame:Hide();
		PlayerTalentFrameStatusFrame:Hide();
		PlayerTalentFrameActivateButton:Hide();

		local preview = GetCVarBool("previewTalents");
		if(preview) then
			PlayerTalentFramePreviewBar:Hide();
		end
	end);

	GlyphFrame:SetScript("OnHide", function()
		PlayerTalentFrameTitleText:Show();
		PlayerTalentFramePointsBar:Show();
		PlayerTalentFrameScrollFrame:Show();

		local preview = GetCVarBool("previewTalents");
		if(preview) then
			PlayerTalentFramePreviewBar:Show();
		end
	end);
end

S:AddCallbackForAddon("Blizzard_GlyphUI", "Glyph", LoadSkin);