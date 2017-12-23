local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local pairs = pairs;
local join = string.join;

local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetMoney = GetMoney
local IsLoggedIn = IsLoggedIn
local IsShiftKeyDown = IsShiftKeyDown
local UnitFactionGroup = UnitFactionGroup

local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS;
local CURRENCY = CURRENCY;

local currencyString = "|T%s:14:14:0:0:64:64:4:60:4:60|t %s";
local Profit = 0;
local Spent = 0;
local resetCountersFormatter = join("", "|cffaaaaaa", L["Reset Counters: Hold Shift + Left Click"], "|r")
local resetInfoFormatter = join("", "|cffaaaaaa", L["Reset Data: Hold Shift + Right Click"], "|r");

local function OnEvent(self)
	if(not IsLoggedIn()) then return; end
	local NewMoney = GetMoney();
	ElvDB = ElvDB or {};
	ElvDB["gold"] = ElvDB["gold"] or {};
	ElvDB["gold"][E.myrealm] = ElvDB["gold"][E.myrealm] or {};
	ElvDB["gold"][E.myrealm][E.myname] = ElvDB["gold"][E.myrealm][E.myname] or NewMoney;

	local OldMoney = ElvDB["gold"][E.myrealm][E.myname] or NewMoney;

	local Change = NewMoney - OldMoney;
	if(OldMoney > NewMoney) then
		Spent = Spent - Change;
	else
		Profit = Profit + Change;
	end

	self.text:SetText(E:FormatMoney(NewMoney, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins));

	ElvDB["gold"][E.myrealm][E.myname] = NewMoney;
end

local function OnClick(self, btn)
	if IsShiftKeyDown() then
		if btn == "LeftButton" then
			Profit = 0
			Spent = 0
			DT.tooltip:Hide();
		elseif btn == "RightButton" then
			ElvDB.gold = nil;
			OnEvent(self)
			DT.tooltip:Hide();
		end
	else
		OpenAllBags();
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self);
	local textOnly = not E.db.datatexts.goldCoins and true or false;
	local style = E.db.datatexts.goldFormat or "BLIZZARD";

	DT.tooltip:AddLine(L["Session:"]);
	DT.tooltip:AddDoubleLine(L["Earned:"], E:FormatMoney(Profit, style, textOnly), 1, 1, 1, 1, 1, 1);
	DT.tooltip:AddDoubleLine(L["Spent:"], E:FormatMoney(Spent, style, textOnly), 1, 1, 1, 1, 1, 1);
	if(Profit < Spent) then
		DT.tooltip:AddDoubleLine(L["Deficit:"], E:FormatMoney(Profit-Spent, style, textOnly), 1, 0, 0, 1, 1, 1);
	elseif((Profit - Spent) > 0) then
		DT.tooltip:AddDoubleLine(L["Profit:"], E:FormatMoney(Profit-Spent, style, textOnly), 0, 1, 0, 1, 1, 1);
	end
	DT.tooltip:AddLine(" ");

	local totalGold = 0;
	DT.tooltip:AddLine(L["Character: "]);

	for k, _ in pairs(ElvDB["gold"][E.myrealm]) do
		if(ElvDB["gold"][E.myrealm][k]) then
			DT.tooltip:AddDoubleLine(k, E:FormatMoney(ElvDB["gold"][E.myrealm][k], style, textOnly), 1, 1, 1, 1, 1, 1);
			totalGold = totalGold + ElvDB["gold"][E.myrealm][k];
		end
	end

	DT.tooltip:AddLine(" ");
	DT.tooltip:AddLine(L["Server: "]);
	DT.tooltip:AddDoubleLine(L["Total: "], E:FormatMoney(totalGold, style, textOnly), 1, 1, 1, 1, 1, 1);

	for i = 1, MAX_WATCHED_TOKENS do
		local name, count, extraCurrencyType, icon = GetBackpackCurrencyInfo(i);
		if name and i == 1 then
			DT.tooltip:AddLine(" ");
			DT.tooltip:AddLine(CURRENCY .. ":");
		end
		if name and count then
			if extraCurrencyType == 1 then
				icon = "Interface\\PVPFrame\\PVP-ArenaPoints-Icon"
			elseif extraCurrencyType == 2 then
				icon = "Interface\\PVPFrame\\PVP-Currency-"..UnitFactionGroup("player")
			end
			DT.tooltip:AddDoubleLine(currencyString:format(icon, name), count, 1, 1, 1)
		end
	end

	DT.tooltip:AddLine(" ");
	DT.tooltip:AddLine(resetCountersFormatter)
	DT.tooltip:AddLine(resetInfoFormatter);

	DT.tooltip:Show();
end

DT:RegisterDatatext("Gold", {"PLAYER_ENTERING_WORLD", "PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED"}, OnEvent, nil, OnClick, OnEnter, nil, L["Gold"])