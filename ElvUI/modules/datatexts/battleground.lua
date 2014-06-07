local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join;

local lastPanel;
local displayString = '';
local classColor = RAID_CLASS_COLORS[E.myclass];

local dataLayout = {
	['LeftChatDataPanel'] = {
		['left'] = 11,
		['middle'] = 5,
		['right'] = 2
	},
	['RightChatDataPanel'] = {
		['left'] = 4,
		['middle'] = 3,
		['right'] = 12
	},	
}

local dataStrings = {
	[11] = DAMAGE,
	[5] = HONOR,
	[2] = KILLING_BLOWS,
	[4] = DEATHS,
	[3] = HONORABLE_KILLS,
	[12] = SHOW_COMBAT_HEALING
}

local name;

function DT:UPDATE_BATTLEFIELD_SCORE()
	local pointIndex = dataLayout[self:GetParent():GetName()][self.pointIndex];
	
	RequestBattlefieldScoreData();
	
	for i = 1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(i);
		
		if ( name == E.myname ) then
			self.text:SetFormattedText(displayString, dataStrings[pointIndex], select(pointIndex, GetBattlefieldScore(i)));
			break	
		end
	end
	
	lastPanel = self;
end

function DT:BattlegroundStats()
	DT:SetupTooltip(self);
	
	for index = 1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(index);
		
		if ( name and name == E.myname ) then
			DT.tooltip:AddDoubleLine(L['Stats For:'], name, 1, 1, 1, classColor.r, classColor.g, classColor.b);
			DT.tooltip:AddLine(' ');
			
			if ( GetRealZoneText() == L['Warsong Gulch'] ) then
				DT.tooltip:AddDoubleLine(L['Flags Captured'], GetBattlefieldStatData(index, 1), 1, 1, 1);
				DT.tooltip:AddDoubleLine(L['Flags Returned'], GetBattlefieldStatData(index, 2), 1, 1, 1);
			elseif ( GetRealZoneText() == L['Eye of the Storm'] ) then
				DT.tooltip:AddDoubleLine(L['Flags Captured'], GetBattlefieldStatData(index, 1), 1, 1, 1);
			elseif ( GetRealZoneText() == L['Alterac Valley'] ) then
				DT.tooltip:AddDoubleLine(L['Graveyards Assaulted'], GetBattlefieldStatData(index, 1), 1, 1, 1);
				DT.tooltip:AddDoubleLine(L['Graveyards Defended'], GetBattlefieldStatData(index, 2), 1, 1, 1);
				DT.tooltip:AddDoubleLine(L['Towers Assaulted'], GetBattlefieldStatData(index, 3), 1, 1, 1);
				DT.tooltip:AddDoubleLine(L['Towers Defended'], GetBattlefieldStatData(index, 4), 1, 1, 1);
			elseif ( GetRealZoneText() == L['Strand of the Ancients'] ) then
				DT.tooltip:AddDoubleLine(L['Demolishers Destroyed'], GetBattlefieldStatData(index, 1), 1, 1, 1);
				DT.tooltip:AddDoubleLine(L['Gates Destroyed'], GetBattlefieldStatData(index, 2), 1, 1, 1);
			elseif ( GetRealZoneText() == L['Arathi Basin'] or GetRealZoneText() == L['Isle of Conquest'] ) then
				DT.tooltip:AddDoubleLine(L['Bases Assaulted'], GetBattlefieldStatData(index, 1), 1, 1, 1);
				DT.tooltip:AddDoubleLine(L['Bases Defended'], GetBattlefieldStatData(index, 2), 1, 1, 1);
			end
			break
		end
	end	
	
	DT.tooltip:Show();
end

function DT:HideBattlegroundTexts()
	DT.ForceHideBGStats = true;
	DT:LoadDataTexts();
	
	E:Print(L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."]);
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join('', '%s: ', hex, '%s|r');

	if ( lastPanel ~= nil ) then
		DT.UPDATE_BATTLEFIELD_SCORE(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;