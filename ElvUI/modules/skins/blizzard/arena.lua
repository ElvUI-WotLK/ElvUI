local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.arena ~= true) then return; end

	ArenaFrame:CreateBackdrop("Transparent");
	ArenaFrame.backdrop:Point("TOPLEFT", 11, -12);
	ArenaFrame.backdrop:Point("BOTTOMRIGHT", -34, 74);

	ArenaFrame:StripTextures(true);

	ArenaFrameNameHeader:Point("TOPLEFT", 28, -55)
	ArenaFrameZoneDescription:SetTextColor(1, 1, 1);

	S:HandleButton(ArenaFrameCancelButton);
	S:HandleButton(ArenaFrameJoinButton);
	S:HandleButton(ArenaFrameGroupJoinButton);
	ArenaFrameGroupJoinButton:Point("RIGHT", ArenaFrameJoinButton, "LEFT", -2, 0);

	S:HandleCloseButton(ArenaFrameCloseButton);
end

S:AddCallback("Arena", LoadSkin);