local E, L, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.pvp ~= true then return; end
	-- BattlefieldFrame
	BattlefieldFrame:StripTextures(true);
	BattlefieldFrame:CreateBackdrop('Transparent');
	BattlefieldFrame.backdrop:Point('TOPLEFT', 12, -12);
	BattlefieldFrame.backdrop:Point('BOTTOMRIGHT', -34, 76);
	
	BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1);
	BattlefieldFrameInfoScrollFrameChildFrameRewardsInfoDescription:SetTextColor(1, 1, 1);
	
	S:HandleButton(BattlefieldFrameCancelButton);
	S:HandleButton(BattlefieldFrameJoinButton);
	BattlefieldFrameGroupJoinButton:SetPoint('RIGHT', BattlefieldFrameJoinButton, 'LEFT', -1, 0);
	S:HandleButton(BattlefieldFrameGroupJoinButton);
	
	S:HandleCloseButton(BattlefieldFrameCloseButton);
	-- PVPBattlegroundFrame
	PVPBattlegroundFrame:StripTextures(true);
	
	PVPBattlegroundFrameTypeScrollFrame:StripTextures();
	S:HandleScrollBar(PVPBattlegroundFrameTypeScrollFrameScrollBar);
	
	S:HandleButton(PVPBattlegroundFrameCancelButton);
	
	PVPBattlegroundFrameInfoScrollFrame:StripTextures();
	S:HandleScrollBar(PVPBattlegroundFrameInfoScrollFrameScrollBar);
	
	PVPBattlegroundFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1);
	PVPBattlegroundFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(1, 1, 1);
	
	S:HandleButton(PVPBattlegroundFrameJoinButton);
	PVPBattlegroundFrameGroupJoinButton:SetPoint('RIGHT', PVPBattlegroundFrameJoinButton, 'LEFT', -1, 0);
	S:HandleButton(PVPBattlegroundFrameGroupJoinButton);
	-- PVPFrame
	PVPParentFrame:CreateBackdrop('Transparent');
	PVPParentFrame.backdrop:Point('TOPLEFT', 13, -13);
	PVPParentFrame.backdrop:Point('BOTTOMRIGHT', -32, 76);
	
	S:HandleCloseButton(PVPParentFrameCloseButton);
	
	PVPFrame:StripTextures(true);
	
	do
		local Team;
		local TeamHighlight;
		
		for i = 1, MAX_ARENA_TEAMS do
			Team = _G['PVPTeam'..i];
			TeamHighlight = _G['PVPTeam'..i..'Highlight'];
			
			Team:StripTextures();
			Team:CreateBackdrop('Transparent');
			Team.backdrop:Point('TOPLEFT', 9, -4);
			Team.backdrop:Point('BOTTOMRIGHT', -24, 3);
			
			TeamHighlight:Kill();
		end
	end
	
	PVPTeamDetails:StripTextures();
	PVPTeamDetails:SetTemplate('Transparent');
	
	S:HandleCloseButton(PVPTeamDetailsCloseButton);
	
	do
		local Header;
		
		for i = 1, 5 do
			Header = _G['PVPTeamDetailsFrameColumnHeader'..i];
			
			Header:StripTextures();
		end
	end
	
	S:HandleButton(PVPTeamDetailsAddTeamMember);
	
	S:HandleNextPrevButton(PVPTeamDetailsToggleButton);
	
	do
		local Tab;
		
		for i = 1, 2 do
			Tab = _G['PVPParentFrameTab'..i];
			
			S:HandleTab(Tab);
		end
	end
end

S:RegisterSkin('ElvUI', LoadSkin);