local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallback("Skin_WorldMap", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.worldmap then return end

	WorldMapFrame:DisableDrawLayer("BACKGROUND")
	WorldMapFrame:DisableDrawLayer("ARTWORK")
	WorldMapFrame:DisableDrawLayer("OVERLAY")
	WorldMapFrame:CreateBackdrop("Transparent")
	WorldMapFrame.backdrop:Point("TOPRIGHT", WorldMapFrameCloseButton, -3, 0)
	WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapTrackQuest, 0, -3)
	WorldMapFrame:SetClampRectInsets(3, 0, 2, 1)

	WorldMapFrameTitle:SetDrawLayer("BORDER")

	WorldMapTitleButton:Width(530)
	WorldMapTitleButton:Point("TOPLEFT", WorldMapFrameMiniBorderLeft, "TOPLEFT", 4, 1)

	WorldMapDetailFrame:CreateBackdrop()
	WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
	WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)

	WorldMapQuestDetailScrollFrame:Width(348)
	WorldMapQuestDetailScrollFrame:Point("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", -25, -207)
	WorldMapQuestDetailScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestDetailScrollFrame.backdrop:Point("TOPLEFT", 24, 2)
	WorldMapQuestDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 23, -4)
	WorldMapQuestDetailScrollFrame.backdrop:SetFrameLevel(WorldMapQuestDetailScrollFrame:GetFrameLevel())
	WorldMapQuestDetailScrollFrame:SetHitRectInsets(24, -23, 0, -2)

	WorldMapQuestDetailScrollChildFrame:SetScale(1)

	WorldMapQuestDetailScrollFrameTrack:Kill()

	WorldMapQuestRewardScrollFrame:Width(340)
	WorldMapQuestRewardScrollFrame:Point("LEFT", WorldMapQuestDetailScrollFrame, "RIGHT", 8, 0)
	WorldMapQuestRewardScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestRewardScrollFrame.backdrop:Point("TOPLEFT", 20, 2)
	WorldMapQuestRewardScrollFrame.backdrop:Point("BOTTOMRIGHT", 22, -4)
	WorldMapQuestRewardScrollFrame.backdrop:SetFrameLevel(WorldMapQuestRewardScrollFrame:GetFrameLevel())
	WorldMapQuestRewardScrollFrame:SetHitRectInsets(20, -22, 0, -2)

	WorldMapQuestRewardScrollChildFrame:SetScale(1)

	WorldMapQuestRewardScrollFrameTrack:SetTexture()

	WorldMapQuestScrollFrame:Point("TOPLEFT", WorldMapDetailFrame, "TOPRIGHT", 6, -1)
	WorldMapQuestScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestScrollFrame.backdrop:Point("TOPLEFT", 0, 2)
	WorldMapQuestScrollFrame.backdrop:Point("BOTTOMRIGHT", 25, -1)
	WorldMapQuestScrollFrame.backdrop:SetFrameLevel(WorldMapQuestScrollFrame:GetFrameLevel())

	WorldMapQuestSelectBar:SetTexture(E.Media.Textures.Highlight)
	WorldMapQuestSelectBar:SetAlpha(0.35)

	WorldMapQuestHighlightBar:SetTexture(E.Media.Textures.Highlight)
	WorldMapQuestHighlightBar:SetAlpha(0.35)

	S:HandleScrollBar(WorldMapQuestScrollFrameScrollBar)
	S:HandleScrollBar(WorldMapQuestDetailScrollFrameScrollBar)
	S:HandleScrollBar(WorldMapQuestRewardScrollFrameScrollBar)

	WorldMapQuestScrollFrameScrollBar:Point("TOPLEFT", WorldMapQuestScrollFrame, "TOPRIGHT", 5, -19)
	WorldMapQuestScrollFrameScrollBar:Point("BOTTOMLEFT", WorldMapQuestScrollFrame, "BOTTOMRIGHT", 5, 20)

	WorldMapQuestDetailScrollFrameScrollBar:Point("TOPLEFT", WorldMapQuestDetailScrollFrame, "TOPRIGHT", 3, -19)
	WorldMapQuestDetailScrollFrameScrollBar:Point("BOTTOMLEFT", WorldMapQuestDetailScrollFrame, "BOTTOMRIGHT", 3, 17)

	WorldMapQuestRewardScrollFrameScrollBar:Point("TOPLEFT", WorldMapQuestRewardScrollFrame, "TOPRIGHT", 2, -19)
	WorldMapQuestRewardScrollFrameScrollBar:Point("BOTTOMLEFT", WorldMapQuestRewardScrollFrame, "BOTTOMRIGHT", 2, 17)

	S:HandleCloseButton(WorldMapFrameCloseButton)

	WorldMapFrameSizeDownButton:ClearAllPoints()
	WorldMapFrameSizeDownButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeDownButton.SetPoint = E.noop
	WorldMapFrameSizeDownButton:GetHighlightTexture():Kill()
	S:HandleNextPrevButton(WorldMapFrameSizeDownButton, "down", nil, true)
	WorldMapFrameSizeDownButton:Size(26)

	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeUpButton:GetHighlightTexture():Kill()
	S:HandleNextPrevButton(WorldMapFrameSizeUpButton, "up", nil, true)
	WorldMapFrameSizeUpButton:Size(26)

	S:HandleDropDownBox(WorldMapLevelDropDown)
	S:HandleDropDownBox(WorldMapZoneMinimapDropDown)
	S:HandleDropDownBox(WorldMapContinentDropDown)
	S:HandleDropDownBox(WorldMapZoneDropDown)

	WorldMapLevelUpButton:Point("TOPLEFT", WorldMapLevelDropDown, "TOPRIGHT", -6, 4)
	WorldMapLevelDownButton:Point("BOTTOMLEFT", WorldMapLevelDropDown, "BOTTOMRIGHT", -6, 0)

	S:HandleButton(WorldMapZoomOutButton)
	WorldMapZoomOutButton:Point("LEFT", WorldMapZoneDropDown, "RIGHT", 0, 3)

	S:HandleCheckBox(WorldMapTrackQuest)
	S:HandleCheckBox(WorldMapQuestShowObjectives)

	WorldMapFrameAreaLabel:FontTemplate(nil, 50, "OUTLINE")
	WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
	WorldMapFrameAreaLabel:SetTextColor(0.90, 0.8294, 0.6407)

	WorldMapFrameAreaDescription:FontTemplate(nil, 40, "OUTLINE")
	WorldMapFrameAreaDescription:SetShadowOffset(2, -2)

	WorldMapZoneInfo:FontTemplate(nil, 27, "OUTLINE")
	WorldMapZoneInfo:SetShadowOffset(2, -2)

	WorldMapLevelDropDown.SetPoint = E.noop

	local setPoint = UIParent.SetPoint
	local currentMapMode

	local function SmallSkin()
		if WORLDMAP_SETTINGS.advanced then
			if currentMapMode == 0 then return end
			currentMapMode = 0

			WorldMapFrame.backdrop:Point("TOPLEFT", 3, 2)
			WorldMapFrame.backdrop:Point("TOPRIGHT", WorldMapFrameCloseButton, -3, 0)

			WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
			WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 1, -1)

			setPoint(WorldMapLevelDropDown, "TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -419, -24)
		else
			if currentMapMode == 1 then return end
			currentMapMode = 1

			WorldMapFrame.backdrop:Point("TOPLEFT", 11, -12)
			WorldMapFrame.backdrop:Point("TOPRIGHT", WorldMapFrameCloseButton, -1, 0)

			WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
			WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)

			setPoint(WorldMapLevelDropDown, "TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -439, -38)
		end
	end

	local function LargeSkin()
		if currentMapMode == 2 then return end
		currentMapMode = 2

		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -8, 70)
		WorldMapFrame.backdrop:Point("TOPRIGHT", WorldMapFrameCloseButton, -3, 0)

		WorldMapDetailFrame.backdrop:Point("TOPLEFT", -1, 1)
		WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 1, -1)

		setPoint(WorldMapLevelDropDown, "TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -50, -35)
	end

	local function QuestSkin()
		if currentMapMode == 3 then return end
		currentMapMode = 3

		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -9, 70)
		WorldMapFrame.backdrop:Point("TOPRIGHT", WorldMapFrameCloseButton, -3, 0)

		WorldMapDetailFrame.backdrop:Point("TOPLEFT", -1, 1)
		WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 1, -1)

		setPoint(WorldMapLevelDropDown, "TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -50, -35)
	end

	local function FixSkin()
		if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
			LargeSkin()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			SmallSkin()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
			QuestSkin()
		end
	end

	if not E.private.worldmap.enable then
		WorldMapFrame:EnableMouse(false)
		WorldMapFrame.EnableMouse = E.noop
	end

	WorldMapTitleButton:Hide()
	WorldMapFrame.backdrop:EnableMouse(true)

	FixSkin()
	S:SetUIPanelWindowInfo(WorldMapFrame, "width", 594)

	hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestSkin)
	hooksecurefunc("WorldMapFrame_SetFullMapView", LargeSkin)
	hooksecurefunc("WorldMapFrame_SetMiniMode", SmallSkin)
	hooksecurefunc("ToggleMapFramerate", FixSkin)
	hooksecurefunc("WorldMapFrame_ToggleAdvanced", FixSkin)
end)