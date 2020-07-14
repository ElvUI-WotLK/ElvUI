local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetGuildBankItemLink = GetGuildBankItemLink
local GetItemQualityColor = GetItemQualityColor

S:AddCallbackForAddon("Blizzard_GuildBankUI", "Skin_Blizzard_GuildBankUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gbank then return end

	GuildBankFrame:Width(639)
	GuildBankFrame:StripTextures()
	GuildBankFrame:CreateBackdrop("Transparent")
	GuildBankFrame.backdrop:Point("TOPLEFT", 11, -12)
	GuildBankFrame.backdrop:Point("BOTTOMRIGHT", 0, 8)

	S:HookScript(GuildBankFrame, "OnShow", function(self)
		S:SetUIPanelWindowInfo(self, "width", nil, 35)
		S:SetBackdropHitRect(self)
		S:Unhook(self, "OnShow")
	end)

	GuildBankFrame.inset = CreateFrame("Frame", nil, GuildBankFrame)
	GuildBankFrame.inset:SetTemplate("Default")
	GuildBankFrame.inset:Point("TOPLEFT", 19, -64)
	GuildBankFrame.inset:Point("BOTTOMRIGHT", -8, 62)

	GuildBankEmblemFrame:StripTextures(true)

	S:HandleCloseButton((select(13, GuildBankFrame:GetChildren())), GuildBankFrame.backdrop)

	S:HandleButton(GuildBankFrameDepositButton)
	S:HandleButton(GuildBankFrameWithdrawButton)
	S:HandleButton(GuildBankInfoSaveButton)
	S:HandleButton(GuildBankFramePurchaseButton)

	GuildBankInfoScrollFrame:StripTextures()

	S:HandleScrollBar(GuildBankInfoScrollFrameScrollBar)

	GuildBankTransactionsScrollFrame:StripTextures()

	S:HandleScrollBar(GuildBankTransactionsScrollFrameScrollBar)

	S:HandleTab(GuildBankFrameTab1)
	S:HandleTab(GuildBankFrameTab2)
	S:HandleTab(GuildBankFrameTab3)
	S:HandleTab(GuildBankFrameTab4)

	for i = 1, 6 do
		local tab = _G["GuildBankTab"..i]
		local button = _G["GuildBankTab"..i.."Button"]
		local texture = _G["GuildBankTab"..i.."ButtonIconTexture"]

		tab:StripTextures(true)

		button:StripTextures()
		button:SetTemplate()
		button:StyleButton()

		button:GetCheckedTexture():SetTexture(1, 1, 1, 0.3)
		button:GetCheckedTexture():SetInside()

		texture:SetInside()
		texture:SetTexCoord(unpack(E.TexCoords))
		texture:SetDrawLayer("ARTWORK")
	end

	local buttonMap = {}

	for column = 1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..column]:StripTextures()

		for index = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = _G["GuildBankColumn"..column.."Button"..index]
			local icon = _G["GuildBankColumn"..column.."Button"..index.."IconTexture"]
			local texture = _G["GuildBankColumn"..column.."Button"..index.."NormalTexture"]
			local count = _G["GuildBankColumn"..column.."Button"..index.."Count"]

			if texture then
				texture:SetTexture(nil)
			end

			button:StyleButton()
			button:SetTemplate("Default", true)

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("OVERLAY")

			count:SetDrawLayer("OVERLAY")

			buttonMap[#buttonMap + 1] = button
		end
	end

	hooksecurefunc("GuildBankFrame_Update", function()
		if GuildBankFrame.mode ~= "bank" then
			GuildBankFrame.inset:Point("BOTTOMRIGHT", -29, 62)
			return
		else
			GuildBankFrame.inset:Point("BOTTOMRIGHT", -8, 62)

			GuildBankColumn1:Point("TOPLEFT", 20, -70)
		end

		local tab = GetCurrentGuildBankTab()
		local _, link, quality

		for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			link = GetGuildBankItemLink(tab, i)

			if link then
				_, _, quality = GetItemInfo(link)

				if quality and quality > 1 then
					buttonMap[i]:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					buttonMap[i]:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				buttonMap[i]:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	GuildBankLimitLabel:ClearAllPoints()
	GuildBankLimitLabel:Point("BOTTOMLEFT", GuildBankMoneyLimitLabel, "TOPLEFT", -1, 11)

	GuildBankFrameDepositButton:Point("BOTTOMRIGHT", -8, 36)
	GuildBankFrameWithdrawButton:Point("RIGHT", GuildBankFrameDepositButton, "LEFT", -3, 0)

	GuildBankFrameTab1:Point("BOTTOMLEFT", 11, -22)
	GuildBankFrameTab2:Point("LEFT", GuildBankFrameTab1, "RIGHT", -15, 0)
	GuildBankFrameTab3:Point("LEFT", GuildBankFrameTab2, "RIGHT", -15, 0)
	GuildBankFrameTab4:Point("LEFT", GuildBankFrameTab3, "RIGHT", -15, 0)

	-- Log + Money Log tabs
	GuildBankMessageFrame:Size(575, 302)
	GuildBankMessageFrame:Point("TOPLEFT", 27, -72)

	GuildBankTransactionsScrollFrame:Size(591, 318)
	GuildBankTransactionsScrollFrame:Point("TOPRIGHT", GuildBankFrame, "TOPRIGHT", -29, -64)

	GuildBankTransactionsScrollFrameScrollBar:Point("TOPLEFT", GuildBankTransactionsScrollFrame, "TOPRIGHT", 3, -19)
	GuildBankTransactionsScrollFrameScrollBar:Point("BOTTOMLEFT", GuildBankTransactionsScrollFrame, "BOTTOMRIGHT", 3, 19)

	-- Info tab
	GuildBankInfo:Point("TOPLEFT", 26, -72)

	GuildBankInfoScrollFrame:Size(575, 302)

	GuildBankInfoScrollFrameScrollBar:Point("TOPLEFT", GuildBankInfoScrollFrame, "TOPRIGHT", 12, -11)
	GuildBankInfoScrollFrameScrollBar:Point("BOTTOMLEFT", GuildBankInfoScrollFrame, "BOTTOMRIGHT", 12, 11)

	GuildBankTabInfoEditBox:Width(575)

	GuildBankInfoSaveButton:Point("BOTTOMLEFT", GuildBankFrame, "BOTTOMLEFT", 19, 35)

	-- Popup
	S:HandleIconSelectionFrame(GuildBankPopupFrame, NUM_GUILDBANK_ICONS_SHOWN, "GuildBankPopupButton", "GuildBankPopup")
	S:SetBackdropHitRect(GuildBankPopupFrame)

	S:HandleScrollBar(GuildBankPopupScrollFrameScrollBar)

	GuildBankPopupFrame:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", 24, 0)

	local nameLable, iconLable = select(5, GuildBankPopupFrame:GetRegions())
	nameLable:Point("TOPLEFT", 24, -18)
	iconLable:Point("TOPLEFT", 24, -60)

	GuildBankPopupEditBox:Point("TOPLEFT", 32, -35)

	GuildBankPopupScrollFrame:CreateBackdrop("Transparent")
	GuildBankPopupScrollFrame.backdrop:Point("TOPLEFT", 91, -10)
	GuildBankPopupScrollFrame.backdrop:Point("BOTTOMRIGHT", -19, 5)
	GuildBankPopupScrollFrame:Point("TOPRIGHT", -30, -66)

	GuildBankPopupScrollFrameScrollBar:Point("TOPLEFT", GuildBankPopupScrollFrame, "TOPRIGHT", -16, -29)
	GuildBankPopupScrollFrameScrollBar:Point("BOTTOMLEFT", GuildBankPopupScrollFrame, "BOTTOMRIGHT", -16, 24)

	GuildBankPopupButton1:Point("TOPLEFT", 24, -82)

	GuildBankPopupCancelButton:Point("BOTTOMRIGHT", -28, 35)
	GuildBankPopupOkayButton:Point("RIGHT", GuildBankPopupCancelButton, "LEFT", -3, 0)

	-- Reposition
	GuildBankTab1:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", E.PixelMode and -3 or -1, -36)
	GuildBankTab2:Point("TOPLEFT", GuildBankTab1, "BOTTOMLEFT", 0, 7)
	GuildBankTab3:Point("TOPLEFT", GuildBankTab2, "BOTTOMLEFT", 0, 7)
	GuildBankTab4:Point("TOPLEFT", GuildBankTab3, "BOTTOMLEFT", 0, 7)
	GuildBankTab5:Point("TOPLEFT", GuildBankTab4, "BOTTOMLEFT", 0, 7)
	GuildBankTab6:Point("TOPLEFT", GuildBankTab5, "BOTTOMLEFT", 0, 7)

	GuildBankColumn1:Point("TOPLEFT", 25, -70)
	GuildBankColumn2:Point("TOPLEFT", GuildBankColumn1, "TOPRIGHT", -14, 0)
	GuildBankColumn3:Point("TOPLEFT", GuildBankColumn2, "TOPRIGHT", -14, 0)
	GuildBankColumn4:Point("TOPLEFT", GuildBankColumn3, "TOPRIGHT", -14, 0)
	GuildBankColumn5:Point("TOPLEFT", GuildBankColumn4, "TOPRIGHT", -14, 0)
	GuildBankColumn6:Point("TOPLEFT", GuildBankColumn5, "TOPRIGHT", -14, 0)
	GuildBankColumn7:Point("TOPLEFT", GuildBankColumn6, "TOPRIGHT", -14, 0)

	GuildBankColumn1Button8:Point("TOPLEFT", GuildBankColumn1Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn2Button8:Point("TOPLEFT", GuildBankColumn2Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn3Button8:Point("TOPLEFT", GuildBankColumn3Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn4Button8:Point("TOPLEFT", GuildBankColumn4Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn5Button8:Point("TOPLEFT", GuildBankColumn5Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn6Button8:Point("TOPLEFT", GuildBankColumn6Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn7Button8:Point("TOPLEFT", GuildBankColumn7Button1, "TOPRIGHT", 6, 0)
end)