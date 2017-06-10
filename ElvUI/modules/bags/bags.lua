local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:NewModule("Bags", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0");
local Search = LibStub("LibItemSearch-1.2");

local _G = _G;
local type, ipairs, pairs, unpack, select, assert = type, ipairs, pairs, unpack, select, assert;
local tinsert = table.insert;
local floor, ceil = math.floor, math.ceil;
local len, sub, find, format, gsub = string.len, string.sub, string.find, string.format, string.gsub;

local CreateFrame = CreateFrame;
local GetContainerNumSlots = GetContainerNumSlots;
local GetContainerItemInfo = GetContainerItemInfo;
local SetItemButtonDesaturated = SetItemButtonDesaturated;
local GetContainerItemInfo = GetContainerItemInfo;
local IsBagOpen, IsOptionFrameOpen = IsBagOpen, IsOptionFrameOpen
local CloseBag, CloseBackpack, CloseBankFrame = CloseBag, CloseBackpack, CloseBankFrame
local ToggleFrame = ToggleFrame;
local GetNumBankSlots = GetNumBankSlots;
local PlaySound = PlaySound;
local GetCurrentGuildBankTab = GetCurrentGuildBankTab;
local GetGuildBankTabInfo = GetGuildBankTabInfo;
local GetGuildBankItemLink = GetGuildBankItemLink;
local GetContainerItemLink = GetContainerItemLink;
local GetItemInfo = GetItemInfo;
local GetContainerItemQuestInfo = GetContainerItemQuestInfo;
local GetItemQualityColor = GetItemQualityColor;
local GetContainerItemCooldown = GetContainerItemCooldown;
local SetItemButtonCount = SetItemButtonCount;
local SetItemButtonTexture = SetItemButtonTexture;
local SetItemButtonTextureVertexColor = SetItemButtonTextureVertexColor;
local CooldownFrame_SetTimer = CooldownFrame_SetTimer;
local BankFrameItemButton_Update = BankFrameItemButton_Update;
local BankFrameItemButton_UpdateLocked = BankFrameItemButton_UpdateLocked;
local UpdateSlot = UpdateSlot;
local GetContainerNumFreeSlots = GetContainerNumFreeSlots;
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo;
local IsModifiedClick = IsModifiedClick;
local GetMoney = GetMoney;
local PickupContainerItem = PickupContainerItem;
local DeleteCursorItem = DeleteCursorItem;
local UseContainerItem = UseContainerItem;
local PickupMerchantItem = PickupMerchantItem;
local IsControlKeyDown = IsControlKeyDown;
local GetKeyRingSize = GetKeyRingSize;
local SEARCH = SEARCH;
local KEYRING_CONTAINER = KEYRING_CONTAINER;
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES;
local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS;
local TEXTURE_ITEM_QUEST_BANG = TEXTURE_ITEM_QUEST_BANG;
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS;
local NUM_BAG_FRAMES = NUM_BAG_FRAMES;
local CONTAINER_SCALE = CONTAINER_SCALE;
local CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y = CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y;
local CONTAINER_WIDTH = CONTAINER_WIDTH;
local CONTAINER_SPACING, VISIBLE_CONTAINER_SPACING = CONTAINER_SPACING, VISIBLE_CONTAINER_SPACING;

local SEARCH_STRING = ""

B.ProfessionColors = {
	[0x0008] = {224/255, 187/255, 74/255}, -- Leatherworking
	[0x0010] = {74/255, 77/255, 224/255}, -- Inscription
	[0x0020] = {18/255, 181/255, 32/255}, -- Herbs
	[0x0040] = {160/255, 3/255, 168/255}, -- Enchanting
	[0x0080] = {232/255, 118/255, 46/255}, -- Engineering
	[0x0200] = {8/255, 180/255, 207/255}, -- Gems
	[0x0400] = {105/255, 79/255, 7/255}, -- Mining
	[0x010000] = {222/255, 13/255, 65/255} -- Cooking
}

function B:GetContainerFrame(arg)
	if type(arg) == "boolean" and arg == true then
		return self.BankFrame;
	elseif type(arg) == "number" then
		if self.BankFrame then
			for _, bagID in ipairs(self.BankFrame.BagIDs) do
				if bagID == arg then
					return self.BankFrame;
				end
			end
		end
	end

	return self.BagFrame;
end

function B:Tooltip_Show()
	GameTooltip:SetOwner(self);
	GameTooltip:ClearLines();
	GameTooltip:AddLine(self.ttText);

	if(self.ttText2) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddDoubleLine(self.ttText2, self.ttText2desc, 1, 1, 1);
	end

	GameTooltip:Show();
end

function B:Tooltip_Hide()
	GameTooltip:Hide();
end

function B:DisableBlizzard()
	BankFrame:UnregisterAllEvents();

	for i=1, NUM_CONTAINER_FRAMES do
		_G["ContainerFrame"..i]:Kill();
	end
end

function B:SearchReset()
	SEARCH_STRING = ""
end

function B:IsSearching()
	if SEARCH_STRING ~= "" and SEARCH_STRING ~= SEARCH then
		return true
	end
	return false
end

function B:UpdateSearch()
	if self.Instructions then self.Instructions:SetShown(self:GetText() == "") end
	local MIN_REPEAT_CHARACTERS = 3;
	local searchString = self:GetText();
	local prevSearchString = SEARCH_STRING;
	if (len(searchString) > MIN_REPEAT_CHARACTERS) then
		local repeatChar = true;
		for i=1, MIN_REPEAT_CHARACTERS, 1 do
			if ( sub(searchString,(0-i), (0-i)) ~= sub(searchString,(-1-i),(-1-i)) ) then
				repeatChar = false;
				break;
			end
		end
		if ( repeatChar ) then
			B.ResetAndClear(self);
			return;
		end
	end

	--Keep active search term when switching between bank and reagent bank
	if searchString == SEARCH and prevSearchString ~= "" then
		searchString = prevSearchString
	elseif searchString == SEARCH then
		searchString = ""
	end

	SEARCH_STRING = searchString

	B:SetSearch(SEARCH_STRING);
	B:SetGuildBankSearch(SEARCH_STRING);
end

function B:OpenEditbox()
	self.BagFrame.detail:Hide();
	self.BagFrame.editBox:Show();
	self.BagFrame.editBox:SetText(SEARCH);
	self.BagFrame.editBox:HighlightText();
end

function B:ResetAndClear()
	local editbox = self:GetParent().editBox or self
	if editbox then editbox:SetText(SEARCH) end

	self:ClearFocus();
	B:SearchReset();
end

function B:SetSearch(query)
	local empty = len(query:gsub(" ", "")) == 0
	for _, bagFrame in pairs(self.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local _, _, _, _, _, _, link = GetContainerItemInfo(bagID, slotID);
				local button = bagFrame.Bags[bagID][slotID];
				local success, result = pcall(Search.Matches, Search, link, query);
				if(empty or (success and result)) then
					SetItemButtonDesaturated(button);
					button:SetAlpha(1);
				else
					SetItemButtonDesaturated(button, 1);
					button:SetAlpha(0.4);
				end
			end
		end
	end

	if(ElvUIKeyFrameItem1) then
		local numKey = GetKeyRingSize();
		for slotID = 1, numKey do
			local _, _, _, _, _, _, link = GetContainerItemInfo(KEYRING_CONTAINER, slotID);
			local button = _G["ElvUIKeyFrameItem"..slotID];
			local success, result = pcall(Search.Matches, Search, link, query);
			if(empty or (success and result)) then
				SetItemButtonDesaturated(button);
				button:SetAlpha(1);
			else
				SetItemButtonDesaturated(button, 1);
				button:SetAlpha(0.4);
			end
		end
	end
end

function B:SetGuildBankSearch(query)
	local empty = len(query:gsub(" ", "")) == 0
	if GuildBankFrame and GuildBankFrame:IsShown() then
		local tab = GetCurrentGuildBankTab()
		local _, _, isViewable = GetGuildBankTabInfo(tab)

		if isViewable then
			for slotID = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
				local link = GetGuildBankItemLink(tab, slotID)
				--A column goes from 1-14, e.g. GuildBankColumn1Button14 (slotID 14) or GuildBankColumn2Button3 (slotID 17)
				local col = ceil(slotID / 14)
				local btn = (slotID % 14)
				if col == 0 then col = 1 end
				if btn == 0 then btn = 14 end
				local button = _G["GuildBankColumn"..col.."Button"..btn]
				local success, result = pcall(Search.Matches, Search, link, query);
				if(empty or (success and result)) then
					SetItemButtonDesaturated(button);
					button:SetAlpha(1);
				else
					SetItemButtonDesaturated(button, 1);
					button:SetAlpha(0.4);
				end
			end
		end
	end
end

function B:UpdateItemLevelDisplay()
	if(E.private.bags.enable ~= true) then return; end
	for _, bagFrame in pairs(self.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local slot = bagFrame.Bags[bagID][slotID];
				if(slot and slot.itemLevel) then
					slot.itemLevel:FontTemplate(E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline);
				end
			end
		end

		if(bagFrame.UpdateAllSlots) then
			bagFrame:UpdateAllSlots();
		end
	end
end

function B:UpdateCountDisplay()
	if(E.private.bags.enable ~= true) then return; end
	local color = E.db.bags.countFontColor;

	for _, bagFrame in pairs(self.BagFrames) do
		for _, bagID in ipairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local slot = bagFrame.Bags[bagID][slotID];
				if(slot and slot.Count) then
					slot.Count:FontTemplate(E.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline);
					slot.Count:SetTextColor(color.r, color.g, color.b);
				end
			end
		end
		if(bagFrame.UpdateAllSlots) then
			bagFrame:UpdateAllSlots();
		end
	end
end

function B:UpdateSlot(bagID, slotID)
	if (self.Bags[bagID] and self.Bags[bagID].numSlots ~= GetContainerNumSlots(bagID)) or not self.Bags[bagID] or not self.Bags[bagID][slotID] then return; end

	local slot, _ = self.Bags[bagID][slotID], nil;
	local bagType = self.Bags[bagID].type;
	local texture, count, locked, _, readable = GetContainerItemInfo(bagID, slotID);
	local clink = GetContainerItemLink(bagID, slotID);

	slot.name, slot.rarity = nil, nil;

	slot:Show();
	slot.questIcon:Hide();
	slot.itemLevel:SetText("")

	if(B.ProfessionColors[bagType]) then
		slot:SetBackdropBorderColor(unpack(B.ProfessionColors[bagType]))
	elseif(clink) then
		local iLvl, itemEquipLoc;
		slot.name, _, slot.rarity, iLvl, _, _, _, _, itemEquipLoc = GetItemInfo(clink);

		local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID);
		local r, g, b;

		if(slot.rarity) then
			r, g, b = GetItemQualityColor(slot.rarity);
		end

		--Item Level
		if(iLvl and B.db.itemLevel and (itemEquipLoc ~= nil and itemEquipLoc ~= "" and itemEquipLoc ~= "INVTYPE_AMMO" and itemEquipLoc ~= "INVTYPE_BAG" and itemEquipLoc ~= "INVTYPE_QUIVER" and itemEquipLoc ~= "INVTYPE_TABARD") and (slot.rarity and slot.rarity > 1)) then
			if(iLvl >= E.db.bags.itemLevelThreshold) then
				slot.itemLevel:SetText(iLvl);
				slot.itemLevel:SetTextColor(r, g, b);
			end
		end

		if questId and not isActiveQuest then
			slot:SetBackdropBorderColor(1.0, 1.0, 0.0);
			slot.questIcon:Show();
		elseif questId or isQuestItem then
			slot:SetBackdropBorderColor(1.0, 0.3, 0.3);
		elseif slot.rarity and slot.rarity > 1 then
			slot:SetBackdropBorderColor(r, g, b);
		else
			slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
		end
	else
		slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
	end

	if(texture) then
		local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
		CooldownFrame_SetTimer(slot.cooldown, start, duration, enable)
		if duration > 0 and enable == 0 then
			SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(slot, 1, 1, 1);
		end
		slot.hasItem = 1
	else
		slot.cooldown:Hide()
		slot.hasItem = nil
	end

	slot.readable = readable

	SetItemButtonTexture(slot, texture);
	SetItemButtonCount(slot, count);
	SetItemButtonDesaturated(slot, locked, 0.5, 0.5, 0.5);

	if GameTooltip:GetOwner() == slot and not slot.hasItem then
		B:Tooltip_Hide()
	end
end

function B:UpdateBagSlots(bagID)
	for slotID = 1, GetContainerNumSlots(bagID) do
		if self.UpdateSlot then
			self:UpdateSlot(bagID, slotID);
		else
			self:GetParent():UpdateSlot(bagID, slotID);
		end
	end
end

function B:UpdateCooldowns()
	for _, bagID in ipairs(self.BagIDs) do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
			CooldownFrame_SetTimer(self.Bags[bagID][slotID].cooldown, start, duration, enable)
			if (duration > 0 and enable == 0) then
				SetItemButtonTextureVertexColor(self.Bags[bagID][slotID], 0.4, 0.4, 0.4);
			else
				SetItemButtonTextureVertexColor(self.Bags[bagID][slotID], 1, 1, 1);
			end
		end
	end
end

function B:UpdateAllSlots()
	for _, bagID in ipairs(self.BagIDs) do
		if self.Bags[bagID] then
			self.Bags[bagID]:UpdateBagSlots(bagID);
		end
	end
end

function B:SetSlotAlphaForBag(f)
	for _, bagID in ipairs(f.BagIDs) do
		if f.Bags[bagID] then
			local numSlots = GetContainerNumSlots(bagID);
			for slotID = 1, numSlots do
				if f.Bags[bagID][slotID] then
					if bagID == self.id then
						f.Bags[bagID][slotID]:SetAlpha(1)
					else
						f.Bags[bagID][slotID]:SetAlpha(0.1)
					end
				end
			end
		end
	end
end

function B:ResetSlotAlphaForBags(f)
	for _, bagID in ipairs(f.BagIDs) do
		if f.Bags[bagID] then
			local numSlots = GetContainerNumSlots(bagID);
			for slotID = 1, numSlots do
				if f.Bags[bagID][slotID] then
					f.Bags[bagID][slotID]:SetAlpha(1)
				end
			end
		end
	end
end

function B:Layout(isBank)
	if E.private.bags.enable ~= true then return; end
	local f = self:GetContainerFrame(isBank);

	if not f then return; end
	local buttonSize = isBank and self.db.bankSize or self.db.bagSize;
	local buttonSpacing = E.PixelMode and 2 or 4;
	local containerWidth = ((isBank and self.db.bankWidth) or self.db.bagWidth);
	local numContainerColumns = floor(containerWidth / (buttonSize + buttonSpacing));
	local holderWidth = ((buttonSize + buttonSpacing) * numContainerColumns) - buttonSpacing;
	local numContainerRows = 0;
	local countColor = E.db.bags.countFontColor;
	f.holderFrame:Width(holderWidth);

	f.totalSlots = 0
	local lastButton;
	local lastRowButton;
	local lastContainerButton;
	local numContainerSlots = GetNumBankSlots();
	for i, bagID in ipairs(f.BagIDs) do
		--Bag Containers
		if (not isBank and bagID <= 3 ) or (isBank and bagID ~= -1 and numContainerSlots >= 1 and not (i - 1 > numContainerSlots)) then
			if not f.ContainerHolder[i] then
				if isBank then
					f.ContainerHolder[i] = CreateFrame("CheckButton", "ElvUIBankBag" .. bagID - 4, f.ContainerHolder, "BankItemButtonBagTemplate")
					f.ContainerHolder[i]:SetScript("OnClick", function(self)
						local inventoryID = self:GetInventorySlot();
						PutItemInBag(inventoryID); --Put bag on empty slot, or drop item in this bag
					end)
				else
					f.ContainerHolder[i] = CreateFrame("CheckButton", "ElvUIMainBag" .. bagID .. "Slot", f.ContainerHolder, "BagSlotButtonTemplate")
					f.ContainerHolder[i]:SetScript("OnClick", function(self)
						local id = self:GetID();
						PutItemInBag(id); --Put bag on empty slot, or drop item in this bag
					end)
				end

				f.ContainerHolder[i]:CreateBackdrop("Default", true)
				f.ContainerHolder[i].backdrop:SetAllPoints();
				f.ContainerHolder[i]:StyleButton()
				f.ContainerHolder[i]:SetNormalTexture("")
				f.ContainerHolder[i]:SetCheckedTexture(nil)
				f.ContainerHolder[i]:SetPushedTexture("")
				f.ContainerHolder[i].id = isBank and bagID or bagID + 1
				f.ContainerHolder[i]:HookScript("OnEnter", function(self) B.SetSlotAlphaForBag(self, f) end)
				f.ContainerHolder[i]:HookScript("OnLeave", function(self) B.ResetSlotAlphaForBags(self, f) end)

				if isBank then
					f.ContainerHolder[i]:SetID(bagID)
					if not f.ContainerHolder[i].tooltipText then
						f.ContainerHolder[i].tooltipText = ""
					end
				end

				f.ContainerHolder[i].iconTexture = _G[f.ContainerHolder[i]:GetName().."IconTexture"];
				f.ContainerHolder[i].iconTexture:SetInside()
				f.ContainerHolder[i].iconTexture:SetTexCoord(unpack(E.TexCoords))
			end

			f.ContainerHolder:Size(((buttonSize + buttonSpacing) * (isBank and i - 1 or i)) + buttonSpacing,buttonSize + (buttonSpacing * 2))

			if isBank then
				BankFrameItemButton_Update(f.ContainerHolder[i])
				BankFrameItemButton_UpdateLocked(f.ContainerHolder[i])
			end

			f.ContainerHolder[i]:Size(buttonSize)
			f.ContainerHolder[i]:ClearAllPoints()
			if (isBank and i == 2) or (not isBank and i == 1) then
				f.ContainerHolder[i]:SetPoint("BOTTOMLEFT", f.ContainerHolder, "BOTTOMLEFT", buttonSpacing, buttonSpacing)
			else
				f.ContainerHolder[i]:SetPoint("LEFT", lastContainerButton, "RIGHT", buttonSpacing, 0)
			end

			lastContainerButton = f.ContainerHolder[i];
		end

		--Bag Slots
		local numSlots = GetContainerNumSlots(bagID);
		if numSlots > 0 then
			if not f.Bags[bagID] then
				f.Bags[bagID] = CreateFrame("Frame", f:GetName().."Bag"..bagID, f);
				f.Bags[bagID]:SetID(bagID);
				f.Bags[bagID].UpdateBagSlots = B.UpdateBagSlots;
				f.Bags[bagID].UpdateSlot = UpdateSlot;
			end

			f.Bags[bagID].numSlots = numSlots;
			f.Bags[bagID].type = select(2, GetContainerNumFreeSlots(bagID));

			--Hide unused slots
			for i = 1, MAX_CONTAINER_ITEMS do
				if f.Bags[bagID][i] then
					f.Bags[bagID][i]:Hide();
				end
			end

			for slotID = 1, numSlots do
				f.totalSlots = f.totalSlots + 1;
				if not f.Bags[bagID][slotID] then
					f.Bags[bagID][slotID] = CreateFrame("CheckButton", f.Bags[bagID]:GetName().."Slot"..slotID, f.Bags[bagID], bagID == -1 and "BankItemButtonGenericTemplate" or "ContainerFrameItemButtonTemplate");
					f.Bags[bagID][slotID]:StyleButton();
					f.Bags[bagID][slotID]:SetTemplate("Default", true);
					f.Bags[bagID][slotID]:SetNormalTexture(nil);
					f.Bags[bagID][slotID]:SetCheckedTexture(nil);

					f.Bags[bagID][slotID].Count = _G[f.Bags[bagID][slotID]:GetName() .. "Count"];
					f.Bags[bagID][slotID].Count:ClearAllPoints();
					f.Bags[bagID][slotID].Count:Point("BOTTOMRIGHT", 0, 2);
					f.Bags[bagID][slotID].Count:FontTemplate(E.LSM:Fetch("font", E.db.bags.countFont), E.db.bags.countFontSize, E.db.bags.countFontOutline);
					f.Bags[bagID][slotID].Count:SetTextColor(countColor.r, countColor.g, countColor.b);

					if not(f.Bags[bagID][slotID].questIcon) then
						f.Bags[bagID][slotID].questIcon = _G[f.Bags[bagID][slotID]:GetName().."IconQuestTexture"] or _G[f.Bags[bagID][slotID]:GetName()].IconQuestTexture
						f.Bags[bagID][slotID].questIcon:SetTexture(TEXTURE_ITEM_QUEST_BANG);
						f.Bags[bagID][slotID].questIcon:SetInside(f.Bags[bagID][slotID]);
						f.Bags[bagID][slotID].questIcon:SetTexCoord(unpack(E.TexCoords));
						f.Bags[bagID][slotID].questIcon:Hide();
					end

					f.Bags[bagID][slotID].iconTexture = _G[f.Bags[bagID][slotID]:GetName().."IconTexture"];
					f.Bags[bagID][slotID].iconTexture:SetInside(f.Bags[bagID][slotID]);
					f.Bags[bagID][slotID].iconTexture:SetTexCoord(unpack(E.TexCoords));

					f.Bags[bagID][slotID].cooldown = _G[f.Bags[bagID][slotID]:GetName().."Cooldown"];
					E:RegisterCooldown(f.Bags[bagID][slotID].cooldown)
					f.Bags[bagID][slotID].bagID = bagID
					f.Bags[bagID][slotID].slotID = slotID

					f.Bags[bagID][slotID].itemLevel = f.Bags[bagID][slotID]:CreateFontString(nil, "OVERLAY");
					f.Bags[bagID][slotID].itemLevel:SetPoint("BOTTOMRIGHT", 0, 2);
					f.Bags[bagID][slotID].itemLevel:FontTemplate(E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline);
				end

				f.Bags[bagID][slotID]:SetID(slotID);
				f.Bags[bagID][slotID]:Size(buttonSize);

				f:UpdateSlot(bagID, slotID);

				if f.Bags[bagID][slotID]:GetPoint() then
					f.Bags[bagID][slotID]:ClearAllPoints();
				end

				if lastButton then
					if (f.totalSlots - 1) % numContainerColumns == 0 then
						f.Bags[bagID][slotID]:Point("TOP", lastRowButton, "BOTTOM", 0, -buttonSpacing);
						lastRowButton = f.Bags[bagID][slotID];
						numContainerRows = numContainerRows + 1;
					else
						f.Bags[bagID][slotID]:Point("LEFT", lastButton, "RIGHT", buttonSpacing, 0);
					end
				else
					f.Bags[bagID][slotID]:Point("TOPLEFT", f.holderFrame, "TOPLEFT");
					lastRowButton = f.Bags[bagID][slotID];
					numContainerRows = numContainerRows + 1;
				end

				lastButton = f.Bags[bagID][slotID];
			end
		else
			for i = 1, MAX_CONTAINER_ITEMS do
				if f.Bags[bagID] and f.Bags[bagID][i] then
					f.Bags[bagID][i]:Hide();
				end
			end

			if f.Bags[bagID] then
				f.Bags[bagID].numSlots = numSlots;
			end

			if self.isBank then
				if self.ContainerHolder[i] then
					BankFrameItemButton_Update(self.ContainerHolder[i])
					BankFrameItemButton_UpdateLocked(self.ContainerHolder[i])
				end
			end
		end
	end

	local numKey = GetKeyRingSize();
	local numKeyColumns = 6;
	if(not isBank) then
		local totalSlots = 0
		local lastRowButton
		local numKeyRows = 1
		for i = 1, numKey do
			totalSlots = totalSlots + 1;

			if(not f.keyFrame.slots[i]) then
				f.keyFrame.slots[i] = CreateFrame("CheckButton", "ElvUIKeyFrameItem"..i, f.keyFrame, "ContainerFrameItemButtonTemplate");
				f.keyFrame.slots[i]:StyleButton(nil, nil, true);
				f.keyFrame.slots[i]:SetTemplate("Default", true);
				f.keyFrame.slots[i]:SetNormalTexture(nil);
				f.keyFrame.slots[i]:SetID(i);

				f.keyFrame.slots[i].cooldown = _G[f.keyFrame.slots[i]:GetName().."Cooldown"];
				E:RegisterCooldown(f.keyFrame.slots[i].cooldown)

				if not(f.keyFrame.slots[i].questIcon) then
					f.keyFrame.slots[i].questIcon = _G[f.keyFrame.slots[i]:GetName().."IconQuestTexture"] or _G[f.keyFrame.slots[i]:GetName()].IconQuestTexture
					f.keyFrame.slots[i].questIcon:SetTexture(TEXTURE_ITEM_QUEST_BANG);
					f.keyFrame.slots[i].questIcon:SetInside(f.keyFrame.slots[i]);
					f.keyFrame.slots[i].questIcon:SetTexCoord(unpack(E.TexCoords));
					f.keyFrame.slots[i].questIcon:Hide();
				end

				f.keyFrame.slots[i].iconTexture = _G[f.keyFrame.slots[i]:GetName().."IconTexture"];
				f.keyFrame.slots[i].iconTexture:SetInside(f.keyFrame.slots[i]);
				f.keyFrame.slots[i].iconTexture:SetTexCoord(unpack(E.TexCoords));
			end

			f.keyFrame.slots[i]:ClearAllPoints()
			f.keyFrame.slots[i]:Size(buttonSize)
			if(f.keyFrame.slots[i-1]) then
				if(totalSlots - 1) % numKeyColumns == 0 then
					f.keyFrame.slots[i]:Point("TOP", lastRowButton, "BOTTOM", 0, -buttonSpacing);
					lastRowButton = f.keyFrame.slots[i];
					numKeyRows = numKeyRows + 1;
				else
					f.keyFrame.slots[i]:Point("RIGHT", f.keyFrame.slots[i-1], "LEFT", -buttonSpacing, 0);
				end
			else
				f.keyFrame.slots[i]:Point("TOPRIGHT", f.keyFrame, "TOPRIGHT", -buttonSpacing, -buttonSpacing);
				lastRowButton = f.keyFrame.slots[i]
			end

			self:UpdateKeySlot(i)
		end

		if(numKey < numKeyColumns) then
			numKeyColumns = numKey;
		end
		f.keyFrame:Size(((buttonSize + buttonSpacing) * numKeyColumns) + buttonSpacing, ((buttonSize + buttonSpacing) * numKeyRows) + buttonSpacing);
	end

	f:Size(containerWidth, (((buttonSize + buttonSpacing) * numContainerRows) - buttonSpacing) + f.topOffset + f.bottomOffset); -- 8 is the cussion of the f.holderFrame
end

function B:UpdateKeySlot(slotID)
	assert(slotID)
	local bagID = KEYRING_CONTAINER
	local texture, count, locked = GetContainerItemInfo(bagID, slotID);
	local clink = GetContainerItemLink(bagID, slotID);
	local slot = _G["ElvUIKeyFrameItem"..slotID]
	if not slot then return; end

	slot.name, slot.rarity = nil, nil;

	slot:Show();
	slot.questIcon:Hide();

	if(clink) then
		local _;
		slot.name, _, slot.rarity = GetItemInfo(clink);

		local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID);
		local r, g, b;

		if(slot.rarity) then
			r, g, b = GetItemQualityColor(slot.rarity);
		end

		if questId and not isActiveQuest then
			slot:SetBackdropBorderColor(1.0, 1.0, 0.0);
			slot.questIcon:Show();
		elseif questId or isQuestItem then
			slot:SetBackdropBorderColor(1.0, 0.3, 0.3);
		elseif slot.rarity and slot.rarity > 1 then
			slot:SetBackdropBorderColor(r, g, b);
		else
			slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
		end
	else
		slot:SetBackdropBorderColor(unpack(E.media.bordercolor));
	end

	if(texture) then
		local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
		CooldownFrame_SetTimer(slot.cooldown, start, duration, enable)
		if(duration > 0 and enable == 0) then
			SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(slot, 1, 1, 1);
		end
	else
		slot.cooldown:Hide()
	end

	SetItemButtonTexture(slot, texture);
	SetItemButtonCount(slot, count);
	SetItemButtonDesaturated(slot, locked, 0.5, 0.5, 0.5);
end

function B:UpdateAll()
	if self.BagFrame then
		self:Layout();
	end

	if self.BankFrame then
		self:Layout(true);
	end
end

function B:OnEvent(event, ...)
	if event == "ITEM_LOCK_CHANGED" or event == "ITEM_UNLOCKED" then
		local bag, slot = ...
		if bag == KEYRING_CONTAINER then
			B:UpdateKeySlot(slot);
		else
			self:UpdateSlot(...);
		end
	elseif event == "BAG_UPDATE" then
		local bag = ...
		if(bag == KEYRING_CONTAINER) then
			for slotID = 1, GetKeyRingSize() do
				B:UpdateKeySlot(slotID);
			end
		end

		for _, bagID in ipairs(self.BagIDs) do
			local numSlots = GetContainerNumSlots(bagID)
			if (not self.Bags[bagID] and numSlots ~= 0) or (self.Bags[bagID] and numSlots ~= self.Bags[bagID].numSlots) then
				B:Layout(self.isBank);
				return;
			end
		end

		self:UpdateBagSlots(...);
		if(B:IsSearching()) then
			B:SetSearch(SEARCH_STRING);
		end
	elseif event == "BAG_UPDATE_COOLDOWN" then
		if not self:IsShown() then return; end
		self:UpdateCooldowns();
	elseif event == "PLAYERBANKSLOTS_CHANGED" then
		self:UpdateAllSlots()
	elseif (event == "QUEST_ACCEPTED" or event == "QUEST_LOG_UPDATE") and self:IsShown() then
		self:UpdateAllSlots()
		for slotID = 1, GetKeyRingSize() do
			B:UpdateKeySlot(slotID);
		end
	end
end

function B:UpdateTokens()
	local f = self.BagFrame;

	local numTokens = 0
	for i = 1, MAX_WATCHED_TOKENS do
		local name, count, type, icon, itemID = GetBackpackCurrencyInfo(i)
		local button = f.currencyButton[i];

		if(type == 1) then
			icon = "Interface\\PVPFrame\\PVP-ArenaPoints-Icon";
		elseif(type == 2) then
			icon = "Interface\\PVPFrame\\PVP-Currency-"..UnitFactionGroup("player");
		end

		button:ClearAllPoints();
		if name then
			button.icon:SetTexture(icon);

			if self.db.currencyFormat == "ICON_TEXT" then
				button.text:SetText(name..": "..count);
			elseif self.db.currencyFormat == "ICON_TEXT_ABBR" then
				button.text:SetText(E:AbbreviateString(name)..": "..count);
			elseif self.db.currencyFormat == "ICON" then
				button.text:SetText(count);
			end

			button.itemID = itemID;
			button:Show();
			numTokens = numTokens + 1;
		else
			button:Hide();
		end
	end

	if numTokens == 0 then
		f.bottomOffset = 8;

		if f.currencyButton:IsShown() then
			f.currencyButton:Hide();
			self:Layout();
		end

		return;
	elseif not f.currencyButton:IsShown() then
		f.bottomOffset = 28;
		f.currencyButton:Show();
		self:Layout();
	end

	f.bottomOffset = 28;
	if numTokens == 1 then
		f.currencyButton[1]:Point("BOTTOM", f.currencyButton, "BOTTOM", -(f.currencyButton[1].text:GetWidth() / 2), 3);
	elseif numTokens == 2 then
		f.currencyButton[1]:Point("BOTTOM", f.currencyButton, "BOTTOM", -(f.currencyButton[1].text:GetWidth()) - (f.currencyButton[1]:GetWidth() / 2), 3);
		f.currencyButton[2]:Point("BOTTOMLEFT", f.currencyButton, "BOTTOM", f.currencyButton[2]:GetWidth() / 2, 3);
	else
		f.currencyButton[1]:Point("BOTTOMLEFT", f.currencyButton, "BOTTOMLEFT", 3, 3);
		f.currencyButton[2]:Point("BOTTOM", f.currencyButton, "BOTTOM", -(f.currencyButton[2].text:GetWidth() / 3), 3);
		f.currencyButton[3]:Point("BOTTOMRIGHT", f.currencyButton, "BOTTOMRIGHT", -(f.currencyButton[3].text:GetWidth()) - (f.currencyButton[3]:GetWidth() / 2), 3);
	end
end

function B:Token_OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetBackpackToken(self:GetID());
end

function B:Token_OnClick()
	if(IsModifiedClick("CHATLINK")) then
		ChatEdit_InsertLink(select(2, GetItemInfo(self.itemID)));
	end
end

function B:UpdateGoldText()
	self.BagFrame.goldText:SetText(E:FormatMoney(GetMoney(), E.db["bags"].moneyFormat, not E.db["bags"].moneyCoins));
end

function B:GetGraysValue()
	local c = 0;

	for b = 0, 4 do
		for s = 1, GetContainerNumSlots(b) do
			local l = GetContainerItemLink(b, s);
			if(l and select(11, GetItemInfo(l))) then
				local p = select(11, GetItemInfo(l)) * select(2, GetContainerItemInfo(b, s));
				if(select(3, GetItemInfo(l)) == 0 and p > 0) then
					c = c + p;
				end
			end
		end
	end

	return c;
end

function B:VendorGrays(delete, _, getValue)
	if (not MerchantFrame or not MerchantFrame:IsShown()) and not delete and not getValue then
		E:Print(L["You must be at a vendor."])
		return
	end

	local c = 0
	local count = 0
	for b=0,4 do
		for s=1,GetContainerNumSlots(b) do
			local l = GetContainerItemLink(b, s)
			if l and select(11, GetItemInfo(l)) then
				local p = select(11, GetItemInfo(l))*select(2, GetContainerItemInfo(b, s))

				if delete then
					if find(l,"ff9d9d9d") then
						if not getValue then
							PickupContainerItem(b, s)
							DeleteCursorItem()
						end
						c = c+p
						count = count + 1
					end
				else
					if select(3, GetItemInfo(l))==0 and p>0 then
						if not getValue then
							UseContainerItem(b, s)
							PickupMerchantItem()
						end
						c = c+p
					end
				end
			end
		end
	end

	if getValue then
		return c
	end

	if c>0 and not delete then
		local g, s, c = floor(c/10000) or 0, floor((c%10000)/100) or 0, c%100
		E:Print(L["Vendored gray items for:"].." |cffffffff"..g..L.goldabbrev.." |cffffffff"..s..L.silverabbrev.." |cffffffff"..c..L.copperabbrev..".")
	end
end

function B:VendorGrayCheck()
	local value = B:GetGraysValue();

	if(value == 0) then
		E:Print(L["No gray items to delete."]);
	elseif(not MerchantFrame or not MerchantFrame:IsShown()) then
		E.PopupDialogs["DELETE_GRAYS"].Money = value;
		E:StaticPopup_Show("DELETE_GRAYS");
	else
		B:VendorGrays();
	end
end

function B:ContructContainerFrame(name, isBank)
	local f = CreateFrame("Button", name, E.UIParent);
	f:SetTemplate("Transparent");
	f:SetFrameStrata("DIALOG");
	f.UpdateSlot = B.UpdateSlot;
	f.UpdateAllSlots = B.UpdateAllSlots;
	f.UpdateBagSlots = B.UpdateBagSlots;
	f.UpdateCooldowns = B.UpdateCooldowns;
	f:RegisterEvent("ITEM_LOCK_CHANGED");
	f:RegisterEvent("ITEM_UNLOCKED");
	f:RegisterEvent("BAG_UPDATE_COOLDOWN")
	f:RegisterEvent("BAG_UPDATE");
	f:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	f:RegisterEvent("QUEST_ACCEPTED");
	f:RegisterEvent("QUEST_LOG_UPDATE");

	f:SetScript("OnEvent", B.OnEvent);
	f:Hide();

	f.isBank = isBank;

	f.bottomOffset = isBank and 8 or 28;
	f.topOffset = isBank and 45 or 50;
	f.BagIDs = isBank and {-1, 5, 6, 7, 8, 9, 10, 11} or {0, 1, 2, 3, 4};
	f.Bags = {};

	local mover = (isBank and ElvUIBankMover or ElvUIBagMover);
	if(mover) then
		f:Point(mover.POINT, mover);
		f.mover = mover;
	end

	f:SetMovable(true)
	f:RegisterForDrag("LeftButton", "RightButton");
	f:RegisterForClicks("AnyUp");
	f:SetScript("OnDragStart", function(self) if(IsShiftKeyDown()) then self:StartMoving(); end end);
	f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); end)
	f:SetScript("OnClick", function(self) if(IsControlKeyDown()) then B.PostBagMove(self.mover); end end);
	f:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4);
		GameTooltip:ClearLines();
		GameTooltip:AddDoubleLine(L["Hold Shift + Drag:"], L["Temporary Move"], 1, 1, 1);
		GameTooltip:AddDoubleLine(L["Hold Control + Right Click:"], L["Reset Position"], 1, 1, 1);

		GameTooltip:Show();
	end);
	f:SetScript("OnLeave", function() GameTooltip:Hide(); end);

	f.closeButton = CreateFrame("Button", name.."CloseButton", f, "UIPanelCloseButton");
	f.closeButton:Point("TOPRIGHT", -4, -4);

	E:GetModule("Skins"):HandleCloseButton(f.closeButton);

	f.holderFrame = CreateFrame("Frame", nil, f);
	f.holderFrame:Point("TOP", f, "TOP", 0, -f.topOffset);
	f.holderFrame:Point("BOTTOM", f, "BOTTOM", 0, 8);

	f.ContainerHolder = CreateFrame("Button", name.."ContainerHolder", f)
	f.ContainerHolder:Point("BOTTOMLEFT", f, "TOPLEFT", 0, 1)
	f.ContainerHolder:SetTemplate("Transparent")
	f.ContainerHolder:Hide()

	if(isBank) then
		f.bagText = f:CreateFontString(nil, "OVERLAY");
		f.bagText:FontTemplate();
		f.bagText:Point("BOTTOMRIGHT", f.holderFrame, "TOPRIGHT", -2, 4);
		f.bagText:SetJustifyH("RIGHT");
		f.bagText:SetText(L["Bank"]);

		f.sortButton = CreateFrame("Button", name.."SortButton", f);
		f.sortButton:SetSize(16 + E.Border, 16 + E.Border);
		f.sortButton:SetTemplate();
		f.sortButton:SetPoint("RIGHT", f.bagText, "LEFT", -5, E.Border * 2);
		f.sortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_RatCage");
		f.sortButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		f.sortButton:GetNormalTexture():SetInside();
		f.sortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_RatCage");
		f.sortButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords));
		f.sortButton:GetPushedTexture():SetInside();
		f.sortButton:SetDisabledTexture("Interface\\ICONS\\INV_Pet_RatCage");
		f.sortButton:GetDisabledTexture():SetTexCoord(unpack(E.TexCoords));
		f.sortButton:GetDisabledTexture():SetInside();
		f.sortButton:GetDisabledTexture():SetDesaturated(true);
		f.sortButton:StyleButton(nil, true);
		f.sortButton.ttText = L["Sort Bags"];
		f.sortButton:SetScript("OnEnter", self.Tooltip_Show);
		f.sortButton:SetScript("OnLeave", self.Tooltip_Hide);
		f.sortButton:SetScript("OnClick", function() B:CommandDecorator(B.SortBags, "bank")(); end);
		if(E.db.bags.disableBankSort) then
			f.sortButton:Disable();
		end

		f.bagsButton = CreateFrame("Button", name.."BagsButton", f.holderFrame);
		f.bagsButton:SetSize(16 + E.Border, 16 + E.Border);
		f.bagsButton:SetTemplate();
		f.bagsButton:SetPoint("RIGHT", f.sortButton, "LEFT", -5, 0);
		f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up");
		f.bagsButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		f.bagsButton:GetNormalTexture():SetInside();
		f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up");
		f.bagsButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords));
		f.bagsButton:GetPushedTexture():SetInside();
		f.bagsButton:StyleButton(nil, true);
		f.bagsButton.ttText = L["Toggle Bags"];
		f.bagsButton:SetScript("OnEnter", self.Tooltip_Show);
		f.bagsButton:SetScript("OnLeave", self.Tooltip_Hide);
		f.bagsButton:SetScript("OnClick", function()
			local numSlots = GetNumBankSlots();
			PlaySound("igMainMenuOption");
			if(numSlots >= 1) then
				ToggleFrame(f.ContainerHolder)
			else
				E:StaticPopup_Show("NO_BANK_BAGS");
			end
		end);

		f.purchaseBagButton = CreateFrame("Button", nil, f.holderFrame);
		f.purchaseBagButton:SetSize(16 + E.Border, 16 + E.Border);
		f.purchaseBagButton:SetTemplate();
		f.purchaseBagButton:SetPoint("RIGHT", f.bagsButton, "LEFT", -5, 0);
		f.purchaseBagButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Coin_01");
		f.purchaseBagButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		f.purchaseBagButton:GetNormalTexture():SetInside();
		f.purchaseBagButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Coin_01");
		f.purchaseBagButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords));
		f.purchaseBagButton:GetPushedTexture():SetInside();
		f.purchaseBagButton:StyleButton(nil, true);
		f.purchaseBagButton.ttText = L["Purchase Bags"];
		f.purchaseBagButton:SetScript("OnEnter", self.Tooltip_Show);
		f.purchaseBagButton:SetScript("OnLeave", self.Tooltip_Hide);
		f.purchaseBagButton:SetScript("OnClick", function()
			local _, full = GetNumBankSlots();
			if(full) then
				E:StaticPopup_Show("CANNOT_BUY_BANK_SLOT");
			else
				E:StaticPopup_Show("BUY_BANK_SLOT");
			end
		end);

		f:SetScript("OnHide", function()
			CloseBankFrame()

			if E.db.bags.clearSearchOnClose then
				B.ResetAndClear(f.editBox);
			end
		end)

		f.editBox = CreateFrame("EditBox", name.."EditBox", f);
		f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2);
		f.editBox:CreateBackdrop("Default");
		f.editBox.backdrop:SetPoint("TOPLEFT", f.editBox, "TOPLEFT", -20, 2);
		f.editBox:Height(15);
		f.editBox:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", (E.Border * 2) + 18, E.Border * 2 + 2);
		f.editBox:Point("RIGHT", f.purchaseBagButton, "LEFT", -5, 0);
		f.editBox:SetAutoFocus(false);
		f.editBox:SetScript("OnEscapePressed", self.ResetAndClear);
		f.editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus(); end);
		f.editBox:SetScript("OnEditFocusGained", f.editBox.HighlightText);
		f.editBox:SetScript("OnTextChanged", self.UpdateSearch);
		f.editBox:SetScript("OnChar", self.UpdateSearch);
		f.editBox:SetText(SEARCH);
		f.editBox:FontTemplate();

		f.editBox.searchIcon = f.editBox:CreateTexture(nil, "OVERLAY");
		f.editBox.searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon");
		f.editBox.searchIcon:SetPoint("LEFT", f.editBox.backdrop, "LEFT", E.Border + 1, -1);
		f.editBox.searchIcon:SetSize(15, 15);
	else
		f.keyFrame = CreateFrame("Frame", name.."KeyFrame", f)
		f.keyFrame:SetPoint("TOPRIGHT", f, "TOPLEFT", -(E.PixelMode and 1 or 3), 0);
		f.keyFrame:SetTemplate("Transparent");
		f.keyFrame:SetID(KEYRING_CONTAINER);
		f.keyFrame.slots = {};
		f.keyFrame:Hide();

		f.goldText = f:CreateFontString(nil, "OVERLAY");
		f.goldText:FontTemplate();
		f.goldText:Point("BOTTOMRIGHT", f.holderFrame, "TOPRIGHT", -2, 4);
		f.goldText:SetJustifyH("RIGHT");

		f.sortButton = CreateFrame("Button", name.."SortButton", f);
		f.sortButton:SetSize(16 + E.Border, 16 + E.Border);
		f.sortButton:SetTemplate();
		f.sortButton:SetPoint("RIGHT", f.goldText, "LEFT", -5, E.Border * 2);
		f.sortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_RatCage");
		f.sortButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		f.sortButton:GetNormalTexture():SetInside();
		f.sortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_RatCage");
		f.sortButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords));
		f.sortButton:GetPushedTexture():SetInside();
		f.sortButton:SetDisabledTexture("Interface\\ICONS\\INV_Pet_RatCage");
		f.sortButton:GetDisabledTexture():SetTexCoord(unpack(E.TexCoords));
		f.sortButton:GetDisabledTexture():SetInside();
		f.sortButton:GetDisabledTexture():SetDesaturated(true);
		f.sortButton:StyleButton(nil, true);
		f.sortButton.ttText = L["Sort Bags"];
		f.sortButton:SetScript("OnEnter", self.Tooltip_Show);
		f.sortButton:SetScript("OnLeave", self.Tooltip_Hide);
		f.sortButton:SetScript("OnClick", function() B:CommandDecorator(B.SortBags, "bags")(); end);
		if(E.db.bags.disableBagSort) then
			f.sortButton:Disable();
		end

		f.keyButton = CreateFrame("Button", name.."KeyButton", f);
		f.keyButton:SetSize(16 + E.Border, 16 + E.Border);
		f.keyButton:SetTemplate();
		f.keyButton:SetPoint("RIGHT", f.sortButton, "LEFT", -5, 0);
		f.keyButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Key_14");
		f.keyButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		f.keyButton:GetNormalTexture():SetInside();
		f.keyButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Key_14");
		f.keyButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords));
		f.keyButton:GetPushedTexture():SetInside();
		f.keyButton:StyleButton(nil, true);
		f.keyButton.ttText = L["Toggle Key"];
		f.keyButton:SetScript("OnEnter", self.Tooltip_Show);
		f.keyButton:SetScript("OnLeave", self.Tooltip_Hide);
		f.keyButton:SetScript("OnClick", function() ToggleFrame(f.keyFrame); end);

		f.bagsButton = CreateFrame("Button", name.."BagsButton", f);
		f.bagsButton:SetSize(16 + E.Border, 16 + E.Border);
		f.bagsButton:SetTemplate();
		f.bagsButton:SetPoint("RIGHT", f.keyButton, "LEFT", -5, 0);
		f.bagsButton:SetNormalTexture("Interface\\Buttons\\Button-Backpack-Up");
		f.bagsButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		f.bagsButton:GetNormalTexture():SetInside();
		f.bagsButton:SetPushedTexture("Interface\\Buttons\\Button-Backpack-Up");
		f.bagsButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords));
		f.bagsButton:GetPushedTexture():SetInside();
		f.bagsButton:StyleButton(nil, true);
		f.bagsButton.ttText = L["Toggle Bags"];
		f.bagsButton:SetScript("OnEnter", self.Tooltip_Show);
		f.bagsButton:SetScript("OnLeave", self.Tooltip_Hide);
		f.bagsButton:SetScript("OnClick", function() ToggleFrame(f.ContainerHolder); end);

		f.vendorGraysButton = CreateFrame("Button", nil, f.holderFrame);
		f.vendorGraysButton:SetSize(16 + E.Border, 16 + E.Border);
		f.vendorGraysButton:SetTemplate();
		f.vendorGraysButton:SetPoint("RIGHT", f.bagsButton, "LEFT", -5, 0);
		f.vendorGraysButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Coin_01");
		f.vendorGraysButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		f.vendorGraysButton:GetNormalTexture():SetInside();
		f.vendorGraysButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Coin_01");
		f.vendorGraysButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords));
		f.vendorGraysButton:GetPushedTexture():SetInside();
		f.vendorGraysButton:StyleButton(nil, true);
		f.vendorGraysButton.ttText = L["Vendor Grays"];
		f.vendorGraysButton:SetScript("OnEnter", self.Tooltip_Show);
		f.vendorGraysButton:SetScript("OnLeave", self.Tooltip_Hide);
		f.vendorGraysButton:SetScript("OnClick", B.VendorGrayCheck);

		f.editBox = CreateFrame("EditBox", name.."EditBox", f);
		f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2);
		f.editBox:CreateBackdrop("Default");
		f.editBox.backdrop:SetPoint("TOPLEFT", f.editBox, "TOPLEFT", -20, 2);
		f.editBox:Height(15);
		f.editBox:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", (E.Border * 2) + 18, E.Border * 2 + 2);
		f.editBox:Point("RIGHT", f.vendorGraysButton, "LEFT", -5, 0);
		f.editBox:SetAutoFocus(false);
		f.editBox:SetScript("OnEscapePressed", self.ResetAndClear);
		f.editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus(); end);
		f.editBox:SetScript("OnEditFocusGained", f.editBox.HighlightText);
		f.editBox:SetScript("OnTextChanged", self.UpdateSearch);
		f.editBox:SetScript("OnChar", self.UpdateSearch);
		f.editBox:SetText(SEARCH);
		f.editBox:FontTemplate();

		f.editBox.searchIcon = f.editBox:CreateTexture(nil, "OVERLAY");
		f.editBox.searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon");
		f.editBox.searchIcon:SetPoint("LEFT", f.editBox.backdrop, "LEFT", E.Border + 1, -1);
		f.editBox.searchIcon:SetSize(15, 15);

		--Currency
		f.currencyButton = CreateFrame("Frame", nil, f);
		f.currencyButton:Point("BOTTOM", 0, 4);
		f.currencyButton:Point("TOPLEFT", f.holderFrame, "BOTTOMLEFT", 0, 18);
		f.currencyButton:Point("TOPRIGHT", f.holderFrame, "BOTTOMRIGHT", 0, 18);
		f.currencyButton:Height(22);
		for i = 1, MAX_WATCHED_TOKENS do
			f.currencyButton[i] = CreateFrame("Button", nil, f.currencyButton);
			f.currencyButton[i]:Size(16);
			f.currencyButton[i]:SetTemplate("Default");
			f.currencyButton[i]:SetID(i);
			f.currencyButton[i].icon = f.currencyButton[i]:CreateTexture(nil, "OVERLAY");
			f.currencyButton[i].icon:SetInside();
			f.currencyButton[i].icon:SetTexCoord(unpack(E.TexCoords));
			f.currencyButton[i].text = f.currencyButton[i]:CreateFontString(nil, "OVERLAY");
			f.currencyButton[i].text:Point("LEFT", f.currencyButton[i], "RIGHT", 2, 0);
			f.currencyButton[i].text:FontTemplate();

			f.currencyButton[i]:SetScript("OnEnter", B.Token_OnEnter);
			f.currencyButton[i]:SetScript("OnLeave", function() GameTooltip:Hide() end);
			f.currencyButton[i]:SetScript("OnClick", B.Token_OnClick);
			f.currencyButton[i]:Hide();
		end

		f:SetScript("OnHide", function()
			CloseBackpack()
			for i = 1, NUM_BAG_FRAMES do
				CloseBag(i);
			end

			if(ElvUIBags and ElvUIBags.buttons) then
				for _, bagButton in pairs(ElvUIBags.buttons) do
					bagButton:SetChecked(false);
				end
			end
			if(E.db.bags.clearSearchOnClose) then
				B.ResetAndClear(f.editBox);
			end
		end)
	end

	f:SetScript("OnShow", function(self)
		self:UpdateCooldowns();
	end);

	tinsert(UISpecialFrames, f:GetName()) --Keep an eye on this for taints..
	tinsert(self.BagFrames, f)
	return f
end

function B:ToggleBags(id)
	if id and GetContainerNumSlots(id) == 0 then return; end --Closes a bag when inserting a new container..

	if self.BagFrame:IsShown() then
	--	self:CloseBags();
	else
		self:OpenBags();
	end
end

function B:ToggleBackpack()
	if(IsOptionFrameOpen()) then
		return;
	end

	if(IsBagOpen(0)) then
		self:OpenBags()
	else
		self:CloseBags()
	end
end

function B:ToggleSortButtonState(isBank)
	local button, disable;
	if isBank and self.BankFrame then
		button = self.BankFrame.sortButton
		disable = E.db.bags.disableBankSort
	elseif not isBank and self.BagFrame then
		button = self.BagFrame.sortButton
		disable = E.db.bags.disableBagSort
	end

	if button and disable then
		button:Disable()
	elseif button and not disable then
		button:Enable()
	end
end

function B:OpenBags()
	self.BagFrame:Show();
	self.BagFrame:UpdateAllSlots();
	E:GetModule("Tooltip"):GameTooltip_SetDefaultAnchor(GameTooltip)
end

function B:CloseBags()
	self.BagFrame:Hide();

	if self.BankFrame then
		self.BankFrame:Hide();
	end

	E:GetModule("Tooltip"):GameTooltip_SetDefaultAnchor(GameTooltip)
end

function B:OpenBank()
	if not self.BankFrame then
		self.BankFrame = self:ContructContainerFrame("ElvUI_BankContainerFrame", true);
	end

	self:Layout(true)
	self.BankFrame:Show();
	self.BankFrame:UpdateAllSlots();
	self:OpenBags()
	self:UpdateTokens()
end

function B:PLAYERBANKBAGSLOTS_CHANGED()
	self:Layout(true)
end

function B:GUILDBANKBAGSLOTS_CHANGED()
	self:SetGuildBankSearch(SEARCH_STRING);
end

function B:CloseBank()
	if not self.BankFrame then return; end -- WHY???, WHO KNOWS!
	self.BankFrame:Hide()
end

function B:PostBagMove()
	if(not E.private.bags.enable) then return; end

	local x, y = self:GetCenter();
	local screenHeight = E.UIParent:GetTop();
	local screenWidth = E.UIParent:GetRight();

	if(y > (screenHeight / 2)) then
		self:SetText(self.textGrowDown);
		self.POINT = ((x > (screenWidth/2)) and "TOPRIGHT" or "TOPLEFT");
	else
		self:SetText(self.textGrowUp);
		self.POINT = ((x > (screenWidth/2)) and "BOTTOMRIGHT" or "BOTTOMLEFT");
	end

	local bagFrame;
	if(self.name == "ElvUIBankMover") then
		bagFrame = B.BankFrame;
	else
		bagFrame = B.BagFrame;
	end

	if(bagFrame) then
		bagFrame:ClearAllPoints();
		bagFrame:Point(self.POINT, self);
	end
end

function B:Initialize()
	self:LoadBagBar();

	local BagFrameHolder = CreateFrame("Frame", nil, E.UIParent);
	BagFrameHolder:Width(200);
	BagFrameHolder:Height(22);
	BagFrameHolder:SetFrameLevel(BagFrameHolder:GetFrameLevel() + 400);

	if(not E.private.bags.enable) then
		BagFrameHolder:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", -(E.Border*2), 22 + E.Border*4 - E.Spacing*2);
		E:CreateMover(BagFrameHolder, "ElvUIBagMover", L["Bag Mover"], nil, nil, B.PostBagMove);

		--self:SecureHook("UpdateContainerFrameAnchors");
		return;
	end

	E.bags = self;
	self.db = E.db.bags;
	self.BagFrames = {};

	BagFrameHolder:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", 0, 22 + E.Border*4 - E.Spacing*2);
	E:CreateMover(BagFrameHolder, "ElvUIBagMover", L["Bag Mover (Grow Up)"], nil, nil, B.PostBagMove);

	local BankFrameHolder = CreateFrame("Frame", nil, E.UIParent);
	BankFrameHolder:Width(200);
	BankFrameHolder:Height(22);
	BankFrameHolder:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", 0, 22 + E.Border*4 - E.Spacing*2);
	BankFrameHolder:SetFrameLevel(BankFrameHolder:GetFrameLevel() + 400);
	E:CreateMover(BankFrameHolder, "ElvUIBankMover", L["Bank Mover (Grow Up)"], nil, nil, B.PostBagMove);

	ElvUIBagMover.textGrowUp = L["Bag Mover (Grow Up)"];
	ElvUIBagMover.textGrowDown = L["Bag Mover (Grow Down)"];
	ElvUIBagMover.POINT = "BOTTOM";
	ElvUIBankMover.textGrowUp = L["Bank Mover (Grow Up)"];
	ElvUIBankMover.textGrowDown = L["Bank Mover (Grow Down)"];
	ElvUIBankMover.POINT = "BOTTOM";

	self.BagFrame = self:ContructContainerFrame("ElvUI_ContainerFrame");

	--Hook onto Blizzard Functions
	self:SecureHook("ToggleBackpack");
	self:SecureHook("ToggleBag", "ToggleBags");
	self:SecureHook("OpenAllBags", "ToggleBackpack");
	self:SecureHook("OpenBackpack", "OpenBags");
	self:SecureHook("CloseAllBags", "CloseBags");
	self:SecureHook("CloseBackpack", "CloseBags");
	self:SecureHook("BackpackTokenFrame_Update", "UpdateTokens");

	self:Layout();

	E.Bags = self;

	self:DisableBlizzard();
	self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED");
	self:RegisterEvent("PLAYER_MONEY", "UpdateGoldText")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateGoldText")
	self:RegisterEvent("PLAYER_TRADE_MONEY", "UpdateGoldText")
	self:RegisterEvent("TRADE_MONEY_CHANGED", "UpdateGoldText")
	self:RegisterEvent("BANKFRAME_OPENED", "OpenBank")
	self:RegisterEvent("BANKFRAME_CLOSED", "CloseBank")
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")

	StackSplitFrame:SetFrameStrata("DIALOG")
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)