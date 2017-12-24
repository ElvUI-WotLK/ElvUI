local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	local WorldMapFrame = _G["WorldMapFrame"]
	WorldMapFrame:CreateBackdrop("Transparent")

	WorldMapDetailFrame:CreateBackdrop()
	WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
	WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)
	WorldMapDetailFrame.backdrop:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() - 2)

	WorldMapQuestDetailScrollFrame:Width(348)
	WorldMapQuestDetailScrollFrame:Point("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", -25, -207)
	WorldMapQuestDetailScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestDetailScrollFrame.backdrop:Point("TOPLEFT", 24, 2)
	WorldMapQuestDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 23, -4)
	WorldMapQuestDetailScrollFrame.backdrop:SetFrameLevel(WorldMapQuestDetailScrollFrame:GetFrameLevel())

	WorldMapQuestDetailScrollChildFrame:SetScale(1)

	WorldMapQuestDetailScrollFrameTrack:Hide()
	WorldMapQuestDetailScrollFrameTrack.Show = E.noop

	WorldMapQuestRewardScrollFrame:Width(340)
	WorldMapQuestRewardScrollFrame:Point("LEFT", WorldMapQuestDetailScrollFrame, "RIGHT", 8, 0)
	WorldMapQuestRewardScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestRewardScrollFrame.backdrop:Point("TOPLEFT", 20, 2)
	WorldMapQuestRewardScrollFrame.backdrop:Point("BOTTOMRIGHT", 22, -4)
	WorldMapQuestRewardScrollFrame.backdrop:SetFrameLevel(WorldMapQuestRewardScrollFrame:GetFrameLevel())

	WorldMapQuestRewardScrollChildFrame:SetScale(1)

	WorldMapQuestScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestScrollFrame.backdrop:Point("TOPLEFT", 0, 2)
	WorldMapQuestScrollFrame.backdrop:Point("BOTTOMRIGHT", 25, -3)
	WorldMapQuestScrollFrame.backdrop:SetFrameLevel(WorldMapQuestScrollFrame:GetFrameLevel())

	S:HandleScrollBar(WorldMapQuestScrollFrameScrollBar)
	S:HandleScrollBar(WorldMapQuestDetailScrollFrameScrollBar, 4)
	S:HandleScrollBar(WorldMapQuestRewardScrollFrameScrollBar, 4)

	S:HandleCloseButton(WorldMapFrameCloseButton)

	S:HandleButton(WorldMapFrameSizeDownButton, true)
	WorldMapFrameSizeDownButton:SetSize(16, 16)
	WorldMapFrameSizeDownButton:ClearAllPoints()
	WorldMapFrameSizeDownButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeDownButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeDownButton:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeDownButton:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")

	S:HandleButton(WorldMapFrameSizeUpButton, true)
	WorldMapFrameSizeUpButton:SetSize(16, 16)
	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)
	WorldMapFrameSizeUpButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeUpButton:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeUpButton:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	WorldMapFrameSizeUpButton:GetNormalTexture():SetTexCoord(1, 1, 1, -1.2246467991474e-016, 1.1102230246252e-016, 1, 0, -1.144237745222e-017)
	WorldMapFrameSizeUpButton:GetPushedTexture():SetTexCoord(1, 1, 1, -1.2246467991474e-016, 1.1102230246252e-016, 1, 0, -1.144237745222e-017)
	WorldMapFrameSizeUpButton:GetHighlightTexture():SetTexCoord(1, 1, 1, -1.2246467991474e-016, 1.1102230246252e-016, 1, 0, -1.144237745222e-017)

	S:HandleDropDownBox(WorldMapLevelDropDown)
	S:HandleDropDownBox(WorldMapZoneMinimapDropDown)
	S:HandleDropDownBox(WorldMapContinentDropDown)
	S:HandleDropDownBox(WorldMapZoneDropDown)

	S:HandleButton(WorldMapZoomOutButton)
	WorldMapZoomOutButton:SetPoint("LEFT", WorldMapZoneDropDown, "RIGHT", 0, 3)

	S:HandleCheckBox(WorldMapTrackQuest)
	S:HandleCheckBox(WorldMapQuestShowObjectives)

	local function SmallSkin()
		WorldMapFrame.backdrop:ClearAllPoints()

		if not WORLDMAP_SETTINGS.advanced then
			WorldMapFrame.backdrop:Point("TOPLEFT", 14, -12)
			WorldMapFrame.backdrop:Point("BOTTOMRIGHT", -20, -12)

			WorldMapLevelDropDown:ClearAllPoints()
			WorldMapLevelDropDown:Point("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -440, -38)
		else
			WorldMapFrame.backdrop:Point("TOPLEFT", 4, 2)
			WorldMapFrame.backdrop:Point("BOTTOMRIGHT", -1, 2)

			WorldMapLevelDropDown:ClearAllPoints()
			WorldMapLevelDropDown:Point("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -420, -24)
		end
	end

	local function LargeSkin()
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

		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -10, 70)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 12, -30)

		WorldMapDetailFrame.backdrop:ClearAllPoints()
		WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
		WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)
	end

	local function QuestSkin()
		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -(E.PixelMode and 10 or 11), 69)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", E.PixelMode and 321 or 322, -237)

		WorldMapDetailFrame.backdrop:ClearAllPoints()
		WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
		WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)
	end

	local function FixSkin()
		WorldMapFrame:StripTextures();

		if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
			LargeSkin()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			SmallSkin()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
			QuestSkin()
		end

		WorldMapFrameAreaLabel:FontTemplate(nil, 50, "OUTLINE")
		WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
		WorldMapFrameAreaLabel:SetTextColor(0.90, 0.8294, 0.6407)

		WorldMapFrameAreaDescription:FontTemplate(nil, 40, "OUTLINE")
		WorldMapFrameAreaDescription:SetShadowOffset(2, -2)

		WorldMapZoneInfo:FontTemplate(nil, 27, "OUTLINE")
		WorldMapZoneInfo:SetShadowOffset(2, -2)

		WorldMapFrameSizeDownButton:ClearAllPoints()
		WorldMapFrameSizeDownButton:Point("RIGHT", WorldMapFrameCloseButton, "LEFT", 4, 0)

	--	if InCombatLockdown() then return end

		--WorldMapFrame:SetFrameStrata("HIGH")
		--WorldMapPOIFrame:SetFrameStrata("HIGH")
		--WorldMapDetailFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 1)
	end

	WorldMapFrame:HookScript("OnShow", FixSkin)
	hooksecurefunc("WorldMapFrame_SetFullMapView", LargeSkin)
	hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestSkin)
	hooksecurefunc("WorldMap_ToggleSizeUp", FixSkin)
end

S:AddCallback("SkinWorldMap", LoadSkin)