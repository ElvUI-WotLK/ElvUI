local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack = unpack;

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

	local once = false;
	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		TradeSkillSkillIcon:StyleButton(nil, true);
		if(TradeSkillSkillIcon:GetNormalTexture()) then
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
			TradeSkillSkillIcon:GetNormalTexture():SetInside();
		end
		TradeSkillSkillIcon:SetTemplate("Default");

		for i=1, MAX_TRADE_SKILL_REAGENTS do
			local button = _G["TradeSkillReagent"..i]
			local icon = _G["TradeSkillReagent"..i.."IconTexture"]
			local count = _G["TradeSkillReagent"..i.."Count"]
			
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("OVERLAY")
			if not icon.backdrop then
				icon.backdrop = CreateFrame("Frame", nil, button)
				icon.backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
				icon.backdrop:SetTemplate("Default")
				icon.backdrop:SetOutside(icon)
			end
			icon:SetParent(icon.backdrop)
			count:SetParent(icon.backdrop)
			count:SetDrawLayer("OVERLAY")
			
			if i > 2 and once == false then
				local point, anchoredto, point2, x, y = button:GetPoint()
				button:ClearAllPoints()
				button:Point(point, anchoredto, point2, x, y - 3)
				once = true
			end
			
			_G["TradeSkillReagent"..i.."NameFrame"]:Kill()
		end
		
		local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(id);
		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if (quality and quality > 1) then
				TradeSkillSkillIcon:SetBackdropBorderColor(GetItemQualityColor(quality));
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
			end
		end
		
		local numReagents = GetTradeSkillNumReagents(id);
		for i = 1, numReagents, 1 do
			local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
			local reagentLink = GetTradeSkillReagentItemLink(id, i)
			local reagent = _G["TradeSkillReagent"..i]
			if reagent:IsShown() then
				if reagentLink then
					local quality = select(3, GetItemInfo(reagentLink))
					if (quality and quality > 1) then
						_G["TradeSkillReagent"..i.."IconTexture"].backdrop:SetBackdropBorderColor(GetItemQualityColor(quality));
					else
						_G["TradeSkillReagent"..i.."IconTexture"].backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor));
					end
				end
			end
		end
	end);
	
	--Expand/Collapse Buttons
	hooksecurefunc('TradeSkillFrame_Update', function()
		local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
		local diplayedSkills = TRADE_SKILLS_DISPLAYED;
		local numTradeSkills = GetNumTradeSkills();
		local buttonIndex = 1
		for i = 1, diplayedSkills, 1 do
			local skillIndex = i + skillOffset
			local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(skillIndex);
			if ( skillIndex <= numTradeSkills ) then
				if ( skillType == "header" ) then
					buttonIndex = i;
					local skillButton = _G["TradeSkillSkill"..buttonIndex];
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons");
					skillButton:GetNormalTexture():Size(12)
					skillButton:GetNormalTexture():SetPoint("LEFT", 3, 2);
					skillButton:SetHighlightTexture('')
					if ( isExpanded ) then
						skillButton:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375)
					else
						skillButton:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
					end
				end
			end
		end
	end)
	
	--Expand/Collapse All Button
	TradeSkillCollapseAllButton:HookScript('OnUpdate', function(self)
		self:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		self:SetHighlightTexture("")
		self:GetNormalTexture():SetPoint("LEFT", 3, 2)
		self:GetNormalTexture():Size(11)
		if (self.collapsed) then
			self:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
		else
			self:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375)
		end
		self:SetDisabledTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		self:GetDisabledTexture():SetPoint("LEFT", 3, 2)
		self:GetDisabledTexture():Size(10)
		self:GetDisabledTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
		self:GetDisabledTexture():SetDesaturated(true)
	end)
end

S:RegisterSkin("Blizzard_TradeSkillUI", LoadSkin);