local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack, select = unpack, select;

local GetItemInfo = GetItemInfo;
local GetItemQualityColor = GetItemQualityColor;
local GetTradePlayerItemLink = GetTradePlayerItemLink;
local GetTradeTargetItemLink = GetTradeTargetItemLink;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trade ~= true) then return; end

	TradeFrame:StripTextures(true);
	TradeFrame:CreateBackdrop("Transparent");
	TradeFrame.backdrop:Point("TOPLEFT", 10, -11);
	TradeFrame.backdrop:Point("BOTTOMRIGHT", -28, 48);

	S:HandleCloseButton(TradeFrameCloseButton, TradeFrame.backdrop);

	S:HandleEditBox(TradePlayerInputMoneyFrameGold);
	S:HandleEditBox(TradePlayerInputMoneyFrameSilver);
	S:HandleEditBox(TradePlayerInputMoneyFrameCopper);

	for i = 1, MAX_TRADE_ITEMS do
		local player = _G["TradePlayerItem" .. i];
		local recipient = _G["TradeRecipientItem" .. i];
		local playerButton = _G["TradePlayerItem" .. i .. "ItemButton"];
		local playerButtonIcon = _G["TradePlayerItem" .. i .. "ItemButtonIconTexture"];
		local recipientButton = _G["TradeRecipientItem" .. i .. "ItemButton"];
		local recipientButtonIcon = _G["TradeRecipientItem" .. i .. "ItemButtonIconTexture"];

		player:StripTextures();
		recipient:StripTextures();

		playerButton:StripTextures();
		playerButton:StyleButton();
		playerButton:SetTemplate("Default", true);

		playerButtonIcon:SetInside();
		playerButtonIcon:SetTexCoord(unpack(E.TexCoords));

		recipientButton:StripTextures();
		recipientButton:StyleButton();
		recipientButton:SetTemplate("Default", true);

		recipientButtonIcon:SetInside();
		recipientButtonIcon:SetTexCoord(unpack(E.TexCoords));
	end

	TradeHighlightPlayerTop:SetTexture(0, 1, 0, 0.2);
	TradeHighlightPlayerBottom:SetTexture(0, 1, 0, 0.2);
	TradeHighlightPlayerMiddle:SetTexture(0, 1, 0, 0.2);

	TradeHighlightPlayerEnchantTop:SetTexture(0, 1, 0, 0.2);
	TradeHighlightPlayerEnchantBottom:SetTexture(0, 1, 0, 0.2);
	TradeHighlightPlayerEnchantMiddle:SetTexture(0, 1, 0, 0.2);

	TradeHighlightRecipientTop:SetTexture(0, 1, 0, 0.2);
	TradeHighlightRecipientBottom:SetTexture(0, 1, 0, 0.2);
	TradeHighlightRecipientMiddle:SetTexture(0, 1, 0, 0.2);

	TradeHighlightRecipientEnchantTop:SetTexture(0, 1, 0, 0.2);
	TradeHighlightRecipientEnchantBottom:SetTexture(0, 1, 0, 0.2);
	TradeHighlightRecipientEnchantMiddle:SetTexture(0, 1, 0, 0.2);

	S:HandleButton(TradeFrameTradeButton);
	S:HandleButton(TradeFrameCancelButton);

	hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
		local link = GetTradePlayerItemLink(id);
		local tradeItemButton = _G["TradePlayerItem" .. id .. "ItemButton"];
		local tradeItemName = _G["TradePlayerItem" .. id .. "Name"];
		if(link) then
			local quality = select(3, GetItemInfo(link));
			tradeItemName:SetTextColor(GetItemQualityColor(quality));
			if(quality and quality > 1) then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality));
			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
		end
	end);

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		local link = GetTradeTargetItemLink(id);
		local tradeItemButton = _G["TradeRecipientItem" .. id .. "ItemButton"];
		local tradeItemName = _G["TradeRecipientItem" .. id .. "Name"];
		if(link) then
			local quality = select(3, GetItemInfo(link));
			tradeItemName:SetTextColor(GetItemQualityColor(quality));
			if(quality and quality > 1) then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality));
			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
		end
	end);
end

S:AddCallback("Trade", LoadSkin);