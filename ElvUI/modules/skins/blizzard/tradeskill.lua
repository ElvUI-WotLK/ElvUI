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

	TradeSkillFrame:StripTextures(true);
	TradeSkillListScrollFrame:StripTextures();
	TradeSkillDetailScrollFrame:StripTextures();

	TradeSkillExpandButtonFrame:StripTextures();
	TradeSkillDetailScrollChildFrame:StripTextures();

	TradeSkillFrame:CreateBackdrop("Transparent");
	TradeSkillFrame.backdrop:Point("TOPLEFT", 10, -12);
	TradeSkillFrame.backdrop:Point("BOTTOMRIGHT", -31, 74);

	TradeSkillRankFrame:StripTextures();
	TradeSkillRankFrame:CreateBackdrop("Default");
	TradeSkillRankFrame:SetStatusBarTexture(E["media"].normTex);
	E:RegisterStatusBar(TradeSkillRankFrame);

	S:HandleCheckBox(TradeSkillFrameAvailableFilterCheckButton);

	S:HandleEditBox(TradeSkillFrameEditBox);
	TradeSkillFrameEditBox.backdrop:Point("TOPLEFT", 0, -4);
	TradeSkillFrameEditBox.backdrop:Point("BOTTOMRIGHT", -1, 4);

	S:HandleDropDownBox(TradeSkillSubClassDropDown);
	S:HandleDropDownBox(TradeSkillInvSlotDropDown);

	S:HandleButton(TradeSkillCreateButton);
	S:HandleButton(TradeSkillCancelButton);
	S:HandleButton(TradeSkillCreateAllButton);

	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar);
	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar);

	S:HandleEditBox(TradeSkillInputBox);

	S:HandleNextPrevButton(TradeSkillDecrementButton);
	S:HandleNextPrevButton(TradeSkillIncrementButton);
	TradeSkillIncrementButton:Point("RIGHT", TradeSkillCreateButton, "LEFT", -13, 0);

	S:HandleCloseButton(TradeSkillFrameCloseButton);

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		TradeSkillSkillIcon:StyleButton(nil, true);
		if(TradeSkillSkillIcon:GetNormalTexture()) then
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
			TradeSkillSkillIcon:GetNormalTexture():SetInside();
		end
		TradeSkillSkillIcon:SetTemplate("Default");

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

			if((reagentName or reagentTexture) and not reagent.isSkinned) then
				icon:SetTexCoord(unpack(E.TexCoords));
				icon:SetDrawLayer("OVERLAY");

				icon.backdrop = CreateFrame("Frame", nil, reagent);
				icon.backdrop:SetFrameLevel(reagent:GetFrameLevel() - 1);
				icon.backdrop:SetTemplate("Default");
				icon.backdrop:SetOutside(icon);

				icon:SetParent(icon.backdrop);
				count:SetParent(icon.backdrop);
				count:SetDrawLayer("OVERLAY");

				_G["TradeSkillReagent" .. i .. "NameFrame"]:Kill();
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