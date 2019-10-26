local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.arena then return end

	ArenaFrame:StripTextures()

	ArenaFrame:CreateBackdrop("Transparent")
	ArenaFrame.backdrop:Point("TOPLEFT", 11, -12)
	ArenaFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(ArenaFrame, "width")

	ArenaFrameNameHeader:SetPoint("TOPLEFT", 28, -55)
	ArenaFrameZoneDescription:SetTextColor(1, 1, 1)

	S:HandleButton(ArenaFrameCancelButton)
	S:HandleButton(ArenaFrameJoinButton)
	S:HandleButton(ArenaFrameGroupJoinButton)
	ArenaFrameGroupJoinButton:SetPoint("RIGHT", ArenaFrameJoinButton, "LEFT", -2, 0)

	S:HandleCloseButton(ArenaFrameCloseButton, ArenaFrame.backdrop)
end

S:AddCallback("Skin_Arena", LoadSkin)