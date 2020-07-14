local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack, select = unpack, select
--WoW API / Variables
local GetInboxHeaderInfo = GetInboxHeaderInfo
local GetInboxItemLink = GetInboxItemLink
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetSendMailItem = GetSendMailItem

local INBOXITEMS_TO_DISPLAY = INBOXITEMS_TO_DISPLAY
local ATTACHMENTS_MAX_SEND = ATTACHMENTS_MAX_SEND
local ATTACHMENTS_MAX_RECEIVE = ATTACHMENTS_MAX_RECEIVE

S:AddCallback("Skin_Mail", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.mail then return end

	-- Inbox Frame
	MailFrame:StripTextures(true)
	MailFrame:CreateBackdrop("Transparent")
	MailFrame.backdrop:Point("TOPLEFT", 11, -12)
	MailFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(MailFrame, "width")
	S:SetBackdropHitRect(MailFrame)
	S:SetBackdropHitRect(SendMailFrame, MailFrame.backdrop)

	MailFrame:EnableMouseWheel(true)

	MailFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if InboxPrevPageButton:IsEnabled() == 1 then
				InboxPrevPage()
			end
		else
			if InboxNextPageButton:IsEnabled() == 1 then
				InboxNextPage()
			end
		end
	end)

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local mail = _G["MailItem"..i]
		local button = _G["MailItem"..i.."Button"]
		local icon = _G["MailItem"..i.."ButtonIcon"]

		mail:StripTextures()
		mail:CreateBackdrop("Transparent")
		mail.backdrop:SetParent(button)
		mail.backdrop:ClearAllPoints()
		mail.backdrop:Point("TOPLEFT", mail, 45, -2)
		mail.backdrop:Point("BOTTOMRIGHT", mail, 4, 9)
		mail.backdrop:SetFrameLevel(mail:GetFrameLevel() - 1)

		button:StripTextures()
		button:CreateBackdrop()
		button:Point("TOPLEFT", 8, -3)
		button:Size(32)
		button:StyleButton()
		button.hover:SetAllPoints()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside(button.backdrop)
	end

	hooksecurefunc("InboxFrame_Update", function()
		local numItems = GetInboxNumItems()
		local index = (InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY

		for i = 1, INBOXITEMS_TO_DISPLAY do
			index = index + 1

			if index <= numItems then
				local button = _G["MailItem"..i.."Button"]
				local packageIcon, _, _, _, _, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(index)

				if packageIcon and not isGM then
					local itemLink = GetInboxItemLink(index, 1)

					if itemLink then
						local quality = select(3, GetItemInfo(itemLink))

						if quality then
							button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
						else
							button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end
				elseif isGM then
					button.backdrop:SetBackdropBorderColor(0, 0.56, 0.94)
				else
					button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)

	InboxTitleText:Point("CENTER", 0, 231)
	SendMailTitleText:Point("CENTER", 0, 231)

	S:HandleNextPrevButton(InboxPrevPageButton, nil, nil, true)
	InboxPrevPageButton:Size(32)

	S:HandleNextPrevButton(InboxNextPageButton, nil, nil, true)
	InboxNextPageButton:Size(32)

	S:HandleCloseButton(InboxCloseButton, MailFrame.backdrop)

	for i = 1, 2 do
		local tab = _G["MailFrameTab"..i]
		tab:StripTextures()
		S:HandleTab(tab)
	end

	MailFrameTab1:Point("BOTTOMLEFT", MailFrame, 11, 46)
	MailFrameTab2:Point("LEFT", MailFrameTab1, "RIGHT", -15, 0)

	-- Send Mail Frame
	SendMailFrame:StripTextures()

	SendMailScrollFrame:StripTextures(true)

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = _G["SendMailAttachment"..i]
			local name = GetSendMailItem(i)

			if not button.skinned then
				button:StripTextures()
				button:SetTemplate("Default", true)
				button:StyleButton(nil, true)

				button.skinned = true
			end

			if name then
				local icon = button:GetNormalTexture()
				local quality = select(3, GetItemInfo(name))

				if quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end

				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetInside()
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	S:HandleScrollBar(SendMailScrollFrameScrollBar)

	S:HandleEditBox(SendMailNameEditBox)
	S:HandleEditBox(SendMailSubjectEditBox)
	S:HandleEditBox(SendMailMoneyGold)
	S:HandleEditBox(SendMailMoneySilver)
	S:HandleEditBox(SendMailMoneyCopper)

	S:HandleButton(SendMailMailButton)
	S:HandleButton(SendMailCancelButton)

	for i = 1, 5 do
		_G["AutoCompleteButton"..i]:StyleButton()
	end

	SendMailScrollFrame:CreateBackdrop()
	SendMailScrollFrame.backdrop:Point("TOPLEFT", 0, 5)
	SendMailScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -5)

	SendMailScrollFrameScrollBar:Point("TOPLEFT", SendMailScrollFrame, "TOPRIGHT", 3, -14)
	SendMailScrollFrameScrollBar:Point("BOTTOMLEFT", SendMailScrollFrame, "BOTTOMRIGHT", 3, 14)

	SendMailBodyEditBox:SetTextColor(1, 1, 1)
	SendMailBodyEditBox:Width(291)
	SendMailBodyEditBox:Point("TOPLEFT", 5, -5)

	SendMailScrollFrame:Width(304)
	SendMailScrollFrame:Point("TOPLEFT", 19, -97)

	SendMailNameEditBox:Height(18)
	SendMailNameEditBox:Point("TOPLEFT", 75, -43)

	SendMailSubjectEditBox:Size(247, 18)
	SendMailSubjectEditBox:Point("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -5)

	SendMailCostMoneyFrame:Point("TOPRIGHT", -27, -45)

	SendMailMoneyText:Point("TOPLEFT", 0, 3)
	SendMailMoney:Point("TOPLEFT", SendMailMoneyText, "BOTTOMLEFT", 2, -3)

	SendMailMoneyFrame:Point("BOTTOMRIGHT", SendMailFrame, "BOTTOMLEFT", 164, 88)
	SendMailMailButton:Point("RIGHT", SendMailCancelButton, "LEFT", -3, 0)

	SendMailCancelButton:Point("BOTTOMRIGHT", -40, 84)

	-- Open Mail Frame
	OpenMailFrame:StripTextures(true)
	OpenMailFrame:CreateBackdrop("Transparent")
	OpenMailFrame.backdrop:Point("TOPLEFT", 11, -12)
	OpenMailFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)
	OpenMailFrame:Point("TOPLEFT", InboxFrame, "TOPRIGHT", -44, 0)

	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["OpenMailAttachmentButton"..i]
		local icon = _G["OpenMailAttachmentButton"..i.."IconTexture"]
		local count = _G["OpenMailAttachmentButton"..i.."Count"]

		button:StripTextures()
		button:SetTemplate("Default", true)
		button:StyleButton()

		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("ARTWORK")
			icon:SetInside()

			count:SetDrawLayer("OVERLAY")
		end
	end

	hooksecurefunc("OpenMailFrame_UpdateButtonPositions", function()
		for i = 1, ATTACHMENTS_MAX_RECEIVE do
			local itemLink = GetInboxItemLink(InboxFrame.openMailID, i)
			local button = _G["OpenMailAttachmentButton"..i]

			if itemLink then
				local quality = select(3, GetItemInfo(itemLink))

				if quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	S:HandleCloseButton(OpenMailCloseButton, OpenMailFrame.backdrop)

	S:HandleButton(OpenMailReportSpamButton)

	S:HandleButton(OpenMailReplyButton)
	S:HandleButton(OpenMailDeleteButton)
	S:HandleButton(OpenMailCancelButton)

	OpenMailScrollFrame:StripTextures(true)
	OpenMailScrollFrame:SetTemplate("Default")

	S:HandleScrollBar(OpenMailScrollFrameScrollBar)

	OpenMailBodyText:SetTextColor(1, 1, 1)
	InvoiceTextFontNormal:SetFont(E.media.normFont, 13)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	OpenMailInvoiceBuyMode:SetTextColor(1, 0.80, 0.10)

	OpenMailArithmeticLine:Kill()

	OpenMailLetterButton:StripTextures()
	OpenMailLetterButton:SetTemplate("Default", true)
	OpenMailLetterButton:StyleButton()

	OpenMailLetterButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailLetterButtonIconTexture:SetDrawLayer("ARTWORK")
	OpenMailLetterButtonIconTexture:SetInside()

	OpenMailLetterButtonCount:SetDrawLayer("OVERLAY")

	OpenMailMoneyButton:StripTextures()
	OpenMailMoneyButton:SetTemplate("Default", true)
	OpenMailMoneyButton:StyleButton()

	OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailMoneyButtonIconTexture:SetDrawLayer("ARTWORK")
	OpenMailMoneyButtonIconTexture:SetInside()

	OpenMailMoneyButtonCount:SetDrawLayer("OVERLAY")

	OpenMailScrollFrame:Width(304)
	OpenMailScrollFrame:Point("TOPLEFT", 19, -92)

	OpenMailScrollFrameScrollBar:Point("TOPLEFT", OpenMailScrollFrame, "TOPRIGHT", 3, -19)
	OpenMailScrollFrameScrollBar:Point("BOTTOMLEFT", OpenMailScrollFrame, "BOTTOMRIGHT", 3, 19)

	OpenMailSenderLabel:Point("TOPRIGHT", OpenMailFrame, "TOPLEFT", 85, -45)
	OpenMailSubjectLabel:Point("TOPRIGHT", OpenMailFrame, "TOPLEFT", 85, -65)
	OpenMailSender:Point("LEFT", OpenMailSenderLabel, "RIGHT", 5, -1)
	OpenMailSubject:Point("TOPLEFT", OpenMailSubjectLabel, "TOPRIGHT", 5, -1)

	OpenMailReportSpamButton:Point("TOPRIGHT", -40, -43)
	OpenMailCancelButton:Point("BOTTOMRIGHT", -40, 84)
	OpenMailDeleteButton:Point("RIGHT", OpenMailCancelButton, "LEFT", -3, 0)
	OpenMailReplyButton:Point("RIGHT", OpenMailDeleteButton, "LEFT", -3, 0)
end)