local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local select = select
local join = string.join
--WoW API / Variables
local GetBattlefieldScore = GetBattlefieldScore
local GetBattlefieldStatData = GetBattlefieldStatData
local GetBattlefieldStatInfo = GetBattlefieldStatInfo
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumBattlefieldStats = GetNumBattlefieldStats
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local displayString = ""
local lastPanel

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
}

local dataStrings = {
	[11] = DAMAGE,
	[5] = HONOR,
	[2] = KILLING_BLOWS,
	[4] = DEATHS,
	[3] = HONORABLE_KILLS,
	[12] = SHOW_COMBAT_HEALING
}

function DT:UPDATE_BATTLEFIELD_SCORE()
	lastPanel = self

	local pointIndex = dataLayout[self:GetParent():GetName()][self.pointIndex]
	for i = 1, GetNumBattlefieldScores() do
		local name = GetBattlefieldScore(i)
		if name == E.myname then
			self.text:SetFormattedText(displayString, dataStrings[pointIndex], E:ShortValue(select(pointIndex, GetBattlefieldScore(i))))
			break
		end
	end
end

function DT:BattlegroundStats()
	DT:SetupTooltip(self)

	local numStatInfo = GetNumBattlefieldStats()
	if numStatInfo then
		for i = 1, GetNumBattlefieldScores() do
			local name = GetBattlefieldScore(i)
			if name and name == E.myname then
				local classColor = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass]) or RAID_CLASS_COLORS[E.myclass]

				DT.tooltip:AddDoubleLine(L["Stats For:"], name, 1, 1, 1, classColor.r, classColor.g, classColor.b)
				DT.tooltip:AddLine(" ")

				-- Add extra statistics to watch based on what BG you are in.
				for j = 1, numStatInfo do
					DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(j), GetBattlefieldStatData(i, j), 1, 1, 1)
				end

				break
			end
		end
	end

	DT.tooltip:Show()
end

function DT:HideBattlegroundTexts()
	DT.ForceHideBGStats = true
	DT:LoadDataTexts()
	E:Print(L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."])
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		DT.UPDATE_BATTLEFIELD_SCORE(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true