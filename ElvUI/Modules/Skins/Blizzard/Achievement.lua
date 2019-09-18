local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs = ipairs
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local GetAchievementNumCriteria = GetAchievementNumCriteria
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo
local CRITERIA_TYPE_ACHIEVEMENT = CRITERIA_TYPE_ACHIEVEMENT

local function LoadSkin(preSkin)
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.achievement then return end

	local function skinAchievement(achievement, biggerIcon)
		if achievement.isSkinned then return end

		achievement:StripTextures(true)
		achievement:SetTemplate("Default", true)
		achievement.icon:SetTemplate()
		achievement.icon:SetSize(biggerIcon and 54 or 36, biggerIcon and 54 or 36)
		achievement.icon:ClearAllPoints()
		achievement.icon:Point("TOPLEFT", 8, -8)
		achievement.icon.bling:Kill()
		achievement.icon.frame:Kill()
		achievement.icon.texture:SetTexCoord(unpack(E.TexCoords))
		achievement.icon.texture:SetInside()

		if achievement.highlight then
			achievement.highlight:StripTextures()
			achievement:HookScript("OnEnter", S.SetModifiedBackdrop)
			achievement:HookScript("OnLeave", S.SetOriginalBackdrop)
		end

		if achievement.label then
			achievement.label:SetTextColor(1, 1, 1)
		end

		if achievement.description then
			achievement.description:SetTextColor(.6, .6, .6)

			hooksecurefunc(achievement.description, "SetTextColor", function(self)
				if self._blocked then return end
				self._blocked = true
				self:SetTextColor(.6, .6, .6)
				self._blocked = nil
			end)
		end

		if achievement.hiddenDescription then
			achievement.hiddenDescription:SetTextColor(1, 1, 1)
		end

		if achievement.tracked then
			S:HandleCheckBox(achievement.tracked, true)
			achievement.tracked:Size(14, 14)
			achievement.tracked:ClearAllPoints()
			achievement.tracked:Point("TOPLEFT", achievement.icon, "BOTTOMLEFT", 0, -2)
		end

		hooksecurefunc(achievement, "Saturate", function(self)
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)
		hooksecurefunc(achievement, "Desaturate", function(self)
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)

		achievement.isSkinned = true
	end

	if preSkin then
		hooksecurefunc("HybridScrollFrame_CreateButtons", function(frame, template)
			if template == "AchievementCategoryTemplate" then
				for _, button in ipairs(frame.buttons) do
					if not button.isSkinned then
						button:StripTextures(true)
						button:StyleButton()
						button.isSkinned = true
					end
				end
			elseif template == "AchievementTemplate" then
				for _, achievement in ipairs(frame.buttons) do
					skinAchievement(achievement, true)
				end
			elseif template == "ComparisonTemplate" then
				for _, achievement in ipairs(frame.buttons) do
					skinAchievement(achievement.player)
					skinAchievement(achievement.friend)
				end
			elseif template == "StatTemplate" then
				for _, stats in ipairs(frame.buttons) do
					if not stats.isSkinned then
					--	stats:StripTextures(true)
						stats:StyleButton()
						stats.isSkinned = true
					end
				end
			end
		end)

		if not IsAddOnLoaded("Blizzard_AchievementUI") then return end
	end

	local frames = {
		"AchievementFrame",
		"AchievementFrameCategories",
		"AchievementFrameSummary",
		"AchievementFrameHeader",
		"AchievementFrameSummaryCategoriesHeader",
		"AchievementFrameSummaryAchievementsHeader",
		"AchievementFrameStatsBG",
		"AchievementFrameAchievements",
		"AchievementFrameComparison",
		"AchievementFrameComparisonHeader",
		"AchievementFrameComparisonSummaryPlayer",
		"AchievementFrameComparisonSummaryFriend"
	}

	for _, frame in ipairs(frames) do
		_G[frame]:StripTextures(true)
	end

	local nonameFrames = {
		"AchievementFrameStats",
		"AchievementFrameSummary",
		"AchievementFrameAchievements",
		"AchievementFrameComparison"
	}

	for _, frame in ipairs(nonameFrames) do
		frame = _G[frame]
		for i = 1, frame:GetNumChildren() do
			local child = select(i, frame:GetChildren())
			if child and not child:GetName() then
				child:SetBackdrop(nil)
			end
		end
	end

	AchievementFrame:CreateBackdrop("Transparent")
	AchievementFrame.backdrop:Point("TOPLEFT", 0, 6)
	AchievementFrame.backdrop:Point("BOTTOMRIGHT")
	AchievementFrameHeaderTitle:ClearAllPoints()
	AchievementFrameHeaderTitle:Point("TOPLEFT", AchievementFrame.backdrop, "TOPLEFT", -30, -8)
	AchievementFrameHeaderPoints:ClearAllPoints()
	AchievementFrameHeaderPoints:Point("LEFT", AchievementFrameHeaderTitle, "RIGHT", 2, 0)

	AchievementFrameCategoriesContainer:CreateBackdrop("Default")
	AchievementFrameCategoriesContainer.backdrop:Point("TOPLEFT", 0, 4)
	AchievementFrameCategoriesContainer.backdrop:Point("BOTTOMRIGHT", -2, -3)
	AchievementFrameAchievementsContainer:CreateBackdrop("Transparent")
	AchievementFrameAchievementsContainer.backdrop:Point("TOPLEFT", -2, 2)
	AchievementFrameAchievementsContainer.backdrop:Point("BOTTOMRIGHT", -2, -3)

	S:HandleCloseButton(AchievementFrameCloseButton, AchievementFrame.backdrop)
	S:HandleDropDownBox(AchievementFrameFilterDropDown)
	AchievementFrameFilterDropDown:Point("TOPRIGHT", AchievementFrame, "TOPRIGHT", -44, 5)

	S:HandleScrollBar(AchievementFrameCategoriesContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameAchievementsContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameStatsContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameComparisonContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameComparisonStatsContainerScrollBar, 5)

	for i = 1, 2 do
		S:HandleTab(_G["AchievementFrameTab"..i])
	end

	local sbcR, sbcG, sbcB = 4/255, 179/255, 30/255

	local function skinStatusBar(bar)
		bar:StripTextures()
		bar:SetStatusBarTexture(E.media.normTex)
		bar:SetStatusBarColor(sbcR, sbcG, sbcB)
		bar:CreateBackdrop("Default")
		E:RegisterStatusBar(bar)

		local barName = bar:GetName()
		local title = _G[barName.."Title"]
		local label = _G[barName.."Label"]
		local text = _G[barName.."Text"]

		if title then
			title:Point("LEFT", 4, 0)
		end

		if label then
			label:Point("LEFT", 4, 0)
		end

		if text then
			text:Point("RIGHT", -4, 0)
		end
	end

	skinStatusBar(AchievementFrameSummaryCategoriesStatusBar)
	skinStatusBar(AchievementFrameComparisonSummaryPlayerStatusBar)
	skinStatusBar(AchievementFrameComparisonSummaryFriendStatusBar)
	AchievementFrameComparisonSummaryFriendStatusBar.text:ClearAllPoints()
	AchievementFrameComparisonSummaryFriendStatusBar.text:Point("CENTER")
	AchievementFrameComparisonHeader:Point("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 45, -20)

	for i = 1, 8 do
		local frame = _G["AchievementFrameSummaryCategoriesCategory"..i]
		local button = _G["AchievementFrameSummaryCategoriesCategory"..i.."Button"]
		local highlight = _G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]
		local middle = _G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlightMiddle"]

		skinStatusBar(frame)
		button:StripTextures()
		highlight:StripTextures()

		middle:SetTexture(1, 1, 1, 0.3)
		middle:SetAllPoints(frame)
	end

	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		local frame, prevFrame

		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			frame = _G["AchievementFrameSummaryAchievement"..i]

			skinAchievement(frame)

			if i ~= 1 then
				prevFrame = _G["AchievementFrameSummaryAchievement"..(i-1)]
				frame:ClearAllPoints()
				frame:Point("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, -1)
				frame:Point("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 1)
			end

			frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	for i = 1, 20 do
		_G["AchievementFrameStatsContainerButton"..i]:StyleButton()
		_G["AchievementFrameStatsContainerButton"..i.."BG"]:SetTexture(1, 1, 1, 0.2)
		_G["AchievementFrameStatsContainerButton"..i.."HeaderLeft"]:Kill()
		_G["AchievementFrameStatsContainerButton"..i.."HeaderRight"]:Kill()
		_G["AchievementFrameStatsContainerButton"..i.."HeaderMiddle"]:Kill()

		local frame = _G["AchievementFrameComparisonStatsContainerButton"..i]
		frame:StripTextures()
		frame:StyleButton()
		_G["AchievementFrameComparisonStatsContainerButton"..i.."BG"]:SetTexture(1, 1, 1, 0.2)
		_G["AchievementFrameComparisonStatsContainerButton"..i.."HeaderLeft"]:Kill()
		_G["AchievementFrameComparisonStatsContainerButton"..i.."HeaderRight"]:Kill()
		_G["AchievementFrameComparisonStatsContainerButton"..i.."HeaderMiddle"]:Kill()
	end

	hooksecurefunc("AchievementButton_GetProgressBar", function(index)
		local frame = _G["AchievementFrameProgressBar"..index]

		if frame and not frame.skinned then
			frame:StripTextures()
			frame:SetStatusBarTexture(E.media.normTex)
			E:RegisterStatusBar(frame)
			frame:SetStatusBarColor(sbcR, sbcG, sbcB)
			frame:GetStatusBarTexture():SetInside()
			frame:Height(frame:GetHeight() + (E.Border + E.Spacing))
			frame:SetTemplate("Default")

			frame.text:ClearAllPoints()
			frame.text:Point("CENTER", frame, "CENTER", 0, -1)
			frame.text:SetJustifyH("CENTER")

			if index > 1 then
				frame:ClearAllPoints()
				frame:Point("TOP", _G["AchievementFrameProgressBar"..index-1], "BOTTOM", 0, -5)
				frame.SetPoint = E.noop
				frame.ClearAllPoints = E.noop
			end

			frame.skinned = true
		end
	end)

	hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
		local numCriteria = GetAchievementNumCriteria(id)
		local textStrings, metas = 0, 0

		for i = 1, numCriteria do
			local _, criteriaType, completed, _, _, _, _, assetID = GetAchievementCriteriaInfo(id, i)

			if criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID then
				metas = metas + 1
				local metaCriteria = AchievementButton_GetMeta(metas)

				metaCriteria:Height(21)
				metaCriteria:StyleButton()
				metaCriteria.border:Kill()
				metaCriteria.icon:SetTexCoord(unpack(E.TexCoords))
				metaCriteria.icon:Point("TOPLEFT", 2, -2)
				metaCriteria.label:Point("LEFT", 26, 0)

				if objectivesFrame.completed and completed then
					metaCriteria.label:SetShadowOffset(0, 0)
					metaCriteria.label:SetTextColor(1, 1, 1, 1)
				elseif completed then
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(0, 1, 0, 1)
				else
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(.6, .6, .6, 1)
				end
			elseif criteriaType ~= 1 then
				textStrings = textStrings + 1
				local criteria = AchievementButton_GetCriteria(textStrings)

				if objectivesFrame.completed and completed then
					criteria.name:SetTextColor(1, 1, 1, 1)
					criteria.name:SetShadowOffset(0, 0)
				elseif completed then
					criteria.name:SetTextColor(0, 1, 0, 1)
					criteria.name:SetShadowOffset(1, -1)
				else
					criteria.name:SetTextColor(.6, .6, .6, 1)
					criteria.name:SetShadowOffset(1, -1)
				end
			end
		end
	end)

	hooksecurefunc("AchievementObjectives_DisplayProgressiveAchievement", function(objectivesFrame, id)
		local mini

		for i = 1, 12 do
			mini = _G["AchievementFrameMiniAchievement"..i]

			if mini and not mini.isSkinned then
				local icon = _G["AchievementFrameMiniAchievement"..i.."Icon"]
				local points = _G["AchievementFrameMiniAchievement"..i.."Points"]
				local border = _G["AchievementFrameMiniAchievement"..i.."Border"]
				local shield = _G["AchievementFrameMiniAchievement"..i.."Shield"]

				mini:SetTemplate()
				mini:SetBackdropColor(0, 0, 0, 0)
				mini:Size(32)

				local prevFrame = _G["AchievementFrameMiniAchievement"..i - 1]
				if i == 1 then
					mini:Point("TOPLEFT", 6, -4)
				elseif i == 7 then
					mini:Point("TOPLEFT", AchievementFrameMiniAchievement1, "BOTTOMLEFT", 0, -20)
				else
					mini:Point("TOPLEFT", prevFrame, "TOPRIGHT", 10, 0)
				end
				mini.SetPoint = E.noop

				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetInside()

				points:Point("BOTTOMRIGHT", -8, -15)
				points:SetTextColor(1, 0.80, 0.10)

				border:Kill()
				shield:Kill()

				mini.isSkinned = true
			end
		end
	end)
end

S:AddCallback("Skin_AchievementUI_HybridScrollButton", function() LoadSkin(true) end)
S:AddCallbackForAddon("Blizzard_AchievementUI", "Skin_Blizzard_AchievementUI", LoadSkin)