local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.petition then return end

	PetitionFrame:StripTextures(true)
	PetitionFrame:CreateBackdrop("Transparent")
	PetitionFrame.backdrop:Point("TOPLEFT", 11, -12)
	PetitionFrame.backdrop:Point("BOTTOMRIGHT", -32, 66)

	S:SetUIPanelWindowInfo(PetitionFrame, "width")
	S:SetBackdropHitRect(PetitionFrame)

	S:HandleButton(PetitionFrameSignButton)
	S:HandleButton(PetitionFrameRequestButton)
	S:HandleButton(PetitionFrameRenameButton)
	S:HandleButton(PetitionFrameCancelButton)
	S:HandleCloseButton(PetitionFrameCloseButton, PetitionFrame.backdrop)

	PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
	PetitionFrameCharterName:SetTextColor(1, 1, 1)
	PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
	PetitionFrameMasterName:SetTextColor(1, 1, 1)
	PetitionFrameMemberTitle:SetTextColor(1, 1, 0)

	for i = 1, 9 do
		_G["PetitionFrameMemberName"..i]:SetTextColor(1, 1, 1)
	end

	PetitionFrameInstructions:SetTextColor(1, 1, 1)

	PetitionFrameRequestButton:Point("BOTTOMLEFT", 19, 74)
	PetitionFrameCancelButton:Point("BOTTOMRIGHT", -40, 74)
	PetitionFrameRenameButton:Point("LEFT", PetitionFrameRequestButton, "RIGHT", 3, 0)
	PetitionFrameRenameButton:Point("RIGHT", PetitionFrameCancelButton, "LEFT", -3, 0)
end

S:AddCallback("Skin_Petition", LoadSkin)