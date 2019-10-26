local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tabard then return end

	TabardFramePortrait:Kill()

	TabardFrame:StripTextures()
	TabardFrame:CreateBackdrop("Transparent")
	TabardFrame.backdrop:Point("TOPLEFT", 11, -12)
	TabardFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	TabardModel:CreateBackdrop("Default")
	S:HandleButton(TabardFrameCancelButton)
	S:HandleButton(TabardFrameAcceptButton)
	S:HandleCloseButton(TabardFrameCloseButton, TabardFrame.backdrop)
	S:HandleRotateButton(TabardCharacterModelRotateLeftButton)
	S:HandleRotateButton(TabardCharacterModelRotateRightButton)

	TabardFrameCostFrame:StripTextures()
	TabardFrameCustomizationFrame:StripTextures()

	for i = 1, 5 do
		local custom = _G["TabardFrameCustomization"..i]
		custom:StripTextures()
		S:HandleNextPrevButton(_G["TabardFrameCustomization"..i.."LeftButton"])
		S:HandleNextPrevButton(_G["TabardFrameCustomization"..i.."RightButton"])

		if i > 1 then
			custom:ClearAllPoints()
			custom:Point("TOP", _G["TabardFrameCustomization"..i - 1], "BOTTOM", 0, -6)
		else
			local point, anchor, point2, x, y = custom:GetPoint()
			custom:Point(point, anchor, point2, x, y + 4)
		end
	end

	TabardCharacterModelRotateLeftButton:Point("BOTTOMLEFT", 4, 4)
	TabardCharacterModelRotateRightButton:Point("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 4, 0)

	hooksecurefunc(TabardCharacterModelRotateLeftButton, "SetPoint", function(self)
		if self._blocked then return end
		self._blocked = true
		self:Point("BOTTOMLEFT", 4, 4)
		self._blocked = nil
	end)

	hooksecurefunc(TabardCharacterModelRotateRightButton, "SetPoint", function(self)
		if self._blocked then return end
		self._blocked = true
		self:Point("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 4, 0)
		self._blocked = nil
	end)
end

S:AddCallback("Skin_Tabard", LoadSkin)