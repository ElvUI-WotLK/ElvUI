local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local format, join = string.format, string.join
--WoW API / Variables
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local BACKPACK_TOOLTIP = BACKPACK_TOOLTIP
local CURRENCY = CURRENCY
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local currencyString = "|T%s:14:14:0:0:64:64:4:60:4:60|t %s"
local displayString = ""
local lastPanel

local function OnEvent(self)
	local free, total = 0, 0
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
	end
	self.text:SetFormattedText(displayString, total - free, total)

	lastPanel = self
end

local function OnClick()
	OpenAllBags()
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local r, g, b
	local _, name, quality, link
	local free, total, used

	for i = 0, NUM_BAG_SLOTS do
		free, total = GetContainerNumFreeSlots(i), GetContainerNumSlots(i)
		used = total - free

		if i == 0 then
			DT.tooltip:AddLine(L["Bags"]..":")
			DT.tooltip:AddDoubleLine(BACKPACK_TOOLTIP, format("%d / %d", used, total), 1, 1, 1)
		else
			link = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
			if link then
				name, _, quality = GetItemInfo(link)
				r, g, b = GetItemQualityColor(quality)
				DT.tooltip:AddDoubleLine(name, format("%d / %d", used, total), r, g, b)
			end
		end
	end

	local count, currencyType, icon
	for i = 1, MAX_WATCHED_TOKENS do
		name, count, currencyType, icon = GetBackpackCurrencyInfo(i)
		if name and i == 1 then
			DT.tooltip:AddLine(" ")
			DT.tooltip:AddLine(CURRENCY..":")
		end

		if name and count then
			if currencyType == 1 then
				icon = "Interface\\PVPFrame\\PVP-ArenaPoints-Icon"
			elseif currencyType == 2 then
				icon = "Interface\\PVPFrame\\PVP-Currency-"..E.myfaction
			end
			DT.tooltip:AddDoubleLine(format(currencyString, icon, name), count, 1, 1, 1)
		end
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", L["Bags"], ": ", hex, "%d/%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Bags", {"PLAYER_ENTERING_WORLD", "BAG_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, L["Bags"])