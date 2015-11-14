local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local displayString = "";
local join = string.join;
local lastPanel;

local function OnEvent(self, event, ...)
	local free, total, used = 0, 0, 0;
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i);
	end
	used = total - free;
	
	self.text:SetFormattedText(displayString, L["Bags"], used, total);
	lastPanel = self;
end

local function OnClick()
	OpenAllBags();
end

local function OnEnter(self)
	DT:SetupTooltip(self);
	
	for i = 1, MAX_WATCHED_TOKENS do
		local name, count = GetBackpackCurrencyInfo(i);
		if(name and i == 1) then
			DT.tooltip:AddLine(CURRENCY);
			DT.tooltip:AddLine(" ");
		end
		
		if(name and count) then DT.tooltip:AddDoubleLine(name, count, 1, 1, 1); end
	end
	
	DT.tooltip:Show();
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "%s: ", hex, "%d/%d|r");
	
	if(lastPanel ~= nil) then
		OnEvent(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext(L["Bags"], { "PLAYER_ENTERING_WORLD", "BAG_UPDATE" }, OnEvent, nil, OnClick, OnEnter);