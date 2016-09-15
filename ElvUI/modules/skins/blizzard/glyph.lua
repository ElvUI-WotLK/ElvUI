local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true) then return; end

	GlyphFrame:StripTextures();

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