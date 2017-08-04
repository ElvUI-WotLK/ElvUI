local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local unpack = unpack;
local find = string.find;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true) then return; end

	local QuestStrip = {
		"QuestFrame",
		"QuestLogFrame",
		"QuestLogCount",
		"EmptyQuestLogFrame",
		"QuestFrameDetailPanel",
		"QuestDetailScrollFrame",
		"QuestDetailScrollChildFrame",
		"QuestRewardScrollFrame",
		"QuestRewardScrollChildFrame",
		"QuestFrameProgressPanel",
		"QuestFrameRewardPanel",
		"QuestFrameGreetingPanel"
	};

	for _, object in pairs(QuestStrip) do
		_G[object]:StripTextures(true);
	end

	local QuestButtons = {
		"QuestLogFrameAbandonButton",
		"QuestLogFrameCancelButton",
		"QuestLogFramePushQuestButton",
		"QuestLogFrameShowMapButton",
		"QuestLogFrameTrackButton"
	};

	for _, button in pairs(QuestButtons) do
		_G[button]:StripTextures();
		S:HandleButton(_G[button]);
	end

	S:HandleButton(QuestFrameAcceptButton);
	QuestFrameAcceptButton:Point("BOTTOMLEFT", QuestFrame, 19, 71);
	S:HandleButton(QuestFrameDeclineButton);
	QuestFrameDeclineButton:Point("BOTTOMRIGHT", QuestFrame, -34, 71);

	S:HandleButton(QuestFrameCompleteButton);
	S:HandleButton(QuestFrameGoodbyeButton);
	S:HandleButton(QuestFrameCompleteQuestButton);
	S:HandleButton(QuestFrameCancelButton);
	S:HandleButton(QuestFrameGreetingGoodbyeButton);

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

	local function QuestQualityColors(frame, text, quality, link)
		if link and not quality then
			quality = select(3, GetItemInfo(link))
		end

		if quality and quality > 1 then
			if frame then
				frame:SetBackdropBorderColor(GetItemQualityColor(quality))
				frame.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
			text:SetTextColor(GetItemQualityColor(quality))
		else
			if frame then
				frame:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				frame.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			end
			text:SetTextColor(1, 1, 1)
		end
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
			local questName = _G["QuestInfoItem"..i.."Name"]
			local link = questItem.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(questItem.type, questItem:GetID())

			if(questItem ~= self) then
				QuestQualityColors(nil, questName, nil, link)
			end
		end
	end);

	local function QuestObjectiveText()
		local numObjectives = GetNumQuestLeaderBoards();
		local objective;
		local _, type, finished;
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

	hooksecurefunc("QuestInfo_Display", function()
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

		QuestObjectiveText()

		for i = 1, MAX_NUM_ITEMS do
			local questItem = _G["QuestInfoItem"..i]
			local questName = _G["QuestInfoItem"..i.."Name"]
			local link = questItem.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(questItem.type, questItem:GetID())

			QuestQualityColors(questItem, questName, nil, link)
		end
	end);

	QuestInfoTimerText:SetTextColor(1, 1, 1);
	QuestInfoAnchor:SetTextColor(1, 1, 1);

	QuestFrameGreetingPanel:HookScript("OnShow", function()
		GreetingText:SetTextColor(1, 1, 0);
		CurrentQuestsText:SetTextColor(1, 1, 1);
		AvailableQuestsText:SetTextColor(1, 1, 1);
	end);

	QuestLogScrollFrame:SetTemplate("Default");
	QuestLogDetailScrollFrame:StripTextures();
	QuestLogDetailScrollFrame:SetTemplate("Default");

	QuestFrame:CreateBackdrop("Transparent");
	QuestFrame.backdrop:Point("TOPLEFT", QuestFrame, "TOPLEFT", 15, -19);
	QuestFrame.backdrop:Point("BOTTOMRIGHT", QuestFrame, "BOTTOMRIGHT", -30, 67);

	QuestLogDetailFrame:StripTextures();
	QuestLogDetailFrame:CreateBackdrop("Transparent");
	QuestLogDetailFrame.backdrop:Point("TOPLEFT", QuestLogDetailFrame, "TOPLEFT", 10, -12);
	QuestLogDetailFrame.backdrop:Point("BOTTOMRIGHT", QuestLogDetailFrame, "BOTTOMRIGHT", 0, 4);

	QuestLogFrame:CreateBackdrop("Transparent");
	QuestLogFrame.backdrop:Point("TOPLEFT", QuestLogFrame, "TOPLEFT", 10, -12);
	QuestLogFrame.backdrop:Point("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -1, 8);

	S:HandleCloseButton(QuestFrameCloseButton);
	S:HandleCloseButton(QuestLogDetailFrameCloseButton);
	S:HandleCloseButton(QuestLogFrameCloseButton);

	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar);
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar);
	S:HandleScrollBar(QuestLogScrollFrameScrollBar, 5);
	QuestLogScrollFrameScrollBar:Point("RIGHT", 25, 0)
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

		for i = 1, MAX_REQUIRED_ITEMS do
			local item = _G["QuestProgressItem"..i]
			local name = _G["QuestProgressItem"..i.."Name"]
			local link = item.type and GetQuestItemLink(item.type, item:GetID())

			QuestQualityColors(item, name, nil, link)
		end
	end);

	for i = 1, #QuestLogScrollFrame.buttons do
		local questLogTitle = _G["QuestLogScrollFrameButton" .. i];
		questLogTitle:SetNormalTexture("");
		questLogTitle.SetNormalTexture = E.noop;
		questLogTitle:SetHighlightTexture("");
		questLogTitle.SetHighlightTexture = E.noop;

		questLogTitle.Text = questLogTitle:CreateFontString(nil, "OVERLAY");
		questLogTitle.Text:FontTemplate(nil, 22);
		questLogTitle.Text:Point("LEFT", 3, 0);
		questLogTitle.Text:SetText("+");

		hooksecurefunc(questLogTitle, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-");
			elseif(find(texture, "PlusButton")) then
				self.Text:SetText("+");
			else
				self.Text:SetText("");
			end
		end);
	end
end

S:AddCallback("Quest", LoadSkin);