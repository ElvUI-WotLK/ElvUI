local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

S:RegisterSkin("ElvUI", function()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.arena ~= true) then return; end
	
	ArenaFrame:CreateBackdrop("Transparent");
	ArenaFrame.backdrop:Point("TOPLEFT", 11, -12);
	ArenaFrame.backdrop:Point("BOTTOMRIGHT", -34, 74);
	
	ArenaFrame:StripTextures(true);
	
	ArenaFrameZoneDescription:SetTextColor(1, 1, 1);
	
	S:HandleButton(ArenaFrameCancelButton);
	S:HandleButton(ArenaFrameJoinButton);
	S:HandleButton(ArenaFrameGroupJoinButton);
	ArenaFrameGroupJoinButton:Point("RIGHT", ArenaFrameJoinButton, "LEFT", -2, 0);
	
	S:HandleCloseButton(ArenaFrameCloseButton);
end);