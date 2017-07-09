local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local _G = _G;
local pairs = pairs;
local format, join, upper = string.format, string.join, string.upper;

local GetInventoryItemDurability = GetInventoryItemDurability;
local GetInventorySlotInfo = GetInventorySlotInfo;
local ToggleCharacter = ToggleCharacter;
local DURABILITY = DURABILITY;

local displayString = "";
local tooltipString = "%d%%";
local totalDurability = 0;
local current, max, lastPanel;
local invDurability = {};
local slots = {
	"RangedSlot",
	"SecondaryHandSlot",
	"MainHandSlot",
	"FeetSlot",
	"LegsSlot",
	"HandsSlot",
	"WristSlot",
	"WaistSlot",
	"ChestSlot",
	"ShoulderSlot",
	"HeadSlot"
};

local function OnEvent(self)
	lastPanel = self;
	totalDurability = 100;

	for _, value in pairs(slots) do
		local slot = GetInventorySlotInfo(value);
		current, max = GetInventoryItemDurability(slot);

		if(current) then
			invDurability[value] = (current / max) * 100;

			if(((current / max) * 100) < totalDurability) then
				totalDurability = (current / max) * 100
			end
		end
	end

	self.text:SetFormattedText(displayString, totalDurability);
end

local function OnClick()
	ToggleCharacter("PaperDollFrame");
end

local function OnEnter(self)
	DT:SetupTooltip(self);

	for slot, durability in pairs(invDurability) do
		DT.tooltip:AddDoubleLine(_G[upper(slot)], format(tooltipString, durability), 1, 1, 1, E:ColorGradient(durability * 0.01, 1, 0, 0, 1, 1, 0, 0, 1, 0));
	end

	DT.tooltip:Show();
end

local function ValueColorUpdate(hex)
	displayString = join("", DURABILITY, ": ", hex, "%d%%|r");

	if(lastPanel ~= nil) then
		OnEvent(lastPanel, "ELVUI_COLOR_UPDATE");
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Durability", {"PLAYER_ENTERING_WORLD", "UPDATE_INVENTORY_DURABILITY", "MERCHANT_SHOW"}, OnEvent, nil, OnClick, OnEnter, nil, DURABILITY)