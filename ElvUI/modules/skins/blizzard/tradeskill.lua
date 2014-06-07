local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true then return end
	
	TradeSkillFrame:StripTextures(true);
	TradeSkillListScrollFrame:StripTextures();
	TradeSkillDetailScrollFrame:StripTextures();
	
	TradeSkillExpandButtonFrame:StripTextures();
	TradeSkillDetailScrollChildFrame:StripTextures();
	
	TradeSkillFrame:CreateBackdrop('Transparent');
	TradeSkillFrame.backdrop:Point('TOPLEFT', 10, -12);
	TradeSkillFrame.backdrop:Point('BOTTOMRIGHT', -31, 74);

	TradeSkillRankFrame:StripTextures();
	TradeSkillRankFrame:CreateBackdrop('Default');
	TradeSkillRankFrame:SetStatusBarTexture(E['media'].normTex);
	
	S:HandleCheckBox(TradeSkillFrameAvailableFilterCheckButton);
	
	S:HandleEditBox(TradeSkillFrameEditBox);
	TradeSkillFrameEditBox.backdrop:Point('TOPLEFT', 0, -4);
	TradeSkillFrameEditBox.backdrop:Point('BOTTOMRIGHT', -1, 4);
	
	S:HandleDropDownBox(TradeSkillSubClassDropDown);
	S:HandleDropDownBox(TradeSkillInvSlotDropDown);
	
	S:HandleButton(TradeSkillCreateButton, true);
	S:HandleButton(TradeSkillCancelButton, true);
	S:HandleButton(TradeSkillCreateAllButton, true);
	
	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar);
	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar);
	
	S:HandleEditBox(TradeSkillInputBox);
	
	S:HandleNextPrevButton(TradeSkillDecrementButton);
	S:HandleNextPrevButton(TradeSkillIncrementButton);
	TradeSkillIncrementButton:Point('RIGHT', TradeSkillCreateButton, 'LEFT', -13, 0);
	
	S:HandleCloseButton(TradeSkillFrameCloseButton);
	
	local once = false;
	hooksecurefunc('TradeSkillFrame_SetSelection', function(id)
		TradeSkillSkillIcon:StyleButton(nil, true);
		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
			TradeSkillSkillIcon:GetNormalTexture():SetInside();
		end
		TradeSkillSkillIcon:SetTemplate('Default');

		for i=1, MAX_TRADE_SKILL_REAGENTS do
			local Reagent = _G['TradeSkillReagent'..i];
			local ReagentIconTexture = _G['TradeSkillReagent'..i..'IconTexture'];
			local ReagentCount = _G['TradeSkillReagent'..i..'Count'];
			
			ReagentIconTexture:SetTexCoord(unpack(E.TexCoords));
			ReagentIconTexture:SetDrawLayer('OVERLAY');
			
			if not ReagentIconTexture.backdrop then
				ReagentIconTexture.backdrop = CreateFrame('Frame', nil, Reagent);
				ReagentIconTexture.backdrop:SetFrameLevel(Reagent:GetFrameLevel() - 1);
				ReagentIconTexture.backdrop:SetTemplate('Default');
				ReagentIconTexture.backdrop:SetOutside(ReagentIconTexture);
			end
			
			ReagentIconTexture:SetParent(ReagentIconTexture.backdrop);
			ReagentCount:SetParent(ReagentIconTexture.backdrop);
			ReagentCount:SetDrawLayer('OVERLAY');
			
			if i > 2 and once == false then
				local point, anchoredto, point2, x, y = Reagent:GetPoint();
				Reagent:ClearAllPoints();
				Reagent:Point(point, anchoredto, point2, x, y - 3);
				once = true;
			end
			
			_G['TradeSkillReagent'..i..'NameFrame']:Kill();
		end
	end)
end

S:RegisterSkin('Blizzard_TradeSkillUI', LoadSkin);