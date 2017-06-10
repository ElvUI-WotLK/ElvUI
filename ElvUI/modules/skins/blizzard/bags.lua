local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G
local unpack = unpack

local GetItemQualityColor = GetItemQualityColor
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemQuestInfo = GetContainerItemQuestInfo
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

function S:ContainerFrame_Update(self)
	local id = self:GetID()
	local name = self:GetName()

	for i = 1, self.size, 1 do
		local itemButton = _G[name.."Item"..i]
		local cooldown = _G[name.."Item"..i.."Cooldown"]
		local questIcon = _G[name.."Item"..i.."IconQuestTexture"]
		local link = GetContainerItemLink(id, itemButton:GetID())

		questIcon:SetAlpha(0)
		questIcon:SetInside()
		questIcon:SetTexCoord(unpack(E.TexCoords))

		E:RegisterCooldown(cooldown)

		if link then
			local _, _, quality = GetItemInfo(link)
			local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(id, itemButton:GetID())
			local r, g, b

			if quality then
				r, g, b = GetItemQualityColor(quality)
			end

			if questId and not isActiveQuest then
				itemButton:SetBackdropBorderColor(1.0, 1.0, 0.0)
				questIcon:SetAlpha(1)
			elseif questId or isQuestItem then
				itemButton:SetBackdropBorderColor(1.0, 0.3, 0.3)
			elseif quality and quality > 1 then
				itemButton:SetBackdropBorderColor(r, g, b)
			else
				itemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			end
		else
			itemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end
	end
end

function S:BankFrameItemButton_Update(button)
	local name = button:GetName()
	local buttonID = button:GetID()
	local link = GetContainerItemLink(BANK_CONTAINER, buttonID)
	local cooldown = _G[name.."Cooldown"]
	local questIcon = _G[name.."IconQuestTexture"]

	if(not button.isBag) then
		questIcon:SetAlpha(0)
		questIcon:SetInside()
		questIcon:SetTexCoord(unpack(E.TexCoords))

		E:RegisterCooldown(cooldown)

		if link then
			local _, _, quality = GetItemInfo(link)
			local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(BANK_CONTAINER, buttonID)
			local r, g, b

			if quality then
				r, g, b = GetItemQualityColor(quality)
			end

			if questId and not isActiveQuest then
				button:SetBackdropBorderColor(1.0, 1.0, 0.0)
				questIcon:SetAlpha(1)
			elseif questId or isQuestItem then
				button:SetBackdropBorderColor(1.0, 0.3, 0.3)
			elseif quality and quality > 1 then
				button:SetBackdropBorderColor(r, g, b)
			else
				button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			end
		else
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end
	end
end

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true or E.private.bags.enable) then return; end

	-- ContainerFrame
	local containerFrame, containerFrameClose;
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		containerFrame = _G["ContainerFrame"..i];
		containerFrameClose = _G["ContainerFrame"..i.."CloseButton"];

		containerFrame:StripTextures(true);
		containerFrame:CreateBackdrop("Transparent");
		containerFrame.backdrop:Point("TOPLEFT", 9, -4);
		containerFrame.backdrop:Point("BOTTOMRIGHT", -4, 2);

		S:HandleCloseButton(containerFrameClose);

		local itemButton, itemButtonIcon;
		for k = 1, MAX_CONTAINER_ITEMS, 1 do
			itemButton = _G["ContainerFrame"..i.."Item"..k];
			itemButtonIcon = _G["ContainerFrame"..i.."Item"..k.."IconTexture"];

			itemButton:SetNormalTexture(nil);

			itemButton:SetTemplate("Default", true);
			itemButton:StyleButton();

			itemButtonIcon:SetInside();
			itemButtonIcon:SetTexCoord(unpack(E.TexCoords));

			_G["ContainerFrame"..i.."Item"..k.."IconQuestTexture"]:SetAlpha(0);
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

	S:SecureHook("ContainerFrame_Update");

	-- BankFrame
	BankFrame:CreateBackdrop("Transparent");
	BankFrame.backdrop:Point("TOPLEFT", 10, -11);
	BankFrame.backdrop:Point("BOTTOMRIGHT", -26, 93);

	BankFrame:StripTextures(true);

	S:HandleCloseButton(BankCloseButton);

	local button, buttonIcon;
	for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
		button = _G["BankFrameItem"..i];
		buttonIcon = _G["BankFrameItem"..i.."IconTexture"];

		button:SetNormalTexture(nil);

		button:SetTemplate("Default", true);
		button:StyleButton();

		buttonIcon:SetInside();
		buttonIcon:SetTexCoord(unpack(E.TexCoords));

		_G["BankFrameItem"..i.."IconQuestTexture"]:SetAlpha(0);
	end

	BankFrame.itemBackdrop = CreateFrame("Frame", "BankFrameItemBackdrop", BankFrame);
	BankFrame.itemBackdrop:SetTemplate("Default");
	BankFrame.itemBackdrop:Point("TOPLEFT", BankFrameItem1, "TOPLEFT", -6, 6);
	BankFrame.itemBackdrop:Point("BOTTOMRIGHT", BankFrameItem28, "BOTTOMRIGHT", 6, -6);
	BankFrame.itemBackdrop:SetFrameLevel(BankFrame:GetFrameLevel());

	for i = 1, NUM_BANKBAGSLOTS, 1 do
		button = _G["BankFrameBag"..i];
		buttonIcon = _G["BankFrameBag"..i.."IconTexture"];

		button:SetNormalTexture(nil);

		button:SetTemplate("Default", true);
		button:StyleButton();

		buttonIcon:SetInside();
		buttonIcon:SetTexCoord(unpack(E.TexCoords));

		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetInside();
		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetTexture(unpack(E["media"].rgbvaluecolor), 0.3);
	end

	BankFrame.bagBackdrop = CreateFrame("Frame", "BankFrameBagBackdrop", BankFrame);
	BankFrame.bagBackdrop:SetTemplate("Default");
	BankFrame.bagBackdrop:Point("TOPLEFT", BankFrameBag1, "TOPLEFT", -6, 6);
	BankFrame.bagBackdrop:Point("BOTTOMRIGHT", BankFrameBag7, "BOTTOMRIGHT", 6, -6);
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel());

	S:HandleButton(BankFramePurchaseButton);

	S:SecureHook("BankFrameItemButton_Update");
end

S:AddCallback("SkinBags", LoadSkin)