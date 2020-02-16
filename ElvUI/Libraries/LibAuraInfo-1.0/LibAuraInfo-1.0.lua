--[[
Name: LibAuraInfo-1.0
Author(s): Cyprias (cyprias@gmail.com)
Documentation: http://www.wowace.com/addons/libaurainfo-1-0/
SVN: svn://svn.wowace.com/wow/libaurainfo-1-0/mainline/trunk
Description: Database of spellID's duration and debuff type.
Dependencies: LibStub
]]

local MAJOR, MINOR = "LibAuraInfo-1.0-ElvUI", 18
if not LibStub then error(MAJOR .. " requires LibStub") return end

local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
if not lib.callbacks then error(MAJOR .. " requires CallbackHandler-1.0") return end

local pairs = pairs
local select = select
local tonumber = tonumber
local band = bit.band
local floor = math.floor
local sub = string.sub
local tinsert, tremove = table.insert, table.remove

local UnitAura = UnitAura
local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists
local UnitName = UnitName
local UnitGUID = UnitGUID
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local GetTime = GetTime
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER

lib.confirmedDur = {}

lib.GUIDBlackList = {}

lib.GUIDDurations = {}

lib.GUIDData_name = {}
lib.GUIDData_flags = {}

--Save debuffType as a number, then return as a string when requested.
lib.debuffTypes = {
	Magic = 1,
	Disease = 2,
	Poison = 3,
	Curse = 4,
}
for name, id in pairs(lib.debuffTypes) do
	lib.debuffTypes[id] = name
end

lib.trackAuras = true
lib.callbacksUsed = {}

function lib.callbacks:OnUsed(target, eventname)
	lib.callbacksUsed[eventname] = lib.callbacksUsed[eventname] or {}
	tinsert(lib.callbacksUsed[eventname], #lib.callbacksUsed[eventname]+1, target)
	lib.trackAuras = true
	lib.frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

	lib.frame:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
	lib.frame:RegisterEvent('PLAYER_TARGET_CHANGED')
	lib.frame:RegisterEvent('UNIT_TARGET')
	lib.frame:RegisterEvent('UNIT_AURA')
end

function lib.callbacks:OnUnused(target, eventname)
	if lib.callbacksUsed[eventname] then
		for i = #lib.callbacksUsed[eventname], 1, -1 do
			if lib.callbacksUsed[eventname][i] == target then
				tremove(lib.callbacksUsed[eventname], i)
			end
		end
	end

	for event, value in pairs(lib.callbacksUsed) do
		if #value == 0 then
			lib.callbacksUsed[event] = nil
		end
	end

	lib.trackAuras = false
	lib.frame:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

	lib.frame:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
	lib.frame:UnregisterEvent('PLAYER_TARGET_CHANGED')
	lib.frame:UnregisterEvent('UNIT_TARGET')
	lib.frame:UnregisterEvent('UNIT_AURA')
end

local function Round(num)
	return floor(num + .5)
end

local function ResetUnitAuras(unitID)
	lib:RemoveAllAurasFromGUID(UnitGUID(unitID))
end

function lib:AddAuraFromUnitID(dstGUID, name, texture, stackCount, debuffType, duration, expirationTime, srcGUID, spellID, filter)
	self.GUIDAuras[dstGUID] = self.GUIDAuras[dstGUID] or {}
	self.GUIDAuras[dstGUID][filter] = self.GUIDAuras[dstGUID][filter] or {}

	tinsert(self.GUIDAuras[dstGUID][filter], #self.GUIDAuras[dstGUID][filter]+1, {
		name = name,
		texture = texture,
		stackCount = stackCount,
		debuffType = debuffType,
		duration = duration,
		expirationTime = expirationTime,
		spellID = spellID,
		srcGUID = srcGUID
	})
end

local CheckUnitAuras
do
	local i
	local _, name, texture, stackCount, dispelType, duration, expirationTime, unitCaster, spellID
	local dstGUID, dstName, srcGUID
	function CheckUnitAuras(unitID, filterType)
		dstGUID, dstName = UnitGUID(unitID), UnitName(unitID)

		if lib.GUIDData_name[dstGUID] ~= dstName then
			lib.GUIDData_name[dstGUID] = dstName
		end

		--Since we have a unitID, lets clear our aura table and use 100% accurate aura info.
		if lib.GUIDAuras[dstGUID] and lib.GUIDAuras[dstGUID][filterType] then
			for j = #lib.GUIDAuras[dstGUID][filterType], 1, -1 do
				tremove(lib.GUIDAuras[dstGUID][filterType], j)
			end
		end

		i = 1
		while true do
			name, _, texture, stackCount, dispelType, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unitID, i, filterType)
			if not name then break end

			duration = Round(duration)

			if not lib.spellDuration[spellID] then
				lib.spellDuration[spellID] = duration
				lib.spellDebuffType[spellID] = (dispelType and lib.debuffTypes[dispelType] or 0)
			elseif not lib.auraInfoPvP[spellID] then
				if unitCaster and UnitExists(unitCaster) then
					srcGUID = UnitGUID(unitCaster)
					local baseDuration = lib:GetDuration(spellID) --, nil, nil, UnitIsPlayer(unitID)
					if baseDuration and baseDuration ~= duration then
						if duration > 0 then -- Sometimes UnitAura says a spell has 0 duration when it realy has more.
							--caster's duration doesn't match our DB, they're probably speced into something. lets remember that.
							lib.GUIDDurations[srcGUID.."-"..spellID] = duration
						end
					end
				end
			end

			if unitCaster and expirationTime > 0 then
				srcGUID = srcGUID or UnitGUID(unitCaster)
				lib:AddAuraFromUnitID(
					dstGUID,
					name,
					texture,
					stackCount and stackCount > 1 and stackCount or nil,
					dispelType,
					duration,
					expirationTime,
					srcGUID,
					spellID,
					filterType
				)
			end

			i = i + 1
			srcGUID = nil
		end

		lib.callbacks:Fire("LibAuraInfo_UNIT_AURA", dstGUID)
	end
end

lib.frame = lib.frame or CreateFrame("Frame")
lib.frame:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, event, ...)
	end
end)

function lib.frame:UPDATE_MOUSEOVER_UNIT()
	ResetUnitAuras("mouseover")
	CheckUnitAuras("mouseover", "HELPFUL")
	CheckUnitAuras("mouseover", "HARMFUL")
end

function lib.frame:PLAYER_TARGET_CHANGED()
	ResetUnitAuras("target")
	CheckUnitAuras("target", "HELPFUL")
	CheckUnitAuras("target", "HARMFUL")
end

do
	local targetID
	function lib.frame:UNIT_TARGET(_, unitID)
		if not UnitIsUnit(unitID, "player") then
			targetID = unitID.."target"
			ResetUnitAuras(targetID)
			CheckUnitAuras(targetID, "HELPFUL")
			CheckUnitAuras(targetID, "HARMFUL")
		end
	end
end

function lib.frame:UNIT_AURA(_, unitID)
	if not unitID then return end
	ResetUnitAuras(unitID)
	CheckUnitAuras(unitID, "HELPFUL")
	CheckUnitAuras(unitID, "HARMFUL")
end

------------------------------------------------------------------------------------------------------
--~ Dimminshing Returns
------------------------------------------------------------------------------------------------------

lib.resetDRTime = 18 --Time it tacks for DR to reset.

--[[
	List of spellID's copied from DRData-1.0 by Shadowed.
	http://www.wowace.com/addons/drdata-1-0/
	http://www.wowace.com/profiles/Shadowed/
]]
lib.drSpells = {
	--[[ TAUNT ]]--
	-- Taunt (Warrior)
	[355] = "taunt",
	-- Taunt (Pet)
	[53477] = "taunt",
	-- Mocking Blow
	[694] = "taunt",
	-- Growl (Druid)
	[6795] = "taunt",
	-- Dark Command
	[56222] = "taunt",
	-- Hand of Reckoning
	[62124] = "taunt",
	-- Righteous Defense
	[31790] = "taunt",
	-- Distracting Shot
	[20736] = "taunt",
	-- Challenging Shout
	[1161] = "taunt",
	-- Challenging Roar
	[5209] = "taunt",
	-- Death Grip
	[49560] = "taunt",
	-- Challenging Howl
	[59671] = "taunt",
	-- Angered Earth
	[36213] = "taunt",

	--[[ DISORIENTS ]]--
	-- Dragon's Breath
	[31661] = "disorient",
	[33041] = "disorient",
	[33042] = "disorient",
	[33043] = "disorient",
	[42949] = "disorient",
	[42950] = "disorient",

	-- Hungering Cold
	[49203] = "disorient",

	-- Sap
	[6770] = "disorient",
	[2070] = "disorient",
	[11297] = "disorient",
	[51724] = "disorient",

	-- Gouge
	[1776] = "disorient",

	-- Hex (Guessing)
	[51514] = "disorient",

	-- Shackle
	[9484] = "disorient",
	[9485] = "disorient",
	[10955] = "disorient",

	-- Polymorph
	[118] = "disorient",
	[12824] = "disorient",
	[12825] = "disorient",
	[28272] = "disorient",
	[28271] = "disorient",
	[12826] = "disorient",
	[61305] = "disorient",
	[61025] = "disorient",
	[61721] = "disorient",
	[61780] = "disorient",

	-- Freezing Trap
	[3355] = "disorient",
	[14308] = "disorient",
	[14309] = "disorient",

	-- Freezing Arrow
	[60210] = "disorient",

	-- Wyvern Sting
	[19386] = "disorient",
	[24132] = "disorient",
	[24133] = "disorient",
	[27068] = "disorient",
	[49011] = "disorient",
	[49012] = "disorient",

	-- Repentance
	[20066] = "disorient",

	--[[ SILENCES ]]--
	-- Nether Shock
	[53588] = "silence",
	[53589] = "silence",

	-- Garrote
	[1330] = "silence",

	-- Arcane Torrent (Energy version)
	[25046] = "silence",

	-- Arcane Torrent (Mana version)
	[28730] = "silence",

	-- Arcane Torrent (Runic power version)
	[50613] = "silence",

	-- Silence
	[15487] = "silence",

	-- Silencing Shot
	[34490] = "silence",

	-- Improved Kick
	[18425] = "silence",

	-- Improved Counterspell
	[18469] = "silence",

	-- Spell Lock
	[19244] = "silence",
	[19647] = "silence",

	-- Shield of the Templar
	[63529] = "silence",

	-- Strangulate
	[47476] = "silence",
	[49913] = "silence",
	[49914] = "silence",
	[49915] = "silence",
	[49916] = "silence",

	-- Gag Order (Warrior talent)
	[18498] = "silence",

	--[[ DISARMS ]]--
	-- Snatch
	[53542] = "disarm",
	[53543] = "disarm",

	-- Dismantle
	[51722] = "disarm",

	-- Disarm
	[676] = "disarm",

	-- Chimera Shot - Scorpid
	[53359] = "disarm",

	-- Psychic Horror (Disarm effect)
	[64058] = "disarm",

	--[[ FEARS ]]--
	-- Blind
	[2094] = "fear",

	-- Fear (Warlock)
	[5782] = "fear",
	[6213] = "fear",
	[6215] = "fear",

	-- Seduction (Pet)
	[6358] = "fear",

	-- Howl of Terror
	[5484] = "fear",
	[17928] = "fear",

	-- Psychic scream
	[8122] = "fear",
	[8124] = "fear",
	[10888] = "fear",
	[10890] = "fear",

	-- Scare Beast
	[1513] = "fear",
	[14326] = "fear",
	[14327] = "fear",

	-- Turn Evil
	[10326] = "fear",

	-- Intimidating Shout
	[5246] = "fear",

	--[[ CONTROL STUNS ]]--
	-- Intercept (Felguard)
	[30153] = "ctrlstun",
	[30195] = "ctrlstun",
	[30197] = "ctrlstun",
	[47995] = "ctrlstun",

	-- Ravage
	[50518] = "ctrlstun",
	[53558] = "ctrlstun",
	[53559] = "ctrlstun",
	[53560] = "ctrlstun",
	[53561] = "ctrlstun",
	[53562] = "ctrlstun",

	-- Sonic Blast
	[50519] = "ctrlstun",
	[53564] = "ctrlstun",
	[53565] = "ctrlstun",
	[53566] = "ctrlstun",
	[53567] = "ctrlstun",
	[53568] = "ctrlstun",

	-- Concussion Blow
	[12809] = "ctrlstun",

	-- Shockwave
	[46968] = "ctrlstun",

	-- Hammer of Justice
	[853] = "ctrlstun",
	[5588] = "ctrlstun",
	[5589] = "ctrlstun",
	[10308] = "ctrlstun",

	-- Bash
	[5211] = "ctrlstun",
	[6798] = "ctrlstun",
	[8983] = "ctrlstun",

	--***********************************************************
	-- Intimidation
	[19577] = "ctrlstun",

	-- Maim
	[22570] = "ctrlstun",
	[49802] = "ctrlstun",

	-- Kidney Shot
	[408] = "ctrlstun",
	[8643] = "ctrlstun",

	-- War Stomp
	[20549] = "ctrlstun",

	-- Intercept
	[20252] = "ctrlstun",

	-- Deep Freeze
	[44572] = "ctrlstun",

	-- Shadowfury
	[30283] = "ctrlstun",
	[30413] = "ctrlstun",
	[30414] = "ctrlstun",

	-- Holy Wrath
	[2812] = "ctrlstun",

	-- Inferno Effect
	[22703] = "ctrlstun",

	-- Demon Charge
	[60995] = "ctrlstun",

	-- Gnaw (Ghoul)
	[47481] = "ctrlstun",

	--[[ RANDOM STUNS ]]--
	-- Impact
	[12355] = "rndstun",

	-- Stoneclaw Stun
	[39796] = "rndstun",

	-- Seal of Justice
	[20170] = "rndstun",

	-- Revenge Stun
	[12798] = "rndstun",

	--[[ CYCLONE ]]--
	-- Cyclone
	[33786] = "cyclone",

	--[[ ROOTS ]]--
	-- Freeze (Water Elemental)
	[33395] = "ctrlroot",

	-- Pin (Crab)
	[50245] = "ctrlroot",
	[53544] = "ctrlroot",
	[53545] = "ctrlroot",
	[53546] = "ctrlroot",
	[53547] = "ctrlroot",
	[53548] = "ctrlroot",

	-- Frost Nova
	[122] = "ctrlroot",
	[865] = "ctrlroot",
	[6131] = "ctrlroot",
	[10230] = "ctrlroot",
	[27088] = "ctrlroot",
	[42917] = "ctrlroot",

	-- Entangling Roots
	[339] = "ctrlroot",
	[1062] = "ctrlroot",
	[5195] = "ctrlroot",
	[5196] = "ctrlroot",
	[9852] = "ctrlroot",
	[9853] = "ctrlroot",
	[26989] = "ctrlroot",
	[53308] = "ctrlroot",

	-- Nature's Grasp (Uses different spellIDs than Entangling Roots for the same spell)
	[19970] = "ctrlroot",
	[19971] = "ctrlroot",
	[19972] = "ctrlroot",
	[19973] = "ctrlroot",
	[19974] = "ctrlroot",
	[19975] = "ctrlroot",
	[27010] = "ctrlroot",
	[53313] = "ctrlroot",

	-- Earthgrab (Storm, Earth and Fire talent)
	[8377] = "ctrlroot",
	[31983] = "ctrlroot",

	-- Web (Spider)
	[4167] = "ctrlroot",

	-- Venom Web Spray (Silithid)
	[54706] = "ctrlroot",
	[55505] = "ctrlroot",
	[55506] = "ctrlroot",
	[55507] = "ctrlroot",
	[55508] = "ctrlroot",
	[55509] = "ctrlroot",

	--[[ RANDOM ROOTS ]]--
	-- Improved Hamstring
	[23694] = "rndroot",

	-- Frostbite
	[12494] = "rndroot",

	-- Shattered Barrier
	[55080] = "rndroot",

	--[[ SLEEPS ]]--
	-- Hibernate
	[2637] = "sleep",
	[18657] = "sleep",
	[18658] = "sleep",

	--[[ HORROR ]]--
	-- Death Coil
	[6789] = "horror",
	[17925] = "horror",
	[17926] = "horror",
	[27223] = "horror",
	[47859] = "horror",
	[47860] = "horror",

	-- Psychic Horror
	[64044] = "horror",

	--[[ MISC ]]--
	-- Scatter Shot
	[19503] = "scatters",

	-- Cheap Shot
	[1833] = "cheapshot",

	-- Pounce
	[9005] = "cheapshot",
	[9823] = "cheapshot",
	[9827] = "cheapshot",
	[27006] = "cheapshot",
	[49803] = "cheapshot",

	-- Charge
	[7922] = "charge",

	-- Mind Control
	[605] = "mc",

	-- Banish
	[710] = "banish",
	[18647] = "banish",

	-- Entrapment
	[64804] = "entrapment",
	[19185] = "entrapment",
}

lib.pveDR = {
	["ctrlstun"] = true,
	["rndstun"] = true,
	["taunt"] = true,
	["cyclone"] = true,
}

lib.GUIDDrEffects_reset = {}
lib.GUIDDrEffects_diminished = {}

do
	local drType, key, reset
	function lib:GUIDGainedDRAura(dstGUID, spellID, dstIsPlayer)
		drType = self.drSpells[spellID]

		if dstIsPlayer or self.pveDR[drType] then
			key = dstGUID..drType
			reset = self.GUIDDrEffects_reset[key]
			if reset and reset <= GetTime() then
				self.GUIDDrEffects_diminished[key] = 1
			end
		end
	end
end

local function NextDR(diminished)
	if diminished == 1 then
		return 0.50
	elseif diminished == 0.50 then
		return 0.25
	end

	return 0
end

do
	local drType, key
	function lib:GUIDRemovedDRAura(dstGUID, spellID, dstIsPlayer)
		drType = self.drSpells[spellID]
		if dstIsPlayer or self.pveDR[drType] then
			key = dstGUID..drType
			self.GUIDDrEffects_reset[key] = GetTime() + self.resetDRTime
			self.GUIDDrEffects_diminished[key] = NextDR( self.GUIDDrEffects_diminished[key] or 1.0 )
		end
	end
end

do
	local drType, key, reset
	function lib:GetDRDuration(dstGUID, spellID, duration)
		duration = duration or self:GetDuration(spellID, nil, dstGUID)
		drType = self.drSpells[spellID]
		if drType then
			key = dstGUID..drType
			reset = self.GUIDDrEffects_reset[key]
			if reset and GetTime() < reset then
				return duration * (self.GUIDDrEffects_diminished[key] or 1)
			end
		end

		return duration
	end
end

-------------------------------------------------------------------------------------------------------
--~ Combatlog
-------------------------------------------------------------------------------------------------------
lib.GUIDAuras = lib.GUIDAuras or {}

local function SaveGUIDInfo(guid, name, flags)
	lib.GUIDData_name[guid] = name
	lib.GUIDData_flags[guid] = flags
end

function lib:GetSpellTexture(spellID)
	return GetSpellTexture(spellID) or select(3, GetSpellInfo(spellID))
end

function lib.frame:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	if lib.GUIDBlackList[dstGUID] then return end

	if srcGUID and not lib.GUIDData_flags[srcGUID] then
		SaveGUIDInfo(srcGUID, srcName, srcFlags)
	end
	if dstGUID and not lib.GUIDData_flags[dstGUID] then
		SaveGUIDInfo(dstGUID, dstName, dstFlags)
	end

	if self[eventType] then
		self[eventType](self, eventType, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	end
end

do
	local data
	-- Remove expired auras from a GUID
	function lib:RemoveExpiredAuras(dstGUID)
		if self.GUIDAuras[dstGUID] then
			for filter in pairs(self.GUIDAuras[dstGUID]) do
				for i = #self.GUIDAuras[dstGUID][filter], 1, -1 do
					data = self.GUIDAuras[dstGUID][filter][i]
					if GetTime() > data.expirationTime then
						tremove(self.GUIDAuras[dstGUID][filter], i)
					end
				end
			end
		end
	end
end

do
	local duration
	-- Add a auraID to our GUID list
	function lib:AddAuraToGUID(dstGUID, name, texture, spellID, srcGUID, filter)
		duration = self:GetDuration(spellID, srcGUID, dstGUID)

		self.GUIDAuras[dstGUID] = self.GUIDAuras[dstGUID] or {}
		self.GUIDAuras[dstGUID][filter] = self.GUIDAuras[dstGUID][filter] or {}

		--[[
			I didn't want to use tables this way when I started the project but due to multiple instnces of a spellID being on a GUID I couldn't do a hash table lookup.
			I wanted do something like
			GUIDAuras_Duration[dstGUID..spellID..srcGUID] = 30
			but because UnitAura() sometimes doesn't return a unitID to get srcGUID, I had to do a index table. meh

		]]

		tinsert(self.GUIDAuras[dstGUID][filter], #self.GUIDAuras[dstGUID][filter] + 1, {
			name = name,
			texture = texture,
			debuffType = self:GetDebuffType(spellID),
			duration = duration,
			expirationTime = duration == 0 and 0 or GetTime() + duration,
			spellID = spellID,
			srcGUID = srcGUID,
			isDebuff = filter
		})

	--~ 	table.sort(self.GUIDAuras[dstGUID], function(a,b)
	--~ 		return a.expirationTime < b.expirationTime
	--~ 	end)
	end
end

do
	local data
	-- Increase stack count of a aura
	function lib:AddAuraDose(dstGUID, spellID, srcGUID, filter)
		if self.GUIDAuras[dstGUID] and self.GUIDAuras[dstGUID][filter] then
			if srcGUID then
				for i = 1, #self.GUIDAuras[dstGUID][filter] do
					data = self.GUIDAuras[dstGUID][filter][i]
					if data.spellID == spellID and data.srcGUID == srcGUID then
						data.stackCount = (data.stackCount or 1) + 1
						data.expirationTime = data.duration + GetTime()

						return true, data.stackCount, data.expirationTime
					end
				end
			end

			for i = 1, #self.GUIDAuras[dstGUID][filter] do
				data = self.GUIDAuras[dstGUID][filter][i]
				if data.spellID == spellID then
					data.stackCount = (data.stackCount or 1) + 1
					data.expirationTime = data.duration + GetTime()

					return true, data.stackCount, data.expirationTime
				end
			end
		end

		return false
	end
end

do
	local data
	-- Remove 1 stack from a aura
	function lib:RemoveAuraDose(dstGUID, spellID, srcGUID, filter)
		if self.GUIDAuras[dstGUID] and self.GUIDAuras[dstGUID][filter] then
			if srcGUID then
				for i = 1, #self.GUIDAuras[dstGUID][filter] do
					data = self.GUIDAuras[dstGUID][filter][i]
					if data.spellID == spellID and data.srcGUID == srcGUID then
						data.stackCount = (data.stackCount or 1) - 1
					--	data.expirationTime = data.duration + GetTime()

						return true, data.stackCount, data.expirationTime
					end
				end
			end

			for i = 1, #self.GUIDAuras[dstGUID][filter] do
				data = self.GUIDAuras[dstGUID][filter][i]
				if data.spellID == spellID then
					data.stackCount = (data.stackCount or 1) - 1
				--	data.expirationTime = data.duration + GetTime()

					return true, data.stackCount, data.expirationTime
				end
			end
		end

		return false
	end
end

do
	local data
	-- Refresh the start and expiration time of a aura
	function lib:RefreshAura(dstGUID, spellID, srcGUID, filter)
		if self.GUIDAuras[dstGUID] and self.GUIDAuras[dstGUID][filter] then
			if srcGUID then
				for i = 1, #self.GUIDAuras[dstGUID][filter] do
					data = self.GUIDAuras[dstGUID][filter][i]
					if data.spellID == spellID and data.srcGUID == srcGUID then
						data.expirationTime = data.duration + GetTime()

						return true, data.expirationTime
					end
				end
			end

			for i = 1, #self.GUIDAuras[dstGUID][filter] do
				data = self.GUIDAuras[dstGUID][filter][i]
				if data.spellID == spellID then
					data.expirationTime = data.duration + GetTime()

					return true, data.expirationTime
				end
			end
		end

		return false
	end
end

do
	local data
	-- Remove a aura from a GUID
	function lib:RemoveAuraFromGUID(dstGUID, spellID, srcGUID, filter)
		if lib.GUIDAuras[dstGUID] and lib.GUIDAuras[dstGUID][filter] then
			if srcGUID then
				for i = #lib.GUIDAuras[dstGUID][filter],1, -1 do
					data = lib.GUIDAuras[dstGUID][filter][i]
					if data.spellID == spellID and srcGUID == data.srcGUID then
						tremove(lib.GUIDAuras[dstGUID][filter], i)
						lib.callbacks:Fire("RemoveAuraFromGUID", dstGUID)
						return
					end
				end
			end

			for i = #lib.GUIDAuras[dstGUID][filter],1, -1 do
				data = lib.GUIDAuras[dstGUID][filter][i]
				if data.spellID == spellID then
					tremove(lib.GUIDAuras[dstGUID][filter], i)
					lib.callbacks:Fire("RemoveAuraFromGUID", dstGUID)
					return
				end
			end

		end
	end
end

-- Remove all auras on a GUID. They must have died
function lib:RemoveAllAurasFromGUID(dstGUID)
	if self.GUIDAuras[dstGUID] then
		for filter in pairs(self.GUIDAuras[dstGUID]) do
			for i=#self.GUIDAuras[dstGUID][filter], 1, -1 do
				tremove(self.GUIDAuras[dstGUID][filter], i)
			end
		end
	end
end

function lib.frame:SPELL_AURA_REMOVED(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, auraType)
	lib:RemoveAuraFromGUID(dstGUID, spellID, srcGUID, auraType == "DEBUFF" and "HARMFUL" or "HELPFUL")

	if lib.drSpells[spellID] then
		lib:GUIDRemovedDRAura(dstGUID, spellID, lib:FlagIsPlayer(dstFlags))
	end
	lib.callbacks:Fire("LibAuraInfo_AURA_REMOVED", dstGUID, spellID, srcGUID)
end

function lib.frame:SPELL_AURA_APPLIED(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, auraType)
	if lib.drSpells[spellID] then
		lib:GUIDGainedDRAura(dstGUID, spellID, lib:FlagIsPlayer(dstFlags))
	end

	if lib.spellDuration[spellID] then
		lib:RemoveExpiredAuras(dstGUID)
		lib:AddAuraToGUID(dstGUID, spellName, lib:GetSpellTexture(spellID), spellID, srcGUID, auraType == "DEBUFF" and "HARMFUL" or "HELPFUL")
		lib.callbacks:Fire("LibAuraInfo_AURA_APPLIED", dstGUID, spellID, srcGUID, auraType)
	end
end

do
	local refreshed
	function lib.frame:SPELL_AURA_REFRESH(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, auraType)
		if lib.drSpells[spellID] then
			lib:GUIDRemovedDRAura(dstGUID, spellID, lib:FlagIsPlayer(dstFlags))
			lib:GUIDGainedDRAura(dstGUID, spellID, lib:FlagIsPlayer(dstFlags))
		end

		refreshed = lib:RefreshAura(dstGUID, spellID, srcGUID, auraType == "DEBUFF" and "HARMFUL" or "HELPFUL")
		if refreshed then
			lib.callbacks:Fire("LibAuraInfo_AURA_REFRESH", dstGUID, spellID, srcGUID, spellSchool, auraType)
			return
		end

		self:SPELL_AURA_APPLIED(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, auraType)
	end
end

do
	local dosed, stackCount, expirationTime
	--DOSE = spell stacking
	function lib.frame:SPELL_AURA_APPLIED_DOSE(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, auraType)
		dosed, stackCount, expirationTime = lib:AddAuraDose(dstGUID, spellID, srcGUID, auraType == "DEBUFF" and "HARMFUL" or "HELPFUL")
		if dosed then
			lib.callbacks:Fire("LibAuraInfo_AURA_APPLIED_DOSE", dstGUID, spellID, srcGUID, spellSchool, auraType, stackCount, expirationTime)
			return
		end

		--Spell isn't in our list, let's add it.
		--Note this event could have fired on the 5th stack but our spell frame will only show it applied once.
		self:SPELL_AURA_APPLIED(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, auraType)
	end
end

do
	local dosed, stackCount, expirationTime
	function lib.frame:SPELL_AURA_APPLIED_REMOVED_DOSE(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, auraType)
		dosed, stackCount, expirationTime = lib:RemoveAuraDose(dstGUID, spellID, srcGUID, auraType == "DEBUFF" and "HARMFUL" or "HELPFUL")
		if dosed then
			lib.callbacks:Fire("LibAuraInfo_AURA_APPLIED_DOSE", dstGUID, spellID, srcGUID, spellSchool, auraType, stackCount, expirationTime)
			return
		end
	end
end

function lib.frame:SPELL_AURA_BROKEN_SPELL(...)
	self:SPELL_AURA_REMOVED(...)
end

function lib.frame:SPELL_AURA_BROKEN(...)
	self:SPELL_AURA_REMOVED(...)
end

function lib.frame:UNIT_DIED(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	if lib.GUIDAuras[dstGUID] then
		lib:RemoveAllAurasFromGUID(dstGUID)
		lib.callbacks:Fire("LibAuraInfo_AURA_CLEAR", dstGUID)
	end
end

function lib.frame:UNIT_DESTROYED(...)
	self:UNIT_DIED(...)
end

function lib.frame:UNIT_DISSIPATES(...)
	self:UNIT_DIED(...)
end

function lib.frame:PARTY_KILL(...)
	self:UNIT_DIED(...)
end

function lib:FlagIsPlayer(flags)
	if band(flags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER then
		return true
	end
end

--------------------------------------------------------------
--~ API
--------------------------------------------------------------
local GUIDIsPlayer
do
	local B, maskedB
	function GUIDIsPlayer(guid)
		B = tonumber(sub(guid, 5, 5), 16);
		maskedB = B % 8; -- x % 8 has the same effect as x & 0x7 on numbers <= 0xf
	--	local knownTypes = {[0]="player", [3]="NPC", [4]="pet", [5]="vehicle"};
	--	print("Your target is a " .. (knownTypes[maskedB] or " unknown entity!"));
		return maskedB == 0
	end
end

do
	local duration, dur
	--Return the duration of a spell.
	function lib:GetDuration(spellID, srcGUID, dstGUID, dstIsPlayer)
		dstIsPlayer = dstIsPlayer or dstGUID and GUIDIsPlayer(dstGUID) or false
		if dstIsPlayer and lib.auraInfoPvP[spellID] then
			--Receiver is a player and the spell has a PvP duration. Return the pvp duration.
			duration = lib.auraInfoPvP[spellID]
			if dstGUID and duration then
				--Check if there's dimminshing returns on the spell.
				duration = self:GetDRDuration(dstGUID, spellID, duration)
			end

			return tonumber(duration or 0)
		elseif self.spellDuration[spellID] then
			--Check caster GUID was given.
			if srcGUID then
				--Check if we've seen that caster cast a spell with a duration that doesn't match our own (spec/glphed into something?)
				if self.GUIDDurations[srcGUID.."-"..spellID] then
					dur = self.GUIDDurations[srcGUID.."-"..spellID]
					--Check if receiver GUID was given.
					if dstGUID then
						--Check if there's dimminshing returns on the spell.
						dur = self:GetDRDuration(dstGUID, spellID, dur)
					end
					return dur
				end
			end

			return self.spellDuration[spellID]
		end
	end
end

do
	local debuffType
	--Return the debuff type of a spell.
	function lib:GetDebuffType(spellID)
		if self.spellDuration[spellID] then
			debuffType = self.spellDebuffType[spellID]
			if debuffType then
				return self.debuffTypes[debuffType] or "unknown"
			end
			return "none"--Lowercase because DebuffTypeColor["none"] is lowercase.
		end
	end
end

function lib:GetNumGUIDAuras(dstGUID)
	self:RemoveExpiredAuras(dstGUID)

	if self.GUIDAuras[dstGUID] then
		local i = 0
		for filter in pairs(self.GUIDAuras[dstGUID]) do
			i = i + #self.GUIDAuras[dstGUID][filter]
		end
		return i
	end

	return 0
end

do
	local data
	function lib:GUIDAura(dstGUID, i, filter)
		if self.GUIDAuras[dstGUID] and self.GUIDAuras[dstGUID][filter] and self.GUIDAuras[dstGUID][filter][i] then
			data = self.GUIDAuras[dstGUID][filter][i]
			return true, data.name, data.texture, data.stackCount or 0, data.debuffType, data.duration, data.expirationTime, data.srcGUID, data.spellID
		end
		return false
	end
end

do
	local data
	function lib:GUIDAuraID(dstGUID, spellID, srcGUID, filter)
		if self.GUIDAuras[dstGUID] and self.GUIDAuras[dstGUID][filter] then
			if srcGUID then
				for i = 1, #self.GUIDAuras[dstGUID][filter] do
					data = self.GUIDAuras[dstGUID][filter][i]
					if data.spellID == spellID and data.srcGUID == srcGUID then
						return true, data.stackCount or 0, data.debuffType, data.duration, data.expirationTime, data.isDebuff, data.srcGUID
					end
				end
			end
			for i = 1, #self.GUIDAuras[dstGUID][filter] do
				data = self.GUIDAuras[dstGUID][filter][i]
				if data.spellID == spellID then
					return true, data.stackCount or 0, data.debuffType, data.duration, data.expirationTime, data.isDebuff, data.srcGUID
				end
			end
		end
		return false
	end
end

do
	local drType, key, reset
	function lib:HasDREffect(dstGUID, spellID)
		drType = self.drSpells[spellID]
		if drType then
			key = dstGUID..drType
			reset = self.GUIDDrEffects_reset[key]
			if reset and GetTime() < reset then
				return true, (self.GUIDDrEffects_diminished[key] or 1)
			end
		end
		return false
	end
end

function lib:GetGUIDInfo(GUID)
	return self.GUIDData_name[GUID], self.GUIDData_flags[GUID]
end