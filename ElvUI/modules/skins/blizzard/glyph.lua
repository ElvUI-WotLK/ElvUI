local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local GetCVarBool = GetCVarBool;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true) then return; end

	GlyphFrame:StripTextures();

	GlyphFrame:CreateBackdrop();
	GlyphFrame.backdrop:Size(328, 353)
	GlyphFrame.backdrop:ClearAllPoints()
	GlyphFrame.backdrop:Point("CENTER", PlayerTalentFrame.backdrop, 0, -16)

	GlyphFrame.texture = GlyphFrame.backdrop:CreateTexture(nil, "OVERLAY");
	GlyphFrame.texture:SetInside();
	GlyphFrame.texture:SetTexture("Interface\\Spellbook\\UI-GlyphFrame");
	GlyphFrame.texture:SetTexCoord(0.0390625, 0.65625, 0.140625, 0.8046875);

	local glyphPositions = {
		{"CENTER", 0, 122},
		{"CENTER", 0, -127},
		{"TOPLEFT", 0, -53},
		{"BOTTOMRIGHT", -10, 70},
		{"TOPRIGHT", 0, -53},
		{"BOTTOMLEFT", 10, 70}
	}

	for i = 1, 6 do
		local frame = _G["GlyphFrameGlyph"..i]
		frame:SetScale(1.0379747)
		frame:SetParent(GlyphFrame.backdrop)
		frame:SetPoint(unpack(glyphPositions[i]))
	end

	GlyphFrame:HookScript("OnShow", function()
		PlayerTalentFrameTitleText:Hide();
		PlayerTalentFramePointsBar:Hide();
		PlayerTalentFrameScrollFrame:Hide();
		PlayerTalentFrameStatusFrame:Hide();
		PlayerTalentFrameActivateButton:Hide();
	end);

	GlyphFrame:SetScript("OnHide", function()
		PlayerTalentFrameTitleText:Show();
		PlayerTalentFramePointsBar:Show();
		PlayerTalentFrameScrollFrame:Show();
	end);

	hooksecurefunc(PlayerTalentFrame, "updateFunction", function()
		if GlyphFrame:IsShown() then
			PlayerTalentFramePreviewBar:Hide()
		end
	end)
end

S:AddCallbackForAddon("Blizzard_GlyphUI", "Glyph", LoadSkin);