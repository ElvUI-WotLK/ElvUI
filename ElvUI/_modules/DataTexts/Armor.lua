local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local format = string.format;
local join = string.join;

local UnitArmor = UnitArmor;
local UnitLevel = UnitLevel;
local PaperDollFrame_GetArmorReduction = PaperDollFrame_GetArmorReduction;
local ARMOR = ARMOR;

local lastPanel;
local chanceString = "%.2f%%";
local displayString = "";
local _, effectiveArmor;

local function OnEvent(self)
	_, effectiveArmor = UnitArmor("player");

	self.text:SetFormattedText(displayString, ARMOR, effectiveArmor);
	lastPanel = self;
end

local function OnEnter(self)
	DT:SetupTooltip(self);

	DT.tooltip:AddLine(L["Mitigation By Level: "]);
	DT.tooltip:AddLine(" ");

	local playerLevel = UnitLevel("player") + 3;
	for i = 1, 4 do
		local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, playerLevel);
		DT.tooltip:AddDoubleLine(playerLevel, format(chanceString, armorReduction), 1, 1, 1);
		playerLevel = playerLevel - 1;
	end

	local targetLevel = UnitLevel("target");
	if(targetLevel and targetLevel > 0 and (targetLevel > playerLevel + 3 or targetLevel < playerLevel)) then
		local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, targetLevel);
		DT.tooltip:AddDoubleLine(targetLevel, format(chanceString, armorReduction), 1, 1, 1);
	end

	DT.tooltip:Show();
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d|r");

	if(lastPanel ~= nil) then
		OnEvent(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;

DT:RegisterDatatext("Armor", {"UNIT_RESISTANCES"}, OnEvent, nil, nil, OnEnter, nil, ARMOR)