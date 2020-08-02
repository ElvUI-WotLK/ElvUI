local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select = select
local unpack = unpack
local find, gsub = string.find, string.gsub
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMoney = GetMoney
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetQuestItemLink = GetQuestItemLink
local GetQuestLogItemLink = GetQuestLogItemLink
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetQuestLogRequiredMoney = GetQuestLogRequiredMoney
local hooksecurefunc = hooksecurefunc
local GetQuestMoneyToGet = GetQuestMoneyToGet

local MAX_NUM_ITEMS = MAX_NUM_ITEMS
local MAX_REPUTATIONS = MAX_REPUTATIONS

S:AddCallback("Skin_Quest", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.quest then return end

	QuestLogFrame:StripTextures()
	QuestLogFrame:CreateBackdrop("Transparent")
	QuestLogFrame.backdrop:Point("TOPLEFT", 11, -12)
	QuestLogFrame.backdrop:Point("BOTTOMRIGHT", -1, 11)

	S:SetUIPanelWindowInfo(QuestLogFrame, "width")
	S:SetBackdropHitRect(QuestLogFrame)

	S:HandleCloseButton(QuestLogFrameCloseButton, QuestLogFrame.backdrop)

	QuestLogCount:StripTextures()
	QuestLogCount:CreateBackdrop("Transparent")
	QuestLogCount.backdrop:Point("TOPLEFT", -1, 0)
	QuestLogCount.backdrop:Point("BOTTOMRIGHT", 1, -4)

	QuestLogFrameShowMapButton:StripTextures()
	S:HandleButton(QuestLogFrameShowMapButton)

	QuestLogScrollFrame:CreateBackdrop("Transparent")
	QuestLogScrollFrame.backdrop:Point("TOPLEFT", 0, 2)
	QuestLogScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)

	QuestLogDetailScrollFrame:StripTextures()
	QuestLogDetailScrollFrame:CreateBackdrop("Transparent")
	QuestLogDetailScrollFrame.backdrop:Point("TOPLEFT", 0, 1)
	QuestLogDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)

	EmptyQuestLogFrame:StripTextures()

	S:HandleButton(QuestLogFrameAbandonButton)
	S:HandleButton(QuestLogFramePushQuestButton)
	S:HandleButton(QuestLogFrameTrackButton)
	S:HandleButton(QuestLogFrameCancelButton)

	QuestLogSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	QuestLogSkillHighlight:SetAlpha(0.35)

	S:HandleScrollBar(QuestLogScrollFrameScrollBar)
	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)

	QuestLogCount:ClearAllPoints()
	QuestLogCount:Point("BOTTOMLEFT", QuestLogScrollFrame, "TOPLEFT", 1, 13)
	QuestLogCount.SetPoint = E.noop

	QuestLogFrameShowMapButton.text:ClearAllPoints()
	QuestLogFrameShowMapButton.text:Point("CENTER")
	QuestLogFrameShowMapButton:Size(QuestLogFrameShowMapButton.text:GetWidth() + 32, 32)

	QuestLogScrollFrame:Point("TOPLEFT", 19, -62)

	QuestLogScrollFrameScrollBar:Point("TOPLEFT", QuestLogScrollFrame, "TOPRIGHT", 3, -17)
	QuestLogScrollFrameScrollBar:Point("BOTTOMLEFT", QuestLogScrollFrame, "BOTTOMRIGHT", 3, 17)

	QuestLogDetailScrollFrame:Width(304)
	QuestLogDetailScrollFrame.Hide = E.noop
	QuestLogDetailScrollFrame:Show()

	QuestLogFrameTrackButton:Height(22)
	QuestLogFrameAbandonButton:Height(22)
	QuestLogFramePushQuestButton:Height(22)

	QuestLogFrameTrackButton:Point("RIGHT", -1, 2)
	QuestLogFrameAbandonButton:Point("LEFT", 1, 2)

	QuestLogFramePushQuestButton:Point("LEFT", QuestLogFrameAbandonButton, "RIGHT", 3, 0)
	QuestLogFramePushQuestButton:Point("RIGHT", QuestLogFrameTrackButton, "LEFT", -3, 0)

	QuestLogFrameCancelButton:Point("BOTTOMRIGHT", -9, 19)

	QuestLogFrame:HookScript("OnShow", function()
		QuestLogDetailScrollFrame.backdrop:Show()

		QuestLogFrameShowMapButton:Point("TOPRIGHT", -30, -24)

		QuestLogDetailScrollFrame:Height(336)
		QuestLogDetailScrollFrame:Point("TOPRIGHT", -30, -61)

		QuestLogDetailScrollFrameScrollBar:Point("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 3, -18)
		QuestLogDetailScrollFrameScrollBar:Point("BOTTOMLEFT", QuestLogDetailScrollFrame, "BOTTOMRIGHT", 3, 17)

		QuestLogControlPanel:SetPoint("BOTTOMLEFT", 18, 15)
	end)

	for _, questLogTitle in ipairs(QuestLogScrollFrame.buttons) do
		questLogTitle:SetNormalTexture(E.Media.Textures.Plus)
		questLogTitle.SetNormalTexture = E.noop
		questLogTitle:GetNormalTexture():Size(16)
		questLogTitle:GetNormalTexture():Point("LEFT", 5, 0)
		questLogTitle:SetHighlightTexture("")
		questLogTitle.SetHighlightTexture = E.noop

		hooksecurefunc(questLogTitle, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
			else
				self:GetNormalTexture():SetTexture(0, 0, 0, 0)
			end
		end)
	end

	-- QuestLog Detail Frame
	QuestLogDetailFrame:StripTextures()
	QuestLogDetailFrame:Height(513)
	QuestLogDetailFrame:CreateBackdrop("Transparent")
	QuestLogDetailFrame.backdrop:Point("TOPLEFT", 11, -12)
	QuestLogDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, 1)

	S:SetUIPanelWindowInfo(QuestLogDetailFrame, "height", nil, nil, true)
	S:SetUIPanelWindowInfo(QuestLogDetailFrame, "width")
	S:SetBackdropHitRect(QuestLogDetailFrame)

	S:HandleCloseButton(QuestLogDetailFrameCloseButton, QuestLogDetailFrame.backdrop)

	QuestLogDetailTitleText:Point("TOP", QuestLogDetailFrame, "TOP", 0, -18)

	QuestLogDetailFrame:HookScript("OnShow", function()
		QuestLogDetailScrollFrame.backdrop:Hide()

		QuestLogDetailScrollFrame:Height(402)
		QuestLogDetailScrollFrame:Point("TOPLEFT", 19, -73)

		QuestLogDetailScrollFrameScrollBar:Point("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 3, -19)
		QuestLogDetailScrollFrameScrollBar:Point("BOTTOMLEFT", QuestLogDetailScrollFrame, "BOTTOMRIGHT", 3, 19)

		QuestLogFrameShowMapButton:Point("TOPRIGHT", -27, -34)
	end)

	-- Quest Frame
	QuestFrame:StripTextures(true)
	QuestFrame:CreateBackdrop("Transparent")
	QuestFrame.backdrop:Point("TOPLEFT", 11, -12)
	QuestFrame.backdrop:Point("BOTTOMRIGHT", -32, 0)

	S:SetUIPanelWindowInfo(QuestFrame, "width")
	S:SetBackdropHitRect(QuestFrame)

	S:HandleCloseButton(QuestFrameCloseButton, QuestFrame.backdrop)

	QuestFrameDetailPanel:StripTextures(true)
	QuestDetailScrollFrame:StripTextures(true)
	QuestDetailScrollChildFrame:StripTextures(true)
	QuestRewardScrollFrame:StripTextures(true)
	QuestRewardScrollChildFrame:StripTextures(true)
	QuestFrameProgressPanel:StripTextures(true)
	QuestFrameRewardPanel:StripTextures(true)

	S:HandleButton(QuestFrameAcceptButton)
	S:HandleButton(QuestFrameCompleteButton)
	S:HandleButton(QuestFrameCompleteQuestButton)
	S:HandleButton(QuestFrameDeclineButton)
	S:HandleButton(QuestFrameGoodbyeButton)
	S:HandleButton(QuestFrameCancelButton)

	QuestFrameNpcNameText:ClearAllPoints()
	QuestFrameNpcNameText:Point("TOP", QuestFrame, "TOP", -6, -15)

	QuestDetailScrollFrame:Size(304, 402)
	QuestRewardScrollFrame:Size(304, 402)
	QuestProgressScrollFrame:Size(304, 402)

	QuestDetailScrollFrame:Point("TOPLEFT", QuestFrame, "TOPLEFT", 19, -73)
	QuestRewardScrollFrame:Point("TOPLEFT", QuestFrame, "TOPLEFT", 19, -73)
	QuestProgressScrollFrame:Point("TOPLEFT", QuestFrame, "TOPLEFT", 19, -73)

	QuestDetailScrollFrameScrollBar:Point("TOPLEFT", QuestDetailScrollFrame, "TOPRIGHT", 3, -19)
	QuestDetailScrollFrameScrollBar:Point("BOTTOMLEFT", QuestDetailScrollFrame, "BOTTOMRIGHT", 3, 19)

	QuestRewardScrollFrameScrollBar:Point("TOPLEFT", QuestRewardScrollFrame, "TOPRIGHT", 3, -19)
	QuestRewardScrollFrameScrollBar:Point("BOTTOMLEFT", QuestRewardScrollFrame, "BOTTOMRIGHT", 3, 19)

	QuestProgressScrollFrameScrollBar:Point("TOPLEFT", QuestProgressScrollFrame, "TOPRIGHT", 3, -19)
	QuestProgressScrollFrameScrollBar:Point("BOTTOMLEFT", QuestProgressScrollFrame, "BOTTOMRIGHT", 3, 19)

	QuestFrameAcceptButton:Point("BOTTOMLEFT", 19, 8)
	QuestFrameCompleteButton:Point("BOTTOMLEFT", 19, 8)
	QuestFrameCompleteQuestButton:Point("BOTTOMLEFT", 19, 8)
	QuestFrameDeclineButton:Point("BOTTOMRIGHT", -40, 8)
	QuestFrameGoodbyeButton:Point("BOTTOMRIGHT", -40, 8)
	QuestFrameCancelButton:Point("BOTTOMRIGHT", -40, 8)

	-- Quest Greeting Frame
	QuestFrameGreetingPanel:StripTextures(true)
	QuestGreetingFrameHorizontalBreak:Kill()

	S:HandleButton(QuestFrameGreetingGoodbyeButton, true)
	S:HandleScrollBar(QuestGreetingScrollFrameScrollBar)

	GreetingText:SetTextColor(1, 1, 1)
	CurrentQuestsText:SetTextColor(1, 0.80, 0.10)
	AvailableQuestsText:SetTextColor(1, 0.80, 0.10)

	GreetingText.SetTextColor = E.noop
	CurrentQuestsText.SetTextColor = E.noop
	AvailableQuestsText.SetTextColor = E.noop

	QuestGreetingScrollFrame:Size(304, 402)
	QuestGreetingScrollFrame:Point("TOPLEFT", GossipFrame, "TOPLEFT", 19, -73)

	QuestGreetingScrollFrameScrollBar:Point("TOPLEFT", QuestGreetingScrollFrame, "TOPRIGHT", 3, -19)
	QuestGreetingScrollFrameScrollBar:Point("BOTTOMLEFT", QuestGreetingScrollFrame, "BOTTOMRIGHT", 3, 19)

	QuestFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", -40, 8)

	QuestFrameGreetingPanel:HookScript("OnShow", function()
		for i = 1, MAX_NUM_QUESTS do
			local button = _G["QuestTitleButton"..i]

			if button:GetFontString() then
				if button:GetText() and find(button:GetText(), "|cff000000") then
					button:SetText(gsub(button:GetText(), "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)

	-- Quest Progress + Reward
	QuestInfoItemHighlight:StripTextures()

	QuestInfoTimerText:SetTextColor(1, 1, 1)
	QuestInfoAnchor:SetTextColor(1, 1, 1)

	local items = {
		["QuestInfoItem"] = MAX_NUM_ITEMS,
		["QuestProgressItem"] = MAX_REQUIRED_ITEMS
	}
	for frame, numItems in pairs(items) do
		for i = 1, numItems do
			local item = _G[frame..i]
			local icon = _G[frame..i.."IconTexture"]
			local count = _G[frame..i.."Count"]

			item:StripTextures()
			item:SetTemplate("Default")
			item:StyleButton()
			item:Size(143, 40)
			item:SetFrameLevel(item:GetFrameLevel() + 2)

			icon:Size(E.PixelMode and 38 or 32)
			icon:SetDrawLayer("OVERLAY")
			icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
			S:HandleIcon(icon)

			count:SetParent(item.backdrop)
			count:SetDrawLayer("OVERLAY")
		end
	end

	local function questQualityColors(frame, text, link, quality)
		if link and not quality then
			quality = select(3, GetItemInfo(link))
		end

		if quality then
			local r, g, b = GetItemQualityColor(quality)

			frame:SetBackdropBorderColor(r, g, b)
			frame.backdrop:SetBackdropBorderColor(r, g, b)

			text:SetTextColor(r, g, b)
		else
			frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
			frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

			text:SetTextColor(1, 1, 1)
		end
	end

	hooksecurefunc("QuestFrameProgressItems_Update", function()
		QuestProgressTitleText:SetTextColor(1, 0.80, 0.10)
		QuestProgressText:SetTextColor(1, 1, 1)
		QuestProgressRequiredItemsText:SetTextColor(1, 0.80, 0.10)

		local moneyToGet = GetQuestMoneyToGet()

		if moneyToGet > 0 then
			if moneyToGet > GetMoney() then
				QuestProgressRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestProgressRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		local item, name, link

		for i = 1, MAX_REQUIRED_ITEMS do
			item = _G["QuestProgressItem"..i]
			name = _G["QuestProgressItem"..i.."Name"]
			link = item.type and GetQuestItemLink(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	hooksecurefunc("QuestInfoItem_OnClick", function(self)
		if self.type == "choice" then
			self:SetBackdropBorderColor(1, 0.80, 0.10)
			self.backdrop:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[self:GetName().."Name"]:SetTextColor(1, 0.80, 0.10)

			local item, name, link

			for i = 1, MAX_NUM_ITEMS do
				item = _G["QuestInfoItem"..i]

				if item ~= self then
					name = _G["QuestInfoItem"..i.."Name"]
					link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

					questQualityColors(item, name, link)
				end
			end
		end
	end)

	local function questObjectiveText()
		local numObjectives = GetNumQuestLeaderBoards()
		local _, objType, finished, objective
		local numVisibleObjectives = 0

		for i = 1, numObjectives do
			_, objType, finished = GetQuestLogLeaderBoard(i)

			if objType ~= "spell" then
				numVisibleObjectives = numVisibleObjectives + 1
				objective = _G["QuestInfoObjective"..numVisibleObjectives]

				if finished then
					objective:SetTextColor(1, 0.80, 0.10)
				else
					objective:SetTextColor(0.6, 0.6, 0.6)
				end
			end
		end
	end

	hooksecurefunc("QuestInfo_Display", function()
		QuestInfoTitleHeader:SetTextColor(1, 0.80, 0.10)
		QuestInfoDescriptionHeader:SetTextColor(1, 0.80, 0.10)
		QuestInfoObjectivesHeader:SetTextColor(1, 0.80, 0.10)
		QuestInfoRewardsHeader:SetTextColor(1, 0.80, 0.10)

		QuestInfoDescriptionText:SetTextColor(1, 1, 1)
		QuestInfoObjectivesText:SetTextColor(1, 1, 1)
		QuestInfoGroupSize:SetTextColor(1, 1, 1)
		QuestInfoRewardText:SetTextColor(1, 1, 1)

		QuestInfoItemChooseText:SetTextColor(1, 1, 1)
		QuestInfoItemReceiveText:SetTextColor(1, 1, 1)
		QuestInfoSpellLearnText:SetTextColor(1, 1, 1)
		QuestInfoHonorFrameReceiveText:SetTextColor(1, 1, 1)
		QuestInfoArenaPointsFrameReceiveText:SetTextColor(1, 1, 1)
		QuestInfoTalentFrameReceiveText:SetTextColor(1, 1, 1)
		QuestInfoXPFrameReceiveText:SetTextColor(1, 1, 1)
		QuestInfoReputationText:SetTextColor(1, 1, 1)

		for i = 1, MAX_REPUTATIONS do
			_G["QuestInfoReputation"..i.."Faction"]:SetTextColor(1, 1, 1)
		end

		local requiredMoney = GetQuestLogRequiredMoney()

		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		questObjectiveText()

		local item, name, link

		for i = 1, MAX_NUM_ITEMS do
			item = _G["QuestInfoItem"..i]
			name = _G["QuestInfoItem"..i.."Name"]
			link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	hooksecurefunc("QuestInfo_ShowRewards", function()
		local item, name, link

		for i = 1, MAX_NUM_ITEMS do
			item = _G["QuestInfoItem"..i]
			name = _G["QuestInfoItem"..i.."Name"]
			link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	hooksecurefunc("QuestInfo_ShowRequiredMoney", function()
		local requiredMoney = GetQuestLogRequiredMoney()

		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end
	end)
end)