local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true) then return; end

	local QuestStrip = {"QuestFrame", "QuestLogFrame", "QuestLogCount", "EmptyQuestLogFrame", "QuestFrameDetailPanel", "QuestDetailScrollFrame", "QuestDetailScrollChildFrame", "QuestRewardScrollFrame", "QuestRewardScrollChildFrame", "QuestFrameProgressPanel", "QuestFrameRewardPanel", "QuestFrameGreetingPanel"};
	for _, object in pairs(QuestStrip) do
		_G[object]:StripTextures(true);
	end

	local QuestButtons = {"QuestLogFrameAbandonButton", "QuestLogFramePushQuestButton", "QuestLogFrameTrackButton", "QuestLogFrameCancelButton"};
	for i = 1, #QuestButtons do
		_G[QuestButtons[i]]:StripTextures();
		S:HandleButton(_G[QuestButtons[i]]);
	end

	S:HandleButton(QuestFrameAcceptButton);
	S:HandleButton(QuestFrameDeclineButton);
	S:HandleButton(QuestFrameCompleteButton);
	S:HandleButton(QuestFrameGoodbyeButton);
	S:HandleButton(QuestFrameCompleteQuestButton);
	S:HandleButton(QuestFrameCancelButton);

	S:HandleButton(QuestFrameGreetingGoodbyeButton);

	QuestLogFrameShowMapButton:StripTextures();
	S:HandleButton(QuestLogFrameShowMapButton);
	QuestLogFrameShowMapButton.text:ClearAllPoints();
	QuestLogFrameShowMapButton.text:SetPoint("CENTER");
	QuestLogFrameShowMapButton:Size(QuestLogFrameShowMapButton:GetWidth() - 30, QuestLogFrameShowMapButton:GetHeight(), - 40);

	QuestLogFramePushQuestButton:Point("LEFT", QuestLogFrameAbandonButton, "RIGHT", 2, 0);
	QuestLogFramePushQuestButton:Point("RIGHT", QuestLogFrameTrackButton, "LEFT", -2, 0);

	for i = 1, MAX_NUM_ITEMS do
		_G["QuestInfoItem" .. i]:StripTextures();
		_G["QuestInfoItem" .. i]:StyleButton();
		_G["QuestInfoItem" .. i]:Width(_G["QuestInfoItem" .. i]:GetWidth() - 4);
		_G["QuestInfoItem" .. i]:SetFrameLevel(_G["QuestInfoItem" .. i]:GetFrameLevel() + 2);
		_G["QuestInfoItem" .. i .. "IconTexture"]:SetTexCoord(unpack(E.TexCoords));
		_G["QuestInfoItem" .. i .. "IconTexture"]:SetDrawLayer("OVERLAY");
		_G["QuestInfoItem" .. i .. "IconTexture"]:Size(_G["QuestInfoItem" .. i .. "IconTexture"]:GetWidth() -(E.Spacing*2), _G["QuestInfoItem" .. i .. "IconTexture"]:GetHeight() -(E.Spacing*2));
		_G["QuestInfoItem" .. i .. "IconTexture"]:Point("TOPLEFT", E.Border, -E.Border);
		S:HandleIcon(_G["QuestInfoItem" .. i .. "IconTexture"]);
		_G["QuestInfoItem" .. i]:SetTemplate("Default");
		_G["QuestInfoItem" .. i .. "Count"]:SetParent(_G["QuestInfoItem" .. i].backdrop);
		_G["QuestInfoItem" .. i .. "Count"]:SetDrawLayer("OVERLAY");
	end

	QuestInfoItemHighlight:StripTextures();
	QuestInfoItemHighlight:SetTemplate("Default", nil, true);
	QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0);
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0);
	QuestInfoItemHighlight:Size(142, 40);

	hooksecurefunc("QuestInfoItem_OnClick", function(self)
		QuestInfoItemHighlight:ClearAllPoints();
		QuestInfoItemHighlight:SetOutside(self:GetName() .. "IconTexture");
		_G[self:GetName() .. "Name"]:SetTextColor(1, 1, 0);

		for i = 1, MAX_NUM_ITEMS do
			local questItem = _G["QuestInfoItem" .. i];
			if(questItem ~= self) then
				_G[questItem:GetName() .. "Name"]:SetTextColor(1, 1, 1);
			end
		end
	end);

	local function QuestObjectiveText()
		local numObjectives = GetNumQuestLeaderBoards();
		local objective;
		local type, finished;
		local numVisibleObjectives = 0;
		for i = 1, numObjectives do
			_, type, finished = GetQuestLogLeaderBoard(i);
			if(type ~= "spell") then
				numVisibleObjectives = numVisibleObjectives+1;
				objective = _G["QuestInfoObjective" .. numVisibleObjectives];
				if(finished) then
					objective:SetTextColor(1, 1, 0);
				else
					objective:SetTextColor(0.6, 0.6, 0.6);
				end
			end
		end
	end

	hooksecurefunc("QuestInfo_Display", function(template, parentFrame, acceptButton, material)								
		local textColor = {1, 1, 1};
		local titleTextColor = {1, 1, 0};

		QuestInfoTitleHeader:SetTextColor(unpack(titleTextColor));
		QuestInfoDescriptionHeader:SetTextColor(unpack(titleTextColor));
		QuestInfoObjectivesHeader:SetTextColor(unpack(titleTextColor));
		QuestInfoRewardsHeader:SetTextColor(unpack(titleTextColor));

		QuestInfoDescriptionText:SetTextColor(unpack(textColor));
		QuestInfoObjectivesText:SetTextColor(unpack(textColor));
		QuestInfoGroupSize:SetTextColor(unpack(textColor));
		QuestInfoRewardText:SetTextColor(unpack(textColor));

		QuestInfoItemChooseText:SetTextColor(unpack(textColor));
		QuestInfoItemReceiveText:SetTextColor(unpack(textColor));
		QuestInfoSpellLearnText:SetTextColor(unpack(textColor));
		QuestInfoHonorFrameReceiveText:SetTextColor(unpack(textColor));
		QuestInfoArenaPointsFrameReceiveText:SetTextColor(unpack(textColor));
		QuestInfoTalentFrameReceiveText:SetTextColor(unpack(textColor));
		QuestInfoXPFrameReceiveText:SetTextColor(unpack(textColor));
		QuestInfoReputationText:SetTextColor(unpack(textColor));

		for i = 1, MAX_REPUTATIONS do
			_G["QuestInfoReputation" .. i .. "Faction"]:SetTextColor(unpack(textColor));
		end

		local r, g, b = QuestInfoRequiredMoneyText:GetTextColor();
		QuestInfoRequiredMoneyText:SetTextColor(1 - r, 1 - g, 1 - b);

		for i = 1, MAX_OBJECTIVES do
			local r, g, b = _G["QuestInfoObjective"..i]:GetTextColor();
			_G["QuestInfoObjective"..i]:SetTextColor(1 - r, 1 - g, 1 - b);
		end

		QuestObjectiveText();
	end);

	QuestInfoTimerText:SetTextColor(1, 1, 1);
	QuestInfoAnchor:SetTextColor(1, 1, 1);

	QuestFrameGreetingPanel:HookScript("OnShow", function()
		GreetingText:SetTextColor(1, 1, 0);
		CurrentQuestsText:SetTextColor(1, 1, 1);
		AvailableQuestsText:SetTextColor(1, 1, 1);
	end);

	QuestLogDetailScrollFrame:StripTextures();
	QuestLogFrame:HookScript("OnShow", function()
		QuestLogScrollFrame:Height(331);
		QuestLogDetailScrollFrame:Height(328);

		if(not QuestLogDetailScrollFrame.backdrop) then
			QuestLogScrollFrame:SetTemplate("Default");
			QuestLogDetailScrollFrame:CreateBackdrop("Default");
		end
	end);

	QuestFrame:CreateBackdrop("Transparent");
	QuestFrame.backdrop:Point("TOPLEFT", QuestFrame, "TOPLEFT", 10, -12);
	QuestFrame.backdrop:Point("BOTTOMRIGHT", QuestFrame, "BOTTOMRIGHT", -31, 67);

	QuestLogDetailFrame:StripTextures();
	QuestLogDetailFrame:CreateBackdrop("Transparent");
	QuestLogDetailFrame.backdrop:Point("TOPLEFT", QuestLogDetailFrame, "TOPLEFT", 10, -12);
	QuestLogDetailFrame.backdrop:Point("BOTTOMRIGHT", QuestLogDetailFrame, "BOTTOMRIGHT", 0, 4);

	QuestLogFrame:CreateBackdrop("Transparent");
	QuestLogFrame.backdrop:Point("TOPLEFT", QuestLogFrame, "TOPLEFT", 10, -12);
	QuestLogFrame.backdrop:Point("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -1, 8);

	S:HandleCloseButton(QuestFrameCloseButton, QuestFrame.backdrop);
	S:HandleCloseButton(QuestLogDetailFrameCloseButton);
	S:HandleCloseButton(QuestLogFrameCloseButton);

	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar);
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar);
	S:HandleScrollBar(QuestLogScrollFrameScrollBar, 5);
	S:HandleScrollBar(QuestProgressScrollFrameScrollBar);
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar);

	for i = 1, 6 do
		local button = _G["QuestProgressItem" .. i]
		local texture = _G["QuestProgressItem" .. i .. "IconTexture"];
		button:StripTextures();
		button:StyleButton();
		button:Width(button:GetWidth() - 4);
		button:SetFrameLevel(button:GetFrameLevel() + 2);
		texture:SetTexCoord(unpack(E.TexCoords));
		texture:SetDrawLayer("OVERLAY");
		texture:Size(texture:GetWidth() -(E.Spacing*2), texture:GetHeight() -(E.Spacing*2));
		texture:Point("TOPLEFT", E.Border, -E.Border);
		S:HandleIcon(texture);
		_G["QuestProgressItem" .. i .. "Count"]:SetParent(button.backdrop);
		_G["QuestProgressItem" .. i .. "Count"]:SetDrawLayer("OVERLAY");
		button:SetTemplate("Default");
	end

	hooksecurefunc("QuestFrameProgressItems_Update", function()
		QuestProgressTitleText:SetTextColor(1, 1, 0);
		QuestProgressText:SetTextColor(1, 1, 1);
		QuestProgressRequiredItemsText:SetTextColor(1, 1, 0);
		QuestProgressRequiredMoneyText:SetTextColor(1, 1, 0);
	end);
end

S:RegisterSkin("ElvUI", LoadSkin);