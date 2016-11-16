local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local SetDressUpBackground = SetDressUpBackground;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.dressingroom ~= true) then return; end

	DressUpFrame:CreateBackdrop("Transparent");
	DressUpFrame.backdrop:Point("TOPLEFT", 10, -12);
	DressUpFrame.backdrop:Point("BOTTOMRIGHT", -33, 73);

	DressUpFrame:StripTextures();
	DressUpFramePortrait:Kill();

	SetDressUpBackground();
	DressUpBackgroundTopLeft:SetDesaturated(true);
	DressUpBackgroundTopRight:SetDesaturated(true);
	DressUpBackgroundBotLeft:SetDesaturated(true);
	DressUpBackgroundBotRight:SetDesaturated(true);

	S:HandleCloseButton(DressUpFrameCloseButton);

	S:HandleRotateButton(DressUpModelRotateLeftButton);
	DressUpModelRotateRightButton:Point("TOPLEFT", DressUpModelRotateLeftButton, "TOPRIGHT", 3, 0);
	S:HandleRotateButton(DressUpModelRotateRightButton);

	S:HandleButton(DressUpFrameCancelButton);
	DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -3, 0);
	S:HandleButton(DressUpFrameResetButton);

	DressUpModel:CreateBackdrop("Default");
	DressUpModel.backdrop:SetOutside(DressUpBackgroundTopLeft, nil, nil, DressUpModel);
end

S:AddCallback("DressingRoom", LoadSkin);