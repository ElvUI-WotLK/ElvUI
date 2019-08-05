local ElvUI = select(2, ...)

local gameLocale
do -- Locale doesn't exist yet, make it exist.
	local convert = {["enGB"] = "enUS", ["esES"] = "esMX", ["itIT"] = "enUS"}
	local lang = GetLocale()

	gameLocale = convert[lang] or lang or "enUS"
	ElvUI[2] = ElvUI[1].Libs.ACL:GetLocale("ElvUI", gameLocale)
end

local E, L, V, P, G = unpack(ElvUI)

local ActionBars = E:GetModule("ActionBars")
local AFK = E:GetModule("AFK")
local Auras = E:GetModule("Auras")
local Bags = E:GetModule("Bags")
local Blizzard = E:GetModule("Blizzard")
local Chat = E:GetModule("Chat")
local DataBars = E:GetModule("DataBars")
local DataTexts = E:GetModule("DataTexts")
local Layout = E:GetModule("Layout")
local Minimap = E:GetModule("Minimap")
local NamePlates = E:GetModule("NamePlates")
local Threat = E:GetModule("Threat")
local Tooltip = E:GetModule("Tooltip")
local Totems = E:GetModule("Totems")
local ReminderBuffs = E:GetModule("ReminderBuffs")
local UnitFrames = E:GetModule("UnitFrames")

local LSM = E.Libs.LSM

local _G = _G
local tonumber, pairs, ipairs, error, unpack, select, tostring = tonumber, pairs, ipairs, error, unpack, select, tostring
local assert, type, collectgarbage, pcall = assert, type, collectgarbage, pcall
local twipe, tinsert, tremove, next = table.wipe, tinsert, tremove, next
local floor = floor
local format, find, match, strrep, strlen, sub, gsub, strjoin = string.format, string.find, string.match, strrep, strlen, string.sub, string.gsub, strjoin

local UnitGUID = UnitGUID
local CreateFrame = CreateFrame
local GetCVar = GetCVar
local IsAddOnLoaded = IsAddOnLoaded
local IsInGuild = IsInGuild
local IsInInstance, GetNumPartyMembers, GetNumRaidMembers = IsInInstance, GetNumPartyMembers, GetNumRaidMembers
local SendAddonMessage = SendAddonMessage
local InCombatLockdown = InCombatLockdown
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

--Constants
E.noop = function() end
E.title = format("|cffff7000E|r|cffe5e3e3lvUI|r")
E.myfaction, E.myLocalizedFaction = UnitFactionGroup("player")
E.mylevel = UnitLevel("player")
E.myLocalizedClass, E.myclass, E.myClassID = UnitClass("player")
E.myLocalizedRace, E.myrace = UnitRace("player")
E.myname = UnitName("player")
E.myrealm = GetRealmName()
E.version = GetAddOnMetadata("ElvUI", "Version")
E.wowpatch, E.wowbuild = GetBuildInfo()
E.wowbuild = tonumber(E.wowbuild)
E.resolution = GetCVar("gxResolution")
E.screenwidth, E.screenheight = tonumber(match(E.resolution, "(%d+)x+%d")), tonumber(match(E.resolution, "%d+x(%d+)"))
E.isMacClient = IsMacClient()

--Tables
E.media = {}
E.frames = {}
E.unitFrameElements = {}
E.statusBars = {}
E.texts = {}
E.snapBars = {}
E.RegisteredModules = {}
E.RegisteredInitialModules = {}
E.ModuleCallbacks = {["CallPriority"] = {}}
E.InitialModuleCallbacks = {["CallPriority"] = {}}
E.valueColorUpdateFuncs = {}
E.TexCoords = {0, 1, 0, 1}
E.VehicleLocks = {}
E.CreditsList = {}

E.InversePoints = {
	TOP = "BOTTOM",
	BOTTOM = "TOP",
	TOPLEFT = "BOTTOMLEFT",
	TOPRIGHT = "BOTTOMRIGHT",
	LEFT = "RIGHT",
	RIGHT = "LEFT",
	BOTTOMLEFT = "TOPLEFT",
	BOTTOMRIGHT = "TOPRIGHT",
	CENTER = "CENTER"
}

E.HealingClasses = {
	PALADIN = 1,
	SHAMAN = 3,
	DRUID = 3,
	PRIEST = {1, 2}
}

E.ClassRole = {
	PALADIN = {
		[1] = "Caster",
		[2] = "Tank",
		[3] = "Melee"
	},
	PRIEST = "Caster",
	WARLOCK = "Caster",
	WARRIOR = {
		[1] = "Melee",
		[2] = "Melee",
		[3] = "Tank"
	},
	HUNTER = "Melee",
	SHAMAN = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Caster"
	},
	ROGUE = "Melee",
	MAGE = "Caster",
	DEATHKNIGHT = {
		[1] = "Tank",
		[2] = "Melee",
		[3] = "Melee"
	},
	DRUID = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Caster"
	}
}

E.DispelClasses = {
	PRIEST = {Magic = true, Disease = true},
	SHAMAN = {Poison = true, Disease = true, Curse = false},
	PALADIN = {Poison = true, Magic = true, Disease = true},
	MAGE = {Curse = true},
	DRUID = {Curse = true, Poison = true}
}

local colorizedName
function E:ColorizedName(name, arg2)
	local length = strlen(name)
	for i = 1, length do
		local letter = sub(name, i, i)
		if i == 1 then
			colorizedName = format("|cffA11313%s", letter)
		elseif i == 2 then
			colorizedName = format("%s|r|cffC4C4C4%s", colorizedName, letter)
		elseif i == length and arg2 then
			colorizedName = format("%s%s|r|cffA11313:|r", colorizedName, letter)
		else
			colorizedName = colorizedName..letter
		end
	end
	return colorizedName
end

--Workaround for people wanting to use white and it reverting to their class color.
E.PriestColors = {r = 0.99, g = 0.99, b = 0.99}

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame("Frame", "ElvUIParent", UIParent)
E.UIParent:SetFrameLevel(UIParent:GetFrameLevel())
E.UIParent:SetPoint("CENTER", UIParent, "CENTER")
E.UIParent:SetSize(UIParent:GetSize())
E.snapBars[#E.snapBars + 1] = E.UIParent

E.HiddenFrame = CreateFrame("Frame")
E.HiddenFrame:Hide()

do -- used in optionsUI
	E.DEFAULT_FILTER = {}
	for filter, tbl in pairs(G.unitframe.aurafilters) do
		E.DEFAULT_FILTER[filter] = tbl.type
	end
end

function E:Print(...)
	(_G[self.db.general.messageRedirect] or DEFAULT_CHAT_FRAME):AddMessage(strjoin("", self:ColorizedName("ElvUI", true), ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

local delayedTimer
local delayedFuncs = {}
function E:ShapeshiftDelayedUpdate(func, ...)
	delayedFuncs[func] = {...}

	if delayedTimer then return end

	delayedTimer = E:ScheduleTimer(function()
		for f in pairs(delayedFuncs) do
			f(unpack(delayedFuncs[f]))
		end

		twipe(delayedFuncs)
		delayedTimer = nil
	end, 0.05)
end

--Basically check if another class border is being used on a class that doesn't match. And then return true if a match is found.
function E:CheckClassColor(r, g, b)
	r, g, b = floor(r*100 + 0.5) / 100, floor(g*100 + 0.5) / 100, floor(b*100 + 0.5) / 100
	local matchFound = false
	for class in pairs(RAID_CLASS_COLORS) do
		if class ~= E.myclass then
			local colorTable = class == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class])
			if colorTable.r == r and colorTable.g == g and colorTable.b == b then
				matchFound = true
			end
		end
	end

	return matchFound
end

function E:SetColorTable(t, data)
	if not data.r or not data.g or not data.b then
		error("SetColorTable: Could not unpack color values.")
	end

	if t and (type(t) == "table") then
		t[1], t[2], t[3], t[4] = E:UpdateColorTable(data)
	else
		t = E:GetColorTable(data)
	end

	return t
end

function E:UpdateColorTable(data)
	if not data.r or not data.g or not data.b then
		error("UpdateColorTable: Could not unpack color values.")
	end

	if (data.r > 1 or data.r < 0) then data.r = 1 end
	if (data.g > 1 or data.g < 0) then data.g = 1 end
	if (data.b > 1 or data.b < 0) then data.b = 1 end
	if data.a and (data.a > 1 or data.a < 0) then data.a = 1 end

	if data.a then
		return data.r, data.g, data.b, data.a
	else
		return data.r, data.g, data.b
	end
end

function E:GetColorTable(data)
	if not data.r or not data.g or not data.b then
		error("GetColorTable: Could not unpack color values.")
	end

	if (data.r > 1 or data.r < 0) then data.r = 1 end
	if (data.g > 1 or data.g < 0) then data.g = 1 end
	if (data.b > 1 or data.b < 0) then data.b = 1 end
	if data.a and (data.a > 1 or data.a < 0) then data.a = 1 end

	if data.a then
		return {data.r, data.g, data.b, data.a}
	else
		return {data.r, data.g, data.b}
	end
end

function E:UpdateMedia()
	if not self.db.general or not self.private.general then return end --Prevent rare nil value errors

	-- Fonts
	self.media.normFont = LSM:Fetch("font", self.db.general.font)
	self.media.combatFont = LSM:Fetch("font", self.private.general.dmgfont)

	-- Textures
	self.media.blankTex = LSM:Fetch("background", "ElvUI Blank")
	self.media.normTex = LSM:Fetch("statusbar", self.private.general.normTex)
	self.media.glossTex = LSM:Fetch("statusbar", self.private.general.glossTex)

	-- Border Color
	local border = E.db.general.bordercolor
	if self:CheckClassColor(border.r, border.g, border.b) then
		local classColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
		E.db.general.bordercolor.r = classColor.r
		E.db.general.bordercolor.g = classColor.g
		E.db.general.bordercolor.b = classColor.b
	end

	self.media.bordercolor = {border.r, border.g, border.b}

	-- UnitFrame Border Color
	border = E.db.unitframe.colors.borderColor
	if self:CheckClassColor(border.r, border.g, border.b) then
		local classColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
		E.db.unitframe.colors.borderColor.r = classColor.r
		E.db.unitframe.colors.borderColor.g = classColor.g
		E.db.unitframe.colors.borderColor.b = classColor.b
	end
	self.media.unitframeBorderColor = {border.r, border.g, border.b}

	-- Backdrop Color
	self.media.backdropcolor = E:SetColorTable(self.media.backdropcolor, self.db.general.backdropcolor)

	-- Backdrop Fade Color
	self.media.backdropfadecolor = E:SetColorTable(self.media.backdropfadecolor, self.db.general.backdropfadecolor)

	-- Value Color
	local value = self.db.general.valuecolor

	if self:CheckClassColor(value.r, value.g, value.b) then
		value = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
		self.db.general.valuecolor.r = value.r
		self.db.general.valuecolor.g = value.g
		self.db.general.valuecolor.b = value.b
	end

	self.media.hexvaluecolor = self:RGBToHex(value.r, value.g, value.b)
	self.media.rgbvaluecolor = {value.r, value.g, value.b}

	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		LeftChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameLeft)
		local a = E.db.general.backdropfadecolor.a or 0.5
		LeftChatPanel.tex:SetAlpha(a)

		RightChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameRight)
		RightChatPanel.tex:SetAlpha(a)
	end

	self:ValueFuncCall()
	self:UpdateBlizzardFonts()
end

do	--Update font/texture paths when they are registered by the addon providing them
	--This helps fix most of the issues with fonts or textures reverting to default because the addon providing them is loading after ElvUI.
	--We use a wrapper to avoid errors in :UpdateMedia because "self" is passed to the function with a value other than ElvUI.
	local function LSMCallback() E:UpdateMedia() end
	LSM.RegisterCallback(E, "LibSharedMedia_Registered", LSMCallback)
end

function E:ValueFuncCall()
	for func in pairs(self.valueColorUpdateFuncs) do
		func(self.media.hexvaluecolor, unpack(self.media.rgbvaluecolor))
	end
end

function E:UpdateFrameTemplates()
	for frame in pairs(self.frames) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreFrameTemplates then
				frame:SetTemplate(frame.template, frame.glossTex)
			end
		else
			self.frames[frame] = nil
		end
	end

	for frame in pairs(self.unitFrameElements) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreFrameTemplates then
				frame:SetTemplate(frame.template, frame.glossTex)
			end
		else
			self.unitFrameElements[frame] = nil
		end
	end
end

function E:UpdateBorderColors()
	for frame in pairs(self.frames) do
		if frame and not frame.ignoreUpdates then
			if not frame.ignoreBorderColors then
				if frame.template == "Default" or frame.template == "Transparent" or frame.template == nil then
					frame:SetBackdropBorderColor(unpack(self.media.bordercolor))
				end
			end
		else
			self.frames[frame] = nil
		end
	end

	for frame in pairs(self.unitFrameElements) do
		if frame and not frame.ignoreUpdates then
			if not frame.ignoreBorderColors then
				if frame.template == "Default" or frame.template == "Transparent" or frame.template == nil then
					frame:SetBackdropBorderColor(unpack(self.media.unitframeBorderColor))
				end
			end
		else
			self.unitFrameElements[frame] = nil
		end
	end
end

function E:UpdateBackdropColors()
	for frame in pairs(self.frames) do
		if frame then
			if not frame.ignoreBackdropColors then
				if frame.template == "Default" or frame.template == nil then
					frame:SetBackdropColor(unpack(self.media.backdropcolor))
				elseif frame.template == "Transparent" then
					frame:SetBackdropColor(unpack(self.media.backdropfadecolor))
				end
			end
		else
			self.frames[frame] = nil
		end
	end

	for frame in pairs(self.unitFrameElements) do
		if frame then
			if not frame.ignoreBackdropColors then
				if frame.template == "Default" or frame.template == nil then
					frame:SetBackdropColor(unpack(self.media.backdropcolor))
				elseif frame.template == "Transparent" then
					frame:SetBackdropColor(unpack(self.media.backdropfadecolor))
				end
			end
		else
			self.unitFrameElements[frame] = nil
		end
	end
end

function E:UpdateFontTemplates()
	for text in pairs(self.texts) do
		if text then
			text:FontTemplate(text.font, text.fontSize, text.fontStyle)
		else
			self.texts[text] = nil
		end
	end
end

function E:RegisterStatusBar(statusBar)
	tinsert(self.statusBars, statusBar)
end

function E:UpdateStatusBars()
	for _, statusBar in pairs(self.statusBars) do
		if statusBar and statusBar:IsObjectType("StatusBar") then
			statusBar:SetStatusBarTexture(self.media.normTex)
		elseif statusBar and statusBar:IsObjectType("Texture") then
			statusBar:SetTexture(self.media.normTex)
		end
	end
end

function E:IncompatibleAddOn(addon, module)
	E.PopupDialogs.INCOMPATIBLE_ADDON.button1 = addon
	E.PopupDialogs.INCOMPATIBLE_ADDON.button2 = "ElvUI "..module
	E.PopupDialogs.INCOMPATIBLE_ADDON.addon = addon
	E.PopupDialogs.INCOMPATIBLE_ADDON.module = module
	E:StaticPopup_Show("INCOMPATIBLE_ADDON", addon, module)
end

function E:CheckIncompatible()
	if E.global.ignoreIncompatible then return end

	if IsAddOnLoaded("Prat-3.0") and E.private.chat.enable then E:IncompatibleAddOn("Prat-3.0", "Chat") end
	if IsAddOnLoaded("Chatter") and E.private.chat.enable then E:IncompatibleAddOn("Chatter", "Chat") end
	if IsAddOnLoaded("TidyPlates") and E.private.nameplates.enable then E:IncompatibleAddOn("TidyPlates", "NamePlates") end
	if IsAddOnLoaded("Aloft") and E.private.nameplates.enable then E:IncompatibleAddOn("Aloft", "NamePlates") end
	if IsAddOnLoaded("Healers-Have-To-Die") and E.private.nameplates.enable then E:IncompatibleAddOn("Healers-Have-To-Die", "NamePlates") end
end

function E:CopyTable(currentTable, defaultTable)
	if type(currentTable) ~= "table" then currentTable = {} end

	if type(defaultTable) == "table" then
		for option, value in pairs(defaultTable) do
			if type(value) == "table" then
				value = self:CopyTable(currentTable[option], value)
			end

			currentTable[option] = value
		end
	end

	return currentTable
end

function E:RemoveEmptySubTables(tbl)
	if type(tbl) ~= "table" then
		E:Print("Bad argument #1 to 'RemoveEmptySubTables' (table expected)")
		return
	end

	for k, v in pairs(tbl) do
		if type(v) == "table" then
			if next(v) == nil then
				tbl[k] = nil
			else
				self:RemoveEmptySubTables(v)
			end
		end
	end
end

--Compare 2 tables and remove duplicate key/value pairs
--param cleanTable : table you want cleaned
--param checkTable : table you want to check against.
--return : a copy of cleanTable with duplicate key/value pairs removed
function E:RemoveTableDuplicates(cleanTable, checkTable)
	if type(cleanTable) ~= "table" then
		E:Print("Bad argument #1 to 'RemoveTableDuplicates' (table expected)")
		return
	end
	if type(checkTable) ~= "table" then
		E:Print("Bad argument #2 to 'RemoveTableDuplicates' (table expected)")
		return
	end

	local rtdCleaned = {}
	for option, value in pairs(cleanTable) do
		if type(value) == "table" and checkTable[option] and type(checkTable[option]) == "table" then
			rtdCleaned[option] = self:RemoveTableDuplicates(value, checkTable[option])
		else
			-- Add unique data to our clean table
			if cleanTable[option] ~= checkTable[option] then
				rtdCleaned[option] = value
			end
		end
	end

	--Clean out empty sub-tables
	self:RemoveEmptySubTables(rtdCleaned)

	return rtdCleaned
end

--Compare 2 tables and remove blacklisted key/value pairs
--param cleanTable : table you want cleaned
--param blacklistTable : table you want to check against.
--return : a copy of cleanTable with blacklisted key/value pairs removed
function E:FilterTableFromBlacklist(cleanTable, blacklistTable)
	if type(cleanTable) ~= "table" then
		E:Print("Bad argument #1 to 'FilterTableFromBlacklist' (table expected)")
		return
	end
	if type(blacklistTable) ~=  "table" then
		E:Print("Bad argument #2 to 'FilterTableFromBlacklist' (table expected)")
		return
	end

	local tfbCleaned = {}
	for option, value in pairs(cleanTable) do
		if type(value) == "table" and blacklistTable[option] and type(blacklistTable[option]) == "table" then
			tfbCleaned[option] = self:FilterTableFromBlacklist(value, blacklistTable[option])
		else
			-- Filter out blacklisted keys
			if blacklistTable[option] ~= true then
				tfbCleaned[option] = value
			end
		end
	end

	--Clean out empty sub-tables
	self:RemoveEmptySubTables(tfbCleaned)

	return tfbCleaned
end

do	--The code in this function is from WeakAuras, credit goes to Mirrored and the WeakAuras Team
	--Code slightly modified by Simpy
	local function recurse(table, level, ret)
		for i, v in pairs(table) do
			ret = ret..strrep("    ", level).."["
			if type(i) == "string" then ret = ret..'"'..i..'"' else ret = ret..i end
			ret = ret.."] = "

			if type(v) == "number" then
				ret = ret..v..",\n"
			elseif type(v) == "string" then
				ret = ret.."\""..v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\""):gsub("\124", "\124\124").."\",\n"
			elseif type(v) == "boolean" then
				if v then ret = ret.."true,\n" else ret = ret.."false,\n" end
			elseif type(v) == "table" then
				ret = ret.."{\n"
				ret = recurse(v, level + 1, ret)
				ret = ret..strrep("    ", level).."},\n"
			else
				ret = ret.."\""..tostring(v).."\",\n"
			end
		end

		return ret
	end

	function E:TableToLuaString(inTable)
		if type(inTable) ~= "table" then
			E:Print("Invalid argument #1 to E:TableToLuaString (table expected)")
			return
		end

		local ret = "{\n"
		if inTable then ret = recurse(inTable, 1, ret) end
		ret = ret.."}"

		return ret
	end
end

do	--The code in this function is from WeakAuras, credit goes to Mirrored and the WeakAuras Team
	--Code slightly modified by Simpy
	local lineStructureTable, profileFormat = {}, {
		profile = "E.db",
		private = "E.private",
		global = "E.global",
		filters = "E.global",
		styleFilters = "E.global"
	}

	local function buildLineStructure(str) -- str is profileText
		for _, v in ipairs(lineStructureTable) do
			if type(v) == "string" then
				str = str..'["'..v..'"]'
			else
				str = str..'['..v..']'
			end
		end

		return str
	end

	local function recurse(tbl, ret, profileText, sameLine)
		local lineStructure = buildLineStructure(profileText)
		for k, v in pairs(tbl) do
			if not sameLine then
				ret = ret..lineStructure
			end

			ret = ret.."["

			if type(k) == "string" then
				ret = ret..'"'..k..'"'
			else
				ret = ret..k
			end

			if type(v) == "table" then
				tinsert(lineStructureTable, k)
				sameLine = true
				ret = ret.."]"
				ret = recurse(v, ret, profileText, sameLine)
			else
				sameLine = false
				ret = ret.."] = "

				if type(v) == "number" then
					ret = ret..v.."\n"
				elseif type(v) == "string" then
					ret = ret.."\""..v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\""):gsub("\124", "\124\124").."\"\n"
				elseif type(v) == "boolean" then
					if v then
						ret = ret.."true\n"
					else
						ret = ret.."false\n"
					end
				else
					ret = ret.."\""..tostring(v).."\"\n"
				end
			end
		end

		tremove(lineStructureTable)

		return ret
	end

	function E:ProfileTableToPluginFormat(inTable, profileType)
		local profileText = profileFormat[profileType]
		if not profileText then return end

		twipe(lineStructureTable)
		local ret = ""
		if inTable and profileType then
			ret = recurse(inTable, ret, profileText, false)
		end

		return ret
	end
end

do	--Split string by multi-character delimiter (the strsplit / string.split function provided by WoW doesn't allow multi-character delimiter)
	local splitTable = {}
	function E:SplitString(str, delim)
		assert(type (delim) == "string" and strlen(delim) > 0, "bad delimiter")

		local start = 1
		twipe(splitTable)  -- results table

		-- find each instance of a string followed by the delimiter
		while true do
			local pos = find(str, delim, start, true) -- plain find
			if not pos then break end

			tinsert(splitTable, sub(str, start, pos - 1))
			start = pos + strlen(delim)
		end -- while

		-- insert final one (after last delimiter)
		tinsert(splitTable, sub(str, start))

		return unpack(splitTable)
	end
end

do
	local SendMessageWaiting -- only allow 1 delay at a time regardless of eventing
	function E:SendMessage()
		local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers()
		if numRaid > 1 then
			local _, instanceType = IsInInstance()
			if instanceType == "pvp" then
				SendAddonMessage("ELVUI_VERSIONCHK", E.version, "BATTLEGROUND")
			else
				SendAddonMessage("ELVUI_VERSIONCHK", E.version, "RAID")
			end
		elseif numParty > 0 then
			SendAddonMessage("ELVUI_VERSIONCHK", E.version, "PARTY")
		elseif IsInGuild() then
			SendAddonMessage("ELVUI_VERSIONCHK", E.version, "GUILD")
		end

		SendMessageWaiting = nil
	end

	local SendRecieveGroupSize = 0
	local myRealm = gsub(E.myrealm, "[%s%-]", "")
	local myName = E.myname.."-"..myRealm
	local function SendRecieve(_, event, prefix, message, _, sender)
		if event == "CHAT_MSG_ADDON" then
			if sender == myName then return end

			if prefix == "ELVUI_VERSIONCHK" then
				local msg, ver = tonumber(message), tonumber(E.version)
				local inCombat = InCombatLockdown()

				if msg and (msg > ver) then -- you're outdated D:
					if not E.recievedOutOfDateMessage then
						E:Print(L["ElvUI is out of date. You can download the newest version from https://github.com/ElvUI-WotLK"])

						if msg and ((msg - ver) >= 0.01) and not inCombat then
							E:StaticPopup_Show("ELVUI_UPDATE_AVAILABLE")
						end

						E.recievedOutOfDateMessage = true
					end
				end
			end
		elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
			local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers() + 1
			local num = numRaid > 0 and numRaid or numParty
			if num ~= SendRecieveGroupSize then
				if num > 1 and num > SendRecieveGroupSize then
					if not SendMessageWaiting then
						SendMessageWaiting = E:Delay(10, E.SendMessage)
					end
				end
				SendRecieveGroupSize = num
			end
		elseif event == "PLAYER_ENTERING_WORLD" then
			if not SendMessageWaiting then
				SendMessageWaiting = E:Delay(10, E.SendMessage)
			end
		end
	end

	local f = CreateFrame("Frame")
	f:RegisterEvent("CHAT_MSG_ADDON")
	f:RegisterEvent("RAID_ROSTER_UPDATE")
	f:RegisterEvent("PARTY_MEMBERS_CHANGED")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", SendRecieve)
end

function E:UpdateAll(ignoreInstall)
	E.private = E.charSettings.profile
	E.db = E.data.profile
	E.global = E.data.global
	E.db.theme = nil
	E.db.install_complete = nil

	E:DBConversions()

	ActionBars.db = E.db.actionbar
	Auras.db = E.db.auras
	Bags.db = E.db.bags
	Chat.db = E.db.chat
	DataBars.db = E.db.databars
	DataTexts.db = E.db.datatexts
	NamePlates.db = E.db.nameplates
	Threat.db = E.db.general.threat
	Tooltip.db = E.db.tooltip
	Totems.db = E.db.general.totems
	ReminderBuffs.db = E.db.general.reminder
	UnitFrames.db = E.db.unitframe

	--The mover is positioned before it is resized, which causes issues for unitframes
	--Allow movers to be "pushed" outside the screen, when they are resized they should be back in the screen area.
	--We set movers to be clamped again at the bottom of this function.
	E:SetMoversClampedToScreen(false)
	E:SetMoversPositions()

	E:UpdateMedia()
	E:UpdateBorderColors()
	E:UpdateBackdropColors()
	E:UpdateFrameTemplates()
	E:UpdateStatusBars()
	E:UpdateCooldownSettings("all")

	Layout:ToggleChatPanels()
	Layout:BottomPanelVisibility()
	Layout:TopPanelVisibility()
	Layout:SetDataPanelStyle()

	if E.private.actionbar.enable then
		ActionBars:ToggleDesaturation()
		ActionBars:UpdateButtonSettings()
		ActionBars:UpdateMicroPositionDimensions()
	end

	AFK:Toggle()

	if E.private.bags.enable then
		Bags:Layout()
		Bags:Layout(true)
		Bags:SizeAndPositionBagBar()
		Bags:UpdateCountDisplay()
		Bags:UpdateItemLevelDisplay()
	end

	if E.private.chat.enable then
		Chat:PositionChat(true)
		Chat:SetupChat()
		Chat:UpdateAnchors()
	end

	DataBars:EnableDisable_ExperienceBar()
	DataBars:EnableDisable_ReputationBar()
	DataBars:UpdateDataBarDimensions()

	DataTexts:LoadDataTexts()

	if E.private.general.minimap.enable then
		Minimap:UpdateSettings()
	end

	if E.private.nameplates.enable then
		NamePlates:ConfigureAll()
		NamePlates:StyleFilterInitializeAllFilters()
	end

	Threat:ToggleEnable()
	Threat:UpdatePosition()

	Totems:PositionAndSize()
	Totems:ToggleEnable()

	ReminderBuffs:UpdateSettings()

	if E.private.unitframe.enable then
		UnitFrames:Update_AllFrames()
	end

	if ElvUIPlayerBuffs then
		Auras:UpdateHeader(ElvUIPlayerBuffs)
	end

	if ElvUIPlayerDebuffs then
		Auras:UpdateHeader(ElvUIPlayerDebuffs)
	end

	if E.RefreshGUI then
		E:RefreshGUI()
	end

	if (ignoreInstall ~= true) and (E.private.install_complete == nil or (E.private.install_complete and type(E.private.install_complete) == "boolean") or (E.private.install_complete and type(tonumber(E.private.install_complete)) == "number" and tonumber(E.private.install_complete) <= 3.83)) then
		E:Install()
	end

	Blizzard:SetWatchFrameHeight()
	E:SetMoversClampedToScreen(true) -- Go back to using clamp after resizing has taken place.

	collectgarbage("collect")
end

function E:ResetAllUI()
	self:ResetMovers()

	if E.db.lowresolutionset then
		E:SetupResolution(true)
	end

	if E.db.layoutSet then
		E:SetupLayout(E.db.layoutSet, true)
	end
end

function E:ResetUI(...)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

	if ... == "" or ... == " " or ... == nil then
		E:StaticPopup_Show("RESETUI_CHECK")
		return
	end

	self:ResetMovers(...)
end

function E:RegisterModule(name, loadFunc)
	if loadFunc and type(loadFunc) == "function" then --New method using callbacks
		if self.initialized then
			loadFunc()
		else
			if self.ModuleCallbacks[name] then
				--Don't allow a registered module name to be overwritten
				E:Print("Invalid argument #1 to E:RegisterModule (module name:", name, "is already registered, please use a unique name)")
				return
			end

			--Add module name to registry
			self.ModuleCallbacks[name] = true
			self.ModuleCallbacks.CallPriority[#self.ModuleCallbacks.CallPriority + 1] = name

			--Register loadFunc to be called when event is fired
			E:RegisterCallback(name, loadFunc, E:GetModule(name))
		end
	else
		if self.initialized then
			self:GetModule(name):Initialize()
		else
			self.RegisteredModules[#self.RegisteredModules + 1] = name
		end
	end
end

function E:RegisterInitialModule(name, loadFunc)
	if loadFunc and type(loadFunc) == "function" then --New method using callbacks
		if self.InitialModuleCallbacks[name] then
			--Don't allow a registered module name to be overwritten
			E:Print("Invalid argument #1 to E:RegisterInitialModule (module name:", name, "is already registered, please use a unique name)")
			return
		end

		--Add module name to registry
		self.InitialModuleCallbacks[name] = true
		self.InitialModuleCallbacks.CallPriority[#self.InitialModuleCallbacks.CallPriority + 1] = name

		--Register loadFunc to be called when event is fired
		E:RegisterCallback(name, loadFunc, E:GetModule(name))
	else
		self.RegisteredInitialModules[#self.RegisteredInitialModules + 1] = name
	end
end

function E:InitializeInitialModules()
	--Fire callbacks for any module using the new system
	for index, moduleName in ipairs(self.InitialModuleCallbacks.CallPriority) do
		self.InitialModuleCallbacks[moduleName] = nil
		self.InitialModuleCallbacks.CallPriority[index] = nil
		E.callbacks:Fire(moduleName)
	end

	--Old deprecated initialize method, we keep it for any plugins that may need it
	for _, module in pairs(E.RegisteredInitialModules) do
		module = self:GetModule(module, true)
		if module and module.Initialize then
			local _, catch = pcall(module.Initialize, module)
			if catch and GetCVarBool("scriptErrors") == true then
				_G.ScriptErrorsFrame:OnError(catch, false, false)
			end
		end
	end
end

function E:InitializeModules()
	--Fire callbacks for any module using the new system
	for index, moduleName in ipairs(self.ModuleCallbacks.CallPriority) do
		self.ModuleCallbacks[moduleName] = nil
		self.ModuleCallbacks.CallPriority[index] = nil
		E.callbacks:Fire(moduleName)
	end

	--Old deprecated initialize method, we keep it for any plugins that may need it
	for _, module in pairs(E.RegisteredModules) do
		module = self:GetModule(module)
		if module.Initialize then
			local _, catch = pcall(module.Initialize, module)

			if catch and GetCVarBool("scriptErrors") == true then
				_G.ScriptErrorsFrame:OnError(catch, false, false)
			end
		end
	end
end

--DATABASE CONVERSIONS
function E:DBConversions()
	--Fix issue where UIScale was incorrectly stored as string
	E.global.general.UIScale = tonumber(E.global.general.UIScale)

	--Not sure how this one happens, but prevent it in any case
	if E.global.general.UIScale <= 0 then
		E.global.general.UIScale = G.general.UIScale
	end

	if gameLocale and E.global.general.locale == "auto" then
		E.global.general.locale = gameLocale
	end

	--Combat & Resting Icon options update
	if E.db.unitframe.units.player.combatIcon ~= nil then
		E.db.unitframe.units.player.CombatIcon.enable = E.db.unitframe.units.player.combatIcon
		E.db.unitframe.units.player.combatIcon = nil
	end
	if E.db.unitframe.units.player.restIcon ~= nil then
		E.db.unitframe.units.player.RestIcon.enable = E.db.unitframe.units.player.restIcon
		E.db.unitframe.units.player.restIcon = nil
	end

	-- [Fader] Combat Fade options for Player
	if E.db.unitframe.units.player.combatfade ~= nil then
		local enabled = E.db.unitframe.units.player.combatfade
		E.db.unitframe.units.player.fader.enable = enabled

		if enabled then -- use the old min alpha too
			E.db.unitframe.units.player.fader.minAlpha = 0
		end

		E.db.unitframe.units.player.combatfade = nil
	end

	-- [Fader] Range check options for Units
	do
		local outsideAlpha
		if E.db.unitframe.OORAlpha ~= nil then
			outsideAlpha = E.db.unitframe.OORAlpha
			E.db.unitframe.OORAlpha = nil
		end

		local rangeCheckUnits = {"target", "targettarget", "targettargettarget", "focus", "focustarget", "pet", "pettarget", "boss", "arena", "party", "raid", "raid40", "raidpet", "tank", "assist"}
		for _, unit in pairs(rangeCheckUnits) do
			if E.db.unitframe.units[unit].rangeCheck ~= nil then
				local enabled = E.db.unitframe.units[unit].rangeCheck
				E.db.unitframe.units[unit].fader.enable = enabled
				E.db.unitframe.units[unit].fader.range = enabled

				if outsideAlpha then
					E.db.unitframe.units[unit].fader.minAlpha = outsideAlpha
				end

				E.db.unitframe.units[unit].rangeCheck = nil
			end
		end
	end

	--Convert old "Buffs and Debuffs" font size option to individual options
	if E.db.auras.fontSize then
		local fontSize = E.db.auras.fontSize
		E.db.auras.buffs.countFontSize = fontSize
		E.db.auras.buffs.durationFontSize = fontSize
		E.db.auras.debuffs.countFontSize = fontSize
		E.db.auras.debuffs.durationFontSize = fontSize
		E.db.auras.fontSize = nil
	end

	--Convert old private cooldown setting to profile setting
	if E.private.cooldown and (E.private.cooldown.enable ~= nil) then
		E.db.cooldown.enable = E.private.cooldown.enable
		E.private.cooldown.enable = nil
		E.private.cooldown = nil
	end

	if not E.db.chat.panelColorConverted then
		local color = E.db.general.backdropfadecolor
		E.db.chat.panelColor = {r = color.r, g = color.g, b = color.b, a = color.a}
		E.db.chat.panelColorConverted = true
	end

	--Convert cropIcon to tristate
	local cropIcon = E.db.general.cropIcon
	if type(cropIcon) == "boolean" then
		E.db.general.cropIcon = (cropIcon and 2) or 0
	end

	--Vendor Greys option is now in bags table
	if E.db.general.vendorGrays then
		E.db.bags.vendorGrays.enable = E.db.general.vendorGrays
		E.db.general.vendorGrays = nil
		E.db.general.vendorGraysDetails = nil
	end

	--Heal Prediction is now a table instead of a bool
	local healPredictionUnits = {"player", "target", "focus", "pet", "arena", "party", "raid", "raid40", "raidpet"}
	for _, unit in pairs(healPredictionUnits) do
		if type(E.db.unitframe.units[unit].healPrediction) ~= "table" then
			local enabled = E.db.unitframe.units[unit].healPrediction
			E.db.unitframe.units[unit].healPrediction = {}
			E.db.unitframe.units[unit].healPrediction.enable = enabled
		end
	end

	--Health Backdrop Multiplier
	if E.db.unitframe.colors.healthmultiplier ~= nil then
		if E.db.unitframe.colors.healthmultiplier > 0.75 then
			E.db.unitframe.colors.healthMultiplier = 0.75
		else
			E.db.unitframe.colors.healthMultiplier = E.db.unitframe.colors.healthmultiplier
		end

		E.db.unitframe.colors.healthmultiplier = nil
	end
end

function E:RefreshModulesDB()
	-- this function is specifically used to reference the new database
	-- onto the unitframe module, its useful dont delete! D:
	twipe(UnitFrames.db) --old ref, dont need so clear it
	UnitFrames.db = self.db.unitframe --new ref
end

function E:Initialize()
	twipe(self.db)
	twipe(self.global)
	twipe(self.private)

	self.myguid = UnitGUID("player")
	self.data = E.Libs.AceDB:New("ElvDB", self.DF)
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	self.charSettings = E.Libs.AceDB:New("ElvPrivateDB", self.privateVars)
	E.Libs.DualSpec:EnhanceDatabase(self.data, "ElvUI")
	self.private = self.charSettings.profile
	self.db = self.data.profile
	self.global = self.data.global

	self:CheckIncompatible()
	self:DBConversions()
	self:UIScale()
	self:BuildPrefixValues()
	self:LoadAPI()
	self:LoadCommands()
	self:InitializeModules()
	self:RefreshModulesDB()
	self:LoadMovers()
	self:UpdateMedia()
	self:UpdateCooldownSettings("all")
	self:Tutorials()
	self.initialized = true

	Minimap:UpdateSettings()

	if E.db.general.smoothingAmount and (E.db.general.smoothingAmount ~= 0.33) then
		E:SetSmoothingAmount(E.db.general.smoothingAmount)
	end

	if self.private.install_complete == nil then
		self:Install()
	end

	if self:HelloKittyFixCheck() then
		self:HelloKittyFix()
	end

	if self.db.general.kittys then
		self:CreateKittys()
		self:Delay(5, self.Print, self, L["Type /hellokitty to revert to old settings."])
	end

	collectgarbage("collect")

	if self.db.general.loginmessage then
		local msg = format(L["LOGIN_MSG"], self.media.hexvaluecolor, self.media.hexvaluecolor, self.version)
		if Chat.Initialized then msg = select(2, Chat:FindURL("CHAT_MSG_DUMMY", msg)) end
		E:Print(msg)
	end
end