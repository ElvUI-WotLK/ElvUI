local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts");

local select = select;
local join = string.join;

local GetBattlefieldScore = GetBattlefieldScore;
local GetNumBattlefieldStats = GetNumBattlefieldStats
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldStatInfo = GetBattlefieldStatInfo
local GetBattlefieldStatData = GetBattlefieldStatData;

local name
local lastPanel;
local displayString = "";

local dataLayout = {
	["LeftChatDataPanel"] = {
		["left"] = 11,
		["middle"] = 5,
		["right"] = 2
	},
	["RightChatDataPanel"] = {
		["left"] = 4,
		["middle"] = 3,
		["right"] = 12
	}
};

local dataStrings = {
	[11] = DAMAGE,
	[5] = HONOR,
	[2] = KILLING_BLOWS,
	[4] = DEATHS,
	[3] = HONORABLE_KILLS,
	[12] = SHOW_COMBAT_HEALING
};

function DT:UPDATE_BATTLEFIELD_SCORE()
	lastPanel = self;
	local pointIndex = dataLayout[self:GetParent():GetName()][self.pointIndex];
	for i = 1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(i);
		if(name == E.myname) then
			self.text:SetFormattedText(displayString, dataStrings[pointIndex], select(pointIndex, GetBattlefieldScore(i)));
			break;
		end
	end
end

function DT:BattlegroundStats()
	DT:SetupTooltip(self);
	local CurrentMapID = GetCurrentMapAreaID();

	local classColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[E.myclass]
	local numStatInfo = GetNumBattlefieldStats()
	if numStatInfo then
		for index = 1, GetNumBattlefieldScores() do
			name = GetBattlefieldScore(index)
			if name and name == E.myname then
				DT.tooltip:AddDoubleLine(L["Stats For:"], name, 1, 1, 1, classColor.r, classColor.g, classColor.b)
				DT.tooltip:AddLine(" ")

				-- Add extra statistics to watch based on what BG you are in.
				for x = 1, numStatInfo do
					DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(x), GetBattlefieldStatData(index, x), 1, 1, 1)
				end
				break
			end
		end
	end

	DT.tooltip:Show();
end

function DT:HideBattlegroundTexts()
	DT.ForceHideBGStats = true;
	DT:LoadDataTexts();
	E:Print(L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."]);
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%s|r");

	if(lastPanel ~= nil) then
		DT.UPDATE_BATTLEFIELD_SCORE(lastPanel);
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true;