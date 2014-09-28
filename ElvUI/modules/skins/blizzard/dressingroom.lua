local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

S:RegisterSkin('ElvUI', function()
	if(E.private.skins.blizzard.enable ~= true
		or E.private.skins.blizzard.dressingroom ~= true)
	then
		return;
	end
	
	DressUpFrame:CreateBackdrop('Transparent');
	DressUpFrame.backdrop:Point('TOPLEFT', 10, -12);
	DressUpFrame.backdrop:Point('BOTTOMRIGHT', -33, 73);
	
	DressUpFrame:StripTextures(true);
	
	S:HandleCloseButton(DressUpFrameCloseButton);
	
	S:HandleRotateButton(DressUpModelRotateLeftButton);
	DressUpModelRotateRightButton:SetPoint('TOPLEFT', DressUpModelRotateLeftButton, 'TOPRIGHT', 3, 0);
	S:HandleRotateButton(DressUpModelRotateRightButton);
	
	S:HandleButton(DressUpFrameCancelButton);
	DressUpFrameResetButton:SetPoint('RIGHT', DressUpFrameCancelButton, 'LEFT', -3, 0);
	S:HandleButton(DressUpFrameResetButton);
end);