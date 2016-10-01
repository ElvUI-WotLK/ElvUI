local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.petition ~= true) then return; end

	PetitionFrame:StripTextures(true);
	PetitionFrame:CreateBackdrop("Transparent");
	PetitionFrame.backdrop:Point("TOPLEFT", 12, -17);
	PetitionFrame.backdrop:Point("BOTTOMRIGHT", -28, 65);

	S:HandleButton(PetitionFrameSignButton);
	S:HandleButton(PetitionFrameRequestButton);
	S:HandleButton(PetitionFrameRenameButton);
	S:HandleButton(PetitionFrameCancelButton);
	S:HandleCloseButton(PetitionFrameCloseButton);

	PetitionFrameCharterTitle:SetTextColor(1, 1, 0);
	PetitionFrameCharterName:SetTextColor(1, 1, 1);
	PetitionFrameMasterTitle:SetTextColor(1, 1, 0);
	PetitionFrameMasterName:SetTextColor(1, 1, 1);
	PetitionFrameMemberTitle:SetTextColor(1, 1, 0);

	for i = 1, 9 do
		_G["PetitionFrameMemberName" .. i]:SetTextColor(1, 1, 1);
	end

	PetitionFrameInstructions:SetTextColor(1, 1, 1);

	PetitionFrameRenameButton:Point("LEFT", PetitionFrameRequestButton, "RIGHT", 3, 0);
	PetitionFrameRenameButton:Point("RIGHT", PetitionFrameCancelButton, "LEFT", -3, 0);
end

S:AddCallback("Petition", LoadSkin);