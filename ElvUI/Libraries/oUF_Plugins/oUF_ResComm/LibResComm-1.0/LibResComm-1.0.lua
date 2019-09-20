--[[
	Name: LibResComm-1.0
	Revision: $Revision: 91 $
	Author(s): DathRarhek (Polleke) (polleke@gmail.com)
	Documentation: http://www.wowace.com/index.php/LibResComm-1.0
	SVN: svn://svn.wowace.com/wow/librescomm-1-0/mainline/trunk
	Description: Keeps track of resurrection spells cast in the raid group
	Dependencies: LibStub, CallbackHandler-1.0
]]

local MAJOR_VERSION = "LibResComm-1.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 92 $"):match("%d+"))

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

if lib.disable then
	lib.disable()
end

------------------------------------------------------------------------
--	Localization
--

local L = {
	-- use global string for locale independence
	CORPSE_OF = "^" .. CORPSE_TOOLTIP:gsub("%%s", "(.+)"),

	-- needs to match return values from HasSoulstone()
	["Reincarnate"] = "Reincarnate",
	["Twisting Nether"] = "Twisting Nether",
	["Use Soulstone"] = "Use Soulstone",

	-- sensible text to show
	["Soulstone"] = "Soulstone",
}

local LOCALE = GetLocale()
if LOCALE == "deDE" then
--	L["Reincarnate"] = "Reinkarnation"
	L["Soulstone"] = "Seelenstein"
--	L["Twisting Nether"] = "Wirbelnder Nether"
--	L["Use Soulstone"] = "Seelenstein benutzen"
elseif LOCALE == "esES" or LOCALE == "esMX" then
--	L["Reincarnate"] = "Reencarnación"
	L["Soulstone"] = "Piedra de alma"
--	L["Twisting Nether"] = "Vacío Abisal"
--	L["Use Soulstone"] = "Usar piedra de alma"
elseif LOCALE == "frFR" then
--	L["Reincarnate"] = "Réincarner"
	L["Soulstone"] = "Pierre d'âme"
--	L["Twisting Nether"] = "Néant distordu"
--	L["Use Soulstone"] = "Utilisez Pierre d'âme"
elseif LOCALE == "ruRU" then
	L.CORPSE_OF = "^" .. CORPSE_TOOLTIP:gsub("%|%S+%(%%s%)", "(.+)")

--	L["Reincarnate"] = "Возродиться"
	L["Soulstone"] = "Камень души"
--	L["Twisting Nether"] = "Круговерть Пустоты"
--	L["Use Soulstone"] = "Использование камня души"
elseif LOCALE == "koKR" then
--	L["Reincarnate"] = "윤회"
	L["Soulstone"] = "영혼석"
--	L["Twisting Nether"] = "뒤틀린 황천"
--	L["Use Soulstone"] = "영혼석 사용"
elseif LOCALE == "zhCN" then
--	L["Reincarnate"] = "复生"
	L["Soulstone"] = "灵魂石"
--	L["Twisting Nether"] = "扭曲虚空"
--	L["Use Soulstone"] = "使用灵魂石"
elseif LOCALE == "zhTW" then
--	L["Reincarnate"] = "復生效果"
	L["Soulstone"] = "靈魂石"
--	L["Twisting Nether"] = "扭曲虛空"
--	L["Use Soulstone"] = "靈魂石復活效果"
end

local soulstoneToken = {
	[L["Use Soulstone"]] = "SS",
	[L["Reincarnate"]] = "RE",
	[L["Twisting Nether"]] = "TN",
}

local soulstoneText = {
	["SS"] = L["Soulstone"],
	["RE"] = GetSpellInfo(20608), -- just use Reincarnation spell name
	["TN"] = L["Twisting Nether"],
}

------------------------------------------------------------------------
--	Event frame
--

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:SetScript("OnEvent", function(this, event, ...)
	this[event](this, ...)
end)
lib.eventFrame:UnregisterAllEvents()

------------------------------------------------------------------------
--	Embed CallbackHandler-1.0
--

if not lib.Callbacks then
	lib.Callbacks = LibStub("CallbackHandler-1.0"):New(lib)
end

------------------------------------------------------------------------
--	Locals
--

local playerName = UnitName("player")
local _, playerClass = UnitClass("player")
local isResser = (playerClass == "PRIEST") or (playerClass == "SHAMAN") or (playerClass == "PALADIN") or (playerClass == "DRUID")

-- Last target name from UNIT_SPELLCAST_SENT
local sentTargetName = nil

-- Mouse down target
local mouseDownTarget = nil
local worldFrameHook = nil

-- Battleground/Arena/Group Indicators
local inBattlegroundOrArena = nil

-- For tracking STOP messages
local isCasting = nil

-- Tracking resses
local activeRes = {}

local resSpell, combatResSpell -- avoid creating tables we're just going to discard immediately
if playerClass == "DRUID" then
	resSpell = GetSpellInfo(50769) -- Revive
	combatResSpell = GetSpellInfo(20484) -- Rebirth
elseif playerClass == "PALADIN" then
	resSpell = GetSpellInfo(7328) -- Redemption
elseif playerClass == "PRIEST" then
	resSpell = GetSpellInfo(2006) -- Resurrection
elseif playerClass == "SHAMAN" then
	resSpell = GetSpellInfo(2008) -- Ancestral Spirit
end

------------------------------------------------------------------------
--	Utilities
--

local function commSend(contents, distribution, target)
	if not (oRA and oRA:HasModule("ParticipantPassive") and oRA:IsModuleActive("ParticipantPassive") or CT_RA_Stats) then
		SendAddonMessage("CTRA", contents, distribution or (inBattlegroundOrArena and "BATTLEGROUND" or "RAID"), target)
	end
end

------------------------------------------------------------------------
--	Event Handlers
--

function lib.eventFrame:UNIT_SPELLCAST_SENT(unit, _, _, targetName)
	sentTargetName = targetName:match("^([^%-]+)")
end

function lib.eventFrame:UNIT_SPELLCAST_START(unit, spellName)
	if unit ~= "player" then return end
	if spellName ~= resSpell and spellName ~= combatResSpell then return end

	isCasting = true

	local target = sentTargetName
	if not sentTargetName or sentTargetName == UNKNOWN then
		target = mouseDownTarget
	end

	if not target and GameTooltipTextLeft1:IsVisible() then
		-- check tooltip in case of mouseover casting on a corpse whose spirit has been released
		target = GameTooltipTextLeft1:GetText():match(L.CORPSE_OF)
	end

	if not target then
		-- still nothing :(
		return
	end

	local endTime = select(6, UnitCastingInfo(unit)) or (GetTime() + 10) * 1000
	endTime = endTime / 1000

	activeRes[playerName] = target

	lib.Callbacks:Fire("ResComm_ResStart", playerName, endTime, target)
	commSend(("RES %s"):format(target))
end

function lib.eventFrame:CHAT_MSG_ADDON(prefix, msg, distribution, sender)
	if prefix ~= "CTRA" then return end
	if sender == playerName then return end
	sender = sender:match("^([^%-]+)")

	local target
	for cmd, targetName in msg:gmatch("(%a+)%s?([^#]*)") do
		-- A lot of garbage can come in, make absolutely sure we have a decent message
		if cmd == "RES" and targetName ~= "" and targetName ~= UNKNOWN then

			local endTime = select(6, UnitCastingInfo(sender)) or (GetTime() + 10)*1000

			if endTime and targetName then
				endTime = endTime / 1000
				activeRes[sender] = targetName
				lib.Callbacks:Fire("ResComm_ResStart", sender, endTime, targetName)
			end
		elseif cmd == "RESNO" or cmd == "RESYES" then
			if activeRes[sender] then
				target = activeRes[sender]
				activeRes[sender] = nil
			end
			lib.Callbacks:Fire("ResComm_ResEnd", sender, target, cmd == "RESYES" and true)
		elseif cmd == "RESSED" then
			if activeRes[sender] then
				target = activeRes[sender]
				activeRes[sender] = nil
			end
			lib.Callbacks:Fire("ResComm_Ressed", sender)
		elseif cmd == "CANRES" then
			lib.Callbacks:Fire("ResComm_CanRes", sender, targetName, targetName and soulstoneText[targetName]) -- send token and text with callback
		elseif cmd == "NORESSED" then
			lib.Callbacks:Fire("ResComm_ResExpired", sender)
		end
	end
end

function lib.eventFrame:UNIT_SPELLCAST_SUCCEEDED(unit, spellName)
	if unit ~= "player" or not isCasting then return end

	local target = activeRes[playerName]
	if activeRes[playerName] then
		activeRes[playerName] = nil
	end

	lib.Callbacks:Fire("ResComm_ResEnd", playerName, target, true)
	commSend("RESYES")
	isCasting = false
end

function lib.eventFrame:UNIT_SPELLCAST_STOP(unit, spellName)
	if unit ~= "player" or not isCasting then return end

	local target = activeRes[playerName]
	if activeRes[playerName] then
		activeRes[playerName] = nil
	end

	lib.Callbacks:Fire("ResComm_ResEnd", playerName, target, false)
	commSend("RESNO")
	isCasting = false
end

lib.eventFrame.UNIT_SPELLCAST_FAILED = lib.eventFrame.UNIT_SPELLCAST_STOP
lib.eventFrame.UNIT_SPELLCAST_INTERRUPTED = lib.eventFrame.UNIT_SPELLCAST_STOP

function lib.eventFrame:PLAYER_ENTERING_WORLD()
	local it = select(2, IsInInstance())
	inBattlegroundOrArena = (it == "pvp") or (it == "arena")
end

------------------------------------------------------------------------
-- Public Functions

--[[
	IsUnitBeingRessed(unit)
	Checks if a unit is being ressurected at that moment.
	Arguments:
		unit - string; name of a friendly player
	Returns:
		isBeingRessed - boolean; true when unit is being ressed, false otherwise
		resser - string; name of the player ressing the unit
]]--

function lib:IsUnitBeingRessed(unit)
	for resser, ressed in pairs(activeRes) do
		if unit == ressed then
			return true, resser
		end
	end
	return false
end

------------------------------------------------------------------------
-- Hooks
--

-- Credits to Ora2
function lib:worldFrameOnMouseDown()
	if GameTooltipTextLeft1:IsVisible() then
		mouseDownTarget = GameTooltipTextLeft1:GetText():match(L.CORPSE_OF)
	end
end

function lib:popupFuncRessed()
	lib.Callbacks:Fire("ResComm_Ressed", playerName)
	commSend("RESSED")
end

function lib:popupFuncCanRes()
	local kind = HasSoulstone()
	if not kind then return end

	lib.Callbacks:Fire("ResComm_CanRes", playerName)
	commSend("CANRES")

	local token = soulstoneToken[kind]
	if token then
		-- send a second comm with a token representing the type of self-res available
		commSend("CANRES " .. token)
	end
end

function lib:popupFuncExpired()
	lib.Callbacks:Fire("ResComm_ResExpired", playerName)
	commSend("NORESSED")
end

function lib:noop()
end

------------------------------------------------------------------------
-- Register events and hooks
--

function lib:start()
	lib.eventFrame:RegisterEvent("CHAT_MSG_ADDON")

	if isResser then
		lib.eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
		lib.eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		lib.eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
		lib.eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
		lib.eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
		lib.eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end

	lib.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

	worldFrameHook = WorldFrame:GetScript("OnMouseDown")
	if not worldFrameHook then
		worldFrameHook = lib.noop
	end

	WorldFrame:SetScript("OnMouseDown", function(...)
		lib:worldFrameOnMouseDown()
		worldFrameHook(...)
	end)

	local res = StaticPopupDialogs["RESURRECT"].OnShow
	StaticPopupDialogs["RESURRECT"].OnShow = function(...)
		lib:popupFuncRessed()
		res(...)
	end

	local resNoSick = StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnShow
	StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnShow = function(...)
		lib:popupFuncRessed()
		resNoSick(...)
	end

	local resNoTimer = StaticPopupDialogs["RESURRECT_NO_TIMER"].OnShow
	StaticPopupDialogs["RESURRECT_NO_TIMER"].OnShow = function(...)
		lib:popupFuncRessed()
		resNoTimer(...)
	end

	local death = StaticPopupDialogs["DEATH"].OnShow
	StaticPopupDialogs["DEATH"].OnShow = function(...)
		lib:popupFuncCanRes()
		death(...)
	end

	if not StaticPopupDialogs["RESURRECT"].OnCancel then
		StaticPopupDialogs["RESURRECT"].OnCancel = function() lib:popupFuncExpired() end
	else
		local resurrect = StaticPopupDialogs["RESURRECT"].OnCancel
		StaticPopupDialogs["RESURRECT"].OnCancel = function(...)
			lib:popupFuncExpired()
			resurrect(...)
		end
	end

	if not StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnCancel then
		StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnCancel = function() lib:popupFuncExpired() end
	else
		local resNoSick = StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnCancel
		StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnCancel = function(...)
			lib:popupFuncExpired()
			resNoSick(...)
		end
	end

	if not StaticPopupDialogs["RESURRECT_NO_TIMER"].OnCancel then
		StaticPopupDialogs["RESURRECT_NO_TIMER"].OnCancel = function()
			if not StaticPopup_FindVisible("DEATH") then lib:popupFuncExpired() end
		end
	else
		local resNoTimer = StaticPopupDialogs["RESURRECT_NO_TIMER"].OnCancel
		StaticPopupDialogs["RESURRECT_NO_TIMER"].OnCancel = function(...)
			if not StaticPopup_FindVisible("DEATH") then lib:popupFuncExpired() end
			resNoTimer(...)
		end
	end
end

------------------------------------------------------------------------
-- Start library
--

lib.disable = function()
	lib.worldFrameOnMouseDown = lib.noop
	lib.popupFuncRessed = lib.noop
	lib.popupFuncCanRes = lib.noop
	lib.popupFuncExpired = lib.noop
	lib.eventFrame:UnregisterAllEvents()
end
lib:start()