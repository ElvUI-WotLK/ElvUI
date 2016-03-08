local E, L, V, P, G, _ = unpack(select(2, ...));
local S = E:GetModule("Skins");

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
end

S:RegisterSkin("ElvUI", LoadSkin);