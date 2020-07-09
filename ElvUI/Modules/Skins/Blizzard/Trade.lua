local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack, select = unpack, select
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

S:AddCallback("Skin_Trade", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.trade then return end

	TradeFrame:StripTextures(true)
	TradeFrame:CreateBackdrop("Transparent")
	TradeFrame.backdrop:Point("TOPLEFT", 11, -12)
	TradeFrame.backdrop:Point("BOTTOMRIGHT", -21, 49)

	S:SetUIPanelWindowInfo(TradeFrame, "width")
	S:SetBackdropHitRect(TradeFrame)

	S:HandleCloseButton(TradeFrameCloseButton, TradeFrame.backdrop)

	S:HandleButton(TradeFrameTradeButton)
	S:HandleButton(TradeFrameCancelButton)

	S:HandleEditBox(TradePlayerInputMoneyFrameGold)
	S:HandleEditBox(TradePlayerInputMoneyFrameSilver)
	S:HandleEditBox(TradePlayerInputMoneyFrameCopper)

	for i = 1, MAX_TRADE_ITEMS do
		local player = _G["TradePlayerItem"..i]
		local recipient = _G["TradeRecipientItem"..i]
		local playerButton = _G["TradePlayerItem"..i.."ItemButton"]
		local playerButtonIcon = _G["TradePlayerItem"..i.."ItemButtonIconTexture"]
		local recipientButton = _G["TradeRecipientItem"..i.."ItemButton"]
		local recipientButtonIcon = _G["TradeRecipientItem"..i.."ItemButtonIconTexture"]

		player:StripTextures()
		recipient:StripTextures()

		playerButton:StripTextures()
		playerButton:StyleButton()
		playerButton:SetTemplate("Default", true)

		playerButtonIcon:SetInside()
		playerButtonIcon:SetTexCoord(unpack(E.TexCoords))

		recipientButton:StripTextures()
		recipientButton:StyleButton()
		recipientButton:SetTemplate("Default", true)

		recipientButtonIcon:SetInside()
		recipientButtonIcon:SetTexCoord(unpack(E.TexCoords))

		playerButton.bg = CreateFrame("Frame", nil, playerButton)
		playerButton.bg:SetTemplate("Default")
		playerButton.bg:Point("TOPLEFT", playerButton, "TOPRIGHT", 4, 0)
		playerButton.bg:Point("BOTTOMRIGHT", _G["TradePlayerItem"..i.."NameFrame"], "BOTTOMRIGHT", 0, 14)
		playerButton.bg:SetFrameLevel(playerButton:GetFrameLevel() - 3)

		recipientButton.bg = CreateFrame("Frame", nil, recipientButton)
		recipientButton.bg:SetTemplate("Default")
		recipientButton.bg:Point("TOPLEFT", recipientButton, "TOPRIGHT", 4, 0)
		recipientButton.bg:Point("BOTTOMRIGHT", _G["TradeRecipientItem"..i.."NameFrame"], "BOTTOMRIGHT", 0, 14)
		recipientButton.bg:SetFrameLevel(recipientButton:GetFrameLevel() - 3)
	end

	TradeHighlightPlayerTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightPlayerEnchantTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightRecipientTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightRecipientEnchantTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantMiddle:SetTexture(0, 1, 0, 0.2)

	TradeHighlightPlayer:SetFrameStrata("HIGH")
	TradeHighlightRecipient:SetFrameStrata("HIGH")
	TradeHighlightPlayerEnchant:SetFrameStrata("HIGH")
	TradeHighlightRecipientEnchant:SetFrameStrata("HIGH")

	hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
		local tradeItemButton = _G["TradePlayerItem"..id.."ItemButton"]
		local link = GetTradePlayerItemLink(id)

		if link then
			local tradeItemName = _G["TradePlayerItem"..id.."Name"]
			local quality = select(3, GetItemInfo(link))

			tradeItemName:SetTextColor(GetItemQualityColor(quality))

			if quality then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		local tradeItemButton = _G["TradeRecipientItem"..id.."ItemButton"]
		local link = GetTradeTargetItemLink(id)

		if link then
			local tradeItemName = _G["TradeRecipientItem"..id.."Name"]
			local quality = select(3, GetItemInfo(link))

			tradeItemName:SetTextColor(GetItemQualityColor(quality))

			if quality then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	TradePlayerInputMoneyFrame:Point("TOPLEFT", 26, -53)
	TradeRecipientMoneyFrame:Point("TOPRIGHT", -40, -58)

	TradePlayerItem1:Point("TOPLEFT", 23, -94)
	TradeRecipientItem1:Point("TOPLEFT", 196, -94)

	TradeHighlightPlayer:Height(263)
	TradeHighlightRecipient:Height(263)
	TradeHighlightPlayer:Point("TOPLEFT", 20, -91)
	TradeHighlightRecipient:Point("TOPLEFT", 193, -91)

	TradeFramePlayerEnchantText:Point("TOPLEFT", 26, -364)

	TradeFrameTradeButton:Point("BOTTOMRIGHT", -113, 61)
end)