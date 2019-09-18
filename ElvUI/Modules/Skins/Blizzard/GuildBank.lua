local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local ceil, fmod = math.ceil, math.fmod
--WoW API / Variables
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetGuildBankItemLink = GetGuildBankItemLink
local GetItemQualityColor = GetItemQualityColor

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gbank then return end

	GuildBankFrame:StripTextures()
	GuildBankFrame:CreateBackdrop("Transparent")
	GuildBankFrame.backdrop:Point("TOPLEFT", 8, -11)
	GuildBankFrame.backdrop:Point("BOTTOMRIGHT", 0, 6)
	GuildBankFrame:Width(654)

	GuildBankEmblemFrame:StripTextures(true)

	for i = 1, GuildBankFrame:GetNumChildren() do
		local child = select(i, GuildBankFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
		end
	end

	S:HandleButton(GuildBankFrameDepositButton, true)
	GuildBankFrameDepositButton:Width(85)

	S:HandleButton(GuildBankFrameWithdrawButton, true)
	GuildBankFrameWithdrawButton:Width(85)
	GuildBankFrameWithdrawButton:Point("RIGHT", GuildBankFrameDepositButton, "LEFT", -2, 0)

	S:HandleButton(GuildBankInfoSaveButton, true)
	S:HandleButton(GuildBankFramePurchaseButton, true)

	GuildBankInfoScrollFrame:StripTextures()
	GuildBankInfoScrollFrame:Width(572)

	S:HandleScrollBar(GuildBankInfoScrollFrameScrollBar)
	GuildBankInfoScrollFrameScrollBar:ClearAllPoints()
	GuildBankInfoScrollFrameScrollBar:Point("TOPRIGHT", GuildBankInfoScrollFrame, "TOPRIGHT", 29, -10)
	GuildBankInfoScrollFrameScrollBar:Point("BOTTOMRIGHT", GuildBankInfoScrollFrame, "BOTTOMRIGHT", 0, 18)

	GuildBankTabInfoEditBox:Width(702)

	GuildBankTransactionsScrollFrame:StripTextures()

	S:HandleScrollBar(GuildBankTransactionsScrollFrameScrollBar)
	GuildBankTransactionsScrollFrameScrollBar:ClearAllPoints()
	GuildBankTransactionsScrollFrameScrollBar:Point("TOPRIGHT", GuildBankTransactionsScrollFrame, "TOPRIGHT", 29, -9)
	GuildBankTransactionsScrollFrameScrollBar:Point("BOTTOMRIGHT", GuildBankTransactionsScrollFrame, "BOTTOMRIGHT", 0, 17)

	GuildBankFrame.inset = CreateFrame("Frame", nil, GuildBankFrame)
	GuildBankFrame.inset:SetTemplate("Default")
	GuildBankFrame.inset:Point("TOPLEFT", 24, -64)
	GuildBankFrame.inset:Point("BOTTOMRIGHT", -18, 62)

	GuildBankLimitLabel:Point("CENTER", GuildBankTabLimitBackground, "CENTER", -40, 1)

	for i = 1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:StripTextures()

		for x = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = _G["GuildBankColumn"..i.."Button"..x]
			local icon = _G["GuildBankColumn"..i.."Button"..x.."IconTexture"]
			local texture = _G["GuildBankColumn"..i.."Button"..x.."NormalTexture"]
			local count = _G["GuildBankColumn"..i.."Button"..x.."Count"]

			if texture then
				texture:SetTexture(nil)
			end

			button:StyleButton()
			button:SetTemplate("Default", true)

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("OVERLAY")

			count:SetDrawLayer("OVERLAY")
		end
	end

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

	for i = 1, 4 do
		S:HandleTab(_G["GuildBankFrameTab"..i])
	end

	hooksecurefunc("GuildBankFrame_Update", function()
		if GuildBankFrame.mode ~= "bank" then return end

		local tab = GetCurrentGuildBankTab()
		local _, index, column, link, quality

		for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			index = fmod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)

			if index == 0 then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP
			end

			column = ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
			link = GetGuildBankItemLink(tab, i)

			if link then
				_, _, quality = GetItemInfo(link)

				if quality and quality > 1 then
					_G["GuildBankColumn"..column.."Button"..index]:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					_G["GuildBankColumn"..column.."Button"..index]:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				_G["GuildBankColumn"..column.."Button"..index]:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	-- Popup
	S:HandleIconSelectionFrame(GuildBankPopupFrame, NUM_GUILDBANK_ICONS_SHOWN, "GuildBankPopupButton", "GuildBankPopup")

	S:HandleScrollBar(GuildBankPopupScrollFrameScrollBar)

	GuildBankPopupScrollFrame:CreateBackdrop("Transparent")
	GuildBankPopupScrollFrame.backdrop:Point("TOPLEFT", 92, 2)
	GuildBankPopupScrollFrame.backdrop:Point("BOTTOMRIGHT", -5, 2)
	GuildBankPopupScrollFrame:Point("TOPRIGHT", GuildBankPopupFrame, "TOPRIGHT", -30, -66)

	GuildBankPopupButton1:Point("TOPLEFT", GuildBankPopupFrame, "TOPLEFT", 30, -86)
	GuildBankPopupFrame:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", 36, 0)

	-- Reposition
	GuildBankTab1:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", E.PixelMode and -3 or -1, -36)
	GuildBankTab2:Point("TOPLEFT", GuildBankTab1, "BOTTOMLEFT", 0, 7)
	GuildBankTab3:Point("TOPLEFT", GuildBankTab2, "BOTTOMLEFT", 0, 7)
	GuildBankTab4:Point("TOPLEFT", GuildBankTab3, "BOTTOMLEFT", 0, 7)
	GuildBankTab5:Point("TOPLEFT", GuildBankTab4, "BOTTOMLEFT", 0, 7)
	GuildBankTab6:Point("TOPLEFT", GuildBankTab5, "BOTTOMLEFT", 0, 7)

	GuildBankColumn1:Point("TOPLEFT", GuildBankFrame, "TOPLEFT", 25, -70)
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
end

S:AddCallbackForAddon("Blizzard_GuildBankUI", "Skin_Blizzard_GuildBankUI", LoadSkin)