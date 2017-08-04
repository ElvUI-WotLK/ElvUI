--- = Background =
-- Blizzard's IsSpellInRange API has always been very limited - you either must have the name of the spell, or its spell book ID. Checking directly by spellID is simply not possible.
-- Now, in Mists of Pandaria, Blizzard changed the way that many talents and specialization spells work - instead of giving you a new spell when leaned, they replace existing spells. These replacement spells do not work with Blizzard's IsSpellInRange function whatsoever; this limitation is what prompted the creation of this lib.
-- = Usage =
-- **LibSpellRange-1.0** exposes an enhanced version of IsSpellInRange that:
-- * Allows ranged checking based on both spell name and spellID.
-- * Works correctly with replacement spells that will not work using Blizzard's IsSpellInRange method alone.
--
-- @class file
-- @name LibSpellRange-1.0.lua

local major = "SpellRange-1.0"
local minor = 19

assert(LibStub, format("%s requires LibStub.", major))

local Lib = LibStub:NewLibrary(major, minor)
if not Lib then return end

local tonumber = _G.tonumber
local strlower = _G.strlower
local wipe = _G.wipe
local type = _G.type

local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local GetSpellName = _G.GetSpellName
local GetSpellTabInfo = _G.GetSpellTabInfo

local IsSpellInRange = _G.IsSpellInRange
local SpellHasRange = _G.SpellHasRange

local MAX_SKILLLINE_TABS = _G.MAX_SKILLLINE_TABS

-- isNumber is basically a tonumber cache for maximum efficiency
Lib.isNumber = Lib.isNumber or setmetatable({}, {
	__mode = "kv",
	__index = function(t, i)
		local o = tonumber(i) or false
		t[i] = o
		return o
end})
local isNumber = Lib.isNumber

-- strlower cache for maximum efficiency
Lib.strlowerCache = Lib.strlowerCache or setmetatable(
{}, {
	__index = function(t, i)
		if not i then return end
		local o
		if type(i) == "number" then
			o = i
		else
			o = strlower(i)
		end
		t[i] = o
		return o
	end,
}) local strlowerCache = Lib.strlowerCache

-- Matches lowercase player spell names to their spellBookID
Lib.spellsByName_spell = Lib.spellsByName_spell or {}
local spellsByName_spell = Lib.spellsByName_spell

-- Matches player spellIDs to their spellBookID
Lib.spellsByID_spell = Lib.spellsByID_spell or {}
local spellsByID_spell = Lib.spellsByID_spell

-- Matches lowercase pet spell names to their spellBookID
Lib.spellsByName_pet = Lib.spellsByName_pet or {}
local spellsByName_pet = Lib.spellsByName_pet

-- Matches pet spellIDs to their spellBookID
Lib.spellsByID_pet = Lib.spellsByID_pet or {}
local spellsByID_pet = Lib.spellsByID_pet

local blacklistedIDs = {}

-- Updates spellsByName and spellsByID
local function UpdateBook(bookType)
	local _, offs, numspells
	local max = 0

	for i = MAX_SKILLLINE_TABS, 1, -1 do
		_, _, offs, numspells = GetSpellTabInfo(i)

		if numspells > 0 then
			max = offs + numspells
			break
		end
	end

	local spellsByName = Lib["spellsByName_" .. bookType]
	local spellsByID = Lib["spellsByID_" .. bookType]

	wipe(spellsByName)
	wipe(spellsByID)
	wipe(blacklistedIDs)

	for spellBookID = 1, max do
		local spellName, rank = GetSpellName(spellBookID, bookType)

		if spellName and (rank == "" or rank:match("%d+")) then
			local link = GetSpellLink(spellName, rank)
			local spellID = tonumber(link and link:gsub("|", "||"):match("spell:(%d+)"))

			if spellName then
				spellsByName[strlower(spellName)] = spellBookID
			end

			if spellID then
				spellsByID[spellID] = spellBookID
			end
		end
	end
end

-- Handles updating spellsByName and spellsByID
if not Lib.updaterFrame then
	Lib.updaterFrame = CreateFrame("Frame")
end
Lib.updaterFrame:UnregisterAllEvents()
Lib.updaterFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
Lib.updaterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function UpdateSpells(_, event)
	UpdateBook("spell")
	UpdateBook("pet")
	if event == "PLAYER_ENTERING_WORLD" then
		Lib.updaterFrame:UnregisterEvent(event)
	end
end

Lib.updaterFrame:SetScript("OnEvent", UpdateSpells)
UpdateSpells()

--- Improved spell range checking function.
-- @name SpellRange.IsSpellInRange
-- @paramsig spell, unit
-- @param spell Name or spellID of a spell that you wish to check the range of. The spell must be a spell that you have in your spellbook or your pet's spellbook.
-- @param unit UnitID of the spell that you wish to check the range on.
-- @return Exact same returns as http://wowprogramming.com/docs/api/IsSpellInRange
-- @usage
-- -- Check spell range by spell name on unit "target"
-- local SpellRange = LibStub("SpellRange-1.0")
-- local inRange = SpellRange.IsSpellInRange("Stormstrike", "target")
--
-- -- Check spell range by spellID on unit "mouseover"
-- local SpellRange = LibStub("SpellRange-1.0")
-- local inRange = SpellRange.IsSpellInRange(17364, "mouseover")
function Lib.IsSpellInRange(spellInput, unit)
	if isNumber[spellInput] then
		local spell = spellsByID_spell[spellInput]
		if spell then
			return IsSpellInRange(spell, "spell", unit)
		else
			spell = spellsByID_pet[spellInput]
			if spell then
				return IsSpellInRange(spell, "pet", unit)
			elseif not blacklistedIDs[spellInput] then
				spell = GetSpellInfo(spellInput)
				if spell then
					spell = strlowerCache[spell]
					if spellsByName_spell[spell] then
						local spellBookID = spellsByName_spell[spell]
						Lib["spellsByID_spell"][spellInput] = spellBookID
						return IsSpellInRange(spellBookID, "spell", unit)
					elseif spellsByName_pet[spell] then
						local spellBookID = spellsByName_pet[spell]
						Lib["spellsByID_pet"][spellInput] = spellBookID
						return IsSpellInRange(spellBookID, "pet", unit)
					end
				end

				blacklistedIDs[spellInput] = true
				return
			end
		end
	else
		spellInput = strlowerCache[spellInput]

		local spell = spellsByName_spell[spellInput]
		if spell then
			return IsSpellInRange(spell, "spell", unit)
		else
			spell = spellsByName_pet[spellInput]
			if spell then
				return IsSpellInRange(spell, "pet", unit)
			end
		end

		return IsSpellInRange(spellInput, unit)
	end
end

--- Improved SpellHasRange.
-- @name SpellRange.SpellHasRange
-- @paramsig spell
-- @param spell Name or spellID of a spell that you wish to check for a range. The spell must be a spell that you have in your spellbook or your pet's spellbook.
-- @return Exact same returns as http://wowprogramming.com/docs/api/SpellHasRange
-- @usage
-- -- Check if a spell has a range by spell name
-- local SpellRange = LibStub("SpellRange-1.0")
-- local hasRange = SpellRange.SpellHasRange("Stormstrike")
--
-- -- Check if a spell has a range by spellID
-- local SpellRange = LibStub("SpellRange-1.0")
-- local hasRange = SpellRange.SpellHasRange(17364)
function Lib.SpellHasRange(spellInput)
	if isNumber[spellInput] then
		local spell = spellsByID_spell[spellInput]
		if spell then
			return SpellHasRange(spell, "spell")
		else
			spell = spellsByID_pet[spellInput]
			if spell then
				return SpellHasRange(spell, "pet")
			end
		end
	else
		spellInput = strlowerCache[spellInput]

		local spell = spellsByName_spell[spellInput]
		if spell then
			return SpellHasRange(spell, "spell")
		else
			spell = spellsByName_pet[spellInput]
			if spell then
				return SpellHasRange(spell, "pet")
			end
		end

		return SpellHasRange(spellInput)
	end
end