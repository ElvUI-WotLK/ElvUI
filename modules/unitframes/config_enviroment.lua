local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames");
local _, ns = ...
local ElvUF = ns.oUF

local _G = _G;
local setmetatable, getfenv, setfenv = setmetatable, getfenv, setfenv;
local type, unpack, select, pairs = type, unpack, select, pairs;
local min, random = math.min, math.random;
local format = string.format;

local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local UnitHealth = UnitHealth;
local UnitHealthMax = UnitHealthMax;
local UnitName = UnitName;
local UnitClass = UnitClass;
local InCombatLockdown = InCombatLockdown;
local UnregisterUnitWatch = UnregisterUnitWatch;
local RegisterUnitWatch = RegisterUnitWatch;
local RegisterStateDriver = RegisterStateDriver;
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE;
local CLASS_SORT_ORDER = CLASS_SORT_ORDER;
local MAX_RAID_MEMBERS = MAX_RAID_MEMBERS;

local attributeBlacklist = {["showRaid"] = true, ["showParty"] = true, ["showSolo"] = true}
local configEnv
local originalEnvs = {}
local overrideFuncs = {}

local function createConfigEnv()
	if( configEnv ) then return end
	configEnv = setmetatable({
		UnitPower = function (unit, displayType)
			if(unit:find("target") or unit:find("focus")) then
				return UnitPower(unit, displayType);
			end

			return random(1, UnitPowerMax(unit, displayType) or 1);
		end,
		UnitHealth = function(unit)
			if(unit:find("target") or unit:find("focus")) then
				return UnitHealth(unit);
			end

			return random(1, UnitHealthMax(unit));
		end,
		UnitName = function(unit)
			if(unit:find("target") or unit:find("focus")) then
				return UnitName(unit);
			end
			if(E.CreditsList) then
				local max = #E.CreditsList;
				return E.CreditsList[random(1, max)];
			end
			return "Test Name";
		end,
		UnitClass = function(unit)
			if(unit:find("target") or unit:find("focus")) then
				return UnitClass(unit);
			end

			local classToken = CLASS_SORT_ORDER[random(1, #(CLASS_SORT_ORDER))];
			return LOCALIZED_CLASS_NAMES_MALE[classToken], classToken;
		end,
		Hex = function(r, g, b)
			if(type(r) == "table") then
				if(r.r) then r, g, b = r.r, r.g, r.b; else r, g, b = unpack(r); end
			end
			return format("|cff%02x%02x%02x", r*255, g*255, b*255);
		end,
		ColorGradient = ElvUF.ColorGradient,
	}, {
		__index = _G,
		__newindex = function(_, key, value) _G[key] = value end,
	})

	overrideFuncs["namecolor"] = ElvUF.Tags["namecolor"]
	overrideFuncs["name:veryshort"] = ElvUF.Tags["name:veryshort"]
	overrideFuncs["name:short"] = ElvUF.Tags["name:short"]
	overrideFuncs["name:medium"] = ElvUF.Tags["name:medium"]
	overrideFuncs["name:long"] = ElvUF.Tags["name:long"]

	overrideFuncs["healthcolor"] = ElvUF.Tags["healthcolor"]
	overrideFuncs["health:current"] = ElvUF.Tags["health:current"]
	overrideFuncs["health:deficit"] = ElvUF.Tags["health:deficit"]
	overrideFuncs["health:current-percent"] = ElvUF.Tags["health:current-percent"]
	overrideFuncs["health:current-max"] = ElvUF.Tags["health:current-max"]
	overrideFuncs["health:current-max-percent"] = ElvUF.Tags["health:current-max-percent"]
	overrideFuncs["health:max"] = ElvUF.Tags["health:max"]
	overrideFuncs["health:percent"] = ElvUF.Tags["health:percent"]

	overrideFuncs["powercolor"] = ElvUF.Tags["powercolor"]
	overrideFuncs["power:current"] = ElvUF.Tags["power:current"]
	overrideFuncs["power:deficit"] = ElvUF.Tags["power:deficit"]
	overrideFuncs["power:current-percent"] = ElvUF.Tags["power:current-percent"]
	overrideFuncs["power:current-max"] = ElvUF.Tags["power:current-max"]
	overrideFuncs["power:current-max-percent"] = ElvUF.Tags["power:current-max-percent"]
	overrideFuncs["power:max"] = ElvUF.Tags["power:max"]
	overrideFuncs["power:percent"] = ElvUF.Tags["power:percent"]
end

function UF:ForceShow(frame)
	if InCombatLockdown() then return; end
	if not frame.isForced then
		frame.oldUnit = frame.unit
		frame.unit = "player"
		frame.isForced = true;
		frame.oldOnUpdate = frame:GetScript("OnUpdate")
	end

	frame:SetScript("OnUpdate", nil)
	frame.forceShowAuras = true
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame, true)

	frame:Show()
	if frame:IsVisible() and frame.Update then
		frame:Update()
	end

	if(_G[frame:GetName().."Target"]) then
		self:ForceShow(_G[frame:GetName().."Target"]);
	end

	if(_G[frame:GetName().."Pet"]) then
		self:ForceShow(_G[frame:GetName().."Pet"]);
	end
end

function UF:UnforceShow(frame)
	if InCombatLockdown() then return; end
	if not frame.isForced then
		return
	end
	frame.forceShowAuras = nil
	frame.isForced = nil

	-- Ask the SecureStateDriver to show/hide the frame for us
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame)

	if frame.oldOnUpdate then
		frame:SetScript("OnUpdate", frame.oldOnUpdate)
		frame.oldOnUpdate = nil
	end

	frame.unit = frame.oldUnit or frame.unit
	-- If we're visible force an update so everything is properly in a
	-- non-config mode state
	if frame:IsVisible() and frame.Update then
		frame:Update()
	end

	if(_G[frame:GetName().."Target"]) then
		self:UnforceShow(_G[frame:GetName().."Target"])
	end

	if(_G[frame:GetName().."Pet"]) then
		self:UnforceShow(_G[frame:GetName().."Pet"])
	end
end

function UF:ShowChildUnits(header, ...)
	header.isForced = true

	for i=1, select("#", ...) do
		local frame = select(i, ...)
		frame:RegisterForClicks(nil)
		frame:SetID(i)
		frame.TargetGlow:SetAlpha(0)
		self:ForceShow(frame)
	end
end

function UF:UnshowChildUnits(header, ...)
	header.isForced = nil

	for i=1, select("#", ...) do
		local frame = select(i, ...)
		frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp")
		frame.TargetGlow:SetAlpha(1)
		self:UnforceShow(frame)
	end
end

local function OnAttributeChanged(self)
	if not self:GetParent().forceShow and not self.forceShow then return; end
	if not self:IsShown() then return end

	local db = self.db or self:GetParent().db
	local maxUnits = MAX_RAID_MEMBERS

	local startingIndex = db.raidWideSorting and -(min(db.numGroups * (db.groupsPerRowCol * 5), maxUnits) + 1) or -4
	if self:GetAttribute("startingIndex") ~= startingIndex then
		self:SetAttribute("startingIndex", startingIndex)
		UF:ShowChildUnits(self, self:GetChildren())
	end
end

function UF:HeaderConfig(header, configMode)
	if InCombatLockdown() then return; end

	createConfigEnv()
	header.forceShow = configMode
	header.forceShowAuras = configMode
	header.isForced = configMode

	if configMode then
		for _, func in pairs(overrideFuncs) do
			if type(func) == "function" then
				if not originalEnvs[func] then
					originalEnvs[func] = getfenv(func)
					setfenv(func, configEnv)
				end
			end
		end

		RegisterStateDriver(header, "visibility", "show")
	else
		for func, env in pairs(originalEnvs) do
			setfenv(func, env)
			originalEnvs[func] = nil
		end

		RegisterStateDriver(header, "visibility", header.db.visibility)

		if(header:GetScript("OnEvent")) then
			header:GetScript("OnEvent")(header, "PLAYER_ENTERING_WORLD");
		end
	end

	for i=1, #header.groups do
		local group = header.groups[i]

		if group:IsShown() then
			group.forceShow = header.forceShow
			group.forceShowAuras = header.forceShowAuras
			group:HookScript("OnAttributeChanged", OnAttributeChanged)
			if configMode then
				for key in pairs(attributeBlacklist) do
					group:SetAttribute(key, nil)
				end

				OnAttributeChanged(group)


				group:Update()
			else
				for key in pairs(attributeBlacklist) do
					group:SetAttribute(key, true)
				end

				UF:UnshowChildUnits(group, group:GetChildren())
				group:SetAttribute("startingIndex", 1)

				group:Update()
			end
		end
	end

	UF["headerFunctions"][header.groupName]:AdjustVisibility(header);
end

function UF:PLAYER_REGEN_DISABLED()
	for _, header in pairs(UF["headers"]) do
		if header.forceShow then
			self:HeaderConfig(header)
		end
	end

	for _, unit in pairs(UF["units"]) do
		local frame = self[unit]
		if frame and frame.forceShow then
			self:UnforceShow(frame)
		end
	end

	for i=1, 5 do
		if self["arena"..i] and self["arena"..i].isForced then
			self:UnforceShow(self["arena"..i])
		end
	end

	for i=1, 4 do
		if self["boss"..i] and self["boss"..i].isForced then
			self:UnforceShow(self["boss"..i])
		end
	end

	for i=1, 4 do
		if self["party"..i] and self["party"..i].isForced then
			self:UnforceShow(self["party"..i])
		end
	end
end

UF:RegisterEvent("PLAYER_REGEN_DISABLED")