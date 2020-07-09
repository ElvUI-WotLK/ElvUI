local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallback("Skin_Arena", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.arena then return end

	ArenaFrame:StripTextures()

	ArenaFrame:CreateBackdrop("Transparent")
	ArenaFrame.backdrop:Point("TOPLEFT", 11, -12)
	ArenaFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(ArenaFrame, "width")
	S:SetBackdropHitRect(ArenaFrame)

	S:HandleCloseButton(ArenaFrameCloseButton, ArenaFrame.backdrop)

	S:HandleButton(ArenaFrameGroupJoinButton)
	S:HandleButton(ArenaFrameJoinButton)
	S:HandleButton(ArenaFrameCancelButton)

	for i = 1, MAX_ARENA_BATTLES do
		S:HandleButtonHighlight(_G["ArenaZone"..i])
	end

	ArenaFrameZoneDescription:SetTextColor(1, 1, 1)

	ArenaFrameNameHeader:Point("TOPLEFT", 28, -55)

	ArenaZone1:Point("TOPLEFT", 24, -79)

	ArenaFrameGroupJoinButton:Width(127)

	ArenaFrameCancelButton:Point("CENTER", ArenaFrame, "TOPLEFT", 302, -417)
	ArenaFrameJoinButton:Point("RIGHT", ArenaFrameCancelButton, "LEFT", -3, 0)
	ArenaFrameGroupJoinButton:Point("RIGHT", ArenaFrameJoinButton, "LEFT", -3, 0)
end)