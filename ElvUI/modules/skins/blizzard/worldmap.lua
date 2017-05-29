local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true) then return; end

	S:HandleScrollBar(WorldMapQuestScrollFrameScrollBar);
	S:HandleScrollBar(WorldMapQuestDetailScrollFrameScrollBar, 4);
	S:HandleScrollBar(WorldMapQuestRewardScrollFrameScrollBar, 4);

	WorldMapFrame:CreateBackdrop("Transparent");
	WorldMapDetailFrame.backdrop = CreateFrame("Frame", nil, WorldMapFrame);
	WorldMapDetailFrame.backdrop:SetTemplate("Default");
	WorldMapDetailFrame.backdrop:SetOutside(WorldMapDetailFrame);
	WorldMapDetailFrame.backdrop:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() - 2);

	S:HandleCloseButton(WorldMapFrameCloseButton);

	S:HandleButton(WorldMapFrameSizeDownButton, true);
	WorldMapFrameSizeDownButton:SetSize(16, 16);
	WorldMapFrameSizeDownButton:ClearAllPoints();
	WorldMapFrameSizeDownButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0);
	WorldMapFrameSizeDownButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit");
	WorldMapFrameSizeDownButton:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit");
	WorldMapFrameSizeDownButton:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit");

	S:HandleButton(WorldMapFrameSizeUpButton, true);
	WorldMapFrameSizeUpButton:SetSize(16, 16);
	WorldMapFrameSizeUpButton:ClearAllPoints();
	WorldMapFrameSizeUpButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0);
	WorldMapFrameSizeUpButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit");
	WorldMapFrameSizeUpButton:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit");
	WorldMapFrameSizeUpButton:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit");
	WorldMapFrameSizeUpButton:GetNormalTexture():SetTexCoord(1, 1, 1, -1.2246467991474e-016, 1.1102230246252e-016, 1, 0, -1.144237745222e-017);
	WorldMapFrameSizeUpButton:GetPushedTexture():SetTexCoord(1, 1, 1, -1.2246467991474e-016, 1.1102230246252e-016, 1, 0, -1.144237745222e-017);
	WorldMapFrameSizeUpButton:GetHighlightTexture():SetTexCoord(1, 1, 1, -1.2246467991474e-016, 1.1102230246252e-016, 1, 0, -1.144237745222e-017);

	S:HandleDropDownBox(WorldMapLevelDropDown);
	S:HandleDropDownBox(WorldMapZoneMinimapDropDown);
	S:HandleDropDownBox(WorldMapContinentDropDown);
	S:HandleDropDownBox(WorldMapZoneDropDown);

	S:HandleButton(WorldMapZoomOutButton);
	WorldMapZoomOutButton:SetPoint("LEFT", WorldMapZoneDropDown, "RIGHT", 0, 3);

	S:HandleCheckBox(WorldMapTrackQuest);
	S:HandleCheckBox(WorldMapQuestShowObjectives);

	WorldMapQuestDetailScrollFrame.backdrop = CreateFrame("Frame", nil, WorldMapQuestDetailScrollFrame);
	WorldMapQuestDetailScrollFrame.backdrop:SetTemplate("Transparent");
	WorldMapQuestDetailScrollFrame.backdrop:Point("TOPLEFT", -21, 3);
	WorldMapQuestDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 25, -3);
	WorldMapQuestDetailScrollFrame.backdrop:SetFrameLevel(WorldMapQuestDetailScrollFrame:GetFrameLevel());

	WorldMapQuestDetailScrollFrameTrack:Hide();
	WorldMapQuestDetailScrollFrameTrack.Show = E.noop;

	WorldMapQuestRewardScrollFrame.backdrop = CreateFrame("Frame", nil, WorldMapQuestRewardScrollFrame);
	WorldMapQuestRewardScrollFrame.backdrop:SetTemplate("Transparent");
	WorldMapQuestRewardScrollFrame.backdrop:Point("TOPLEFT", 0, 3);
	WorldMapQuestRewardScrollFrame.backdrop:Point("BOTTOMRIGHT", 20, -3);
	WorldMapQuestRewardScrollFrame.backdrop:SetFrameLevel(WorldMapQuestRewardScrollFrame:GetFrameLevel());

	WorldMapQuestScrollFrame.backdrop = CreateFrame("Frame", nil, WorldMapQuestScrollFrame);
	WorldMapQuestScrollFrame.backdrop:SetTemplate("Transparent");
	WorldMapQuestScrollFrame.backdrop:Point("TOPLEFT", 0, 2);
	WorldMapQuestScrollFrame.backdrop:Point("BOTTOMRIGHT", 25, -2);
	WorldMapQuestScrollFrame.backdrop:SetFrameLevel(WorldMapQuestScrollFrame:GetFrameLevel());

	local function SmallSkin()
		WorldMapFrame.backdrop:ClearAllPoints();

		if(not WORLDMAP_SETTINGS.advanced) then
			WorldMapFrame.backdrop:SetPoint("TOPLEFT", 14, -12);
			WorldMapFrame.backdrop:SetPoint("BOTTOMRIGHT", -20, -12);

			WorldMapLevelDropDown:ClearAllPoints();
			WorldMapLevelDropDown:SetPoint("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -440, -38);
		else
			WorldMapFrame.backdrop:SetPoint("TOPLEFT", 4, 2);
			WorldMapFrame.backdrop:SetPoint("BOTTOMRIGHT", -1, 2);

			WorldMapLevelDropDown:ClearAllPoints();
			WorldMapLevelDropDown:SetPoint("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -420, -24);
		end
	end

	local function LargeSkin()
		WorldMapFrame.backdrop:ClearAllPoints();
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -12, 69);
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 12, -30);
	end

	local function QuestSkin()
		WorldMapFrame.backdrop:ClearAllPoints();
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -8, 69);
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 321, -234);
	end

	local function FixSkin()
		WorldMapFrame:StripTextures();

		if(WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE) then
			LargeSkin();
		elseif(WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE) then
			SmallSkin();
		elseif(WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE) then
			QuestSkin();
		end

		WorldMapFrameAreaLabel:FontTemplate(nil, 50, "OUTLINE");
		WorldMapFrameAreaLabel:SetShadowOffset(2, -2);
		WorldMapFrameAreaLabel:SetTextColor(0.90, 0.8294, 0.6407);

		WorldMapFrameAreaDescription:FontTemplate(nil, 40, "OUTLINE");
		WorldMapFrameAreaDescription:SetShadowOffset(2, -2);

		WorldMapZoneInfo:FontTemplate(nil, 27, "OUTLINE");
		WorldMapZoneInfo:SetShadowOffset(2, -2);

		WorldMapFrameSizeDownButton:ClearAllPoints();
		WorldMapFrameSizeDownButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0);

		if(InCombatLockdown()) then return; end
		WorldMapFrame:SetFrameStrata("HIGH");
		WorldMapDetailFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 1);
	end

	WorldMapFrame:HookScript("OnShow", FixSkin);
	hooksecurefunc("WorldMapFrame_SetFullMapView", LargeSkin);
	hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestSkin);
	hooksecurefunc("WorldMap_ToggleSizeUp", FixSkin);
end

S:AddCallback("SkinWorldMap", LoadSkin);