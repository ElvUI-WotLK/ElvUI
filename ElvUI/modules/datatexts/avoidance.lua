local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local format = string.format;
local join = string.join;

local lastPanel;
local displayString;
local chanceString = '%.2f%%';
local modifierString = join('', '%d (+', chanceString, ')');

local targetLevel, playerlv;
local baseMissChance, levelDifference, dodge, parry, block, avoidance, unhittable, avoided, blocked, numAvoidances, unhittableMax;

local AVD_DECAY_RATE = 1.5;

function IsWearingShield()
	local slotID = GetInventorySlotInfo('SecondaryHandSlot');
	local itemID = GetInventoryItemID('player', slotID);
	
	if(itemID ) then
		return select(9, GetItemInfo(itemID));
	end
end

local function OnEvent(self, event, unit)
	targetLevel, playerLevel = UnitLevel('target'), UnitLevel('player');
	
	baseMissChance = E.myrace == 'NightElf' and 7 or 5;
	
	if(targetLevel == -1 ) then
		levelDifference = 3;
	elseif(targetLevel > playerLevel ) then
		levelDifference = (targetLevel - playerLevel);
	elseif(targetLevel < playerLevel and targetLevel > 0 ) then
		levelDifference = (targetLevel - playerLevel);
	else
		levelDifference = 0;
	end

	if(levelDifference >= 0 ) then
		dodge = (GetDodgeChance() - levelDifference * AVD_DECAY_RATE);
		parry = (GetParryChance() - levelDifference * AVD_DECAY_RATE);
		block = (GetBlockChance() - levelDifference * AVD_DECAY_RATE);
		baseMissChance = (baseMissChance - levelDifference * AVD_DECAY_RATE);
	else
		dodge = (GetDodgeChance() + abs(levelDifference * AVD_DECAY_RATE));
		parry = (GetParryChance() + abs(levelDifference * AVD_DECAY_RATE));
		block = (GetBlockChance() + abs(levelDifference * AVD_DECAY_RATE));
		baseMissChance = (baseMissChance+ abs(levelDifference * AVD_DECAY_RATE));
	end
	
	unhittableMax = 100;
	numAvoidances = 4;
	
	if(dodge <= 0 ) then
		dodge = 0;
	end
	
	if(parry <= 0 ) then
		parry = 0;
	end
	
	if(block <= 0 ) then
		block = 0;
	end
	
	if(E.myclass == 'DRUID' and GetBonusBarOffset() == 3 ) then
		parry = 0;
		numAvoidances = numAvoidances - 1;
	end
	
	if(IsWearingShield() ~= 'INVTYPE_SHIELD' ) then
		block = 0;
		numAvoidances = numAvoidances - 1;
	end
	
	unhittableMax = unhittableMax + ((AVD_DECAY_RATE * levelDifference) * numAvoidances);
	
	avoided = (dodge + parry+ baseMissChance);
	blocked = (100 - avoided) * block / 100;
	avoidance = (avoided + blocked);
	unhittable = avoidance - unhittableMax;
	
	self.text:SetFormattedText(displayString, DEFENSE, avoidance);
	
	lastPanel = self;
end

local function OnEnter(self)
	DT:SetupTooltip(self);
	
	if(targetLevel > 1 ) then
		DT.tooltip:AddDoubleLine(L['Avoidance Breakdown'], join('', ' (', L['lvl'], ' ', targetLevel, ')'));
	elseif(targetLevel == -1 ) then
		DT.tooltip:AddDoubleLine(L['Avoidance Breakdown'], join('', ' (', BOSS, ')'));
	else
		DT.tooltip:AddDoubleLine(L['Avoidance Breakdown'], join('', ' (', L['lvl'], ' ', playerLevel, ')'));
	end
	
	DT.tooltip:AddLine(' ');
	DT.tooltip:AddDoubleLine(DODGE_CHANCE, format(chanceString, dodge), 1, 1, 1);
	DT.tooltip:AddDoubleLine(PARRY_CHANCE, format(chanceString, parry), 1, 1, 1);
	DT.tooltip:AddDoubleLine(BLOCK_CHANCE, format(chanceString, block), 1, 1, 1);
	DT.tooltip:AddDoubleLine(L['MISS_CHANCE'], format(chanceString, baseMissChance), 1, 1, 1);
	DT.tooltip:AddLine(' ');
	
	if(unhittable > 0 ) then
		DT.tooltip:AddDoubleLine(L['Unhittable:'], '+'..format(chanceString, unhittable), 1, 1, 1, 0, 1, 0);
	else
		DT.tooltip:AddDoubleLine(L['Unhittable:'], format(chanceString, unhittable), 1, 1, 1, 1, 0, 0);
	end
	
	DT.tooltip:Show();
end


local function ValueColorUpdate(hex, r, g, b)
	displayString = join('', '%s: ', hex, '%.2f%%|r');
	
	if(lastPanel ~= nil ) then
		OnEvent(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

DT:RegisterDatatext(DEFENSE, { 'UNIT_TARGET', 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'PLAYER_EQUIPMENT_CHANGED' }, OnEvent, nil, nil, OnEnter);