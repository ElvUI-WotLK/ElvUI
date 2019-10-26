local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
--WoW API / Variables
local GetPetHappiness = GetPetHappiness
local HasPetUI = HasPetUI
local UnitExists = UnitExists

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.stable then return end

	PetStableFrame:StripTextures()
	PetStableFramePortrait:Kill()
	PetStableFrame:CreateBackdrop("Transparent")
	PetStableFrame.backdrop:Point("TOPLEFT", 11, -12)
	PetStableFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:HandleButton(PetStablePurchaseButton)
	S:HandleCloseButton(PetStableFrameCloseButton, PetStableFrame.backdrop)
	S:HandleRotateButton(PetStableModelRotateRightButton)
	S:HandleRotateButton(PetStableModelRotateLeftButton)

	S:HandleItemButton(_G["PetStableCurrentPet"], true)
	_G["PetStableCurrentPetIconTexture"]:SetDrawLayer("OVERLAY")

	PetStablePetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30)
	PetStablePetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2)
	PetStablePetInfo:CreateBackdrop("Default")
	PetStablePetInfo:Size(24, 24)

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
		local texture = PetStablePetInfo:GetRegions()

		if happiness == 1 then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
		elseif happiness == 2 then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
		elseif happiness == 3 then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
		end
	end)
end

S:AddCallback("Skin_Stable", LoadSkin)