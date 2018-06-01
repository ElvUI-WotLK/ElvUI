local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemQuestInfo = GetContainerItemQuestInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc
local BANK_CONTAINER = BANK_CONTAINER
local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

local ProfessionColors = {
	[0x0001] = {225/255, 175/255, 105/255}, -- Quiver
	[0x0002] = {225/255, 175/255, 105/255}, -- Ammo Pouch
	[0x0004] = {225/255, 175/255, 105/255}, -- Soul Bag
	[0x0008] = {224/255, 187/255, 74/255}, -- Leatherworking
	[0x0010] = {74/255, 77/255, 224/255}, -- Inscription
	[0x0020] = {18/255, 181/255, 32/255}, -- Herbs
	[0x0040] = {160/255, 3/255, 168/255}, -- Enchanting
	[0x0080] = {232/255, 118/255, 46/255}, -- Engineering
	[0x0200] = {8/255, 180/255, 207/255}, -- Gems
	[0x0400] = {105/255, 79/255, 7/255}, -- Mining
	[0x010000] = {222/255, 13/255, 65/255} -- Cooking
}

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true or E.private.bags.enable then return end

	-- ContainerFrame
	local containerFrame
	local itemButton, itemButtonIcon, questTexture
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		containerFrame = _G["ContainerFrame"..i]

		containerFrame:StripTextures(true)
		containerFrame:CreateBackdrop("Transparent")
		containerFrame.backdrop:Point("TOPLEFT", 9, -4)
		containerFrame.backdrop:Point("BOTTOMRIGHT", -4, 2)

		S:HandleCloseButton(_G["ContainerFrame"..i.."CloseButton"])

		for k = 1, MAX_CONTAINER_ITEMS, 1 do
			itemButton = _G["ContainerFrame"..i.."Item"..k]
			itemButtonIcon = _G["ContainerFrame"..i.."Item"..k.."IconTexture"]
			questTexture = _G["ContainerFrame"..i.."Item"..k.."IconQuestTexture"]

			itemButton:SetNormalTexture(nil)

			itemButton:StyleButton()
			itemButton:SetTemplate("Default", true)

			itemButtonIcon:SetInside()
			itemButtonIcon:SetTexCoord(unpack(E.TexCoords))

			questTexture:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagQuestIcon.tga")
			questTexture.SetTexture = E.noop
			questTexture:SetTexCoord(0, 1, 0, 1)
			questTexture:SetInside()

			E:RegisterCooldown(_G["ContainerFrame"..i.."Item"..k.."Cooldown"])
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

	hooksecurefunc("ContainerFrame_Update", function(self)
		local id = self:GetID()
		local name = self:GetName()
		local itemButton, questTexture, itemLink
		local quality
		local isQuestItem, questId, isActive
		local _, bagType = GetContainerNumFreeSlots(id)

		for i = 1, self.size, 1 do
			itemButton = _G[name.."Item"..i]
			questTexture = _G[name.."Item"..i.."IconQuestTexture"]
			itemLink = GetContainerItemLink(id, itemButton:GetID())

			questTexture:Hide()

			if ProfessionColors[bagType] then
				itemButton:SetBackdropBorderColor(unpack(ProfessionColors[bagType]))
				itemButton.ignoreBorderColors = true
			elseif itemLink then
				isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, itemButton:GetID())
				_, _, quality = GetItemInfo(itemLink)

				if questId and not isActive then
					itemButton:SetBackdropBorderColor(1.0, 1.0, 0.0)
					itemButton.ignoreBorderColors = true
					questTexture:Show()
				elseif questId or isQuestItem then
					itemButton:SetBackdropBorderColor(1.0, 0.3, 0.3)
					itemButton.ignoreBorderColors = true
				elseif quality and quality > 1 then
					itemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
					itemButton.ignoreBorderColors = true
				else
					itemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
					itemButton.ignoreBorderColors = true
				end
			else
				itemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				itemButton.ignoreBorderColors = true
			end
		end
	end)

	-- BankFrame
	BankFrame:CreateBackdrop("Transparent")
	BankFrame.backdrop:Point("TOPLEFT", 10, -11)
	BankFrame.backdrop:Point("BOTTOMRIGHT", -26, 93)

	BankFrame:StripTextures(true)

	S:HandleCloseButton(BankCloseButton)

	local button, buttonIcon
	for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
		button = _G["BankFrameItem"..i]
		buttonIcon = _G["BankFrameItem"..i.."IconTexture"]
		questTexture = _G["BankFrameItem"..i.."IconQuestTexture"]

		button:SetNormalTexture(nil)

		button:StyleButton()
		button:SetTemplate("Default", true)

		buttonIcon:SetInside()
		buttonIcon:SetTexCoord(unpack(E.TexCoords))
		
		questTexture:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagQuestIcon.tga")
		questTexture.SetTexture = E.noop
		questTexture:SetTexCoord(0, 1, 0, 1)
		questTexture:SetInside()

		E:RegisterCooldown(_G["BankFrameItem"..i.."Cooldown"])
	end

	BankFrame.itemBackdrop = CreateFrame("Frame", "BankFrameItemBackdrop", BankFrame)
	BankFrame.itemBackdrop:SetTemplate("Default")
	BankFrame.itemBackdrop:SetOutside(BankFrameItem1, 6, 6, BankFrameItem28)
	BankFrame.itemBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	for i = 1, NUM_BANKBAGSLOTS, 1 do
		button = _G["BankFrameBag"..i]
		buttonIcon = _G["BankFrameBag"..i.."IconTexture"]

		button:SetNormalTexture(nil)

		button:StyleButton()
		button:SetTemplate("Default", true)

		buttonIcon:SetInside()
		buttonIcon:SetTexCoord(unpack(E.TexCoords))

		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetInside()
		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetTexture(unpack(E["media"].rgbvaluecolor), 0.3)
	end

	BankFrame.bagBackdrop = CreateFrame("Frame", "BankFrameBagBackdrop", BankFrame)
	BankFrame.bagBackdrop:SetTemplate("Default")
	BankFrame.bagBackdrop:SetOutside(BankFrameBag1, 6, 6, BankFrameBag7)
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	S:HandleButton(BankFramePurchaseButton)

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		if button.isBag then return end

		local id = button:GetID()
		local link = GetContainerItemLink(BANK_CONTAINER, id)
		if link then
			local questTexture = _G[button:GetName().."IconQuestTexture"]
			local isQuestItem, questId, isActive = GetContainerItemQuestInfo(BANK_CONTAINER, id)
			local _, _, quality = GetItemInfo(link)

			questTexture:Hide()

			if questId and not isActive then
				button:SetBackdropBorderColor(1.0, 1.0, 0.0)
				button.ignoreBorderColors = true
				questTexture:Show()
			elseif questId or isQuestItem then
				button:SetBackdropBorderColor(1.0, 0.3, 0.3)
				button.ignoreBorderColors = true
			elseif quality and quality > 1 then
				button:SetBackdropBorderColor(GetItemQualityColor(quality))
				button.ignoreBorderColors = true
			else
				button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				button.ignoreBorderColors = true
			end
		else
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			button.ignoreBorderColors = true
		end
	end)
end

S:AddCallback("SkinBags", LoadSkin)