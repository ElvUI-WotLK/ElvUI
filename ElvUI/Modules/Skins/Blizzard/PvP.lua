local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
--WoW API / Variables
local CanQueueForWintergrasp = CanQueueForWintergrasp

S:AddCallback("Skin_PvP", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.pvp then return end

	PVPParentFrame:CreateBackdrop("Transparent")
	PVPParentFrame.backdrop:Point("TOPLEFT", 11, -12)
	PVPParentFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(PVPParentFrame, "width")
	S:SetBackdropHitRect(PVPParentFrame)
	S:SetBackdropHitRect(PVPFrame, PVPParentFrame.backdrop)
	S:SetBackdropHitRect(PVPBattlegroundFrame, PVPParentFrame.backdrop)

	S:HandleCloseButton(PVPParentFrameCloseButton, PVPParentFrame.backdrop)

	S:HandleTab(PVPParentFrameTab1)
	S:HandleTab(PVPParentFrameTab2)

	PVPFrame:StripTextures(true)

	for i = 1, MAX_ARENA_TEAMS do
		local pvpTeam = _G["PVPTeam"..i]
		pvpTeam:StripTextures()
		pvpTeam:CreateBackdrop("Default")
		pvpTeam.backdrop:Point("TOPLEFT", 9, -4)
		pvpTeam.backdrop:Point("BOTTOMRIGHT", -24, 3)
		S:SetBackdropHitRect(pvpTeam)

		pvpTeam:HookScript("OnEnter", S.SetModifiedBackdrop)
		pvpTeam:HookScript("OnLeave", S.SetOriginalBackdrop)

		_G["PVPTeam"..i.."Highlight"]:Kill()
	end

	-- PVP Team Details
	PVPTeamDetails:StripTextures()
	PVPTeamDetails:SetTemplate("Transparent")
	PVPTeamDetails:Point("TOPLEFT", PVPFrame, "TOPRIGHT", -33, -81)

	S:HandleCloseButton(PVPTeamDetailsCloseButton, PVPTeamDetails)

	for i = 1, 5 do
		_G["PVPTeamDetailsFrameColumnHeader"..i]:StripTextures()
	end

	for i = 1, MAX_ARENA_TEAM_MEMBERS do
		S:HandleButtonHighlight(_G["PVPTeamDetailsButton"..i])
	end

	S:HandleButton(PVPTeamDetailsAddTeamMember)
	S:HandleNextPrevButton(PVPTeamDetailsToggleButton)

	PVPTeamDetailsAddTeamMember:Point("TOPLEFT", PVPTeamDetailsButton10, "BOTTOMLEFT", 5, -8)
	PVPTeamDetailsToggleButton:Point("BOTTOMRIGHT", -20, 25)

	-- PVP Battleground Frame
	PVPBattlegroundFrame:StripTextures(true)

	PVPBattlegroundFrameTypeScrollFrame:StripTextures()
	S:HandleScrollBar(PVPBattlegroundFrameTypeScrollFrameScrollBar)

	PVPBattlegroundFrameInfoScrollFrame:StripTextures()
	S:HandleScrollBar(PVPBattlegroundFrameInfoScrollFrameScrollBar)

	S:HandleButton(PVPBattlegroundFrameGroupJoinButton)
	S:HandleButton(PVPBattlegroundFrameJoinButton)
	S:HandleButton(PVPBattlegroundFrameCancelButton)

	for i = 1, 5 do
		S:HandleButtonHighlight(_G["BattlegroundType"..i])
	end

	PVPBattlegroundFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)
	PVPBattlegroundFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(1, 1, 1)

	PVPBattlegroundFrameTypeScrollFrameScrollBar:Point("TOPLEFT", PVPBattlegroundFrameTypeScrollFrame, "TOPRIGHT", 6, -19)
	PVPBattlegroundFrameTypeScrollFrameScrollBar:Point("BOTTOMLEFT", PVPBattlegroundFrameTypeScrollFrame, "BOTTOMRIGHT", 6, 19)

	PVPBattlegroundFrameInfoScrollFrame:Point("BOTTOMLEFT", 19, 114)

	PVPBattlegroundFrameInfoScrollFrameScrollBar:Point("TOPLEFT", PVPBattlegroundFrameInfoScrollFrame, "TOPRIGHT", 7, -24)
	PVPBattlegroundFrameInfoScrollFrameScrollBar:Point("BOTTOMLEFT", PVPBattlegroundFrameInfoScrollFrame, "BOTTOMRIGHT", 7, 19)

	PVPBattlegroundFrameGroupJoinButton:Width(127)
	PVPBattlegroundFrameCancelButton:Point("CENTER", PVPBattlegroundFrame, "TOPLEFT", 300, -416)
	PVPBattlegroundFrameJoinButton:Point("RIGHT", PVPBattlegroundFrameCancelButton, "LEFT", -3, 0)
	PVPBattlegroundFrameGroupJoinButton:Point("RIGHT", PVPBattlegroundFrameJoinButton, "LEFT", -3, 0)

	WintergraspTimer:Size(24)
	WintergraspTimer:SetTemplate("Default")
	WintergraspTimer:Point("RIGHT", PVPBattlegroundFrame, "TOPRIGHT", -42, -58)

	WintergraspTimer.texture:SetDrawLayer("ARTWORK")
	WintergraspTimer.texture:SetInside()

	WintergraspTimer:HookScript("OnUpdate", function(self)
		if CanQueueForWintergrasp() then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 32, 64, 20, 20, 6, 38
			self.texture:SetTexCoord(0.1875, 0.8125, 0.59375, 0.90625)
		else
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 32, 64, 20, 20, 6, 6
			self.texture:SetTexCoord(0.1875, 0.8125, 0.09375, 0.40625)
		end
	end)

	-- Battlefield Frame
	BattlefieldFrame:StripTextures(true)
	BattlefieldFrame:CreateBackdrop("Transparent")
	BattlefieldFrame.backdrop:Point("TOPLEFT", 11, -12)
	BattlefieldFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(BattlefieldFrame, "width")
	S:SetBackdropHitRect(BattlefieldFrame)

	S:HandleCloseButton(BattlefieldFrameCloseButton, BattlefieldFrame.backdrop)

	BattlefieldListScrollFrame:StripTextures()
	S:HandleScrollBar(BattlefieldListScrollFrameScrollBar)
	S:HandleScrollBar(BattlefieldFrameInfoScrollFrameScrollBar)

	BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)
	BattlefieldFrameInfoScrollFrameChildFrameRewardsInfoDescription:SetTextColor(1, 1, 1)

	S:HandleButton(BattlefieldFrameGroupJoinButton)
	S:HandleButton(BattlefieldFrameJoinButton)
	S:HandleButton(BattlefieldFrameCancelButton)

	for i = 1, BATTLEFIELD_ZONES_DISPLAYED do
		S:HandleButtonHighlight(_G["BattlefieldZone"..i])
	end

	BattlefieldFrameNameHeader:Point("TOPLEFT", 73, -57)

	BattlefieldZone1:Point("TOPLEFT", 25, -80)

	BattlefieldListScrollFrameScrollBar:Point("TOPLEFT", BattlefieldListScrollFrame, "TOPRIGHT", 9, -23)
	BattlefieldListScrollFrameScrollBar:Point("BOTTOMLEFT", BattlefieldListScrollFrame, "BOTTOMRIGHT", 9, 23)

	BattlefieldFrameInfoScrollFrame:Point("BOTTOMLEFT", 21, 113)

	BattlefieldFrameInfoScrollFrameScrollBar:Point("TOPLEFT", BattlefieldFrameInfoScrollFrame, "TOPRIGHT", 7, -20)
	BattlefieldFrameInfoScrollFrameScrollBar:Point("BOTTOMLEFT", BattlefieldFrameInfoScrollFrame, "BOTTOMRIGHT", 7, 19)

	BattlefieldFrameGroupJoinButton:Width(127)
	BattlefieldFrameGroupJoinButton:Point("RIGHT", BattlefieldFrameJoinButton, "LEFT", -3, 0)
	BattlefieldFrameJoinButton:Point("RIGHT", BattlefieldFrameCancelButton, "LEFT", -3, 0)
	BattlefieldFrameCancelButton:Point("CENTER", BattlefieldFrame, "TOPLEFT", 302, -417)
end)