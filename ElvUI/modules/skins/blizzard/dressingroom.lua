local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.dressingroom ~= true then return end
	DressUpFrame:StripTextures(true)
	DressUpFrame:CreateBackdrop("Transparent")
	DressUpFrame.backdrop:Point("TOPLEFT", 10, -12)
	DressUpFrame.backdrop:Point("BOTTOMRIGHT", -33, 73)
	
	S:HandleButton(DressUpFrameResetButton)
	S:HandleButton(DressUpFrameCancelButton)
	S:HandleCloseButton(DressUpFrameCloseButton, DressUpFrame.backdrop)
	
	DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -2, 0)
end

S:RegisterSkin('ElvUI', LoadSkin)