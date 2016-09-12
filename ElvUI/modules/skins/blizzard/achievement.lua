local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack, pairs = unpack, pairs;

local function LoadSkin(event)
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.achievement ~= true) then return; end

	local function SkinAchievement(achievement, BiggerIcon)
		if(achievement.isSkinned) then return; end

		achievement:StripTextures(true);
		achievement:SetTemplate("Default", true);
		achievement.icon:SetTemplate();
		achievement.icon:SetSize(BiggerIcon and 54 or 36, BiggerIcon and 54 or 36);
		achievement.icon:ClearAllPoints();
		achievement.icon:Point("TOPLEFT", 8, -8);
		achievement.icon.bling:Kill();
		achievement.icon.frame:Kill();
		achievement.icon.texture:SetTexCoord(unpack(E.TexCoords));
		achievement.icon.texture:SetInside();

		if(achievement.highlight) then
			achievement.highlight:StripTextures();
			achievement:HookScript("OnEnter", S.SetModifiedBackdrop);
			achievement:HookScript("OnLeave", S.SetOriginalBackdrop);
		end

		if(achievement.label) then
			achievement.label:SetTextColor(1, 1, 1);
		end

		if(achievement.description) then
			achievement.description:SetTextColor(.6, .6, .6);
			hooksecurefunc(achievement.description, "SetTextColor", function(_, r, g, b)
				if(r == 0 and g == 0 and b == 0) then
					achievement.description:SetTextColor(.6, .6, .6);
				end
			end);
		end

		if(achievement.hiddenDescription) then
			achievement.hiddenDescription:SetTextColor(1, 1, 1)
		end

		if(achievement.tracked) then
			S:HandleCheckBox(achievement.tracked, true);
			achievement.tracked:Size(14, 14);
			achievement.tracked:ClearAllPoints();
			achievement.tracked:Point("TOPLEFT", achievement.icon, "BOTTOMLEFT", 0, -2);
		end

		hooksecurefunc(achievement, "Saturate", function()
			achievement:SetBackdropBorderColor(unpack(E["media"].bordercolor));
		end);
		hooksecurefunc(achievement, "Desaturate", function()
			achievement:SetBackdropBorderColor(unpack(E["media"].bordercolor));
		end);

		achievement.isSkinned = true;
	end

	if(event == "PLAYER_ENTERING_WORLD") then
		hooksecurefunc("HybridScrollFrame_CreateButtons", function(frame, template)
			if(template == "AchievementCategoryTemplate") then
				for _, button in pairs(frame.buttons) do
					if(button.isSkinned) then return; end
					button:StripTextures(true);
					button:StyleButton();
					button.isSkinned = true;
				end
			end
			if(template == "AchievementTemplate") then
				for _, achievement in pairs(frame.buttons) do
					SkinAchievement(achievement, true);
				end
			end
			if(template == "ComparisonTemplate") then
				for _, achievement in pairs(frame.buttons) do
					if(achievement.isSkinned) then return; end
					SkinAchievement(achievement.player);
					SkinAchievement(achievement.friend);
				end
			end
			if(template == "StatTemplate") then
				for _, stats in pairs(frame.buttons) do
					-- stats:StripTextures(true);
					stats:StyleButton();
				end
			end
		end);
	end

	if(not IsAddOnLoaded("Blizzard_AchievementUI")) then
		return;
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
	};

	for _, frame in pairs(frames) do
		_G[frame]:StripTextures(true);
	end

	local noname_frames = {
		"AchievementFrameStats",
		"AchievementFrameSummary",
		"AchievementFrameAchievements",
		"AchievementFrameComparison"
	};

	for _, frame in pairs(noname_frames) do
		for i = 1, _G[frame]:GetNumChildren() do
			local child = select(i, _G[frame]:GetChildren());
			if(child and not child:GetName()) then
				child:SetBackdrop(nil);
			end
		end
	end

	AchievementFrame:CreateBackdrop("Transparent");
	AchievementFrame.backdrop:Point("TOPLEFT", 0, 6);
	AchievementFrame.backdrop:Point("BOTTOMRIGHT");
	AchievementFrameHeaderTitle:ClearAllPoints();
	AchievementFrameHeaderTitle:Point("TOPLEFT", AchievementFrame.backdrop, "TOPLEFT", -30, -8);
	AchievementFrameHeaderPoints:ClearAllPoints();
	AchievementFrameHeaderPoints:Point("LEFT", AchievementFrameHeaderTitle, "RIGHT", 2, 0);

	AchievementFrameCategoriesContainer:CreateBackdrop("Default");
	AchievementFrameCategoriesContainer.backdrop:Point("TOPLEFT", 0, 4);
	AchievementFrameCategoriesContainer.backdrop:Point("BOTTOMRIGHT", -2, -3);
	AchievementFrameAchievementsContainer:CreateBackdrop("Transparent");
	AchievementFrameAchievementsContainer.backdrop:Point("TOPLEFT", -2, 2);
	AchievementFrameAchievementsContainer.backdrop:Point("BOTTOMRIGHT", -2, -3);

	S:HandleCloseButton(AchievementFrameCloseButton, AchievementFrame.backdrop);
	S:HandleDropDownBox(AchievementFrameFilterDropDown);
	AchievementFrameFilterDropDown:Point("TOPRIGHT", AchievementFrame, "TOPRIGHT", -44, 5);

	S:HandleScrollBar(AchievementFrameCategoriesContainerScrollBar, 5);
	S:HandleScrollBar(AchievementFrameAchievementsContainerScrollBar, 5);
	S:HandleScrollBar(AchievementFrameStatsContainerScrollBar, 5);
	S:HandleScrollBar(AchievementFrameComparisonContainerScrollBar, 5);
	S:HandleScrollBar(AchievementFrameComparisonStatsContainerScrollBar, 5);

	for i = 1, 2 do
		S:HandleTab(_G["AchievementFrameTab" .. i]);
	end

	local function AnimationStatusBar(bar, noNumber)
		bar.anim = CreateAnimationGroup(bar);
		bar.anim.progress = bar.anim:CreateAnimation("Progress");
		bar.anim.progress:SetSmoothing("Out");

		bar.anim.color = bar.anim:CreateAnimation("Color");
		bar.anim.color:SetSmoothing("Out");
		bar.anim.color:SetColorType("Statusbar");
		bar.anim.color.StartR, bar.anim.color.StartG, bar.anim.color.StartB = 1, 0, 0;

		if(not noNumber) then
			bar.anim2 = CreateAnimationGroup(_G[bar:GetName() .. "Text"]);
			bar.anim2.number = bar.anim2:CreateAnimation("Number");
		end
	end

	local function PlayAnimationStatusBar(bar, max, value, noNumber)
		if(E.private.skins.animations) then
			bar.anim.progress:SetDuration(1.7);
			bar.anim.color:SetDuration(1.7);
			if(not noNumber) then
				bar.anim2.number:SetDuration(1.7);
			end
		else
			bar.anim.progress:SetDuration(0);
			bar.anim.color:SetDuration(0);
			if(not noNumber) then
				bar.anim2.number:SetDuration(0);
			end
		end

		if(bar.anim:IsPlaying() or (bar.anim2 and bar.anim2:IsPlaying())) then
			bar.anim:Stop();
			if(not noNumber) then
				bar.anim2:Stop();
			end
		end
		bar:SetValue(0);
		bar.anim.progress:SetChange(value);

		local r, g, b = E:ColorGradient(value / max, 1, 0, 0, 1, 1, 0, 0, 1, 0);
		bar.anim.color:Reset();
		bar.anim.color:SetChange(r, g, b);
		bar.anim:Play();

		if(not noNumber) then
			bar.anim2.number:SetPostfix("/" .. max);
			bar.anim2.number:SetChange(value);
			bar.anim2:Play();
		end
	end

	local function SkinStatusBar(bar)
		bar:StripTextures();
		bar:SetStatusBarTexture(E["media"].normTex);
		bar:SetStatusBarColor(4/255, 179/255, 30/255);
		bar:CreateBackdrop("Default");
		E:RegisterStatusBar(bar);

		local barName = bar:GetName();
		if(_G[barName .. "Title"]) then
			_G[barName .. "Title"]:Point("LEFT", 4, 0);
		end

		if(_G[barName .. "Label"]) then
			_G[barName .. "Label"]:Point("LEFT", 4, 0);
		end

		if(_G[barName .. "Text"]) then
			_G[barName .. "Text"]:Point("RIGHT", -4, 0);
		end

		AnimationStatusBar(bar);
	end

	SkinStatusBar(AchievementFrameSummaryCategoriesStatusBar);
	SkinStatusBar(AchievementFrameComparisonSummaryPlayerStatusBar);
	SkinStatusBar(AchievementFrameComparisonSummaryFriendStatusBar);
	AchievementFrameComparisonSummaryFriendStatusBar.text:ClearAllPoints();
	AchievementFrameComparisonSummaryFriendStatusBar.text:Point("CENTER");
	AchievementFrameComparisonHeader:Point("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 45, -20);

	for i = 1, 8 do
		local frame = _G["AchievementFrameSummaryCategoriesCategory" .. i];
		local button = _G["AchievementFrameSummaryCategoriesCategory" .. i .. "Button"];
		local highlight = _G["AchievementFrameSummaryCategoriesCategory" .. i .. "ButtonHighlight"];
		SkinStatusBar(frame);
		button:StripTextures();
		highlight:StripTextures();

		_G[highlight:GetName() .. "Middle"]:SetTexture(1, 1, 1, 0.3);
		_G[highlight:GetName() .. "Middle"]:SetAllPoints(frame);
	end

	hooksecurefunc("AchievementFrameCategory_StatusBarTooltip", function(self)
		local index = GameTooltip.shownStatusBars;
		local name = GameTooltip:GetName().."StatusBar"..index;
		local statusBar = _G[name];
		if(not statusBar) then return; end

		if(not statusBar.anim) then
			AnimationStatusBar(statusBar);
		end

		PlayAnimationStatusBar(statusBar, self.numAchievements, self.numCompleted);
	end);

	hooksecurefunc("AchievementFrameComparison_UpdateStatusBars", function(id)
		local numAchievements, numCompleted = GetCategoryNumAchievements(id);
		local statusBar = AchievementFrameComparisonSummaryPlayerStatusBar;
		PlayAnimationStatusBar(statusBar, numAchievements, numCompleted);

		local friendCompleted = GetComparisonCategoryNumAchievements(id);
		statusBar = AchievementFrameComparisonSummaryFriendStatusBar;
		PlayAnimationStatusBar(statusBar, numAchievements, friendCompleted);
	end);

	hooksecurefunc("AchievementFrameSummaryCategoriesStatusBar_Update", function()
		local total, completed = GetNumCompletedAchievements();
		PlayAnimationStatusBar(AchievementFrameSummaryCategoriesStatusBar, total, completed);
	end);

	hooksecurefunc("AchievementFrameSummaryCategory_OnShow", function(self)
		local totalAchievements, totalCompleted = AchievementFrame_GetCategoryTotalNumAchievements(self:GetID(), true);
		PlayAnimationStatusBar(self, totalAchievements, totalCompleted);
	end);

	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local frame = _G["AchievementFrameSummaryAchievement" .. i];
			if(not frame.isSkinned) then
				SkinAchievement(frame);
				frame.isSkinned = true;
			end

			local prevFrame = _G["AchievementFrameSummaryAchievement" .. i-1];
			if(i ~= 1) then
				frame:ClearAllPoints()
				frame:Point("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, -1);
				frame:Point("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 1);
			end

			frame:SetBackdropBorderColor(unpack(E.media.bordercolor));
		end
	end);

	for i = 1, 20 do
		local frame = _G["AchievementFrameStatsContainerButton" .. i];
		frame:StyleButton();

		_G["AchievementFrameStatsContainerButton" .. i .. "BG"]:SetTexture(1, 1, 1, 0.2);
		_G["AchievementFrameStatsContainerButton" .. i .. "HeaderLeft"]:Kill();
		_G["AchievementFrameStatsContainerButton" .. i .. "HeaderRight"]:Kill();
		_G["AchievementFrameStatsContainerButton" .. i .. "HeaderMiddle"]:Kill();

		local frame = "AchievementFrameComparisonStatsContainerButton" .. i;
		_G[frame]:StripTextures();
		_G[frame]:StyleButton();
		_G[frame .. "BG"]:SetTexture(1, 1, 1, 0.2);
		_G[frame .. "HeaderLeft"]:Kill();
		_G[frame .. "HeaderRight"]:Kill();
		_G[frame .. "HeaderMiddle"]:Kill();
	end

	hooksecurefunc("AchievementButton_GetProgressBar", function(index)
		local frame = _G["AchievementFrameProgressBar" .. index];
		if(frame) then
			if(not frame.skinned) then
				frame:StripTextures();
				frame:SetStatusBarTexture(E["media"].normTex);
				E:RegisterStatusBar(frame);
				frame:SetStatusBarColor(4/255, 179/255, 30/255);
				frame:GetStatusBarTexture():SetInside();
				frame:Height(frame:GetHeight() + (E.Border + E.Spacing));
				frame:SetTemplate("Default");

				frame.text:ClearAllPoints();
				frame.text:Point("CENTER", frame, "CENTER", 0, -1);
				frame.text:SetJustifyH("CENTER");

				if(index > 1) then
					frame:ClearAllPoints();
					frame:Point("TOP", _G["AchievementFrameProgressBar" .. index-1], "BOTTOM", 0, -5);
					frame.SetPoint = E.noop;
					frame.ClearAllPoints = E.noop;
				end

				AnimationStatusBar(frame, true);

				frame.skinned = true;
			end
		end
	end);

	hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
		local numCriteria = GetAchievementNumCriteria(id);
		local textStrings, metas, progressBars = 0, 0, 0;
		for i = 1, numCriteria do
			local _, criteriaType, completed, quantity, reqQuantity, _, flags, assetID = GetAchievementCriteriaInfo(id, i);
			if(criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID) then
				metas = metas + 1;
				local metaCriteria = AchievementButton_GetMeta(metas);
				if(objectivesFrame.completed and completed) then
					metaCriteria.label:SetShadowOffset(0, 0)
					metaCriteria.label:SetTextColor(1, 1, 1, 1);
				elseif(completed) then
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(0, 1, 0, 1);
				else
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(.6, .6, .6, 1);
				end
			elseif(bit.band(flags, ACHIEVEMENT_CRITERIA_PROGRESS_BAR) == ACHIEVEMENT_CRITERIA_PROGRESS_BAR) then
				progressBars = progressBars + 1;
				local progressBar = AchievementButton_GetProgressBar(progressBars);
				PlayAnimationStatusBar(progressBar, reqQuantity, quantity, true);
			elseif(criteriaType ~= 1) then
				textStrings = textStrings + 1;
				local criteria = AchievementButton_GetCriteria(textStrings);
				if(objectivesFrame.completed and completed) then
					criteria.name:SetTextColor(1, 1, 1, 1);
					criteria.name:SetShadowOffset(0, 0);
				elseif(completed) then
					criteria.name:SetTextColor(0, 1, 0, 1);
					criteria.name:SetShadowOffset(1, -1);
				else
					criteria.name:SetTextColor(.6, .6, .6, 1);
					criteria.name:SetShadowOffset(1, -1);
				end
			end
		end
	end);
end

local f = CreateFrame("Frame");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event);
	LoadSkin(event);
end);

S:RegisterSkin("Blizzard_AchievementUI", LoadSkin);