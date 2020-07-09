local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select = select
local unpack = unpack
--WoW API / Variables
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemQuestInfo = GetContainerItemQuestInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetInventoryItemID = GetInventoryItemID

local BANK_CONTAINER = BANK_CONTAINER

S:AddCallback("Skin_Bags", function()
	if E.private.bags.enable then return end
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bags then return end

	local professionColors = {
		[0x0001] = {E.db.bags.colors.profession.quiver.r, E.db.bags.colors.profession.quiver.g, E.db.bags.colors.profession.quiver.b},
		[0x0002] = {E.db.bags.colors.profession.ammoPouch.r, E.db.bags.colors.profession.ammoPouch.g, E.db.bags.colors.profession.ammoPouch.b},
		[0x0004] = {E.db.bags.colors.profession.soulBag.r, E.db.bags.colors.profession.soulBag.g, E.db.bags.colors.profession.soulBag.b},
		[0x0008] = {E.db.bags.colors.profession.leatherworking.r, E.db.bags.colors.profession.leatherworking.g, E.db.bags.colors.profession.leatherworking.b},
		[0x0010] = {E.db.bags.colors.profession.inscription.r, E.db.bags.colors.profession.inscription.g, E.db.bags.colors.profession.inscription.b},
		[0x0020] = {E.db.bags.colors.profession.herbs.r, E.db.bags.colors.profession.herbs.g, E.db.bags.colors.profession.herbs.b},
		[0x0040] = {E.db.bags.colors.profession.enchanting.r, E.db.bags.colors.profession.enchanting.g, E.db.bags.colors.profession.enchanting.b},
		[0x0080] = {E.db.bags.colors.profession.engineering.r, E.db.bags.colors.profession.engineering.g, E.db.bags.colors.profession.engineering.b},
		[0x0200] = {E.db.bags.colors.profession.gems.r, E.db.bags.colors.profession.gems.g, E.db.bags.colors.profession.gems.b},
		[0x0400] = {E.db.bags.colors.profession.mining.r, E.db.bags.colors.profession.mining.g, E.db.bags.colors.profession.mining.b},
	}

	local questColors = {
		["questStarter"] = {E.db.bags.colors.items.questStarter.r, E.db.bags.colors.items.questStarter.g, E.db.bags.colors.items.questStarter.b},
		["questItem"] =	{E.db.bags.colors.items.questItem.r, E.db.bags.colors.items.questItem.g, E.db.bags.colors.items.questItem.b}
	}

	-- ContainerFrame
	for i = 1, NUM_CONTAINER_FRAMES do
		local frame = _G["ContainerFrame"..i]
		local closeButton = _G["ContainerFrame"..i.."CloseButton"]

		frame:StripTextures(true)
		frame:CreateBackdrop("Transparent")
		frame.backdrop:Point("TOPLEFT", 9, -4)
		frame.backdrop:Point("BOTTOMRIGHT", -4, 1)

		S:HookScript(frame, "OnShow", function(self)
			S:SetBackdropHitRect(self)
			S:Unhook(self, "OnShow")
		end)

		S:HandleCloseButton(closeButton, frame.backdrop)

		for j = 1, MAX_CONTAINER_ITEMS do
			local item = _G["ContainerFrame"..i.."Item"..j]
			local icon = _G["ContainerFrame"..i.."Item"..j.."IconTexture"]
			local questIcon = _G["ContainerFrame"..i.."Item"..j.."IconQuestTexture"]
			local cooldown = _G["ContainerFrame"..i.."Item"..j.."Cooldown"]

			item:SetNormalTexture(nil)
			item:SetTemplate("Default", true)
			item:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))

			questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
			questIcon.SetTexture = E.noop
			questIcon:SetTexCoord(0, 1, 0, 1)
			questIcon:SetInside()

			cooldown.CooldownOverride = "bags"
			E:RegisterCooldown(cooldown)
		end
	end

	BackpackTokenFrame:StripTextures()

	for i = 1, MAX_WATCHED_TOKENS do
		local token = _G["BackpackTokenFrameToken"..i]

		token:CreateBackdrop("Default")
		token.backdrop:SetOutside(token.icon)

		token.icon:SetTexCoord(unpack(E.TexCoords))
		token.icon:Point("LEFT", token.count, "RIGHT", 2, 0)
		token.icon:Size(16)
	end

	local function setBagIcon(frame, texture)
		if not frame.BagIcon then
			local portraitButton = _G[frame:GetName().."PortraitButton"]

			portraitButton:CreateBackdrop()
			portraitButton:Size(32)
			portraitButton:Point("TOPLEFT", 12, -7)
			portraitButton:StyleButton(nil, true)
			portraitButton.hover:SetAllPoints()

			frame.BagIcon = portraitButton:CreateTexture()
			frame.BagIcon:SetTexCoord(unpack(E.TexCoords))
			frame.BagIcon:SetAllPoints()
		end

		frame.BagIcon:SetTexture(texture)
	end

	local bagIconCache = {
		[-2] = "Interface\\ContainerFrame\\KeyRing-Bag-Icon",
		[0] = "Interface\\Buttons\\Button-Backpack-Up"
	}

	hooksecurefunc("ContainerFrame_GenerateFrame", function(frame)
		local id = frame:GetID()

		if id > 0 then
			local itemID = GetInventoryItemID("player", ContainerIDToInventoryID(id))

			if not bagIconCache[itemID] then
				bagIconCache[itemID] = select(10, GetItemInfo(itemID))
			end

			setBagIcon(frame, bagIconCache[itemID])
		else
			setBagIcon(frame, bagIconCache[id])
		end
	end)

	hooksecurefunc("ContainerFrame_Update", function(frame)
		local frameName = frame:GetName()
		local id = frame:GetID()
		local _, bagType = GetContainerNumFreeSlots(id)
		local item, questIcon, link

		for i = 1, frame.size do
			item = _G[frameName.."Item"..i]
			questIcon = _G[frameName.."Item"..i.."IconQuestTexture"]
			link = GetContainerItemLink(id, item:GetID())

			questIcon:Hide()

			if professionColors[bagType] then
				item:SetBackdropBorderColor(unpack(professionColors[bagType]))
				item.ignoreBorderColors = true
			elseif link then
				local isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, item:GetID())
				local _, _, quality = GetItemInfo(link)

				if questId and not isActive then
					item:SetBackdropBorderColor(unpack(questColors.questStarter))
					item.ignoreBorderColors = true
					questIcon:Show()
				elseif questId or isQuestItem then
					item:SetBackdropBorderColor(unpack(questColors.questItem))
					item.ignoreBorderColors = true
				elseif quality then
					item:SetBackdropBorderColor(GetItemQualityColor(quality))
					item.ignoreBorderColors = true
				else
					item:SetBackdropBorderColor(unpack(E.media.bordercolor))
					item.ignoreBorderColors = nil
				end
			else
				item:SetBackdropBorderColor(unpack(E.media.bordercolor))
				item.ignoreBorderColors = nil
			end
		end
	end)

	-- BankFrame
	BankFrame:StripTextures(true)
	BankFrame:CreateBackdrop("Transparent")
	BankFrame.backdrop:Point("TOPLEFT", 11, -12)
	BankFrame.backdrop:Point("BOTTOMRIGHT", -26, 76)

	S:SetBackdropHitRect(BankFrame)

	S:HandleCloseButton(BankCloseButton)

	BankFrameItem1:Point("TOPLEFT", 39, -73)

	for i = 1, NUM_BANKGENERIC_SLOTS do
		local button = _G["BankFrameItem"..i]
		local icon = _G["BankFrameItem"..i.."IconTexture"]
		local quest = _G["BankFrameItem"..i.."IconQuestTexture"]
		local cooldown = _G["BankFrameItem"..i.."Cooldown"]

		button:SetNormalTexture(nil)
		button:SetTemplate("Default", true)
		button:StyleButton()

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		quest:SetTexture(E.Media.Textures.BagQuestIcon)
		quest.SetTexture = E.noop
		quest:SetTexCoord(0, 1, 0, 1)
		quest:SetInside()

		cooldown.CooldownOverride = "bags"
		E:RegisterCooldown(cooldown)
	end

	BankFrame.itemBackdrop = CreateFrame("Frame", "BankFrameItemBackdrop", BankFrame)
	BankFrame.itemBackdrop:SetTemplate("Default")
	BankFrame.itemBackdrop:SetOutside(BankFrameItem1, 6, 6, BankFrameItem28)
	BankFrame.itemBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	for i = 1, NUM_BANKBAGSLOTS do
		local button = _G["BankFrameBag"..i]
		local icon = _G["BankFrameBag"..i.."IconTexture"]
		local highlight = _G["BankFrameBag"..i.."HighlightFrameTexture"]

		button:SetNormalTexture(nil)
		button:SetTemplate("Default", true)
		button:StyleButton()

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		highlight:SetInside()
		highlight:SetTexture(unpack(E.media.rgbvaluecolor), 0.3)
	end

	BankFrame.bagBackdrop = CreateFrame("Frame", "BankFrameBagBackdrop", BankFrame)
	BankFrame.bagBackdrop:SetTemplate("Default")
	BankFrame.bagBackdrop:SetOutside(BankFrameBag1, 6, 6, BankFrameBag7)
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	S:HandleButton(BankFramePurchaseButton)

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		local id = button:GetID()

		if button.isBag then
			local link = GetInventoryItemLink("player", ContainerIDToInventoryID(id))

			if link then
				local quality = select(3, GetItemInfo(link))

				if quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
					button.ignoreBorderColors = true
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
					button.ignoreBorderColors = nil
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.ignoreBorderColors = nil
			end
		else
			local link = GetContainerItemLink(BANK_CONTAINER, id)
			local questTexture = _G[button:GetName().."IconQuestTexture"]

			if questTexture then
				questTexture:Hide()
			end

			if link then
				local isQuestItem, questId, isActive = GetContainerItemQuestInfo(BANK_CONTAINER, id)

				if questId and not isActive then
					button:SetBackdropBorderColor(unpack(questColors.questStarter))
					button.ignoreBorderColors = true

					if questTexture then
						questTexture:Show()
					end
				elseif questId or isQuestItem then
					button:SetBackdropBorderColor(unpack(questColors.questItem))
					button.ignoreBorderColors = true
				else
					local quality = select(3, GetItemInfo(link))

					if quality then
						button:SetBackdropBorderColor(GetItemQualityColor(quality))
						button.ignoreBorderColors = true
					else
						button:SetBackdropBorderColor(unpack(E.media.bordercolor))
						button.ignoreBorderColors = nil
					end
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.ignoreBorderColors = nil
			end
		end
	end)
end)