local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack, select = unpack, select;
local find = string.find;

local GetItemInfo = GetItemInfo;
local GetItemQualityColor = GetItemQualityColor;
local GetTradeSkillItemLink = GetTradeSkillItemLink;
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo;
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true) then return; end

	TradeSkillListScrollFrame:StripTextures();
	TradeSkillDetailScrollFrame:StripTextures();

	TradeSkillExpandButtonFrame:StripTextures();
	TradeSkillDetailScrollChildFrame:StripTextures();

	TradeSkillFrame:StripTextures(true);
	TradeSkillFrame:CreateBackdrop("Transparent");
	TradeSkillFrame.backdrop:Point("TOPLEFT", 10, 0);
	TradeSkillFrame.backdrop:Point("BOTTOMRIGHT", -38, 74);

	TradeSkillRankFrame:StripTextures();
	TradeSkillRankFrame:CreateBackdrop();
	TradeSkillRankFrame:Point("TOPLEFT", TradeSkillFrame, "TOPLEFT", 35, -22);
	TradeSkillRankFrame:Size(280, 16);
	TradeSkillRankFrame:SetStatusBarTexture(E["media"].normTex);
	TradeSkillRankFrame:SetStatusBarColor(0.13, 0.35, 0.80);
	E:RegisterStatusBar(TradeSkillRankFrame);

	TradeSkillRankFrameSkillRank:FontTemplate(nil, 12, "OUTLINE");
	TradeSkillRankFrameSkillRank:ClearAllPoints();
	TradeSkillRankFrameSkillRank:Point("CENTER", TradeSkillRankFrame, "CENTER", 0, 0);

	S:HandleCheckBox(TradeSkillFrameAvailableFilterCheckButton);

	TradeSkillFrameEditBox:Point("TOPRIGHT", TradeSkillRankFrame, "BOTTOMRIGHT", 2, -2);
	TradeSkillFrameEditBox:Height(26);
	S:HandleEditBox(TradeSkillFrameEditBox);
	TradeSkillFrameEditBox.backdrop:Point("TOPLEFT", 0, -4);
	TradeSkillFrameEditBox.backdrop:Point("BOTTOMRIGHT", -1, 4);

	TradeSkillFrameTitleText:Point("TOP", TradeSkillFrame, "TOP", -20, -5);

	TradeSkillFrameAvailableFilterCheckButton:Point("TOPLEFT", TradeSkillFrame, "TOPLEFT", 30, -41);

	S:HandleDropDownBox(TradeSkillSubClassDropDown);
	TradeSkillSubClassDropDown:Point("RIGHT", TradeSkillInvSlotDropDown, "LEFT", 15, 0);
	TradeSkillSubClassDropDown:Width(140);

	S:HandleDropDownBox(TradeSkillInvSlotDropDown);
	TradeSkillInvSlotDropDown:Point("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -60, -68);
	TradeSkillInvSlotDropDown:Width(140);

	TradeSkillCreateButton:Point("CENTER", TradeSkillFrame, "TOPLEFT", 214, -422);
	S:HandleButton(TradeSkillCreateButton);

	TradeSkillCancelButton:Point("CENTER", TradeSkillFrame, "TOPLEFT", 300, -422);
	S:HandleButton(TradeSkillCancelButton);

	TradeSkillCreateAllButton:ClearAllPoints();
	TradeSkillCreateAllButton:Point("CENTER", TradeSkillFrame, "TOPLEFT", 58, -422);
	S:HandleButton(TradeSkillCreateAllButton);

	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar);
	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar);

	TradeSkillInputBox:Height(16);
	S:HandleEditBox(TradeSkillInputBox);

	S:HandleNextPrevButton(TradeSkillDecrementButton);
	S:HandleNextPrevButton(TradeSkillIncrementButton);

	TradeSkillFrameCloseButton:Point("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -34, 4);
	S:HandleCloseButton(TradeSkillFrameCloseButton);

	TradeSkillReagent1:Point("TOPLEFT", TradeSkillReagentLabel, "BOTTOMLEFT", -2, -3)
	TradeSkillReagent2:Point("LEFT", TradeSkillReagent1, "RIGHT", 3, 0)
	TradeSkillReagent4:Point("LEFT", TradeSkillReagent3, "RIGHT", 3, 0)
	TradeSkillReagent6:Point("LEFT", TradeSkillReagent5, "RIGHT", 3, 0)
	TradeSkillReagent8:Point("LEFT", TradeSkillReagent7, "RIGHT", 3, 0)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		TradeSkillSkillIcon:StyleButton(nil, true);
		TradeSkillSkillIcon:SetTemplate();
		if(TradeSkillSkillIcon:GetNormalTexture()) then
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
			TradeSkillSkillIcon:GetNormalTexture():SetInside();
		end

		local skillLink = GetTradeSkillItemLink(id)
		if(skillLink) then
			TradeSkillRequirementLabel:SetTextColor(1, 0.80, 0.10);
			local quality = select(3, GetItemInfo(skillLink));
			if(quality and quality > 1) then
				TradeSkillSkillIcon:SetBackdropBorderColor(GetItemQualityColor(quality));
				TradeSkillSkillName:SetTextColor(GetItemQualityColor(quality));
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
				TradeSkillSkillName:SetTextColor(1, 1, 1);
			end
		end

		local numReagents = GetTradeSkillNumReagents(id);
		for i = 1, numReagents, 1 do
			local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
			local reagentLink = GetTradeSkillReagentItemLink(id, i);
			local reagent = _G["TradeSkillReagent" .. i];
			local icon = _G["TradeSkillReagent" .. i .. "IconTexture"];
			local name = _G["TradeSkillReagent" .. i .. "Name"];
			local count = _G["TradeSkillReagent" .. i .. "Count"];
			local nameFrame = _G["TradeSkillReagent" .. i .. "NameFrame"];

			if((reagentName or reagentTexture) and not reagent.isSkinned) then
				reagent:SetTemplate("Transparent", true);
				reagent:StyleButton(nil, true);
				reagent:Size(reagent:GetWidth(), reagent:GetHeight() + 1)

				icon:SetTexCoord(unpack(E.TexCoords));
				icon:SetDrawLayer("OVERLAY");
				icon:Size(38);
				icon:Point("TOPLEFT", 2, -2);

				icon.backdrop = CreateFrame("Frame", nil, reagent);
				icon.backdrop:SetFrameLevel(reagent:GetFrameLevel() - 1);
				icon.backdrop:SetTemplate();
				icon.backdrop:SetOutside(icon);

				icon:SetParent(icon.backdrop);
				count:SetParent(icon.backdrop);
				count:SetDrawLayer("OVERLAY");

				nameFrame:Kill();

				reagent.isSkinned = true;
			end

			if(reagentLink) then
				local quality = select(3, GetItemInfo(reagentLink));
				if(quality and quality > 1) then
					icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality));
					 if(playerReagentCount < reagentCount) then
						name:SetTextColor(0.5, 0.5, 0.5);
					else
						name:SetTextColor(GetItemQualityColor(quality));
					end
				else
					icon.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor));
 				end
			end
		end
	end);

	for i = 1, TRADE_SKILLS_DISPLAYED do
		local skillButton = _G["TradeSkillSkill" .. i];
		skillButton:SetNormalTexture("");
		skillButton.SetNormalTexture = E.noop;

		_G["TradeSkillSkill" .. i .. "Highlight"]:SetTexture("");
		_G["TradeSkillSkill" .. i .. "Highlight"].SetTexture = E.noop;

		skillButton.Text = skillButton:CreateFontString(nil, "OVERLAY");
		skillButton.Text:FontTemplate(nil, 22);
		skillButton.Text:Point("LEFT", 3, 0);
		skillButton.Text:SetText("+");

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-");
			elseif(find(texture, "PlusButton")) then
				self.Text:SetText("+");
			else
				self.Text:SetText("");
			end
		end);
	end

	TradeSkillCollapseAllButton:SetNormalTexture("");
	TradeSkillCollapseAllButton.SetNormalTexture = E.noop;
	TradeSkillCollapseAllButton:SetHighlightTexture("");
	TradeSkillCollapseAllButton.SetHighlightTexture = E.noop;

	TradeSkillCollapseAllButton.Text = TradeSkillCollapseAllButton:CreateFontString(nil, "OVERLAY");
	TradeSkillCollapseAllButton.Text:FontTemplate(nil, 22);
	TradeSkillCollapseAllButton.Text:Point("LEFT", 3, 0);
	TradeSkillCollapseAllButton.Text:SetText("+");

	hooksecurefunc(TradeSkillCollapseAllButton, "SetNormalTexture", function(self, texture)
		if(find(texture, "MinusButton")) then
			self.Text:SetText("-");
		else
			self.Text:SetText("+");
		end
	end);
end

S:AddCallbackForAddon("Blizzard_TradeSkillUI", "TradeSkill", LoadSkin);