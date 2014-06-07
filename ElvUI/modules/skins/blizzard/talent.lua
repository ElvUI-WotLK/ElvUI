local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end
	
	local TalentUIStrip = {'PlayerTalentFrame', 'PlayerTalentFrameStatusFrame', 'PlayerTalentFrameScrollFrame', 'PlayerTalentFramePointsBar', 'PlayerTalentFramePreviewBar', 'PlayerTalentFramePreviewBarFiller'}
	for _, object in pairs(TalentUIStrip) do
		_G[object]:StripTextures()
	end
	
	local TalentUIKill = {'PlayerTalentFramePortrait'}
	for _, texture in pairs(TalentUIKill) do
		_G[texture]:Kill()
	end

	local TalentUIButtons = {'PlayerTalentFrameActivateButton','PlayerTalentFrameLearnButton','PlayerTalentFrameResetButton'}
	for i = 1, #TalentUIButtons do
		_G[TalentUIButtons[i]]:StripTextures()
		S:HandleButton(_G[TalentUIButtons[i]], true)
	end

	for i=1, MAX_TALENT_TABS do
		local tab = _G['PlayerSpecTab'..i]
		if tab then
			local a = tab:GetRegions()
			a:Hide()
			tab:StripTextures()
			tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			
			tab:GetNormalTexture():ClearAllPoints()
			tab:GetNormalTexture():SetInside()

			tab:CreateBackdrop('Default')
			tab.backdrop:SetAllPoints()
			tab:StyleButton(nil, true)
		end
	end

	for i=1, 4 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])
	end

	for i=1, MAX_NUM_TALENTS do
		button = _G['PlayerTalentFrameTalent'..i]
		icon = _G['PlayerTalentFrameTalent'..i..'IconTexture']
		rank = _G['PlayerTalentFrameTalent'..i..'Rank']
		
		if ( button ) then
			button:StripTextures()
			button:SetTemplate('Default', true)
			button:StyleButton()
			
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("ARTWORK")
			icon:ClearAllPoints()
			icon:SetInside()
			
			rank:SetFont(E.LSM:Fetch("font", E.db['general'].font), 12, 'OUTLINE')
			rank:Point('BOTTOMRIGHT', -1, 1)
		end
	end
	
	PlayerTalentFrame:CreateBackdrop('Transparent')
	PlayerTalentFrame.backdrop:Point('TOPLEFT', 10, -12)
	PlayerTalentFrame.backdrop:Point('BOTTOMRIGHT', -31, 76)
	
	S:HandleCloseButton(PlayerTalentFrameCloseButton)
	PlayerTalentFrameScrollFrame:CreateBackdrop('Default')
	S:HandleScrollBar(PlayerTalentFrameScrollFrameScrollBar)
end

S:RegisterSkin("Blizzard_TalentUI", LoadSkin)