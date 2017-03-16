local E, L, V, P, G = unpack(select(2, ...));
local M = E:GetModule("Misc");

local CloseLoot = CloseLoot
local CursorOnUpdate = CursorOnUpdate
local CursorUpdate = CursorUpdate
local GetCVar = GetCVar
local GetCursorPosition = GetCursorPosition
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local GetNumLootItems = GetNumLootItems
local GiveMasterLoot = GiveMasterLoot
local IsFishingLoot = IsFishingLoot
local IsModifiedClick = IsModifiedClick
local LootSlot = LootSlot
local LootSlotIsCoin = LootSlotIsCoin
local LootSlotIsItem = LootSlotIsItem
local ResetCursor = ResetCursor
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS;
local LOOT = LOOT;

local max = math.max
local tinsert = table.insert
local unpack, pairs = unpack, pairs;

-- Credit Haste
local lootFrame, lootFrameHolder
local iconSize = 30;

local sq, ss, sn;
local OnEnter = function(self)
	local slot = self:GetID();
	if(LootSlotIsItem(slot)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetLootItem(slot);
		CursorUpdate(self);
	end

	self.drop:Show();
	self.drop:SetVertexColor(1, 1, 0);
end

local OnLeave = function(self)
	if self.quality and (self.quality > 1) then
		local color = ITEM_QUALITY_COLORS[self.quality]
		self.drop:SetVertexColor(color.r, color.g, color.b)
	else
		self.drop:Hide();
	end

	GameTooltip:Hide();
	ResetCursor();
end

local OnClick = function(self)
	LootFrame.selectedQuality = self.quality;
	LootFrame.selectedItemName = self.name:GetText()
	LootFrame.selectedSlot = self:GetID()
	LootFrame.selectedLootButton = self:GetName()

	if(IsModifiedClick()) then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		ss = self:GetID()
		sq = self.quality
		sn = self.name:GetText()
		LootSlot(ss)
	end
end

local OnShow = function(self)
	if(GameTooltip:IsOwned(self)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

local function anchorSlots(self)
	local shownSlots = 0
	for i = 1, #self.slots do
		local frame = self.slots[i]
		if(frame:IsShown()) then
			shownSlots = shownSlots + 1

			frame:Point("TOP", lootFrame, 4, (-8 + iconSize) - (shownSlots * iconSize))
		end
	end

	self:Height(max(shownSlots * iconSize + 16, 20))
end

local function createSlot(id)
	local frame = CreateFrame("Button", "ElvLootSlot"..id, lootFrame)
	frame:Point("LEFT", 8, 0)
	frame:Point("RIGHT", -8, 0)
	frame:Height(iconSize - 2)
	frame:SetID(id)

	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)
	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnShow", OnShow)

	local iconFrame = CreateFrame("Frame", nil, frame)
	iconFrame:Size(iconSize - 2)
	iconFrame:SetPoint("RIGHT", frame)
	iconFrame:SetTemplate("Default")
	frame.iconFrame = iconFrame
	E["frames"][iconFrame] = nil;

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(unpack(E.TexCoords))
	icon:SetInside()
	frame.icon = icon

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:SetJustifyH("RIGHT")
	count:Point("BOTTOMRIGHT", iconFrame, -2, 2)
	count:FontTemplate(nil, nil, "OUTLINE")
	count:SetText(1)
	frame.count = count

	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", frame)
	name:SetPoint("RIGHT", icon, "LEFT")
	name:SetNonSpaceWrap(true)
	name:FontTemplate(nil, nil, "OUTLINE")
	frame.name = name

	local drop = frame:CreateTexture(nil, "ARTWORK")
	drop:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	drop:SetPoint("LEFT", icon, "RIGHT", 0, 0)
	drop:SetPoint("RIGHT", frame)
	drop:SetAllPoints(frame)
	drop:SetAlpha(.3)
	frame.drop = drop

	lootFrame.slots[id] = frame
	return frame
end

function M:LOOT_SLOT_CLEARED(_, slot)
	if(not lootFrame:IsShown()) then return end

	lootFrame.slots[slot]:Hide()
	anchorSlots(lootFrame)
end

function M:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	lootFrame:Hide()

	for _, v in pairs(lootFrame.slots) do
		v:Hide()
	end
end

function M:OPEN_MASTER_LOOT_LIST()
	ToggleDropDownMenu(1, nil, GroupLootDropDown, lootFrame.slots[ss], 0, 0)
end

function M:UPDATE_MASTER_LOOT_LIST()
	UIDropDownMenu_Refresh(GroupLootDropDown);
end

function M:LOOT_OPENED(_, autoloot)
	lootFrame:Show()

	if(not lootFrame:IsShown()) then
		CloseLoot(not autoLoot)
	end

	local items = GetNumLootItems()

	if(IsFishingLoot()) then
		lootFrame.title:SetText(L["Fishy Loot"])
	elseif(not UnitIsFriend("player", "target") and UnitIsDead("target")) then
		lootFrame.title:SetText(UnitName("target"))
	else
		lootFrame.title:SetText(LOOT)
	end

	-- Blizzard uses strings here
	if(GetCVar("lootUnderMouse") == "1") then
		local x, y = GetCursorPosition()
		x = x / lootFrame:GetEffectiveScale()
		y = y / lootFrame:GetEffectiveScale()

		lootFrame:ClearAllPoints()
		lootFrame:Point("TOPLEFT", UIParent, "BOTTOMLEFT", x - 40, y + 20)
		lootFrame:GetCenter()
		lootFrame:Raise()
		E:DisableMover("LootFrameMover");
	else
		lootFrame:ClearAllPoints()
		lootFrame:SetPoint("TOPLEFT", lootFrameHolder, "TOPLEFT")
		E:EnableMover("LootFrameMover");
	end

	local m, w, t = 0, 0, lootFrame.title:GetStringWidth()
	if(items > 0) then
		for i = 1, items do
			local slot = lootFrame.slots[i] or createSlot(i)
			local texture, item, quantity, quality = GetLootSlotInfo(i)
			local color = ITEM_QUALITY_COLORS[quality]

			if(LootSlotIsCoin(i)) then
				item = item:gsub("\n", ", ")
			end

			if quantity and (quantity > 1) then
				slot.count:SetText(quantity)
				slot.count:Show()
			else
				slot.count:Hide()
			end

			if quality and (quality > 1) then
				slot.drop:SetVertexColor(color.r, color.g, color.b)
				slot.drop:Show()
			else
				slot.drop:Hide()
			end

			slot.quality = quality
			slot.name:SetText(item)
			if color then
				slot.name:SetTextColor(color.r, color.g, color.b)
			end
			slot.icon:SetTexture(texture)

			if quality then
				m = max(m, quality)
			end
			w = max(w, slot.name:GetStringWidth())

			slot:Enable()
			slot:Show()
		end
	else
		local slot = lootFrame.slots[1] or createSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(L["Empty Slot"])
		if color then
			slot.name:SetTextColor(color.r, color.g, color.b)
		end
		slot.icon:SetTexture[[Interface\Icons\INV_Misc_Herb_AncientLichen]]

		items = 1
		w = max(w, slot.name:GetStringWidth())

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end
	anchorSlots(lootFrame)

	w = w + 60
	t = t + 5

	local color = ITEM_QUALITY_COLORS[m]
	lootFrame:SetBackdropBorderColor(color.r, color.g, color.b, .8)
	lootFrame:Width(max(w, t))
end

function M:LoadLoot()
	if not E.private.general.loot then return end
	lootFrameHolder = CreateFrame("Frame", "ElvLootFrameHolder", E.UIParent)
	lootFrameHolder:Point("TOPLEFT", 36, -195)
	lootFrameHolder:Size(150, 22)

	lootFrame = CreateFrame("Button", "ElvLootFrame", lootFrameHolder)
	lootFrame:SetClampedToScreen(true)
	lootFrame:SetPoint("TOPLEFT")
	lootFrame:Size(256, 64)
	lootFrame:SetTemplate("Transparent")
	lootFrame:SetFrameStrata("FULLSCREEN")
	lootFrame:SetToplevel(true)
	lootFrame.title = lootFrame:CreateFontString(nil, "OVERLAY")
	lootFrame.title:FontTemplate(nil, nil, "OUTLINE")
	lootFrame.title:Point("BOTTOMLEFT", lootFrame, "TOPLEFT", 0, 1);
	lootFrame.slots = {}
	lootFrame:SetScript("OnHide", function()
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		CloseLoot()
	end)
	E["frames"][lootFrame] = nil;

	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST")
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST")

	E:CreateMover(lootFrameHolder, "LootFrameMover", L["Loot Frame"])

	if(GetCVar("lootUnderMouse") == "1") then
		E:DisableMover("LootFrameMover");
	end

	-- Fuzz
	LootFrame:UnregisterAllEvents()
	tinsert(UISpecialFrames, "ElvLootFrame")

	function _G.GroupLootDropDown_GiveLoot(self)
		if(sq >= MASTER_LOOT_THREHOLD) then
			local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[sq].hex..sn..FONT_COLOR_CODE_CLOSE, self:GetText())
			if (dialog) then
				dialog.data = self.value
			end
		else
			GiveMasterLoot(ss, self.value)
		end
		CloseDropDownMenus()
	end

	E.PopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(self, data)
		GiveMasterLoot(ss, data);
	end
	StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].preferredIndex = 3;
end