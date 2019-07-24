local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local join = string.join;

local GetPVPLifetimeStats = GetPVPLifetimeStats;
local KILLS = KILLS;
local HONORABLE_KILLS = HONORABLE_KILLS;

local lastPanel;
local displayNumberString = "";

local function OnEvent(self)
	local hk = GetPVPLifetimeStats();

	self.text:SetFormattedText(displayNumberString, KILLS, hk);

	lastPanel = self;
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%d|r");

	if(lastPanel ~= nil) then
		OnEvent(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Honorable Kills", {"PLAYER_PVP_KILLS_CHANGED", "PLAYER_PVP_RANK_CHANGED"}, OnEvent, nil, nil, nil, nil, HONORABLE_KILLS)