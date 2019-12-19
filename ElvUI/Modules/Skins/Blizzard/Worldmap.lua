local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables
local InCombatLockdown = InCombatLockdown

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.worldmap then return end

	WorldMapFrame:DisableDrawLayer("BACKGROUND")
	WorldMapFrame:DisableDrawLayer("ARTWORK")
	WorldMapFrame:DisableDrawLayer("OVERLAY")
	WorldMapFrame:CreateBackdrop("Transparent")
	WorldMapFrame.backdrop:Point("TOPRIGHT", WorldMapFrameCloseButton, -3, 0)
	WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapTrackQuest, 0, -3)

	WorldMapFrameTitle:SetDrawLayer("BORDER")

	WorldMapDetailFrame:CreateBackdrop()
	WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
	WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)

	WorldMapQuestDetailScrollFrame:Width(348)
	WorldMapQuestDetailScrollFrame:Point("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", -25, -207)
	WorldMapQuestDetailScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestDetailScrollFrame.backdrop:Point("TOPLEFT", 24, 2)
	WorldMapQuestDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 23, -4)
	WorldMapQuestDetailScrollFrame:SetHitRectInsets(24, -23, 0, -2)
	WorldMapQuestDetailScrollFrame.backdrop:SetFrameLevel(WorldMapQuestDetailScrollFrame:GetFrameLevel())

	WorldMapQuestDetailScrollChildFrame:SetScale(1)

	WorldMapQuestDetailScrollFrameTrack:Kill()

	WorldMapQuestRewardScrollFrame:Width(340)
	WorldMapQuestRewardScrollFrame:Point("LEFT", WorldMapQuestDetailScrollFrame, "RIGHT", 8, 0)
	WorldMapQuestRewardScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestRewardScrollFrame.backdrop:Point("TOPLEFT", 20, 2)
	WorldMapQuestRewardScrollFrame.backdrop:Point("BOTTOMRIGHT", 22, -4)
	WorldMapQuestRewardScrollFrame:SetHitRectInsets(20, -22, 0, -2)
	WorldMapQuestRewardScrollFrame.backdrop:SetFrameLevel(WorldMapQuestRewardScrollFrame:GetFrameLevel())

	WorldMapQuestRewardScrollChildFrame:SetScale(1)

	WorldMapQuestScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestScrollFrame.backdrop:Point("TOPLEFT", 0, 2)
	WorldMapQuestScrollFrame.backdrop:Point("BOTTOMRIGHT", 25, -3)
	WorldMapQuestScrollFrame.backdrop:SetFrameLevel(WorldMapQuestScrollFrame:GetFrameLevel())

	WorldMapQuestSelectBar:SetTexture(E.Media.Textures.Highlight)
	WorldMapQuestSelectBar:SetAlpha(0.35)

	WorldMapQuestHighlightBar:SetTexture(E.Media.Textures.Highlight)
	WorldMapQuestHighlightBar:SetAlpha(0.35)

	S:HandleScrollBar(WorldMapQuestScrollFrameScrollBar)
	S:HandleScrollBar(WorldMapQuestDetailScrollFrameScrollBar, 4)
	S:HandleScrollBar(WorldMapQuestRewardScrollFrameScrollBar, 4)

	S:HandleCloseButton(WorldMapFrameCloseButton)

	WorldMapFrameSizeDownButton:ClearAllPoints()
	WorldMapFrameSizeDownButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeDownButton.SetPoint = E.noop
	WorldMapFrameSizeDownButton:GetHighlightTexture():Kill()
	S:HandleNextPrevButton(WorldMapFrameSizeDownButton, nil, nil, true)
	WorldMapFrameSizeDownButton:Size(26)

	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeUpButton:GetHighlightTexture():Kill()
	S:HandleNextPrevButton(WorldMapFrameSizeUpButton, nil, nil, true)
	WorldMapFrameSizeUpButton:Size(26)

	S:HandleDropDownBox(WorldMapLevelDropDown)
	S:HandleDropDownBox(WorldMapZoneMinimapDropDown)
	S:HandleDropDownBox(WorldMapContinentDropDown)
	S:HandleDropDownBox(WorldMapZoneDropDown)

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

	local function SmallSkin()
		if WORLDMAP_SETTINGS.advanced then
			WorldMapFrame.backdrop:Point("TOPLEFT", 4, 2)

			WorldMapLevelDropDown:ClearAllPoints()
			WorldMapLevelDropDown:Point("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -420, -24)
		else
			WorldMapFrame.backdrop:Point("TOPLEFT", 11, -12)

			WorldMapLevelDropDown:ClearAllPoints()
			WorldMapLevelDropDown:Point("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -440, -38)
		end
	end

	local function LargeSkin()
		if not E.private.worldmap.enable or (E.private.worldmap.enable and not E.global.general.smallerWorldMap) then
			if not InCombatLockdown() then
				WorldMapFrame:EnableMouse(false)
				WorldMapFrame:EnableKeyboard(false)
			elseif not WorldMapFrame:IsEventRegistered("PLAYER_REGEN_ENABLED") then
				WorldMapFrame:RegisterEvent("PLAYER_REGEN_ENABLED", function(self)
					self:EnableMouse(false)
					self:EnableKeyboard(false)
					self:UnregisterEvent("PLAYER_REGEN_ENABLED")
				end)
			end
		end

		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -13, 70)
	end

	local function QuestSkin()
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -14, 70)
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
		ShowUIPanel(WorldMapFrame)
		FixSkin()
		HideUIPanel(WorldMapFrame)
	else
		FixSkin()
	end

	hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestSkin)
	hooksecurefunc("WorldMapFrame_SetFullMapView", LargeSkin)
	hooksecurefunc("WorldMapFrame_SetMiniMode", SmallSkin)
	hooksecurefunc("ToggleMapFramerate", FixSkin)
	hooksecurefunc("WorldMapFrame_ToggleAdvanced", FixSkin)
end

S:AddCallback("Skin_WorldMap", LoadSkin)