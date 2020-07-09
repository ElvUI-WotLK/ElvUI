local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
--WoW API / Variables
local GetPetHappiness = GetPetHappiness
local HasPetUI = HasPetUI
local UnitExists = UnitExists

S:AddCallback("Skin_Stable", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.stable then return end

	PetStableFrame:StripTextures()
	PetStableFramePortrait:Kill()
	PetStableFrame:CreateBackdrop("Transparent")
	PetStableFrame.backdrop:Point("TOPLEFT", 11, -12)
	PetStableFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(PetStableFrame, "width")
	S:SetBackdropHitRect(PetStableFrame)

	S:HandleCloseButton(PetStableFrameCloseButton, PetStableFrame.backdrop)

	S:HandleRotateButton(PetStableModelRotateLeftButton)
	S:HandleRotateButton(PetStableModelRotateRightButton)

	S:HandleButton(PetStablePurchaseButton)

	S:HandleItemButton(PetStableCurrentPet, true)
	PetStableCurrentPetIconTexture:SetDrawLayer("OVERLAY")

	PetStableModel:Size(325, 224)
	PetStableModel:Point("TOPLEFT", 19, -71)

	PetStableModelRotateLeftButton:Point("TOPLEFT", PetStableModel, "TOPLEFT", 4, -4)
	PetStableModelRotateRightButton:Point("TOPLEFT", PetStableModelRotateLeftButton, "TOPRIGHT", 3, 0)

	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 52, 4
	PetStablePetInfo:GetRegions():SetTexCoord(0.03125, 0.15625, 0.0625, 0.3125)
	PetStablePetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2)
	PetStablePetInfo:CreateBackdrop("Default")
	PetStablePetInfo:Size(25)
	PetStablePetInfo:Point("TOPLEFT", PetStableModelRotateLeftButton, "BOTTOMLEFT", 10, -4)

	PetStableCurrentPet:Point("BOTTOMLEFT", 40, 150)

	local function UpdateSlot(self, r, g, b)
		if g ~= 1 then
			self:SetTexture(.8, .2, .2, .3)
		else
			self:SetTexture(0, 0, 0, 0)
		end
	end

	for i = 1, NUM_PET_STABLE_SLOTS do
		S:HandleItemButton(_G["PetStableStabledPet"..i], true)
		_G["PetStableStabledPet"..i.."IconTexture"]:SetDrawLayer("OVERLAY")

		local bg = _G["PetStableStabledPet"..i.."Background"]
		bg:SetDrawLayer("BORDER")
		bg:SetInside()
		hooksecurefunc(bg, "SetVertexColor", UpdateSlot)
	end

	hooksecurefunc("PetStable_Update", function()
		local hasPetUI, isHunterPet = HasPetUI()
		if hasPetUI and not isHunterPet and UnitExists("pet") then return end

		local happiness = GetPetHappiness()

		if happiness == 1 then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 52, 4
			PetStablePetInfo:GetRegions():SetTexCoord(0.40625, 0.53125, 0.0625, 0.3125)
		elseif happiness == 2 then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 28, 4
			PetStablePetInfo:GetRegions():SetTexCoord(0.21875, 0.34375, 0.0625, 0.3125)
		elseif happiness == 3 then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 52, 4
			PetStablePetInfo:GetRegions():SetTexCoord(0.03125, 0.15625, 0.0625, 0.3125)
		end
	end)
end)