local E, L, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local _G = _G;
local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS;

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
	
	WintergraspTimer:SetSize(24, 24);
	WintergraspTimer:SetTemplate("Default");
	
	WintergraspTimer.texture:SetDrawLayer("ARTWORK");
	WintergraspTimer.texture:SetInside();
	
	WintergraspTimer:HookScript("OnUpdate", function(self)
		local canQueue = CanQueueForWintergrasp();
		if(canQueue) then
			self.texture:SetTexCoord(0.2, 0.8, 0.6, 0.9);
		else
			self.texture:SetTexCoord(0.2, 0.8, 0.1, 0.4);
		end
	end);
	
	PVPBattlegroundFrameTypeScrollFrame:StripTextures();
	S:HandleScrollBar(PVPBattlegroundFrameTypeScrollFrameScrollBar);
	
	S:HandleButton(PVPBattlegroundFrameCancelButton);
	
	PVPBattlegroundFrameInfoScrollFrame:StripTextures();
	S:HandleScrollBar(PVPBattlegroundFrameInfoScrollFrameScrollBar);
	
	PVPBattlegroundFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1);
	PVPBattlegroundFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(1, 1, 1);
	
	S:HandleButton(PVPBattlegroundFrameJoinButton);
	PVPBattlegroundFrameGroupJoinButton:Point("RIGHT", PVPBattlegroundFrameJoinButton, "LEFT", -2, 0);
	S:HandleButton(PVPBattlegroundFrameGroupJoinButton);
	-- PVPFrame
	PVPParentFrame:CreateBackdrop('Transparent');
	PVPParentFrame.backdrop:Point('TOPLEFT', 13, -13);
	PVPParentFrame.backdrop:Point('BOTTOMRIGHT', -32, 76);
	
	S:HandleCloseButton(PVPParentFrameCloseButton);
	
	PVPFrame:StripTextures(true);
	
	for i = 1, MAX_ARENA_TEAMS do
		local team = _G["PVPTeam"..i];
		team:StripTextures();
		team:CreateBackdrop("Default");
		team.backdrop:Point("TOPLEFT", 9, -4);
		team.backdrop:Point("BOTTOMRIGHT", -24, 3);
		
		team:HookScript("OnEnter", S.SetModifiedBackdrop);
		team:HookScript("OnLeave", S.SetOriginalBackdrop);
		
		_G["PVPTeam"..i.."Highlight"]:Kill();
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