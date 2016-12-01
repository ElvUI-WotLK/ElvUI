local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gbank ~= true then return end
	GuildBankFrame:StripTextures()
	GuildBankFrame:CreateBackdrop("Transparent")
	GuildBankFrame.backdrop:Point("TOPLEFT", 8, -11)
	GuildBankFrame.backdrop:Point("BOTTOMRIGHT", 0, 6)
	GuildBankEmblemFrame:StripTextures(true)
	S:HandleScrollBar(GuildBankPopupScrollFrameScrollBar)

	--Close button doesn't have a fucking name, extreme hackage
	for i=1, GuildBankFrame:GetNumChildren() do
		local child = select(i, GuildBankFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
		end
	end

	S:HandleButton(GuildBankFrameDepositButton, true)
	S:HandleButton(GuildBankFrameWithdrawButton, true)
	S:HandleButton(GuildBankInfoSaveButton, true)
	S:HandleButton(GuildBankFramePurchaseButton, true)

	GuildBankFrameWithdrawButton:Point("RIGHT", GuildBankFrameDepositButton, "LEFT", -2, 0)

	GuildBankInfoScrollFrame:Point("TOPLEFT", GuildBankInfo, "TOPLEFT", -10, 12)
	GuildBankInfoScrollFrame:StripTextures()
	GuildBankInfoScrollFrame:Width(GuildBankInfoScrollFrame:GetWidth() + 14)

	GuildBankTabInfoEditBox:SetWidth(702)

	GuildBankTransactionsScrollFrame:StripTextures()

	GuildBankFrame.inset = CreateFrame("Frame", nil, GuildBankFrame)
	GuildBankFrame.inset:SetTemplate("Default")
	GuildBankFrame.inset:Point("TOPLEFT", 20, -58)
	GuildBankFrame.inset:Point("BOTTOMRIGHT", -16, 60)

	for i=1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:StripTextures()

		for x=1, NUM_SLOTS_PER_GUILDBANK_GROUP do
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

	for i=1, 6 do
		local button = _G["GuildBankTab"..i.."Button"]
		local texture = _G["GuildBankTab"..i.."ButtonIconTexture"]
		_G["GuildBankTab"..i]:StripTextures(true)

		button:StripTextures()
		button:StyleButton()
		button:SetTemplate("Default", true)

		texture:SetInside()
		texture:SetTexCoord(unpack(E.TexCoords))
		texture:SetDrawLayer("OVERLAY")
	end

	GuildBankTab1:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", -3, -36)
	GuildBankTab2:Point("TOPLEFT", GuildBankTab1, "BOTTOMLEFT", 0, 7)
	GuildBankTab3:Point("TOPLEFT", GuildBankTab2, "BOTTOMLEFT", 0, 7)
	GuildBankTab4:Point("TOPLEFT", GuildBankTab3, "BOTTOMLEFT", 0, 7)
	GuildBankTab5:Point("TOPLEFT", GuildBankTab4, "BOTTOMLEFT", 0, 7)
	GuildBankTab6:Point("TOPLEFT", GuildBankTab5, "BOTTOMLEFT", 0, 7)

	for i=1, 4 do
		S:HandleTab(_G["GuildBankFrameTab"..i])
	end

	hooksecurefunc("GuildBankFrame_Update", function()
		if GuildBankFrame.mode ~= "bank" then return; end
		local tab = GetCurrentGuildBankTab();
		local button, index, column, itemLink, itemRarity, r, g, b;
		for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
			index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
			if ( index == 0 ) then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP;
			end
			column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
			button = _G["GuildBankColumn"..column.."Button"..index];

			itemLink = GetGuildBankItemLink(tab, i);
			if itemLink then
				itemRarity = select(3, GetItemInfo(itemLink))
				if itemRarity > 1 then
					r, g, b = GetItemQualityColor(itemRarity)
				else
					r, g, b = unpack(E.media.bordercolor)
				end
			else
				r, g, b = unpack(E.media.bordercolor)
			end
			button:SetBackdropBorderColor(r, g, b)
		end
	end)

	--Popup
	S:HandleIconSelectionFrame(GuildBankPopupFrame, NUM_GUILDBANK_ICONS_SHOWN, "GuildBankPopupButton", "GuildBankPopup");

	S:HandleScrollBar(GuildBankTransactionsScrollFrameScrollBar)
	S:HandleScrollBar(GuildBankInfoScrollFrameScrollBar)
end

S:AddCallbackForAddon("Blizzard_GuildBankUI", "GuildBank", LoadSkin);