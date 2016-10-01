local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true
		or E.private.skins.blizzard.bgscore ~= true)
	then
		return;
	end

	WorldStateScoreFrame:CreateBackdrop('Transparent');
	WorldStateScoreFrame.backdrop:Point('TOPLEFT', 10, -15);
	WorldStateScoreFrame.backdrop:Point('BOTTOMRIGHT', -113, 67);

	WorldStateScoreFrame:StripTextures();

	WorldStateScoreScrollFrame:StripTextures();
	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar);

	local tab
	for i = 1, 3 do
		tab = _G['WorldStateScoreFrameTab'..i];

		S:HandleTab(tab);

		_G['WorldStateScoreFrameTab'..i..'Text']:Point('CENTER', 0, 2);
	end

	S:HandleButton(WorldStateScoreFrameLeaveButton);
	S:HandleCloseButton(WorldStateScoreFrameCloseButton);

	WorldStateScoreFrameKB:StyleButton()
	WorldStateScoreFrameDeaths:StyleButton()
	WorldStateScoreFrameHK:StyleButton()
	WorldStateScoreFrameDamageDone:StyleButton()
	WorldStateScoreFrameHealingDone:StyleButton()
	WorldStateScoreFrameHonorGained:StyleButton()
	WorldStateScoreFrameName:StyleButton()
	WorldStateScoreFrameClass:StyleButton()
	WorldStateScoreFrameTeam:StyleButton()
	--WorldStateScoreFrameRatingChange:StyleButton()

	for i = 1, 5 do
		_G["WorldStateScoreColumn"..i]:StyleButton()
	end
end

S:AddCallback("WorldStateScore", LoadSkin);