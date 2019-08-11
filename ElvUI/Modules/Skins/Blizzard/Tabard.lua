local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tabard ~= true then return; end

	TabardFrame:StripTextures()
	TabardFramePortrait:Kill()
	TabardFrame:CreateBackdrop("Transparent")
	TabardFrame.backdrop:Point("TOPLEFT", 10, -12)
	TabardFrame.backdrop:Point("BOTTOMRIGHT", -32, 74)
	TabardModel:CreateBackdrop("Default")
	S:HandleButton(TabardFrameCancelButton)
	S:HandleButton(TabardFrameAcceptButton)
	S:HandleCloseButton(TabardFrameCloseButton)
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
	hooksecurefunc(TabardCharacterModelRotateLeftButton, "SetPoint", function(self, point, _, _, xOffset, yOffset)
		if point ~= "BOTTOMLEFT" or xOffset ~= 4 or yOffset ~= 4 then
			self:Point("BOTTOMLEFT", 4, 4)
		end
	end)

	hooksecurefunc(TabardCharacterModelRotateRightButton, "SetPoint", function(self, point, _, _, xOffset, yOffset)
		if point ~= "TOPLEFT" or xOffset ~= 4 or yOffset ~= 0 then
			self:Point("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 4, 0)
		end
	end)
end

S:AddCallback("Tabard", LoadSkin)