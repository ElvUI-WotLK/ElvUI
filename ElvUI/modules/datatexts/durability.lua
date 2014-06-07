local E, L, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join;

local lastPanel;
local displayString = '';
local invDurability = {};

local Slots = {
	['RangedSlot'] = RANGEDSLOT,
	['SecondaryHandSlot'] = SECONDARYHANDSLOT,
	['MainHandSlot'] = MAINHANDSLOT,
	['FeetSlot'] = FEETSLOT,
	['LegsSlot'] = LEGSSLOT,
	['HandsSlot'] = HANDSSLOT,
	['WristSlot'] = WRISTSLOT,
	['WaistSlot'] = WAISTSLOT,
	['ChestSlot'] = CHESTSLOT,
	['ShoulderSlot'] = SHOULDERSLOT,
	['HeadSlot'] = HEADSLOT,
}

local function OnEvent(self, event, ...)
	local total = 0;
	local totalDurability = 0;
	local totalPerc = 0;
	
	for index, value in pairs(Slots) do
		local slot = GetInventorySlotInfo(index);
		local current, max = GetInventoryItemDurability(slot);
		
		if ( current ) then
			totalDurability = totalDurability + current;
			invDurability[value] = (current / max) * 100;
			totalPerc = totalPerc + (current / max) * 100;
			total = total + 1;
		end
	end
	
	if ( total > 0 ) then
		self.text:SetFormattedText(displayString, DURABILITY, totalPerc / total);
	end
	
	lastPanel = self;
end

local function Click()
	ToggleCharacter('PaperDollFrame');
end

local function OnEnter(self)
	DT:SetupTooltip(self);
	
	for slot, durability in pairs(invDurability) do
		DT.tooltip:AddDoubleLine(slot, format('%d%%', durability), 1, 1, 1, E:ColorGradient(durability * 0.01, 1, 0, 0, 1, 1, 0, 0, 1, 0));
	end
	
	DT.tooltip:Show();
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join('', '%s: ', hex, '%d%%|r');
	
	if ( lastPanel ~= nil ) then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE');
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

DT:RegisterDatatext(DURABILITY, { 'PLAYER_ENTERING_WORLD', 'UPDATE_INVENTORY_DURABILITY', 'MERCHANT_SHOW' }, OnEvent, nil, Click, OnEnter);