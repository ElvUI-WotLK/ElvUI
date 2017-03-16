local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local _G = _G;
local floor = math.floor;
local format = string.format;

local GetNumPartyMembers = GetNumPartyMembers;
local GetPVPTimer = GetPVPTimer;
local GetThreatStatusColor = GetThreatStatusColor;
local GetTime = GetTime;
local GetUnitSpeed = GetUnitSpeed;
local UnitClass = UnitClass;
local UnitClassification = UnitClassification;
local UnitDetailedThreatSituation = UnitDetailedThreatSituation;
local UnitGUID = UnitGUID;
local UnitHealth = UnitHealth;
local UnitHealthMax = UnitHealthMax;
local UnitIsAFK = UnitIsAFK;
local UnitIsConnected = UnitIsConnected;
local UnitIsDND = UnitIsDND;
local UnitIsDead = UnitIsDead;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsGhost = UnitIsGhost;
local UnitIsPVP = UnitIsPVP;
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll;
local UnitIsPlayer = UnitIsPlayer;
local UnitLevel = UnitLevel;
local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local UnitPowerType = UnitPowerType;
local UnitReaction = UnitReaction;
local DEFAULT_AFK_MESSAGE = DEFAULT_AFK_MESSAGE;
local PVP = PVP;
local SPELL_POWER_MANA = SPELL_POWER_MANA

------------------------------------------------------------------------
--	Tags
------------------------------------------------------------------------

ElvUF.Tags.Events["afk"] = "PLAYER_FLAGS_CHANGED"
ElvUF.Tags.Methods["afk"] = function(unit)
	local isAFK = UnitIsAFK(unit)
	if isAFK then
		return ("|cffFFFFFF[|r|cffFF0000%s|r|cFFFFFFFF]|r"):format(DEFAULT_AFK_MESSAGE)
	else
		return ""
	end
end

ElvUF.Tags.Events["healthcolor"] = "UNIT_HEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
ElvUF.Tags.Methods["healthcolor"] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return Hex(0.84, 0.75, 0.65)
	else
		local r, g, b = ElvUF.ColorGradient(UnitHealth(unit), UnitHealthMax(unit), 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return Hex(r, g, b)
	end
end

ElvUF.Tags.Events["health:current"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
ElvUF.Tags.Methods["health:current"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
	if (status) then
		return status
	else
		return E:GetFormattedText("CURRENT", UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events["health:deficit"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
ElvUF.Tags.Methods["health:deficit"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

	if (status) then
		return status
	else
		return E:GetFormattedText("DEFICIT", UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events["health:current-percent"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
ElvUF.Tags.Methods["health:current-percent"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

	if (status) then
		return status
	else
		return E:GetFormattedText("CURRENT_PERCENT", UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events["health:current-max"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
ElvUF.Tags.Methods["health:current-max"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

	if (status) then
		return status
	else
		return E:GetFormattedText("CURRENT_MAX", UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events["health:current-max-percent"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
ElvUF.Tags.Methods["health:current-max-percent"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

	if (status) then
		return status
	else
		return E:GetFormattedText("CURRENT_MAX_PERCENT", UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events["health:max"] = "UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:max"] = function(unit)
	local max = UnitHealthMax(unit)

	return E:GetFormattedText("CURRENT", max, max)
end

ElvUF.Tags.Events["health:percent"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED"
ElvUF.Tags.Methods["health:percent"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

	if (status) then
		return status
	else
		return E:GetFormattedText("PERCENT", UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.Tags.Events["health:current-nostatus"] = "UNIT_HEALTH UNIT_MAXHEALTH";
ElvUF.Tags.Methods["health:current-nostatus"] = function(unit)
	return E:GetFormattedText("CURRENT", UnitHealth(unit), UnitHealthMax(unit));
end

ElvUF.Tags.Events["health:deficit-nostatus"] = "UNIT_HEALTH UNIT_MAXHEALTH";
ElvUF.Tags.Methods["health:deficit-nostatus"] = function(unit)
	return E:GetFormattedText("DEFICIT", UnitHealth(unit), UnitHealthMax(unit));
end

ElvUF.Tags.Events["health:current-percent-nostatus"] = "UNIT_HEALTH UNIT_MAXHEALTH";
ElvUF.Tags.Methods["health:current-percent-nostatus"] = function(unit)
	return E:GetFormattedText("CURRENT_PERCENT", UnitHealth(unit), UnitHealthMax(unit));
end

ElvUF.Tags.Events["health:current-max-nostatus"] = "UNIT_HEALTH UNIT_MAXHEALTH";
ElvUF.Tags.Methods["health:current-max-nostatus"] = function(unit)
	return E:GetFormattedText("CURRENT_MAX", UnitHealth(unit), UnitHealthMax(unit));
end

ElvUF.Tags.Events["health:current-max-percent-nostatus"] = "UNIT_HEALTH UNIT_MAXHEALTH";
ElvUF.Tags.Methods["health:current-max-percent-nostatus"] = function(unit)
	return E:GetFormattedText("CURRENT_MAX_PERCENT", UnitHealth(unit), UnitHealthMax(unit));
end

ElvUF.Tags.Events["health:percent-nostatus"] = "UNIT_HEALTH UNIT_MAXHEALTH";
ElvUF.Tags.Methods["health:percent-nostatus"] = function(unit)
	return E:GetFormattedText("PERCENT", UnitHealth(unit), UnitHealthMax(unit));
end

ElvUF.Tags.Events["health:deficit-percent:name"] = "UNIT_HEALTH UNIT_MAXHEALTH";
ElvUF.Tags.Methods["health:deficit-percent:name"] = function(unit)
	local currentHealth = UnitHealth(unit)
	local deficit = UnitHealthMax(unit) - currentHealth;

	if (deficit > 0 and currentHealth > 0) then
		return _TAGS["health:percent-nostatus"](unit);
	else
		return _TAGS["name"](unit);
	end
end

ElvUF.Tags.Events["health:deficit-percent:name-long"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:deficit-percent:name-long"] = function(unit)
	local currentHealth = UnitHealth(unit)
	local deficit = UnitHealthMax(unit) - currentHealth

	if (deficit > 0 and currentHealth > 0) then
		return _TAGS["health:percent-nostatus"](unit)
	else
		return _TAGS["name:long"](unit)
	end
end

ElvUF.Tags.Events["health:deficit-percent:name-medium"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:deficit-percent:name-medium"] = function(unit)
	local currentHealth = UnitHealth(unit)
	local deficit = UnitHealthMax(unit) - currentHealth

	if (deficit > 0 and currentHealth > 0) then
		return _TAGS["health:percent-nostatus"](unit)
	else
		return _TAGS["name:medium"](unit)
	end
end

ElvUF.Tags.Events["health:deficit-percent:name-short"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:deficit-percent:name-short"] = function(unit)
	local currentHealth = UnitHealth(unit)
	local deficit = UnitHealthMax(unit) - currentHealth

	if (deficit > 0 and currentHealth > 0) then
		return _TAGS["health:percent-nostatus"](unit)
	else
		return _TAGS["name:short"](unit)
	end
end

ElvUF.Tags.Events["health:deficit-percent:name-veryshort"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:deficit-percent:name-veryshort"] = function(unit)
	local currentHealth = UnitHealth(unit)
	local deficit = UnitHealthMax(unit) - currentHealth

	if (deficit > 0 and currentHealth > 0) then
		return _TAGS["health:percent-nostatus"](unit)
	else
		return _TAGS["name:veryshort"](unit)
	end
end

ElvUF.Tags.Events["powercolor"] = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods["powercolor"] = function(unit)
	local _, pToken, altR, altG, altB = UnitPowerType(unit)
	local color = ElvUF["colors"].power[pToken]
	if color then
		return Hex(color[1], color[2], color[3])
	else
		return Hex(altR, altG, altB)
	end
end

ElvUF.Tags.Events["power:current"] = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods["power:current"] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and " " or E:GetFormattedText("CURRENT", min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events["power:current-max"] = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods["power:current-max"] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and " " or E:GetFormattedText("CURRENT_MAX", min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events["power:current-percent"] = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods["power:current-percent"] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and " " or E:GetFormattedText("CURRENT_PERCENT", min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events["power:current-max-percent"] = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods["power:current-max-percent"] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and " " or E:GetFormattedText("CURRENT_MAX_PERCENT", min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events["power:percent"] = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods["power:percent"] = function(unit)
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and " " or E:GetFormattedText("PERCENT", min, UnitPowerMax(unit, pType))
end

ElvUF.Tags.Events["power:deficit"] = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER"
ElvUF.Tags.Methods["power:deficit"] = function(unit)
	local pType = UnitPowerType(unit)

	return E:GetFormattedText("DEFICIT", UnitPower(unit, pType), UnitPowerMax(unit, pType), r, g, b)
end

ElvUF.Tags.Events["power:max"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_MAXRUNIC_POWER"
ElvUF.Tags.Methods["power:max"] = function(unit)
	local max = UnitPowerMax(unit, UnitPowerType(unit))

	return E:GetFormattedText("CURRENT", max, max)
end

ElvUF.Tags.Methods["manacolor"] = function()
	local altR, altG, altB = PowerBarColor["MANA"].r, PowerBarColor["MANA"].g, PowerBarColor["MANA"].b
	local color = ElvUF["colors"].power["MANA"]
	if color then
		return Hex(color[1], color[2], color[3])
	else
		return Hex(altR, altG, altB)
	end
end

ElvUF.Tags.Events["mana:current"] = "UNIT_MANA UNIT_MAXMANA"
ElvUF.Tags.Methods["mana:current"] = function(unit)
	local min = UnitPower(unit, SPELL_POWER_MANA)

	return min == 0 and " " or E:GetFormattedText("CURRENT", min, UnitPowerMax(unit, SPELL_POWER_MANA))
end

ElvUF.Tags.Events["mana:current-max"] = "UNIT_MANA UNIT_MAXMANA"
ElvUF.Tags.Methods["mana:current-max"] = function(unit)
	local min = UnitPower(unit, SPELL_POWER_MANA)

	return min == 0 and " " or E:GetFormattedText("CURRENT_MAX", min, UnitPowerMax(unit, SPELL_POWER_MANA))
end

ElvUF.Tags.Events["mana:current-percent"] = "UNIT_MANA UNIT_MAXMANA"
ElvUF.Tags.Methods["mana:current-percent"] = function(unit)
	local min = UnitPower(unit, SPELL_POWER_MANA)

	return min == 0 and " " or E:GetFormattedText("CURRENT_PERCENT", min, UnitPowerMax(unit, SPELL_POWER_MANA))
end

ElvUF.Tags.Events["mana:current-max-percent"] = "UNIT_MANA UNIT_MAXMANA"
ElvUF.Tags.Methods["mana:current-max-percent"] = function(unit)
	local min = UnitPower(unit, SPELL_POWER_MANA)

	return min == 0 and " " or E:GetFormattedText("CURRENT_MAX_PERCENT", min, UnitPowerMax(unit, SPELL_POWER_MANA))
end

ElvUF.Tags.Events["mana:percent"] = "UNIT_MANA UNIT_MAXMANA"
ElvUF.Tags.Methods["mana:percent"] = function(unit)
	local min = UnitPower(unit, SPELL_POWER_MANA)

	return min == 0 and " " or E:GetFormattedText("PERCENT", min, UnitPowerMax(unit, SPELL_POWER_MANA))
end

ElvUF.Tags.Events["mana:deficit"] = "UNIT_MANA UNIT_MAXMANA"
ElvUF.Tags.Methods["mana:deficit"] = function(unit)
	return E:GetFormattedText("DEFICIT", UnitPower(unit), UnitPowerMax(unit, SPELL_POWER_MANA))
end

ElvUF.Tags.Events["mana:max"] = "UNIT_MAXMANA"
ElvUF.Tags.Methods["mana:max"] = function(unit)
	local max = UnitPowerMax(unit, SPELL_POWER_MANA)

	return E:GetFormattedText("CURRENT", max, max)
end

ElvUF.Tags.Events["difficultycolor"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
ElvUF.Tags.Methods["difficultycolor"] = function(unit)
	local r, g, b = 0.69, 0.31, 0.31
	local level = UnitLevel(unit)
	if (level > 1) then
		local DiffColor = UnitLevel(unit) - UnitLevel("player")
		if (DiffColor >= 5) then
			r, g, b = 0.69, 0.31, 0.31
		elseif (DiffColor >= 3) then
			r, g, b = 0.71, 0.43, 0.27
		elseif (DiffColor >= -2) then
			r, g, b = 0.84, 0.75, 0.65
		elseif (-DiffColor <= GetQuestGreenRange()) then
			r, g, b = 0.33, 0.59, 0.33
		else
			r, g, b = 0.55, 0.57, 0.61
		end
	end

	return Hex(r, g, b)
end

ElvUF.Tags.Events["namecolor"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["namecolor"] = function(unit)
	local unitReaction = UnitReaction(unit, "player")
	local _, unitClass = UnitClass(unit)
	if (UnitIsPlayer(unit)) then
		local class = ElvUF.colors.class[unitClass]
		if not class then return "" end
		return Hex(class[1], class[2], class[3])
	elseif (unitReaction) then
		local reaction = ElvUF["colors"].reaction[unitReaction]
		return Hex(reaction[1], reaction[2], reaction[3])
	else
		return "|cFFC2C2C2"
	end
end

ElvUF.Tags.Events["smartlevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
ElvUF.Tags.Methods["smartlevel"] = function(unit)
	local level = UnitLevel(unit)
	if level == UnitLevel("player") then
		return ""
	elseif(level > 0) then
		return level
	else
		return "??"
	end
end

ElvUF.Tags.Events["name:veryshort"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:veryshort"] = function(unit)
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 5) or ""
end

ElvUF.Tags.Events["name:short"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:short"] = function(unit)
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 10) or ""
end

ElvUF.Tags.Events["name:medium"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:medium"] = function(unit)
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 15) or ""
end

ElvUF.Tags.Events["name:long"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:long"] = function(unit)
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 20) or ""
end

ElvUF.Tags.Events["name:veryshort:status"] = "UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_HEALTH"
ElvUF.Tags.Methods["name:veryshort:status"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
	local name = UnitName(unit)
	if (status) then
		return status
	else
		return name ~= nil and E:ShortenString(name, 5) or ""
	end
end

ElvUF.Tags.Events["name:short:status"] = "UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_HEALTH"
ElvUF.Tags.Methods["name:short:status"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
	local name = UnitName(unit)
	if (status) then
		return status
	else
		return name ~= nil and E:ShortenString(name, 10) or ""
	end
end

ElvUF.Tags.Events["name:medium:status"] = "UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_HEALTH"
ElvUF.Tags.Methods["name:medium:status"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
	local name = UnitName(unit)
	if (status) then
		return status
	else
		return name ~= nil and E:ShortenString(name, 15) or ""
	end
end

ElvUF.Tags.Events["name:long:status"] = "UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_HEALTH"
ElvUF.Tags.Methods["name:long:status"] = function(unit)
	local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
	local name = UnitName(unit)
	if (status) then
		return status
	else
		return name ~= nil and E:ShortenString(name, 20) or ""
	end
end

ElvUF.Tags.Events["threat:percent"] = "UNIT_THREAT_SITUATION_UPDATE"
ElvUF.Tags.Methods["threat:percent"] = function(unit)
	local _, _, percent = UnitDetailedThreatSituation("player", unit)
	if(percent and percent > 0) and (GetNumPartyMembers() or UnitExists("pet")) then
		return format("%.0f%%", percent)
	else
		return ""
	end
end

ElvUF.Tags.Events["threat:current"] = "UNIT_THREAT_SITUATION_UPDATE"
ElvUF.Tags.Methods["threat:current"] = function(unit)
	local _, _, percent, _, threatvalue = UnitDetailedThreatSituation("player", unit)
	if(percent and percent > 0) and (GetNumPartyMembers() or UnitExists("pet")) then
		return E:ShortValue(threatvalue)
	else
		return ""
	end
end

ElvUF.Tags.Events["threatcolor"] = "UNIT_THREAT_SITUATION_UPDATE"
ElvUF.Tags.Methods["threatcolor"] = function(unit)
	local _, status = UnitDetailedThreatSituation("player", unit)
	if (status) and (GetNumPartyMembers() > 0 or UnitExists("pet")) then
		return Hex(GetThreatStatusColor(status))
	else
		return ""
	end
end

local unitStatus = {}
ElvUF.Tags.OnUpdateThrottle["statustimer"] = 1
ElvUF.Tags.Methods["statustimer"] = function(unit)
	if not UnitIsPlayer(unit) then return; end
	local guid = UnitGUID(unit)
	if (UnitIsAFK(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "AFK" then
			unitStatus[guid] = {"AFK", GetTime()}
		end
	elseif(UnitIsDND(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "DND" then
			unitStatus[guid] = {"DND", GetTime()}
		end
	elseif(UnitIsDead(unit)) or (UnitIsGhost(unit))then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "Dead" then
			unitStatus[guid] = {"Dead", GetTime()}
		end
	elseif(not UnitIsConnected(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= "Offline" then
			unitStatus[guid] = {"Offline", GetTime()}
		end
	else
		unitStatus[guid] = nil
	end

	if unitStatus[guid] ~= nil then
		local status = unitStatus[guid][1]
		local timer = GetTime() - unitStatus[guid][2]
		local mins = floor(timer / 60)
		local secs = floor(timer - (mins * 60))
		return ("%s (%01.f:%02.f)"):format(status, mins, secs)
	else
		return ""
	end
end

ElvUF.Tags.OnUpdateThrottle["pvptimer"] = 1
ElvUF.Tags.Methods["pvptimer"] = function(unit)
	if (UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit)) then
		local timer = GetPVPTimer()

		if timer ~= 301000 and timer ~= -1 then
			local mins = floor((timer / 1000) / 60)
			local secs = floor((timer / 1000) - (mins * 60))
			return ("%s (%01.f:%02.f)"):format(PVP, mins, secs)
		else
			return PVP
		end
	else
		return ""
	end
end

local baseSpeed = 7;
local speedText = SPEED;

ElvUF.Tags.OnUpdateThrottle["speed:percent"] = 0.1;
ElvUF.Tags.Methods["speed:percent"] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit);
	local currentSpeedInPercent = (currentSpeedInYards / baseSpeed) * 100;

	return format("%s: %d%%", speedText, currentSpeedInPercent);
end

ElvUF.Tags.OnUpdateThrottle["speed:percent-moving"] = 0.1;
ElvUF.Tags.Methods["speed:percent-moving"] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit);
	local currentSpeedInPercent = currentSpeedInYards > 0 and ((currentSpeedInYards / baseSpeed) * 100);

	if(currentSpeedInPercent) then
		currentSpeedInPercent = format("%s: %d%%", speedText, currentSpeedInPercent);
	end

	return currentSpeedInPercent or "";
end

ElvUF.Tags.OnUpdateThrottle["speed:percent-raw"] = 0.1;
ElvUF.Tags.Methods["speed:percent-raw"] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit);
	local currentSpeedInPercent = (currentSpeedInYards / baseSpeed) * 100;

	return format("%d%%", currentSpeedInPercent);
end

ElvUF.Tags.OnUpdateThrottle["speed:percent-moving-raw"] = 0.1;
ElvUF.Tags.Methods["speed:percent-moving-raw"] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit);
	local currentSpeedInPercent = currentSpeedInYards > 0 and ((currentSpeedInYards / baseSpeed) * 100);

	if(currentSpeedInPercent) then
		currentSpeedInPercent = format("%d%%", currentSpeedInPercent);
	end

	return currentSpeedInPercent or "";
end

ElvUF.Tags.OnUpdateThrottle["speed:yardspersec"] = 0.1;
ElvUF.Tags.Methods["speed:yardspersec"] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit);

	return format("%s: %.1f", speedText, currentSpeedInYards);
end

ElvUF.Tags.OnUpdateThrottle["speed:yardspersec-moving"] = 0.1;
ElvUF.Tags.Methods["speed:yardspersec-moving"] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit);

	return currentSpeedInYards > 0 and format("%s: %.1f", speedText, currentSpeedInYards) or "";
end

ElvUF.Tags.OnUpdateThrottle["speed:yardspersec-raw"] = 0.1;
ElvUF.Tags.Methods["speed:yardspersec-raw"] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit);

	return format("%.1f", currentSpeedInYards);
end

ElvUF.Tags.OnUpdateThrottle["speed:yardspersec-moving-raw"] = 0.1;
ElvUF.Tags.Methods["speed:yardspersec-moving-raw"] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit);

	return currentSpeedInYards > 0 and format("%.1f", currentSpeedInYards) or "";
end

ElvUF.Tags.Events["classificationcolor"] = "UNIT_CLASSIFICATION_CHANGED";
ElvUF.Tags.Methods["classificationcolor"] = function(unit)
	local c = UnitClassification(unit);
	if(c == "rare" or c == "elite") then
		return Hex(1, 0.5, 0.25); -- Orange
	elseif(c == "rareelite" or c == "worldboss") then
		return Hex(1, 0, 0); -- Red
	end
end

ElvUF.Tags.Events["guild"] = "PLAYER_GUILD_UPDATE"
ElvUF.Tags.Methods["guild"] = function(unit)
	local guildName = GetGuildInfo(unit)

	return guildName or ""
end

ElvUF.Tags.Events["guild:brackets"] = "PLAYER_GUILD_UPDATE"
ElvUF.Tags.Methods["guild:brackets"] = function(unit)
	local guildName = GetGuildInfo(unit)

	return guildName and format("<%s>", guildName) or ""
end

ElvUF.Tags.Events["target:veryshort"] = "UNIT_TARGET"
ElvUF.Tags.Methods["target:veryshort"] = function(unit)
	local targetName = UnitName(unit.."target")
	return targetName ~= nil and E:ShortenString(targetName, 5) or ""
end

ElvUF.Tags.Events["target:short"] = "UNIT_TARGET"
ElvUF.Tags.Methods["target:short"] = function(unit)
	local targetName = UnitName(unit.."target")
	return targetName ~= nil and E:ShortenString(targetName, 10) or ""
end

ElvUF.Tags.Events["target:medium"] = "UNIT_TARGET"
ElvUF.Tags.Methods["target:medium"] = function(unit)
	local targetName = UnitName(unit.."target")
	return targetName ~= nil and E:ShortenString(targetName, 15) or ""
end

ElvUF.Tags.Events["target:long"] = "UNIT_TARGET"
ElvUF.Tags.Methods["target:long"] = function(unit)
	local targetName = UnitName(unit.."target")
	return targetName ~= nil and E:ShortenString(targetName, 20) or ""
end

ElvUF.Tags.Events["target"] = "UNIT_TARGET"
ElvUF.Tags.Methods["target"] = function(unit)
	local targetName = UnitName(unit.."target")
	return targetName or ""
end