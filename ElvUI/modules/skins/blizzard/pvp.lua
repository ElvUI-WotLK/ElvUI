local E, L, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.pvp ~= true then return end
	
	S:HandleCloseButton(PVPParentFrameCloseButton)
	
	for i=1, 2 do
		S:HandleTab(_G['PVPParentFrameTab'..i])
	end	
	
	for i=1, MAX_ARENA_TEAMS do
		_G['PVPTeam'..i]:StripTextures()
		_G['PVPTeam'..i]:CreateBackdrop('Transparent')
		_G['PVPTeam'..i].backdrop:Point('TOPLEFT', 9, -6)
		_G['PVPTeam'..i].backdrop:Point('BOTTOMRIGHT', -24, 5)
		_G['PVPTeam'..i..'StandardBar']:Kill()
		_G['PVPTeam'..i..'Highlight']:Kill()
		
		local Highlight = _G['PVPTeam'..i]:CreateTexture(nil, 'HIGHLIGHT')
		Highlight:SetTexture(1, 1, 1, .3)
		Highlight:SetInside(_G['PVPTeam'..i].backdrop)
	end	
	
	PVPFrame:StripTextures(true)
	PVPFrame:CreateBackdrop('Transparent')
	PVPFrame.backdrop:Point('TOPLEFT', 10, -12)
	PVPFrame.backdrop:Point('BOTTOMRIGHT', -32, 76)
	
	PVPTeamDetails:StripTextures()
	PVPTeamDetails:CreateBackdrop('Transparent')
	PVPTeamDetails.backdrop:Point('TOPLEFT', 8, -2)
	PVPTeamDetails.backdrop:Point('BOTTOMRIGHT', -2, 12)
	
	S:HandleCloseButton(PVPTeamDetailsCloseButton)
	
	for i=1, 5 do
		_G['PVPTeamDetailsFrameColumnHeader'..i]:StripTextures()
	end
	S:HandleButton(PVPTeamDetailsAddTeamMember)
	
	S:HandleNextPrevButton(PVPTeamDetailsToggleButton)
	
	PVPBattlegroundFrame:StripTextures(true)
	PVPBattlegroundFrame:CreateBackdrop('Transparent')
	PVPBattlegroundFrame.backdrop:Point('TOPLEFT', 8, -11)
	PVPBattlegroundFrame.backdrop:Point('BOTTOMRIGHT', -34, 77)
	
	-- WintergraspTimer:SetTemplate('Default')
	
	for i=1, BATTLEFIELD_ZONES_DISPLAYED do
		_G['BattlegroundType'..i..'Highlight']:SetTexture(E['media'].normTex)
	end
	
	PVPBattlegroundFrameTypeScrollFrame:StripTextures()
	S:HandleScrollBar(PVPBattlegroundFrameTypeScrollFrameScrollBar)
	
	PVPBattlegroundFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 0)
	PVPBattlegroundFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(1, 1, 1)

	S:HandleButton(PVPBattlegroundFrameGroupJoinButton)
	S:HandleButton(PVPBattlegroundFrameJoinButton)
	S:HandleButton(PVPBattlegroundFrameCancelButton)
	PVPBattlegroundFrameCancelButton:Point('CENTER', BattlefieldFrame, 'TOPLEFT', 304, -420)
	
	BattlefieldFrame:StripTextures(true)
	BattlefieldFrame:CreateBackdrop('Transparent')
	BattlefieldFrame.backdrop:Point('TOPLEFT', 10, -12)
	BattlefieldFrame.backdrop:Point('BOTTOMRIGHT', -32, 76)
	
	S:HandleCloseButton(BattlefieldFrameCloseButton)
	
	for i=1, NUM_DISPLAYED_BATTLEGROUNDS do
		_G['BattlefieldZone'..i..'Highlight']:SetTexture(E['media'].normTex)
	end
	
	BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)
	BattlefieldFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(1, 1, 1)
	
	S:HandleButton(BattlefieldFrameGroupJoinButton)
	S:HandleButton(BattlefieldFrameJoinButton)
	S:HandleButton(BattlefieldFrameCancelButton)
	BattlefieldFrameCancelButton:Point('CENTER', BattlefieldFrame, 'TOPLEFT', 304, -420)
end

S:RegisterSkin('ElvUI', LoadSkin)