local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local _G = _G;

local TexCoords = E.TexCoords;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return; end
	
	PlayerTalentFrame:StripTextures(true);
	PlayerTalentFrame:CreateBackdrop('Transparent');
	PlayerTalentFrame.backdrop:Point('TOPLEFT', 13, -12);
	PlayerTalentFrame.backdrop:Point('BOTTOMRIGHT', -31, 76);
	
	S:HandleCloseButton(PlayerTalentFrameCloseButton);
	
	PlayerTalentFrameStatusFrame:StripTextures();
	
	S:HandleButton(PlayerTalentFrameActivateButton, true);
	
	PlayerTalentFramePointsBar:StripTextures();
	PlayerTalentFramePreviewBar:StripTextures();
	
	S:HandleButton(PlayerTalentFrameResetButton);
	PlayerTalentFrameLearnButton:Point('RIGHT', PlayerTalentFrameResetButton, 'LEFT', -1, 0);
	S:HandleButton(PlayerTalentFrameLearnButton);
	
	PlayerTalentFramePreviewBarFiller:StripTextures();
	
	PlayerTalentFrameScrollFrame:StripTextures();
	PlayerTalentFrameScrollFrame:CreateBackdrop('Default');
	S:HandleScrollBar(PlayerTalentFrameScrollFrameScrollBar);
	
	do
		local talent, talentIcon;
		
		for i = 1, MAX_NUM_TALENTS do
			talent = _G['PlayerTalentFrameTalent'..i];
			talentIcon = _G['PlayerTalentFrameTalent'..i..'IconTexture'];
			
			talent:StripTextures();
			talent:StyleButton();
			talent:SetTemplate('Default');
			
			talentIcon:SetInside();
			talentIcon:SetTexCoord(unpack(TexCoords));
		end
	end
	
	do
		local tab;
		
		for i = 1, 4 do
			tab = _G['PlayerTalentFrameTab'..i];
			
			S:HandleTab(tab);
		end
	end
	
	do
		local tab;
		local tabRegions;
		
		for i = 1, MAX_TALENT_TABS do
			tab = _G['PlayerSpecTab'..i];
			
			if(tab) then
				tabRegions = tab:GetRegions();
				tabRegions:Hide();
				
				tab:SetTemplate('Default');
				tab:StyleButton(nil, true);
				
				tab:GetNormalTexture():SetInside();
				tab:GetNormalTexture():SetTexCoord(unpack(TexCoords));
			end
		end
	end
end

S:RegisterSkin('Blizzard_TalentUI', LoadSkin);