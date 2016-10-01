--[[
-- Credits: Vika, Cladhaire, Tekkub
]]

local parent, ns = ...
local oUF = ns.oUF

local _G = _G
local unpack = unpack
local format = string.format
local tinsert, tremove = table.insert, table.remove

local UnitHealth = UnitHealth
local UnitPower = UnitPower
local UnitHealthMax = UnitHealthMax
local UnitPowerMax = UnitPowerMax
local UnitClass = UnitClass
local UnitFactionGroup = UnitFactionGroup
local UnitRace = UnitRace

local _PATTERN = '%[..-%]+'

local _ENV = {
	Hex = function(r, g, b)
		if type(r) == "table" then
			if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
	end,
	ColorGradient = oUF.ColorGradient,
}
local _PROXY = setmetatable(_ENV, {__index = _G})

local tagStrings = {
	["creature"] = [[function(u)
		return UnitCreatureFamily(u) or UnitCreatureType(u)
	end]],

	["dead"] = [[function(u)
		if(UnitIsDead(u)) then
			return 'Dead'
		elseif(UnitIsGhost(u)) then
			return 'Ghost'
		end
	end]],

	["difficulty"] = [[function(u)
		if UnitCanAttack("player", u) then
			local l = UnitLevel(u)
			return Hex(GetQuestDifficultyColor((l > 0) and l or 99))
		end
	end]],

	["leader"] = [[function(u)
		if(UnitIsPartyLeader(u)) then
			return 'L'
		end
	end]],

	["leaderlong"]  = [[function(u)
		if(UnitIsPartyLeader(u)) then
			return 'Leader'
		end
	end]],

	["level"] = [[function(u)
		local l = UnitLevel(u)
		if(l > 0) then
			return l
		else
			return '??'
		end
	end]],

	["missinghp"] = [[function(u)
		local current = UnitHealthMax(u) - UnitHealth(u)
		if(current > 0) then
			return current
		end
	end]],

	["missingpp"] = [[function(u)
		local current = UnitPowerMax(u) - UnitPower(u)
		if(current > 0) then
			return current
		end
	end]],

	["name"] = [[function(u, r)
		return UnitName(r or u)
	end]],

	["offline"] = [[function(u)
		if(not UnitIsConnected(u)) then
			return 'Offline'
		end
	end]],

	["perhp"] = [[function(u)
		local m = UnitHealthMax(u)
		if(m == 0) then
			return 0
		else
			return math.floor(UnitHealth(u)/m*100+.5)
		end
	end]],

	["perpp"] = [[function(u)
		local m = UnitPowerMax(u)
		if(m == 0) then
			return 0
		else
			return math.floor(UnitPower(u)/m*100+.5)
		end
	end]],

	["manapp"] = [[function(u)
		local m = UnitPowerMax(u, 0);
		if(m == 0) then
			return 0
		else
			return math.floor(UnitPower(u, 0)/m*100+.5)
		end
	end]],

	["plus"] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'elite' or c == 'rareelite') then
			return '+'
		end
	end]],

	["pvp"] = [[function(u)
		if(UnitIsPVP(u)) then
			return 'PvP'
		end
	end]],

	["raidcolor"] = [[function(u)
		local _, x = UnitClass(u)
		if(x) then
			return Hex(_COLORS.class[x])
		end
	end]],

	["rare"] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'rare' or c == 'rareelite') then
			return 'Rare'
		end
	end]],

	["resting"] = [[function(u)
		if(u == 'player' and IsResting()) then
			return 'zzz'
		end
	end]],

	["sex"] = [[function(u)
		local s = UnitSex(u)
		if(s == 2) then
			return 'Male'
		elseif(s == 3) then
			return 'Female'
		end
	end]],

	["smartclass"] = [[function(u)
		if(UnitIsPlayer(u)) then
			return _TAGS['class'](u)
		end

		return _TAGS['creature'](u)
	end]],

	["status"] = [[function(u)
		if(UnitIsDead(u)) then
			return 'Dead'
		elseif(UnitIsGhost(u)) then
			return 'Ghost'
		elseif(not UnitIsConnected(u)) then
			return 'Offline'
		else
			return _TAGS['resting'](u)
		end
	end]],

	["threat"] = [[function(u)
		local s = UnitThreatSituation(u)
		if(s == 1) then
			return '++'
		elseif(s == 2) then
			return '--'
		elseif(s == 3) then
			return 'Aggro'
		end
	end]],

	["threatcolor"] = [[function(u)
		return Hex(GetThreatStatusColor(UnitThreatSituation(u)))
	end]],

	["cpoints"] = [[function(u)
		local cp
		if(UnitExists'vehicle') then
			cp = GetComboPoints('vehicle', 'target')
		else
			cp = GetComboPoints('player', 'target')
		end

		if(cp > 0) then
			return cp
		end
	end]],

	['smartlevel'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'worldboss') then
			return 'Boss'
		else
			local plus = _TAGS['plus'](u)
			local level = _TAGS['level'](u)
			if(plus) then
				return level .. plus
			else
				return level
			end
		end
	end]],

	["classification"] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'rare') then
			return 'Rare'
		elseif(c == 'eliterare') then
			return 'Rare Elite'
		elseif(c == 'elite') then
			return 'Elite'
		elseif(c == 'worldboss') then
			return 'Boss'
		end
	end]],

	["shortclassification"] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'rare') then
			return 'R'
		elseif(c == 'eliterare') then
			return 'R+'
		elseif(c == 'elite') then
			return '+'
		elseif(c == 'worldboss') then
			return 'B'
		end
	end]],

	["group"] = [[function(unit)
		local name, server = UnitName(unit)
		if(server and server ~= "") then
			name = string.format("%s-%s", name, server)
		end

		for i=1, GetNumRaidMembers() do
			local raidName, _, group = GetRaidRosterInfo(i)
			if( raidName == name ) then
				return group
			end
		end
	end]],

	["defict:name"] = [[function(u)
		local missinghp = _TAGS['missinghp'](u)
		if(missinghp) then
			return '-' .. missinghp
		else
			return _TAGS['name'](u)
		end
	end]],

	['happiness'] = [[function(u)
		if(UnitIsUnit(u, 'pet')) then
			local happiness = GetPetHappiness()
			if(happiness == 1) then
				return ":<"
			elseif(happiness == 2) then
				return ":|"
			elseif(happiness == 3) then
				return ":D"
			end
		end
	end]],
}

local tags = setmetatable(
{
	curhp = UnitHealth,
	curpp = UnitPower,
	maxhp = UnitHealthMax,
	maxpp = UnitPowerMax,
	class = UnitClass,
	faction = UnitFactionGroup,
	race = UnitRace,
},

{
	__index = function(self, key)
		local tagFunc = tagStrings[key]
		if(tagFunc) then
			local func, err = loadstring('return ' .. tagFunc)
			if(func) then
				func = func()

				-- Want to trigger __newindex, so no rawset.
				self[key] = func
				tagStrings[key] = nil

				return func
			else
				error(err, 3)
			end
		end
	end,
	__newindex = function(self, key, val)
		if(type(val) == 'string') then
			tagStrings[key] = val
		elseif(type(val) == 'function') then
			-- So we don't clash with any custom envs.
			if(getfenv(val) == _G) then
				setfenv(val, _PROXY)
			end

			rawset(self, key, val)
		end
	end,
})

_ENV._TAGS = tags

local onUpdateDelay = {}
local tagEvents = {
	["curhp"]               = "UNIT_HEALTH",
	["curpp"]               = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER",
	["dead"]                = "UNIT_HEALTH",
	["leader"]              = "PARTY_LEADER_CHANGED",
	["leaderlong"]          = "PARTY_LEADER_CHANGED",
	["level"]               = "UNIT_LEVEL PLAYER_LEVEL_UP",
	["maxhp"]               = "UNIT_MAXHEALTH",
	["maxpp"]               = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_MAXRUNIC_POWER",
	["missinghp"]           = "UNIT_HEALTH UNIT_MAXHEALTH",
	["missingpp"]           = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER",
	["name"]                = "UNIT_NAME_UPDATE",
	["offline"]             = "UNIT_HEALTH",
	["perhp"]               = "UNIT_HEALTH UNIT_MAXHEALTH",
	["perpp"]               = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER",
	["manapp"]              = "UNIT_MANA UNIT_MAXMANA",
	["pvp"]                 = "UNIT_FACTION",
	["resting"]             = "PLAYER_UPDATE_RESTING",
	["status"]              = "UNIT_HEALTH PLAYER_UPDATE_RESTING",
	["smartlevel"]          = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED",
	["threat"]              = "UNIT_THREAT_SITUATION_UPDATE",
	["threatcolor"]         = "UNIT_THREAT_SITUATION_UPDATE",
	['cpoints']             = 'UNIT_COMBO_POINTS PLAYER_TARGET_CHANGED',
	['rare']                = 'UNIT_CLASSIFICATION_CHANGED',
	['classification']      = 'UNIT_CLASSIFICATION_CHANGED',
	['shortclassification'] = 'UNIT_CLASSIFICATION_CHANGED',
	["group"]               = "RAID_ROSTER_UPDATE",
	['happiness']           = 'UNIT_HAPPINESS',
}

local unitlessEvents = {
	PLAYER_LEVEL_UP = true,
	PLAYER_UPDATE_RESTING = true,
	PLAYER_TARGET_CHANGED = true,

	PARTY_LEADER_CHANGED = true,

	RAID_ROSTER_UPDATE = true,

	UNIT_COMBO_POINTS = true
}

local events = {}
local frame = CreateFrame"Frame"
frame:SetScript('OnEvent', function(_, event, unit)
	local strings = events[event]
	if(strings) then
		for k, fontstring in next, strings do
			if(fontstring:IsVisible() and (unitlessEvents[event] or fontstring.parent.unit == unit)) then
				fontstring:UpdateTag()
			end
		end
	end
end)

local OnUpdates = {}
local eventlessUnits = {}

local createOnUpdate = function(timer)
	local OnUpdate = OnUpdates[timer]

	if(not OnUpdate) then
		local total = timer
		local frame = CreateFrame'Frame'
		local strings = eventlessUnits[timer]

		frame:SetScript('OnUpdate', function(_, elapsed)
			if(total >= timer) then
				for k, fs in next, strings do
					if(fs.parent:IsShown() and UnitExists(fs.parent.unit)) then
						fs:UpdateTag()
					end
				end

				total = 0
			end

			total = total + elapsed
		end)

		OnUpdates[timer] = frame
	end
end

local OnShow = function(self)
	for _, fs in next, self.__tags do
		fs:UpdateTag()
	end
end

local getTagName = function(tag)
	local s = (tag:match('>+()') or 2)
	local e = tag:match('.*()<+')
	e = (e and e - 1) or -2

	return tag:sub(s, e), s, e
end

local RegisterEvent = function(fontstr, event)
	if(not events[event]) then events[event] = {} end

	frame:RegisterEvent(event)
	tinsert(events[event], fontstr)
end

local RegisterEvents = function(fontstr, tagstr)
	for tag in tagstr:gmatch(_PATTERN) do
		tag = getTagName(tag)
		local tagevents = tagEvents[tag]
		if(tagevents) then
			for event in tagevents:gmatch'%S+' do
				RegisterEvent(fontstr, event)
			end
		end
	end
end

local UnregisterEvents = function(fontstr)
	for event, data in pairs(events) do
		for k, tagfsstr in pairs(data) do
			if(tagfsstr == fontstr) then
				if(#data == 1) then
					frame:UnregisterEvent(event)
				end

				tremove(data, k)
			end
		end
	end
end

local OnEnter = function(self)
	for _, fs in pairs(self.__mousetags) do
		fs:SetAlpha(1)
	end
end

local OnLeave = function(self)
	for _, fs in pairs(self.__mousetags) do
		fs:SetAlpha(0)
	end
end

local tagPool = {}
local funcPool = {}
local tmp = {}
local escapeSequences = {
	["||c"] = "|c",
	["||r"] = "|r",
	["||T"] = "|T",
	["||t"] = "|t",
}

local Tag = function(self, fs, tagstr)
	if(not fs or not tagstr) then return end

	if(not self.__tags) then
		self.__tags = {}
		self.__mousetags = {}
		tinsert(self.__elements, OnShow)
	else
		-- Since people ignore everything that's good practice - unregister the tag
		-- if it already exists.
		for _, tag in pairs(self.__tags) do
			if(fs == tag) then
				-- We don't need to remove it from the __tags table as Untag handles
				-- that for us.
				self:Untag(fs)
			end
		end
	end

	fs.parent = self

	for escapeSequence, replacement in pairs(escapeSequences) do
		while tagstr:find(escapeSequence) do
			tagstr = tagstr:gsub(escapeSequence, replacement)
		end
	end

	if tagstr:find('%[mouseover%]') then
		tinsert(self.__mousetags, fs)
		fs:SetAlpha(0)
		if not self.__HookFunc then
			self:HookScript('OnEnter', OnEnter)
			self:HookScript('OnLeave', OnLeave)
			self.__HookFunc = true;
		end
		tagstr = tagstr:gsub('%[mouseover%]', '')
	else
		for index, fontString in pairs(self.__mousetags) do
			if fontString == fs then
				self.__mousetags[index] = nil;
				fs:SetAlpha(1)
			end
		end
	end

	local containsOnUpdate
	for tag in tagstr:gmatch(_PATTERN) do
		if not tagEvents[tag:sub(2, -2)] then
			containsOnUpdate = onUpdateDelay[tag:sub(2, -2)] or 0.15;
		end
	end

	local func = tagPool[tagstr]
	if(not func) then
		local format = tagstr:gsub('%%', '%%%%'):gsub(_PATTERN, '%%s')
		local args = {}

		for bracket in tagstr:gmatch(_PATTERN) do
			local tagFunc = funcPool[bracket] or tags[bracket:sub(2, -2)]
			if(not tagFunc) then
				local tagName, s, e = getTagName(bracket)

				local tag = tags[tagName]
				if(tag) then
					s = s - 2
					e = e + 2

					if(s ~= 0 and e ~= 0) then
						local pre = bracket:sub(2, s)
						local ap = bracket:sub(e, -2)

						tagFunc = function(u,r)
							local str = tag(u,r)
							if(str) then
								return pre..str..ap
							end
						end
					elseif(s ~= 0) then
						local pre = bracket:sub(2, s)

						tagFunc = function(u,r)
							local str = tag(u,r)
							if(str) then
								return pre..str
							end
						end
					elseif(e ~= 0) then
						local ap = bracket:sub(e, -2)

						tagFunc = function(u,r)
							local str = tag(u,r)
							if(str) then
								return str..ap
							end
						end
					end

					funcPool[bracket] = tagFunc
				end
			end

			if(tagFunc) then
				tinsert(args, tagFunc)
			else
				return error(('Attempted to use invalid tag %s.'):format(bracket), 3)
			end
		end

		func = function(self)
			local unit = self.parent.unit
			local __unit = self.parent.realUnit

			_ENV._COLORS = self.parent.colors
			for i, func in next, args do
				tmp[i] = func(unit, __unit) or ''
			end

			self:SetFormattedText(format, unpack(tmp))
		end

		tagPool[tagstr] = func
	end
	fs.UpdateTag = func

	local unit = self.unit
	if((unit and unit:match'%w+target') or fs.frequentUpdates) or containsOnUpdate then
		local timer
		if(type(fs.frequentUpdates) == 'number') then
			timer = fs.frequentUpdates
		elseif containsOnUpdate then
			timer = containsOnUpdate
		else
			timer = .1
		end

		if(not eventlessUnits[timer]) then eventlessUnits[timer] = {} end
		tinsert(eventlessUnits[timer], fs)

		createOnUpdate(timer)
	else
		RegisterEvents(fs, tagstr)
	end

	tinsert(self.__tags, fs)
end

local Untag = function(self, fs)
	if(not fs) then return end

	UnregisterEvents(fs)
	for _, timers in next, eventlessUnits do
		for k, fontstr in next, timers do
			if(fs == fontstr) then
				tremove(timers, k)
			end
		end
	end

	for k, fontstr in next, self.__tags do
		if(fontstr == fs) then
			tremove(self.__tags, k)
		end
	end

	fs.UpdateTag = nil
end

oUF.Tags = tags
oUF.TagEvents = tagEvents
oUF.UnitlessTagEvents = unitlessEvents
oUF.OnUpdateThrottle = onUpdateDelay,

oUF:RegisterMetaFunction('Tag', Tag)
oUF:RegisterMetaFunction('Untag', Untag)
