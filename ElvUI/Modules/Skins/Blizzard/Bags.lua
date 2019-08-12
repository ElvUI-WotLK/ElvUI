local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemQuestInfo = GetContainerItemQuestInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc
local BACKPACK_TOOLTIP = BACKPACK_TOOLTIP
local BANK_CONTAINER = BANK_CONTAINER
local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

local bagIconCache = {}

local function LoadSkin()
	if E.private.bags.enable then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true then return end

	local ProfessionColors = {
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

	local QuestColors = {
		["questStarter"] = {E.db.bags.colors.items.questStarter.r, E.db.bags.colors.items.questStarter.g, E.db.bags.colors.items.questStarter.b},
		["questItem"] =	{E.db.bags.colors.items.questItem.r, E.db.bags.colors.items.questItem.g, E.db.bags.colors.items.questItem.b}
	}

	-- ContainerFrame
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i]
		local closeButton = _G["ContainerFrame"..i.."CloseButton"]

		frame:StripTextures(true)
		frame:CreateBackdrop("Transparent")
		frame.backdrop:Point("TOPLEFT", 9, -4)
		frame.backdrop:Point("BOTTOMRIGHT", -4, 2)

		S:HandleCloseButton(_G["ContainerFrame"..i.."CloseButton"])

		for k = 1, MAX_CONTAINER_ITEMS, 1 do
			local item = _G["ContainerFrame"..i.."Item"..k]
			local icon = _G["ContainerFrame"..i.."Item"..k.."IconTexture"]
			local questIcon = _G["ContainerFrame"..i.."Item"..k.."IconQuestTexture"]
			local cooldown = _G["ContainerFrame"..i.."Item"..k.."Cooldown"]

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

	local function BagIcon(container, texture)
		local portraitButton = _G[container:GetName().."PortraitButton"]

		if portraitButton then
			portraitButton:CreateBackdrop()
			portraitButton:Size(36)
			portraitButton:Point("TOPLEFT", 12, -7)

			if not container.BagIcon then
				container.BagIcon = portraitButton:CreateTexture()
				container.BagIcon:SetTexCoord(unpack(E.TexCoords))
				container.BagIcon:SetAllPoints()
			end

			container.BagIcon:SetTexture(texture)
		end
	end

	hooksecurefunc("ContainerFrame_Update", function(frame)
		local id = frame:GetID()
		local _, bagType = GetContainerNumFreeSlots(id)
		local frameName = frame:GetName()
		local title = _G[frameName.."Name"]

		if title and title.GetText then
			local name = title:GetText()
			if bagIconCache[name] then
				BagIcon(frame, bagIconCache[name])
			else
				if name == BACKPACK_TOOLTIP then
					bagIconCache[name] = MainMenuBarBackpackButtonIconTexture:GetTexture()
				else
					bagIconCache[name] = select(10, GetItemInfo(name))
				end

				BagIcon(frame, bagIconCache[name])
			end
		end

		for i = 1, frame.size, 1 do
			local item = _G[frameName.."Item"..i]
			local questIcon = _G[frameName.."Item"..i.."IconQuestTexture"]
			local link = GetContainerItemLink(id, item:GetID())

			questIcon:Hide()

			if ProfessionColors[bagType] then
				item:SetBackdropBorderColor(unpack(ProfessionColors[bagType]))
				item.ignoreBorderColors = true
			elseif link then
				local isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, item:GetID())
				local _, _, quality = GetItemInfo(link)

				if questId and not isActive then
					item:SetBackdropBorderColor(unpack(QuestColors.questStarter))
					item.ignoreBorderColors = true
					questIcon:Show()
				elseif questId or isQuestItem then
					item:SetBackdropBorderColor(unpack(QuestColors.questItem))
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
	BankFrame.backdrop:Point("TOPLEFT", 10, -11)
	BankFrame.backdrop:Point("BOTTOMRIGHT", -26, 93)

	S:HandleCloseButton(BankCloseButton)

	for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
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

	for i = 1, NUM_BANKBAGSLOTS, 1 do
		local button = _G["BankFrameBag"..i]
		local icon = _G["BankFrameBag"..i.."IconTexture"]

		button:SetNormalTexture(nil)
		button:SetTemplate("Default", true)
		button:StyleButton()

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetInside()
		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetTexture(unpack(E.media.rgbvaluecolor), 0.3)
	end

	BankFrame.bagBackdrop = CreateFrame("Frame", "BankFrameBagBackdrop", BankFrame)
	BankFrame.bagBackdrop:SetTemplate("Default")
	BankFrame.bagBackdrop:SetOutside(BankFrameBag1, 6, 6, BankFrameBag7)
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	S:HandleButton(BankFramePurchaseButton)

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		local id = button:GetID()
		local link = button.isBag and GetInventoryItemLink("player", ContainerIDToInventoryID(id)) or GetContainerItemLink(BANK_CONTAINER, id)

		if link then
			local questTexture = _G[button:GetName().."IconQuestTexture"]
			local isQuestItem, questId, isActive = GetContainerItemQuestInfo(BANK_CONTAINER, id)
			local quality = select(3, GetItemInfo(link))

			if questTexture then questTexture:Hide() end

			if button.isBag then
				button:SetBackdropBorderColor(GetItemQualityColor(quality))
				button.ignoreBorderColors = true
			elseif questId and not isActive then
				button:SetBackdropBorderColor(unpack(QuestColors.questStarter))
				button.ignoreBorderColors = true
				if questTexture then questTexture:Show() end
			elseif questId or isQuestItem then
				button:SetBackdropBorderColor(unpack(QuestColors.questItem))
				button.ignoreBorderColors = true
			elseif quality then
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
	end)
end

S:AddCallback("SkinBags", LoadSkin)