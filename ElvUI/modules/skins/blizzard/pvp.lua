local E, L, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local _G = _G;

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
	BattlefieldFrameGroupJoinButton:Point('RIGHT', BattlefieldFrameJoinButton, 'LEFT', -1, 0);
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
	PVPBattlegroundFrameGroupJoinButton:Point('RIGHT', PVPBattlegroundFrameJoinButton, 'LEFT', -1, 0);
	S:HandleButton(PVPBattlegroundFrameGroupJoinButton);
	-- PVPFrame
	PVPParentFrame:CreateBackdrop('Transparent');
	PVPParentFrame.backdrop:Point('TOPLEFT', 13, -13);
	PVPParentFrame.backdrop:Point('BOTTOMRIGHT', -32, 76);
	
	S:HandleCloseButton(PVPParentFrameCloseButton);
	
	PVPFrame:StripTextures(true);
	
	do
		local team;
		local teamHighlight;
		
		for i = 1, MAX_ARENA_TEAMS do
			team = _G['PVPTeam'..i];
			teamHighlight = _G['PVPTeam'..i..'Highlight'];
			
			team:StripTextures();
			team:CreateBackdrop('Transparent');
			team.backdrop:Point('TOPLEFT', 9, -4);
			team.backdrop:Point('BOTTOMRIGHT', -24, 3);
			
			teamHighlight:Kill();
		end
	end
	
	PVPTeamDetails:StripTextures();
	PVPTeamDetails:SetTemplate('Transparent');
	
	S:HandleCloseButton(PVPTeamDetailsCloseButton);
	
	do
		local header;
		
		for i = 1, 5 do
			header = _G['PVPTeamDetailsFrameColumnHeader'..i];
			
			header:StripTextures();
		end
	end
	
	S:HandleButton(PVPTeamDetailsAddTeamMember);
	
	S:HandleNextPrevButton(PVPTeamDetailsToggleButton);
	
	do
		local tab;
		
		for i = 1, 2 do
			tab = _G['PVPParentFrameTab'..i];
			
			S:HandleTab(tab);
		end
	end
end

S:RegisterSkin('ElvUI', LoadSkin);