local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select = select
local unpack = unpack
local find = string.find
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

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.quest then return end

	QuestLogFrame:StripTextures()
	QuestLogFrame:CreateBackdrop("Transparent")
	QuestLogFrame.backdrop:Point("TOPLEFT", 11, -12)
	QuestLogFrame.backdrop:Point("BOTTOMRIGHT", -1, 8)

	QuestLogCount:StripTextures()
	QuestLogCount:SetTemplate("Transparent")

	QuestInfoItemHighlight:StripTextures()

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

	QuestLogFrameShowMapButton:StripTextures()
	S:HandleButton(QuestLogFrameShowMapButton)
	QuestLogFrameShowMapButton.text:ClearAllPoints()
	QuestLogFrameShowMapButton.text:Point("CENTER")
	QuestLogFrameShowMapButton:Size(QuestLogFrameShowMapButton:GetWidth() - 30, QuestLogFrameShowMapButton:GetHeight(), - 40)

	S:HandleButton(QuestLogFrameAbandonButton)
	S:HandleButton(QuestLogFrameTrackButton)

	S:HandleButton(QuestLogFrameCancelButton)
	QuestLogFrameCancelButton:Point("BOTTOMRIGHT", -9, 14)

	S:HandleButton(QuestLogFramePushQuestButton)
	QuestLogFramePushQuestButton:Point("LEFT", QuestLogFrameAbandonButton, "RIGHT", 2, 0)
	QuestLogFramePushQuestButton:Point("RIGHT", QuestLogFrameTrackButton, "LEFT", -2, 0)
	QuestLogFrameTrackButton:Point("RIGHT", 0, 1)

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

	QuestInfoTimerText:SetTextColor(1, 1, 1)
	QuestInfoAnchor:SetTextColor(1, 1, 1)

	QuestLogDetailFrame:SetAttribute("UIPanelLayout-height", E:Scale(490))
	QuestLogDetailFrame:Height(490)
	QuestLogDetailFrame:StripTextures()
	QuestLogDetailFrame:CreateBackdrop("Transparent")
	QuestLogDetailFrame.backdrop:Point("TOPLEFT", 11, -12)
	QuestLogDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, 1)

	QuestLogDetailScrollFrame:StripTextures()

	QuestLogFrame:HookScript("OnShow", function()
		if not QuestLogScrollFrame.backdrop then
			QuestLogScrollFrame:CreateBackdrop("Transparent")
		end

		QuestLogScrollFrame.backdrop:Point("TOPLEFT", 0, 2)
		QuestLogScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
		QuestLogScrollFrame:Size(302, 331)

		if not QuestLogDetailScrollFrame.backdrop then
			QuestLogDetailScrollFrame:CreateBackdrop("Transparent")
		end
		QuestLogDetailScrollFrame.backdrop:Point("TOPLEFT", 0, 3)
		QuestLogDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
		QuestLogDetailScrollFrame:Height(331)
		QuestLogDetailScrollFrame:Point("TOPRIGHT", -32, -76)

		QuestLogFrameShowMapButton:Point("TOPRIGHT", -32, -35)

		QuestLogScrollFrameScrollBar:Point("TOPLEFT", QuestLogScrollFrame, "TOPRIGHT", 5, -12)
		QuestLogDetailScrollFrameScrollBar:Point("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 6, -13)
	end)

	QuestLogDetailFrame:HookScript("OnShow", function()
		if not QuestLogDetailScrollFrame.backdrop then
			QuestLogDetailScrollFrame:CreateBackdrop("Transparent")
		end
		QuestLogDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
		QuestLogDetailScrollFrame:Size(302, 375)

		QuestLogFrameShowMapButton:Point("TOPRIGHT", -33, -35)

		QuestLogDetailScrollFrameScrollBar:Point("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 6, -13)
	end)

	QuestLogSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	QuestLogSkillHighlight:SetAlpha(0.35)

	S:HandleCloseButton(QuestLogDetailFrameCloseButton, QuestLogDetailFrame.backdrop)
	S:HandleCloseButton(QuestLogFrameCloseButton, QuestLogFrame.backdrop)

	EmptyQuestLogFrame:StripTextures()

	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestLogScrollFrameScrollBar, 5)
	QuestLogScrollFrameScrollBar:Point("RIGHT", 25, 0)
	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)

	-- Quest Frame
	QuestFrame:StripTextures(true)
	QuestFrame:CreateBackdrop("Transparent")
	QuestFrame.backdrop:Point("TOPLEFT", 11, -12)
	QuestFrame.backdrop:Point("BOTTOMRIGHT", -32, 0)

	QuestFrameNpcNameText:ClearAllPoints()
	QuestFrameNpcNameText:Point("TOP", -6, -17)

	QuestFrameDetailPanel:StripTextures(true)
	QuestDetailScrollFrame:StripTextures(true)
	QuestDetailScrollFrame:Height(402)
	QuestDetailScrollChildFrame:StripTextures(true)
	QuestRewardScrollFrame:StripTextures(true)
	QuestRewardScrollFrame:Height(402)
	QuestRewardScrollChildFrame:StripTextures(true)
	QuestFrameProgressPanel:StripTextures(true)
	QuestProgressScrollFrame:Height(402)
	QuestFrameRewardPanel:StripTextures(true)

	S:HandleButton(QuestFrameAcceptButton, true)
	QuestFrameAcceptButton:Point("BOTTOMLEFT", 20, 4)

	S:HandleButton(QuestFrameDeclineButton, true)
	QuestFrameDeclineButton:Point("BOTTOMRIGHT", -37, 4)

	S:HandleButton(QuestFrameCompleteButton, true)
	QuestFrameCompleteButton:Point("BOTTOMLEFT", 20, 4)

	S:HandleButton(QuestFrameGoodbyeButton, true)
	QuestFrameGoodbyeButton:Point("BOTTOMRIGHT", -37, 4)

	S:HandleButton(QuestFrameCompleteQuestButton, true)
	QuestFrameCompleteQuestButton:Point("BOTTOMLEFT", 20, 4)

	S:HandleButton(QuestFrameCancelButton)
	QuestFrameCancelButton:Point("BOTTOMRIGHT", -37, 4)

	S:HandleCloseButton(QuestFrameCloseButton, QuestFrame.backdrop)

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

	for i = 1, #QuestLogScrollFrame.buttons do
		local questLogTitle = _G["QuestLogScrollFrameButton"..i]
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
end

S:AddCallback("Skin_Quest", LoadSkin)