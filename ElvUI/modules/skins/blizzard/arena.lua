local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.arena ~= true then return end
	
	ArenaFrame:StripTextures(true)
	ArenaFrame:CreateBackdrop('Transparent')
	ArenaFrame.backdrop:Point('TOPLEFT', 10, -12)
	ArenaFrame.backdrop:Point('BOTTOMRIGHT', -32, 76)
	
	S:HandleCloseButton(ArenaFrameCloseButton)
	
	for i=1, MAX_ARENA_BATTLES, 1 do
		_G['ArenaZone'..i..'Highlight']:SetTexture(E['media'].normTex)
	end
	
	ArenaFrameZoneDescription:SetTextColor(1, 1, 1)
	
	S:HandleButton(ArenaFrameGroupJoinButton)
	S:HandleButton(ArenaFrameJoinButton)
	S:HandleButton(ArenaFrameCancelButton)
	ArenaFrameCancelButton:Point("CENTER", ArenaFrame, "TOPLEFT", 304, -420)
end

S:RegisterSkin('ElvUI', LoadSkin)