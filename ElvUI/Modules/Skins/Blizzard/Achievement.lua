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

local function skinAchievement(achievement, biggerIcon)
	if achievement.isSkinned then return end

	_G[achievement:GetName().."Background"]:Kill()
	achievement:StripTextures()
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
		achievement.description.SetTextColor = E.noop
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

S:AddCallback("Skin_AchievementUI_HybridScrollButton", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.achievement then return end

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
end)

S:AddCallbackForAddon("Blizzard_AchievementUI", "Skin_Blizzard_AchievementUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.achievement then return end

	local frames = {
		"AchievementFrame",
	--	"AchievementFrameCategories",
		"AchievementFrameSummary",
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

	local function updatePanelInfo(self)
		if self == AchievementFrameComparison then
			if AchievementFrame.isComparison then
				AchievementFrame:Width(863)
			else
				AchievementFrame:Width(737)
			end
		end

		S:SetUIPanelWindowInfo(AchievementFrame, "xoffset", 11, nil, true)
		S:SetUIPanelWindowInfo(AchievementFrame, "yoffset", -12, nil, true)
		S:SetUIPanelWindowInfo(AchievementFrame, "width", nil, -11)
	end

	AchievementFrame:HookScript("OnShow", updatePanelInfo)
	AchievementFrameComparison:HookScript("OnShow", updatePanelInfo)
	AchievementFrameComparison:HookScript("OnHide", updatePanelInfo)

	S:HandleCloseButton(AchievementFrameCloseButton, AchievementFrame.backdrop)

	S:HandleDropDownBox(AchievementFrameFilterDropDown)

	S:HandleScrollBar(AchievementFrameCategoriesContainerScrollBar)
	S:HandleScrollBar(AchievementFrameAchievementsContainerScrollBar)
	S:HandleScrollBar(AchievementFrameStatsContainerScrollBar)
	S:HandleScrollBar(AchievementFrameComparisonContainerScrollBar)
	S:HandleScrollBar(AchievementFrameComparisonStatsContainerScrollBar)

	AchievementFrameHeaderTitle:SetParent(AchievementFrame)
	AchievementFrameHeaderTitle:ClearAllPoints()
	AchievementFrameHeaderTitle:Point("TOPLEFT", AchievementFrame, "TOPLEFT", -29, -9)

	AchievementFrameHeaderPoints:SetParent(AchievementFrame)
	AchievementFrameHeaderPoints:ClearAllPoints()
	AchievementFrameHeaderPoints:Point("LEFT", AchievementFrameHeaderTitle, "RIGHT", 2, 0)

	AchievementFrameHeaderShield:SetParent(AchievementFrame)

	AchievementFrameHeader:Hide()
	AchievementFrameHeader.Show = E.noop

	AchievementFrame:Size(737, 485)
	AchievementFrame:SetTemplate("Transparent")

	AchievementFrameFilterDropDown:Point("TOPRIGHT", AchievementFrame, "TOPRIGHT", -21, -5)

	AchievementFrameCategories:SetTemplate("Default")
	AchievementFrameCategories:Point("TOPLEFT", 8, -35)
	AchievementFrameCategories:Point("BOTTOMLEFT", 21, 8)

	AchievementFrameCategoriesContainerScrollBar:Point("TOPLEFT", AchievementFrameCategoriesContainer, "TOPRIGHT", 3, -14)
	AchievementFrameCategoriesContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameCategoriesContainer, "BOTTOMRIGHT", 3, 14)

	AchievementFrameSummaryAchievements:Point("TOPLEFT", 5, -10)
	AchievementFrameSummaryAchievements:Point("TOPRIGHT", -5, -30)

	AchievementFrameAchievements:SetTemplate("Transparent")

	AchievementFrameAchievementsContainer:Point("TOPLEFT", 2, -2)
	AchievementFrameAchievementsContainer:Point("BOTTOMRIGHT", -2, 4)

	AchievementFrameAchievementsContainerScrollBar:Point("TOPLEFT", AchievementFrameAchievementsContainer, "TOPRIGHT", 5, -17)
	AchievementFrameAchievementsContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameAchievementsContainer, "BOTTOMRIGHT", 5, 15)

	AchievementFrameStats:SetTemplate("Transparent")

	AchievementFrameStatsContainerScrollBar:Point("TOPLEFT", AchievementFrameStatsContainer, "TOPRIGHT", 3, -16)
	AchievementFrameStatsContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameStatsContainer, "BOTTOMRIGHT", 3, 14)

	AchievementFrameComparison:SetTemplate("Transparent")

	AchievementFrameComparisonHeader:Point("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 50, -1)

	AchievementFrameComparison:Point("TOPLEFT", AchievementFrameCategories, "TOPRIGHT", 3, 0)

	AchievementFrameComparisonSummary:Height(30)
	AchievementFrameComparisonSummary:Point("TOPLEFT", 4, -2)

	AchievementFrameComparisonContainer:Point("TOPLEFT", AchievementFrameComparisonSummary, "BOTTOMLEFT", 0, -3)

	AchievementFrameComparisonContainerScrollBar:Point("TOPLEFT", AchievementFrameComparisonSummary, "TOPRIGHT", 9, -17)
	AchievementFrameComparisonContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameComparisonContainer, "BOTTOMRIGHT", 9, 14)

	AchievementFrameComparisonStatsContainer:Point("TOPLEFT", 5, -3)

	AchievementFrameComparisonStatsContainerScrollBar:Point("TOPLEFT", AchievementFrameComparisonStatsContainer, "TOPRIGHT", 3, -16)
	AchievementFrameComparisonStatsContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameComparisonStatsContainer, "BOTTOMRIGHT", 3, 14)

	AchievementFrameAchievementsContainerScrollBar.Show = function(self)
		AchievementFrameAchievements:SetWidth(500)
		for _, button in ipairs(AchievementFrameAchievements.buttons) do
			button:SetWidth(496)
		end
		getmetatable(self).__index.Show(self)
	end

	AchievementFrameAchievementsContainerScrollBar.Hide = function(self)
		AchievementFrameAchievements:SetWidth(521)
		for _, button in ipairs(AchievementFrameAchievements.buttons) do
			button:SetWidth(517)
		end
		getmetatable(self).__index.Hide(self)
	end

	AchievementFrameStatsContainerScrollBar.Show = function(self)
		AchievementFrameStats:SetWidth(500)
		for _, button in ipairs(AchievementFrameStats.buttons) do
			button:SetWidth(494)
		end
		getmetatable(self).__index.Show(self)
	end

	AchievementFrameStatsContainerScrollBar.Hide = function(self)
		AchievementFrameStats:SetWidth(521)
		for _, button in ipairs(AchievementFrameStats.buttons) do
			button:SetWidth(515)
		end
		getmetatable(self).__index.Hide(self)
	end

--[[
	AchievementFrameComparisonContainerScrollBar.Show = function(self)
		AchievementFrameComparison:SetWidth(626)
		AchievementFrameComparisonSummaryPlayer:SetWidth(498)
		for _, button in ipairs(AchievementFrameComparisonContainer.buttons) do
			button:SetWidth(616)
			button.player:SetWidth(498)
		end
		getmetatable(self).__index.Show(self)
	end
]]

	AchievementFrameComparisonContainerScrollBar.Hide = function(self)
		AchievementFrameComparison:SetWidth(647)
		AchievementFrameComparisonSummaryPlayer:SetWidth(519)
		for _, button in ipairs(AchievementFrameComparisonContainer.buttons) do
			button:SetWidth(637)
			button.player:SetWidth(519)
		end
		getmetatable(self).__index.Hide(self)
	end

--[[
	AchievementFrameComparisonStatsContainerScrollBar.Show = function(self)
		AchievementFrameComparison:SetWidth(626)
		for _, button in ipairs(AchievementFrameComparisonStatsContainer.buttons) do
			button:SetWidth(616)
		end
		getmetatable(self).__index.Show(self)
	end
]]

	AchievementFrameComparisonStatsContainerScrollBar.Hide = function(self)
		AchievementFrameComparison:SetWidth(647)
		for _, button in ipairs(AchievementFrameComparisonStatsContainer.buttons) do
			button:SetWidth(637)
		end
		getmetatable(self).__index.Hide(self)
	end

	local function categoriesContainerScripts()
		AchievementFrameCategoriesContainerScrollBar.Show = function(self)
			ACHIEVEMENTUI_CATEGORIESWIDTH = 176

			AchievementFrameCategories:SetWidth(176)
			AchievementFrameCategoriesContainer:GetScrollChild():SetWidth(176)

			AchievementFrameAchievements:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 24, 0)
			AchievementFrameStats:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 24, 0)
			AchievementFrameComparison:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 24, 0)

			for _, button in ipairs(AchievementFrameCategoriesContainer.buttons) do
				AchievementFrameCategories_DisplayButton(button, button.element)
			end
			getmetatable(self).__index.Show(self)
		end

		AchievementFrameCategoriesContainerScrollBar.Hide = function(self)
			ACHIEVEMENTUI_CATEGORIESWIDTH = 197

			AchievementFrameCategories:SetWidth(197)
			AchievementFrameCategoriesContainer:GetScrollChild():SetWidth(197)

			AchievementFrameAchievements:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 3, 0)
			AchievementFrameStats:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 3, 0)
			AchievementFrameComparison:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 3, 0)

			for _, button in ipairs(AchievementFrameCategoriesContainer.buttons) do
				AchievementFrameCategories_DisplayButton(button, button.element)
			end
			getmetatable(self).__index.Hide(self)
		end
	end

	if AchievementFrameCategoriesContainer.update then
		categoriesContainerScripts()
	else
		AchievementFrameCategories:HookScript("OnEvent", categoriesContainerScripts)
	end

	for i = 1, 2 do
		local tab = _G["AchievementFrameTab"..i]
		S:HandleTab(tab)
		tab.text:SetPoint("CENTER", 0, 2)
		tab.text.SetPoint = E.noop
	end

	AchievementFrameTab1:Point("BOTTOMLEFT", AchievementFrame, "BOTTOMLEFT", 0, -30)
	AchievementFrameTab2:Point("LEFT", AchievementFrameTab1, "RIGHT", -15, 0)

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
end)