local E, L, V, P, G, _ = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;

local GetPetHappiness = GetPetHappiness;
local HasPetUI = HasPetUI;
local UnitExists = UnitExists;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.stable ~= true) then return; end

	PetStableFrame:StripTextures();
	PetStableFramePortrait:Kill();
	PetStableFrame:CreateBackdrop("Transparent");
	PetStableFrame.backdrop:Point("TOPLEFT", 10, -11);
	PetStableFrame.backdrop:Point("BOTTOMRIGHT", -32, 71);

	S:HandleButton(PetStablePurchaseButton);
	S:HandleCloseButton(PetStableFrameCloseButton);
	S:HandleRotateButton(PetStableModelRotateRightButton);
	S:HandleRotateButton(PetStableModelRotateLeftButton);

	S:HandleItemButton(_G["PetStableCurrentPet"], true);
	_G["PetStableCurrentPetIconTexture"]:SetDrawLayer("OVERLAY");

	for i = 1, NUM_PET_STABLE_SLOTS do
		S:HandleItemButton(_G["PetStableStabledPet" .. i], true);
		_G["PetStableStabledPet" .. i .. "IconTexture"]:SetDrawLayer("OVERLAY");
	end

	PetStablePetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30);
	PetStablePetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2);
	PetStablePetInfo:CreateBackdrop("Default");
	PetStablePetInfo:Size(24, 24);

	hooksecurefunc("PetStable_Update", function()
		local happiness = GetPetHappiness();
		local hasPetUI, isHunterPet = HasPetUI();
		if(UnitExists("pet") and hasPetUI and not isHunterPet) then
			return;
		end
		local texture = PetStablePetInfo:GetRegions();
		if(happiness == 1) then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30);
		elseif(happiness == 2) then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30);
		elseif(happiness == 3) then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30);
		end
	end);
end

S:AddCallback("Stable", LoadSkin);