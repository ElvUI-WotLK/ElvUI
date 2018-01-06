local MAJOR, MINOR = "LibElvUIPlugin-1.0", 18
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

--Cache global variables
--Lua functions
local pairs, tonumber = pairs, tonumber
local format, gsub, strmatch, strsplit = format, gsub, strmatch, strsplit
--WoW API / Variables
local CreateFrame = CreateFrame
local GetAddOnMetadata = GetAddOnMetadata
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local IsAddOnLoaded = IsAddOnLoaded
local IsInInstance = IsInInstance
local SendAddonMessage = SendAddonMessage

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: ElvUI

lib.plugins = {}
lib.index = 0
lib.prefix = "ElvUIPluginVC"

-- MULTI Language Support (Default Language: English)
local MSG_OUTDATED = "Your version of %s %s is out of date (latest is version %s). You can download the latest version from https://github.com/ElvUI-WotLK/ElvUI/"
local HDR_CONFIG = "Plugins"
local HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins Loaded  (Green means you have current version, Red means out of date)"
local INFO_BY = "by"
local INFO_VERSION = "Version:"
local INFO_NEW = "Newest:"
local LIBRARY = "Library"

if GetLocale() == "deDE" then -- German Translation
	MSG_OUTDATED = "Deine Version von %s %s ist veraltet (akutelle Version ist %s). Du kannst die aktuelle Version von https://github.com/ElvUI-WotLK/ElvUI/ herunterrladen."
	HDR_CONFIG = "Plugins"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins geladen (Grün bedeutet du hast die aktuelle Version, Rot bedeutet es ist veraltet)"
	INFO_BY = "von"
	INFO_VERSION = "Version:"
	INFO_NEW = "Neuste:"
	LIBRARY = "Bibliothek"
end

if GetLocale() == "ruRU" then -- Russian Translations
	MSG_OUTDATED = "Ваша версия %s %s устарела (последняя версия %s). Вы можете скачать последнюю версию на https://github.com/ElvUI-WotLK/ElvUI/"
	HDR_CONFIG = "Плагины"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - загруженные плагины (зеленый означает, что у вас последняя версия, красный - устаревшая)"
	INFO_BY = "от"
	INFO_VERSION = "Версия:"
	INFO_NEW = "Последняя:"
	LIBRARY = "Библиотека"
end

--
-- Plugin table format:
--	{ name (string) - The name of the plugin,
--		version (string) - The version of the plugin,
--		optionCallback (string) - The callback to call when ElvUI_Config is loaded
--	}
--

--
-- RegisterPlugin(name,callback)
--	Registers a module with the given name and option callback, pulls version info from metadata
--

function lib:RegisterPlugin(name,callback, isLib)
	local plugin = {}
	plugin.name = name
	plugin.version = name == MAJOR and MINOR or GetAddOnMetadata(name, "Version")
	if isLib then plugin.isLib = true; plugin.version = 1 end
	plugin.callback = callback
	lib.plugins[name] = plugin
	local loaded = IsAddOnLoaded("ElvUI_Config")

	if not lib.vcframe then
		local f = CreateFrame("Frame")
		f:RegisterEvent("RAID_ROSTER_UPDATE")
		f:RegisterEvent("PARTY_MEMBERS_CHANGED")
		f:RegisterEvent("CHAT_MSG_ADDON")
		f:SetScript("OnEvent", lib.VersionCheck)
		lib.vcframe = f
	end

	if not loaded then
		if not lib.ConfigFrame then
			local configFrame = CreateFrame("Frame")
			configFrame:RegisterEvent("ADDON_LOADED")
			configFrame:SetScript("OnEvent", function(self, event, addon)
				if addon == "ElvUI_Config" then
					for _, PlugIn in pairs(lib.plugins) do
						if PlugIn.callback then
							PlugIn.callback()
						end
					end
				end
			end)
			lib.ConfigFrame = configFrame
		end
	elseif loaded then
		-- Need to update plugins list
		if name ~= MAJOR then
			ElvUI[1].Options.args.plugins.args.plugins.name = lib:GeneratePluginList()
		end
		callback()
	end

	return plugin
end

function lib:GetPluginOptions()
	ElvUI[1].Options.args.plugins = {
		order = -10,
		type = "group",
		name = HDR_CONFIG,
		guiInline = false,
		args = {
			pluginheader = {
				order = 1,
				type = "header",
				name = format(HDR_INFORMATION, MINOR),
			},
			plugins = {
				order = 2,
				type = "description",
				name = lib:GeneratePluginList(),
			},
		}
	}
end

function lib:GenerateVersionCheckMessage()
	local list = ""
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			list = list..plugin.name.."="..plugin.version..";"
		end
	end
	return list
end

local function SendPluginVersionCheck(self)
	lib:SendPluginVersionCheck(lib:GenerateVersionCheckMessage())

	if self["ElvUIPluginSendMSGTimer"] then
		self:CancelTimer(self["ElvUIPluginSendMSGTimer"])
		self["ElvUIPluginSendMSGTimer"] = nil
	end
end

function lib:VersionCheck(event, prefix, message, channel, sender)
	if not ElvUI[1].global.general.versionCheck then return end

	local E = ElvUI[1]
	if event == "CHAT_MSG_ADDON" then
		if not (prefix == lib.prefix and sender and message and not strmatch(message, "^%s-$")) then return end
		if sender == E.myname then return end

		if not E["pluginRecievedOutOfDateMessage"] then
			local name, version, plugin, Pname
			for _, p in pairs({strsplit(";",message)}) do
				if not strmatch(p, "^%s-$") then
					name, version = strmatch(p, "([%w_]+)=([%d%p]+)")
					if lib.plugins[name] then
						plugin = lib.plugins[name]
						if plugin.version ~= "BETA" and version and tonumber(version) and plugin.version and tonumber(plugin.version) and tonumber(version) > tonumber(plugin.version) then
							plugin.old = true
							plugin.newversion = tonumber(version)
							Pname = GetAddOnMetadata(plugin.name, "Title")
							E:Print(format(MSG_OUTDATED, Pname, plugin.version, plugin.newversion))
							E["pluginRecievedOutOfDateMessage"] = true
						end
					end
				end
			end
		end
	else
		if not E.SendPluginVersionCheck then
			E.SendPluginVersionCheck = SendPluginVersionCheck
		end

		local numRaid, numParty = GetNumRaidMembers(), GetNumPartyMembers() + 1
		local num = numRaid > 0 and numRaid or numParty
		if num ~= lib.groupSize then
			if num > 1 and ((lib.groupSize and num > lib.groupSize) or not lib.groupSize) then
				E["ElvUIPluginSendMSGTimer"] = E:ScheduleTimer("SendPluginVersionCheck", 12)
			end
			lib.groupSize = num
		end
	end
end

function lib:GeneratePluginList()
	local list, E = "", ElvUI[1]
	local author, Pname, color
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			author = GetAddOnMetadata(plugin.name, "Author")
			Pname = GetAddOnMetadata(plugin.name, "Title") or plugin.name
			color = plugin.old and E:RGBToHex(1,0,0) or E:RGBToHex(0,1,0)
			list = list .. Pname
			if author then
				list = list .. " ".. INFO_BY .." " .. author
			end
			list = list .. color .. (plugin.isLib and " " .. LIBRARY or " - " .. INFO_VERSION .. " " .. plugin.version)
			if plugin.old then
				list = list .. " (" .. INFO_NEW .." " .. plugin.newversion .. ")"
			end
			list = list .. "|r\n"
		end
	end
	return list
end

function lib:SendPluginVersionCheck(message)
	if (not message) or strmatch(message, "^%s-$") then return end

	local ChatType
	if GetNumRaidMembers() > 1 then
		local _, instanceType = IsInInstance()
		ChatType = instanceType == "pvp" and "BATTLEGROUND" or "RAID"
	elseif GetNumPartyMembers() > 0 then
		ChatType = "PARTY"
	end
	if not ChatType then return end

	local maxChar, msgLength = 254 - strlen(lib.prefix), strlen(message)
	if msgLength > maxChar then
		local delay, splitMessage = 0

		for _ = 1, ceil(msgLength/maxChar) do
			splitMessage = strmatch(strsub(message, 1, maxChar), ".+;")

			if splitMessage then -- incase the string is over `maxChar` but doesnt contain `;`
				message = gsub(message, "^"..gsub(splitMessage, '([%-%.%+%[%]%(%)%$%^%%%?%*])','%%%1'), "")
				ElvUI[1]:Delay(delay, SendAddonMessage, lib.prefix, splitMessage, ChatType)
				delay = delay + 1
			end
		end
	else
		SendAddonMessage(lib.prefix, message, ChatType)
	end
end

lib:RegisterPlugin(MAJOR, lib.GetPluginOptions)