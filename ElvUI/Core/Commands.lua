local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")
local AB = E:GetModule("ActionBars")

--Lua functions
local tonumber, type = tonumber, type
local format, lower, match, split = string.format, string.lower, string.match, string.split
--WoW API / Variables
local InCombatLockdown = InCombatLockdown
local UIFrameFadeOut, UIFrameFadeIn = UIFrameFadeOut, UIFrameFadeIn
local EnableAddOn, DisableAllAddOns = EnableAddOn, DisableAllAddOns
local SetCVar = SetCVar
local ReloadUI = ReloadUI
local debugprofilestop = debugprofilestop
local UpdateAddOnCPUUsage, GetAddOnCPUUsage = UpdateAddOnCPUUsage, GetAddOnCPUUsage
local ResetCPUUsage = ResetCPUUsage
local GetAddOnInfo = GetAddOnInfo
local GetCVarBool = GetCVarBool
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT

function E:Grid(msg)
	msg = msg and tonumber(msg)
	if type(msg) == "number" and (msg <= 256 and msg >= 4) then
		E.db.gridSize = msg
		E:Grid_Show()
	elseif ElvUIGrid and ElvUIGrid:IsShown() then
		E:Grid_Hide()
	else
		E:Grid_Show()
	end
end

function E:LuaError(msg)
	msg = lower(msg)
	if msg == "on" then
		DisableAllAddOns()
		EnableAddOn("ElvUI")
		EnableAddOn("ElvUI_OptionsUI")
		SetCVar("scriptErrors", 1)
		ReloadUI()
	elseif msg == "off" then
		SetCVar("scriptErrors", 0)
		E:Print("Lua errors off.")
	else
		E:Print("/luaerror on - /luaerror off")
	end
end

function E:BGStats()
	DT.ForceHideBGStats = nil
	DT:LoadDataTexts()

	E:Print(L["Battleground datatexts will now show again if you are inside a battleground."])
end

local function OnCallback(command)
	MacroEditBox:GetScript("OnEvent")(MacroEditBox, "EXECUTE_CHAT_LINE", command)
end

function E:DelayScriptCall(msg)
	local secs, command = match(msg, "^(%S+)%s+(.*)$")
	secs = tonumber(secs)
	if (not secs) or (#command == 0) then
		self:Print("usage: /in <seconds> <command>")
		self:Print("example: /in 1.5 /say hi")
	else
		E:Delay(secs, OnCallback, command)
	end
end

function FarmMode()
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
	if not E.private.general.minimap.enable then return end

	if Minimap:IsShown() then
		UIFrameFadeOut(Minimap, 0.3)
		UIFrameFadeIn(FarmModeMap, 0.3)
		Minimap.fadeInfo.finishedFunc = function()
			Minimap:Hide()
			FarmModeMap:SetAlpha(1)

			local zoomLevel = Minimap:GetZoom()
			if zoomLevel < 5 then
				Minimap:SetZoom(zoomLevel + 1)
				Minimap:SetZoom(zoomLevel)
			else
				Minimap:SetZoom(zoomLevel - 1)
				Minimap:SetZoom(zoomLevel)
			end
		end
		FarmModeMap.enabled = true
	else
		UIFrameFadeOut(FarmModeMap, 0.3)
		UIFrameFadeIn(Minimap, 0.3)
		FarmModeMap.fadeInfo.finishedFunc = function()
			FarmModeMap:Hide()
			Minimap:SetAlpha(1)

			local zoomLevel = Minimap:GetZoom()
			if zoomLevel < 5 then
				Minimap:SetZoom(zoomLevel + 1)
				Minimap:SetZoom(zoomLevel)
			else
				Minimap:SetZoom(zoomLevel - 1)
				Minimap:SetZoom(zoomLevel)
			end
		end
		FarmModeMap.enabled = false
	end
end

function E:FarmMode(msg)
	if not E.private.general.minimap.enable then return end

	if msg and type(tonumber(msg)) == "number" and tonumber(msg) <= 500 and tonumber(msg) >= 20 and not InCombatLockdown() then
		E.db.farmSize = tonumber(msg)
		FarmModeMap:Size(tonumber(msg))
	end

	FarmMode()
end

-- make this a locale later?
local MassKickMessage = "Guild Cleanup Results: Removed all guild members below rank %s, that have a minimal level of %s, and have not been online for at least: %s days."
function E:MassGuildKick(msg)
	local minLevel, minDays, minRankIndex = split(",", msg)
	minRankIndex = tonumber(minRankIndex)
	minLevel = tonumber(minLevel)
	minDays = tonumber(minDays)

	if not minLevel or not minDays then
		E:Print("Usage: /cleanguild <minLevel>, <minDays>, [<minRankIndex>]")
		return
	end

	if minDays > 31 then
		E:Print("Maximum days value must be below 32.")
		return
	end

	if not minRankIndex then minRankIndex = GuildControlGetNumRanks() - 1 end

	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex, level, _, _, note, officerNote, connected, _, classFileName = GetGuildRosterInfo(i)
		local minLevelx = minLevel

		if classFileName == "DEATHKNIGHT" then
			minLevelx = minLevelx + 55
		end

		if not connected then
			local years, months, days = GetGuildRosterLastOnline(i)
			if days ~= nil and ((years > 0 or months > 0 or days >= minDays) and rankIndex >= minRankIndex)
			and note ~= nil and officerNote ~= nil and (level <= minLevelx) then
				GuildUninvite(name)
			end
		end
	end

	SendChatMessage(format(MassKickMessage, GuildControlGetRankName(minRankIndex), minLevel, minDays), "GUILD")
end

local num_frames = 0
local function OnUpdate()
	num_frames = num_frames + 1
end
local f = CreateFrame("Frame")
f:Hide()
f:SetScript("OnUpdate", OnUpdate)

local toggleMode, debugTimer, cpuImpactMessage = false, 0, "Consumed %sms per frame. Each frame took %sms to render."
function E:GetCPUImpact()
	if not GetCVarBool("scriptProfile") then
		E:Print("For `/cpuimpact` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.")
		return
	end

	if not toggleMode then
		ResetCPUUsage()
		toggleMode, num_frames, debugTimer = true, 0, debugprofilestop()
		self:Print("CPU Impact being calculated, type /cpuimpact to get results when you are ready.")
		f:Show()
	else
		f:Hide()
		local ms_passed = debugprofilestop() - debugTimer
		UpdateAddOnCPUUsage()

		local per, passed =
			((num_frames == 0 and 0) or (GetAddOnCPUUsage("ElvUI") / num_frames)),
			((num_frames == 0 and 0) or (ms_passed / num_frames))
		self:Print(format(cpuImpactMessage, per and per > 0 and format("%.3f", per) or 0, passed and passed > 0 and format("%.3f", passed) or 0))
		toggleMode = false
	end
end

local BLIZZARD_ADDONS = {
	"Blizzard_AchievementUI",
	"Blizzard_ArenaUI",
	"Blizzard_AuctionUI",
	"Blizzard_BarbershopUI",
	"Blizzard_BattlefieldMinimap",
	"Blizzard_BindingUI",
	"Blizzard_Calendar",
	"Blizzard_CombatLog",
	"Blizzard_CombatText",
	"Blizzard_DebugTools",
	"Blizzard_GlyphUI",
	"Blizzard_GMChatUI",
	"Blizzard_GMSurveyUI",
	"Blizzard_GuildBankUI",
	"Blizzard_InspectUI",
	"Blizzard_ItemSocketingUI",
	"Blizzard_MacroUI",
	"Blizzard_RaidUI",
	"Blizzard_TalentUI",
	"Blizzard_TimeManager",
	"Blizzard_TokenUI",
	"Blizzard_TradeSkillUI",
	"Blizzard_TrainerUI"
}

function E:EnableBlizzardAddOns()
	for _, addon in pairs(BLIZZARD_ADDONS) do
		local reason = select(5, GetAddOnInfo(addon))
		if reason == "DISABLED" then
			EnableAddOn(addon)
			E:Print("The following addon was re-enabled:", addon)
		end
	end
end

function E:LoadCommands()
	self:RegisterChatCommand("in", "DelayScriptCall")
	self:RegisterChatCommand("ec", "ToggleOptionsUI")
	self:RegisterChatCommand("elvui", "ToggleOptionsUI")
	self:RegisterChatCommand("cpuimpact", "GetCPUImpact")

	self:RegisterChatCommand("cpuusage", "GetTopCPUFunc")
	-- args: module, showall, delay, minCalls
	-- Example1: /cpuusage all
	-- Example2: /cpuusage Bags true
	-- Example3: /cpuusage UnitFrames nil 50 25
	-- Note: showall, delay, and minCalls will default if not set
	-- arg1 can be "all" this will scan all registered modules!

	self:RegisterChatCommand("bgstats", "BGStats")
	self:RegisterChatCommand("hellokitty", "HelloKittyToggle")
	self:RegisterChatCommand("hellokittyfix", "HelloKittyFix")
	self:RegisterChatCommand("harlemshake", "HarlemShakeToggle")
	self:RegisterChatCommand("luaerror", "LuaError")
	self:RegisterChatCommand("egrid", "Grid")
	self:RegisterChatCommand("moveui", "ToggleMoveMode")
	self:RegisterChatCommand("resetui", "ResetUI")
	self:RegisterChatCommand("enable", "EnableAddon")
	self:RegisterChatCommand("disable", "DisableAddon")
	self:RegisterChatCommand("farmmode", "FarmMode")
	self:RegisterChatCommand("cleanguild", "MassGuildKick")
	self:RegisterChatCommand("estatus", "ShowStatusReport")
	-- self:RegisterChatCommand("aprilfools", "") --Don't need this until next april fools

	if E.private.actionbar.enable then
		self:RegisterChatCommand("kb", AB.ActivateBindMode)
	end
end