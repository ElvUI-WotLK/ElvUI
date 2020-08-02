local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack, select = unpack, select
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradeSkillItemLink = GetTradeSkillItemLink
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon("Blizzard_TradeSkillUI", "Skin_Blizzard_TradeSkillUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tradeskill then return end

	local SKILLS_DISPLAYED = 21
	TRADE_SKILLS_DISPLAYED = SKILLS_DISPLAYED

	for i = 9, SKILLS_DISPLAYED do
		CreateFrame("Button", "TradeSkillSkill"..i, TradeSkillFrame, "TradeSkillSkillButtonTemplate"):Point("TOPLEFT", _G["TradeSkillSkill"..i - 1], "BOTTOMLEFT")
	end

	TradeSkillFrame:StripTextures(true)
	TradeSkillFrame:Width(713)

	TradeSkillFrame:CreateBackdrop("Transparent")
	TradeSkillFrame.backdrop:Point("TOPLEFT", 11, -12)
	TradeSkillFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(TradeSkillFrame, "width")
	S:SetBackdropHitRect(TradeSkillFrame)

	S:HandleCloseButton(TradeSkillFrameCloseButton, TradeSkillFrame.backdrop)

	TradeSkillRankFrame:StripTextures()
	TradeSkillRankFrame:CreateBackdrop()
	TradeSkillRankFrame:SetStatusBarTexture(E.media.normTex)
	TradeSkillRankFrame:SetStatusBarColor(0.22, 0.39, 0.84)
	TradeSkillRankFrame.SetStatusBarColor = E.noop
	E:RegisterStatusBar(TradeSkillRankFrame)

	S:HandleCheckBox(TradeSkillFrameAvailableFilterCheckButton)

	S:HandleEditBox(TradeSkillFrameEditBox)

	S:HandleDropDownBox(TradeSkillInvSlotDropDown, 140)
	S:HandleDropDownBox(TradeSkillSubClassDropDown, 140)

	TradeSkillExpandButtonFrame:StripTextures()

	TradeSkillCollapseAllButton:SetNormalTexture(E.Media.Textures.Plus)
	TradeSkillCollapseAllButton.SetNormalTexture = E.noop
	TradeSkillCollapseAllButton:GetNormalTexture():Point("LEFT", 3, 2)
	TradeSkillCollapseAllButton:GetNormalTexture():Size(16)

	TradeSkillCollapseAllButton:SetHighlightTexture("")
	TradeSkillCollapseAllButton.SetHighlightTexture = E.noop

	TradeSkillCollapseAllButton:SetDisabledTexture(E.Media.Textures.Plus)
	TradeSkillCollapseAllButton.SetDisabledTexture = E.noop
	TradeSkillCollapseAllButton:GetDisabledTexture():Point("LEFT", 3, 2)
	TradeSkillCollapseAllButton:GetDisabledTexture():Size(16)
	TradeSkillCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	for i = 1, SKILLS_DISPLAYED do
		local skillButton = _G["TradeSkillSkill"..i]
		local skillButtonHighlight = _G["TradeSkillSkill"..i.."Highlight"]

		skillButton:SetNormalTexture(E.Media.Textures.Plus)
		skillButton.SetNormalTexture = E.noop
		skillButton:GetNormalTexture():Size(13)
		skillButton:GetNormalTexture():Point("LEFT", 2, 1)

		skillButtonHighlight:SetTexture("")
		skillButtonHighlight.SetTexture = E.noop

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
			else
				self:GetNormalTexture():SetTexture("")
			end
		end)
	end

	TradeSkillListScrollFrame:StripTextures()
	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar)

	TradeSkillDetailScrollFrame:StripTextures()
	TradeSkillDetailScrollFrame.scrollBarHideable = nil
	TradeSkillDetailScrollChildFrame:StripTextures()
	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar)

	TradeSkillSkillIcon:StyleButton(nil, true)
	TradeSkillSkillIcon:SetTemplate("Default")

	TradeSkillRequirementLabel:SetTextColor(1, 0.80, 0.10)

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local reagent = _G["TradeSkillReagent"..i]
		local icon = _G["TradeSkillReagent"..i.."IconTexture"]
		local count = _G["TradeSkillReagent"..i.."Count"]
		local name = _G["TradeSkillReagent"..i.."Name"]
		local nameFrame = _G["TradeSkillReagent"..i.."NameFrame"]

		reagent:SetTemplate("Default")
		reagent:StyleButton(nil, true)
		reagent:Size(143, 40)

		icon.backdrop = CreateFrame("Frame", nil, reagent)
		icon.backdrop:SetTemplate()
		icon.backdrop:Point("TOPLEFT", icon, -1, 1)
		icon.backdrop:Point("BOTTOMRIGHT", icon, 1, -1)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer("OVERLAY")
		icon:Size(E.PixelMode and 38 or 32)
		icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
		icon:SetParent(icon.backdrop)

		count:SetParent(icon.backdrop)
		count:SetDrawLayer("OVERLAY")

		name:Point("LEFT", nameFrame, "LEFT", 20, 0)

		nameFrame:Kill()
	end

	TradeSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	TradeSkillHighlight:SetAlpha(0.35)

	S:HandleNextPrevButton(TradeSkillDecrementButton)
	S:HandleEditBox(TradeSkillInputBox)
	S:HandleNextPrevButton(TradeSkillIncrementButton)

	S:HandleButton(TradeSkillCancelButton)
	S:HandleButton(TradeSkillCreateButton)
	S:HandleButton(TradeSkillCreateAllButton)

	TradeSkillRankFrame:Size(522, 17)
	TradeSkillRankFrame:Point("TOPLEFT", 85, -36)

	TradeSkillRankFrameSkillRank:Point("TOP", TradeSkillFrameTitleText, 0, -23)

	TradeSkillFrameAvailableFilterCheckButton:Point("TOPLEFT", 80, -59)

	TradeSkillFrameEditBox:Height(18)
	TradeSkillFrameEditBox:Point("TOPRIGHT", TradeSkillRankFrame, "BOTTOMRIGHT", -263, -9)

	TradeSkillInvSlotDropDown:Point("TOPRIGHT", -32, -58)
	TradeSkillSubClassDropDown:Point("RIGHT", TradeSkillInvSlotDropDown, "LEFT", 21, 0)

	TradeSkillExpandButtonFrame:Point("TOPLEFT", 15, -68)

	TradeSkillSkill1:Point("TOPLEFT", 25, -90)

	TradeSkillListScrollFrame:Size(305, 340)
	TradeSkillListScrollFrame:Point("TOPRIGHT", -389, -88)
	TradeSkillListScrollFrame.Hide = E.noop
	TradeSkillListScrollFrame:Show()

	TradeSkillListScrollFrameScrollBar:Point("TOPLEFT", TradeSkillListScrollFrame, "TOPRIGHT", 3, -19)
	TradeSkillListScrollFrameScrollBar:Point("BOTTOMLEFT", TradeSkillListScrollFrame, "BOTTOMRIGHT", 3, 19)

	TradeSkillDetailScrollFrame:Size(304, 311)
	TradeSkillDetailScrollFrame:Point("TOPLEFT", 348, -88)

	TradeSkillDetailScrollChildFrame:Size(304, 310)

	TradeSkillDetailScrollFrameScrollBar:Point("TOPLEFT", TradeSkillDetailScrollFrame, "TOPRIGHT", 3, -19)
	TradeSkillDetailScrollFrameScrollBar:Point("BOTTOMLEFT", TradeSkillDetailScrollFrame, "BOTTOMRIGHT", 3, 19)

	TradeSkillSkillIcon:Size(47)
	TradeSkillSkillIcon:Point("TOPLEFT", 10, -9)

	TradeSkillSkillName:Point("TOPLEFT", 65, -9)
	TradeSkillDescription:Point("TOPLEFT", 8, -64)

	TradeSkillReagent1:Point("TOPLEFT", TradeSkillReagentLabel, "BOTTOMLEFT", 1, -3)
	TradeSkillReagent2:Point("LEFT", TradeSkillReagent1, "RIGHT", 3, 0)
	TradeSkillReagent3:Point("TOPLEFT", TradeSkillReagent1, "BOTTOMLEFT", 0, -3)
	TradeSkillReagent4:Point("LEFT", TradeSkillReagent3, "RIGHT", 3, 0)
	TradeSkillReagent5:Point("TOPLEFT", TradeSkillReagent3, "BOTTOMLEFT", 0, -3)
	TradeSkillReagent6:Point("LEFT", TradeSkillReagent5, "RIGHT", 3, 0)
	TradeSkillReagent7:Point("TOPLEFT", TradeSkillReagent5, "BOTTOMLEFT", 0, -3)
	TradeSkillReagent8:Point("LEFT", TradeSkillReagent7, "RIGHT", 3, 0)

	TradeSkillInputBox:Height(16)

	TradeSkillCancelButton:Point("CENTER", TradeSkillFrame, "TOPLEFT", 633, -417)
	TradeSkillCreateButton:Point("CENTER", TradeSkillFrame, "TOPLEFT", 550, -417)
	TradeSkillCreateAllButton:Point("RIGHT", TradeSkillCreateButton, "LEFT", -82, 0)
	TradeSkillIncrementButton:Point("RIGHT", TradeSkillCreateButton, "LEFT", -4, 0)
	TradeSkillDecrementButton:Point("LEFT", TradeSkillCreateAllButton, "RIGHT", 4, 0)

	hooksecurefunc(TradeSkillCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			self:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
		else
			self:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
		end
	end)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillSkillIcon:SetAlpha(1)
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			TradeSkillSkillIcon:GetNormalTexture():SetInside()
		else
			TradeSkillSkillIcon:SetAlpha(0)
		end

		local skillLink = GetTradeSkillItemLink(id)
		local r, g, b

		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))

			if quality then
				r, g, b = GetItemQualityColor(quality)

				TradeSkillSkillIcon:SetBackdropBorderColor(r, g, b)
				TradeSkillSkillName:SetTextColor(r, g, b)
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E.media.bordercolor))
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end

		for i = 1, GetTradeSkillNumReagents(id) do
			local _, _, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
			local reagentLink = GetTradeSkillReagentItemLink(id, i)

			if reagentLink then
				local reagent = _G["TradeSkillReagent"..i]
				local icon = _G["TradeSkillReagent"..i.."IconTexture"]
				local quality = select(3, GetItemInfo(reagentLink))

				if quality then
					local name = _G["TradeSkillReagent"..i.."Name"]
					r, g, b = GetItemQualityColor(quality)

					icon.backdrop:SetBackdropBorderColor(r, g, b)
					reagent:SetBackdropBorderColor(r, g, b)

					if playerReagentCount < reagentCount then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(r, g, b)
					end
				else
					reagent:SetBackdropBorderColor(unpack(E.media.bordercolor))
					icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)
end)