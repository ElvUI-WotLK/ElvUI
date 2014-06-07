local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgscore ~= true then return end

	
	WorldStateScoreScrollFrame:StripTextures()
	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:CreateBackdrop("Transparent")
	WorldStateScoreFrame.backdrop:Point("TOPLEFT", 10, -15)
	WorldStateScoreFrame.backdrop:Point("BOTTOMRIGHT", -113, 67)
	
	S:HandleCloseButton(WorldStateScoreFrameCloseButton)
	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar)
	S:HandleButton(WorldStateScoreFrameLeaveButton)
	
	for i = 1, 3 do 
		S:HandleTab(_G["WorldStateScoreFrameTab"..i])
		_G["WorldStateScoreFrameTab"..i].backdrop:Point("TOPLEFT", 10, E.PixelMode and -1 or -3)
		_G["WorldStateScoreFrameTab"..i].backdrop:Point("BOTTOMRIGHT", -10, 14)
	end
end

S:RegisterSkin('ElvUI', LoadSkin)