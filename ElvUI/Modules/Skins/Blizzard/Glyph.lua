local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

S:AddCallbackForAddon("Blizzard_GlyphUI", "Skin_Blizzard_GlyphUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.talent then return end

	if not PlayerTalentFrame then
		TalentFrame_LoadUI()
	end

	GlyphFrame:StripTextures()

	GlyphFrameBackground:Size(323, 349)
	GlyphFrameBackground:Point("TOPLEFT", 20, -59)
	GlyphFrameBackground:CreateBackdrop()

	S:HookScript(GlyphFrame, "OnShow", function(self)
		S:SetBackdropHitRect(self, PlayerTalentFrame.backdrop)
		S:Unhook(self, "OnShow")
	end)

	GlyphFrameBackground:SetTexture("Interface\\Spellbook\\UI-GlyphFrame")
	GlyphFrameGlow:SetTexture("Interface\\Spellbook\\UI-GlyphFrame-Glow")
	GlyphFrameGlow:SetAllPoints(GlyphFrameBackground)

	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 512, 512, 315, 340, 21, 72
	GlyphFrameBackground:SetTexCoord(0.041015625, 0.65625, 0.140625, 0.8046875)

	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 512, 512, 315, 340, 30, 34
	GlyphFrameGlow:SetTexCoord(0.05859375, 0.673828125, 0.06640625, 0.73046875)

	local glyphBGScale = 1.0253968
	local glyphPositions = {
		{"CENTER", -1, 126},
		{"CENTER", -1, -119},
		{"TOPLEFT", 8, -62},
		{"BOTTOMRIGHT", -10, 70},
		{"TOPRIGHT", -8, -62},
		{"BOTTOMLEFT", 7, 70}
	}

	local glyphFrameLevel = GlyphFrame:GetFrameLevel() + 1
	for i = 1, 6 do
		local frame = _G["GlyphFrameGlyph"..i]
		frame:SetParent(GlyphFrameBackground.backdrop)
		frame:SetFrameLevel(glyphFrameLevel)
		frame:SetScale(glyphBGScale)
		frame:Point(unpack(glyphPositions[i]))
	end

	GlyphFrame:HookScript("OnShow", function()
		PlayerTalentFrameTitleText:Hide()
		PlayerTalentFramePointsBar:Hide()
		PlayerTalentFrameScrollFrame:Hide()
		PlayerTalentFrameStatusFrame:Hide()
		PlayerTalentFrameActivateButton:Hide()
	end)

	GlyphFrame:SetScript("OnHide", function()
		PlayerTalentFrameTitleText:Show()
		PlayerTalentFramePointsBar:Show()
		PlayerTalentFrameScrollFrame:Show()
	end)

	hooksecurefunc(PlayerTalentFrame, "updateFunction", function()
		if GlyphFrame:IsShown() then
			PlayerTalentFramePreviewBar:Hide()
		end
	end)

	do
		local slotAnimations = {}
		local TOPLEFT, TOP, TOPRIGHT, BOTTOMRIGHT, BOTTOM, BOTTOMLEFT = 3, 1, 5, 4, 2, 6
		slotAnimations[TOPLEFT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -85, ["yStart"] = 17, ["yStop"] = 60}
		slotAnimations[TOP] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -13, ["yStart"] = 17, ["yStop"] = 100}
		slotAnimations[TOPRIGHT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = 59, ["yStart"] = 17, ["yStop"] = 60}
		slotAnimations[BOTTOM] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -13, ["yStart"] = 17, ["yStop"] = -64}
		slotAnimations[BOTTOMLEFT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -87, ["yStart"] = 18, ["yStop"] = -27}
		slotAnimations[BOTTOMRIGHT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = 61, ["yStart"] = 18, ["yStop"] = -27}

		for _, animData in pairs(slotAnimations) do
			animData.xStart = animData.xStart + 3
			animData.yStart = animData.yStart + 8
			animData.xStop = (animData.xStop + 3) * glyphBGScale
			animData.yStop = (animData.yStop + 8) * glyphBGScale
		end

		hooksecurefunc("GlyphFrame_StartSlotAnimation", function(slotID, duration, size)
			local sparkle = _G["GlyphFrameSparkle"..slotID]
			local animation = slotAnimations[slotID]

			sparkle:SetPoint("CENTER", GlyphFrame, animation.point, animation.xStart, animation.yStart)
			sparkle.animGroup.translate:SetOffset(animation.xStop - animation.xStart, animation.yStop - animation.yStart)
		end)
	end
end)