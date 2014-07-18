local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join;

local lastPanel;
local displayNumberString = '';

local function OnEvent(self, event)
	local hk = GetPVPLifetimeStats();
	
	self.text:SetFormattedText(displayNumberString, HONORABLE_KILLS, hk);

	lastPanel = self;
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join('', '%s: ', hex, '%d|r');
	
	if(lastPanel ~= nil) then
		OnEvent(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

DT:RegisterDatatext(HONORABLE_KILLS, nil, OnEvent);